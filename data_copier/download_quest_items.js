import { writeFile } from '@sanjo/write-file'
import { request } from '@sanjo/request'
import { readdir } from 'node:fs/promises'

async function downloadAllQuestItems(baseURL, from = 1) {
  const totalNumberOfQuestItems = await determineTotalNumberOfQuestItems(baseURL)

  const numberOfAlreadyDownloadedQuestItems = await determineNumberOfAlreadyDownloadedQuestItems()

  let totalNumberOfDownloadedQuestItems = numberOfAlreadyDownloadedQuestItems

  const maxResultSize = 1000
  while (totalNumberOfDownloadedQuestItems < totalNumberOfQuestItems) {
    const to = from + maxResultSize - 1
    const numberOfQuestItemsThatHaveBeenDownloaded = await downloadQuestItems(baseURL, from, to)
    totalNumberOfDownloadedQuestItems += numberOfQuestItemsThatHaveBeenDownloaded

    console.log(Math.floor(totalNumberOfDownloadedQuestItems / totalNumberOfQuestItems * 100) + '%')

    from = to + 1
  }
}

async function determineNumberOfAlreadyDownloadedQuestItems() {
  let numberOfAlreadyDownloadedQuestItems = 0
  const files = await readdir('quest_items')
  const fileNameRegExp = /(\d+)\.html/
  for (const file of files) {
    const match = fileNameRegExp.exec(file)
    if (match) {
      numberOfAlreadyDownloadedQuestItems++
    }
  }
  return numberOfAlreadyDownloadedQuestItems
}

function parseNumber(numberText) {
  return parseInt(numberText.replaceAll(',', ''), 10)
}

const numberOfQuestItemsFoundRegExp = /([\d,]+) items found/

async function determineTotalNumberOfQuestItems(baseURL) {
  const response = await request(baseURL)
  const content = response.body

  const match = numberOfQuestItemsFoundRegExp.exec(content)
  const numberOfQuests = parseNumber(match[1])

  return numberOfQuests
}

const questItemsRegExp = /var listviewitems.+/

async function downloadQuestItems(baseURL, from, to) {
  let numberOfQuestItemsThatHaveBeenDownloaded = 0

  const response = await request(baseURL + '?filter=151:151;2:4;' + from + ':' + to)
  const content = response.body

  const match2 = questItemsRegExp.exec(content)
  if (match2) {
    const content2 = match2[0]
    const idRegExp = /"id":(\d+)/g
    let match
    const IDs = []
    while (match = idRegExp.exec(content2)) {
      const ID = Number(match[1])
      IDs.push(ID)
    }

    await Promise.all(IDs.map(async ID => {
      const hasBeenDownloaded = await downloadQuestItem(ID)
      if (hasBeenDownloaded) {
        numberOfQuestItemsThatHaveBeenDownloaded++
      }
    }))
  }

  return numberOfQuestItemsThatHaveBeenDownloaded
}

async function downloadQuestItem(id) {
  let hasBeenDownloaded
  const redirectResponse = await request('https://www.wowhead.com/item=' + id)
  const location = redirectResponse.headers.location
  if (location) {
    const redirectURL = location.startsWith('/') ? 'https://www.wowhead.com' + location : location
    const response = await request(redirectURL)
    const content = response.body

    await writeFile('quest_items/' + id + '.html', content)
    hasBeenDownloaded = true
  } else {
    hasBeenDownloaded = false
  }
  return hasBeenDownloaded
}

const baseURL = 'https://www.wowhead.com/items/quest'
await downloadAllQuestItems(baseURL, 1)
