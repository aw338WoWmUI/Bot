import { writeFile } from '@sanjo/write-file'
import { request } from '@sanjo/request'
import { readdir } from 'node:fs/promises'

async function downloadAllQuests(baseURL, from = 1) {
  const totalNumberOfQuests = await determineTotalNumberOfQuests(baseURL)

  const numberOfAlreadyDownloadedQuests = await determineNumberOfAlreadyDownloadedQuests()

  let totalNumberOfDownloadedQuests = numberOfAlreadyDownloadedQuests

  const maxResultSize = 1000
  while (totalNumberOfDownloadedQuests < totalNumberOfQuests) {
    const to = from + maxResultSize - 1
    const numberOfQuestsThatHaveBeenDownloaded = await downloadQuests(baseURL, from, to)
    totalNumberOfDownloadedQuests += numberOfQuestsThatHaveBeenDownloaded

    console.log(Math.floor(totalNumberOfDownloadedQuests / totalNumberOfQuests * 100) + '%')

    from = to + 1
  }
}

async function determineNumberOfAlreadyDownloadedQuests() {
  let numberOfAlreadyDownloadedQuests = 0
  const files = await readdir('quests')
  const fileNameRegExp = /(\d+)\.html/
  for (const file of files) {
    const match = fileNameRegExp.exec(file)
    if (match) {
      numberOfAlreadyDownloadedQuests++
    }
  }
  return numberOfAlreadyDownloadedQuests
}

function parseNumber(numberText) {
  return parseInt(numberText.replaceAll(',', ''), 10)
}

const numberOfQuestsFoundRegExp = /([\d,]+) quests found/

async function determineTotalNumberOfQuests(baseURL) {
  const response = await request(baseURL)
  const content = response.body

  const match = numberOfQuestsFoundRegExp.exec(content)
  const numberOfQuests = parseNumber(match[1])

  return numberOfQuests
}

const questsRegExp = /new Listview.+/

async function downloadQuests(baseURL, from, to) {
  let numberOfQuestsThatHaveBeenDownloaded = 0

  const response = await request(baseURL + '?filter=30:30;2:4;' + from + ':' + to)
  const content = response.body

  const match2 = questsRegExp.exec(content)
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
      const hasBeenDownloaded = await downloadQuest(ID)
      if (hasBeenDownloaded) {
        numberOfQuestsThatHaveBeenDownloaded++
      }
    }))
  }

  return numberOfQuestsThatHaveBeenDownloaded
}

async function downloadQuest(id) {
  let hasBeenDownloaded
  const redirectResponse = await request('https://www.wowhead.com/quest=' + id)
  const location = redirectResponse.headers.location
  if (location) {
    const response = await request('https://www.wowhead.com' + location)
    const content = response.body

    await writeFile('quests/' + id + '.html', content)
    hasBeenDownloaded = true
  } else {
    hasBeenDownloaded = false
  }
  return hasBeenDownloaded
}

const baseURL = 'https://www.wowhead.com/quests'
await downloadAllQuests(baseURL, 1)
