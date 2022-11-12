import { request } from '@sanjo/request'
import { writeFile } from '@sanjo/write-file'
import { readdir } from 'node:fs/promises'
import { extractNPCIds } from './lib.js'

async function downloadAllNPCs(baseURL, from = 1) {
  const totalNumberOfNPCs = await determineTotalNumberOfNPCs(baseURL)

  const numberOfAlreadyDownloadedNPCs = await determineNumberOfAlreadyDownloadedNPCs()

  let totalNumberOfDownloadedNPCs = numberOfAlreadyDownloadedNPCs

  const maxResultSize = 1000
  while (totalNumberOfDownloadedNPCs < totalNumberOfNPCs) {
    const to = from + maxResultSize - 1
    const numberOfNPCsThatHaveBeenDownloaded = await downloadNPCs(baseURL, from, to)
    totalNumberOfDownloadedNPCs += numberOfNPCsThatHaveBeenDownloaded

    console.log(Math.floor(totalNumberOfDownloadedNPCs / totalNumberOfNPCs * 100) + '%')

    from = to + 1
  }
}

async function determineNumberOfAlreadyDownloadedNPCs() {
  let numberOfAlreadyDownloadedNPCs = 0
  const files = await readdir('npcs')
  const fileNameRegExp = /(\d+)\.html/
  for (const file of files) {
    const match = fileNameRegExp.exec(file)
    if (match) {
      numberOfAlreadyDownloadedNPCs++
    }
  }
  return numberOfAlreadyDownloadedNPCs
}

function parseNumber(numberText) {
  return parseInt(numberText.replaceAll(',', ''), 10)
}

const numberOfNPCsFoundRegExp = /([\d,]+) NPCs found/

async function determineTotalNumberOfNPCs(baseURL) {
  const response = await request(baseURL)
  const content = response.body

  const match = numberOfNPCsFoundRegExp.exec(content)
  const numberOfNPCs = parseNumber(match[1])

  return numberOfNPCs
}

async function downloadNPCs(baseURL, from, to) {
  let numberOfNPCsThatHaveBeenDownloaded = 0

  const response = await request(baseURL + '?filter=37:37;2:4;' + from + ':' + to)
  const content = response.body

  const IDs = extractNPCIds(content)

  await Promise.all(IDs.map(async ID => {
    const hasBeenDownloaded = await downloadNPC(ID)
    if (hasBeenDownloaded) {
      numberOfNPCsThatHaveBeenDownloaded++
    }
  }))

  return numberOfNPCsThatHaveBeenDownloaded
}

let startTime

async function downloadNPC(id) {
  let hasBeenDownloaded
  const redirectResponse = await request('https://www.wowhead.com/npc=' + id)
  const location = redirectResponse.headers.location
  if (location) {
    const response = await request('https://www.wowhead.com' + location)
    const content = response.body

    await writeFile('npcs/' + id + '.html', content)
    hasBeenDownloaded = true
  } else {
    hasBeenDownloaded = false
  }
  return hasBeenDownloaded
}

const baseURL = 'https://www.wowhead.com/npcs'
startTime = Date.now()
await downloadAllNPCs(baseURL, 199026)
