// TODO: SavedVariables
// * PLAYER_LOGOUT (see https://wowwiki-archive.fandom.com/wiki/Events/System)
// * PLAYER_LOGIN (see https://wowwiki-archive.fandom.com/wiki/Events/System)

import { readFile } from '@sanjo/read-file'
import { open, rm } from 'node:fs/promises'
import * as path from 'path'

// const entryPointAddOn = 'Bot'
const entryPointAddOn = 'MeshNet'

const loadOrder = []
const alreadyLoadedAddOns = new Set()
const resolvedAddOns = new Set()

async function readTOCFile(addOn) {
  const tocFilePath = `${ determineAddOnPath(addOn) }${ addOn }.toc`
  const content = await readFile(tocFilePath)
  return content
}

async function resolveDependencies(addOn) {
  resolvedAddOns.add(addOn)
  const content = await readTOCFile(addOn)
  const dependenciesRegExp = /## Dependencies: (.+)/
  const match = dependenciesRegExp.exec(content)
  if (match) {
    const addOnDependencies = match[1].split(', ')
    for (const addOn of addOnDependencies) {
      if (!resolvedAddOns.has(addOn)) {
        await resolveDependencies(addOn)
      }
    }
    const addOnsStillToLoad = addOnDependencies.filter(addOn => !alreadyLoadedAddOns.has(addOn))
    addOnsStillToLoad.forEach(addAddOnToLoadOrder)
  }
  if (!alreadyLoadedAddOns.has(addOn)) {
    addAddOnToLoadOrder(addOn)
  }
}

function addAddOnToLoadOrder(addOn) {
  loadOrder.push(addOn)
  alreadyLoadedAddOns.add(addOn)
}

await resolveDependencies(entryPointAddOn)

async function generateFile() {
  const outputPath = 'output2.lua'
  await rm(outputPath, {
    force: true
  })
  const file = await open(outputPath, 'a')
  for (const addOn of loadOrder) {
    await file.appendFile('\n(function (...)\n')
    const addOnPath = determineAddOnPath(addOn)
    const tocFileContent = await readTOCFile(addOn)
    const listedFiles = extractListedFiles(tocFileContent)
    for (const listedFile of listedFiles) {
      const filePath = path.join(addOnPath, listedFile)
      const content = await readFile(filePath)
      const before = '\ndo\n-- ' + filePath + ':\n'
      await file.appendFile(before)
      await file.appendFile(content)
      const after = '\nend\n'
      await file.appendFile(after)
    }
    await file.appendFile('\nend)(' + "'" + addOn + "'" + ', {});\n')
  }
  await file.close()
}

function determineAddOnPath(addOn) {
  return `AddOns/${ addOn }/`
}

function extractListedFiles(tocFileContent) {
  const lines = tocFileContent.split(/(?:\n|\r\n|\r)/)
  const loadFileLines = lines.filter(isLoadFileLine)
  const loadedFiles = loadFileLines.map(line => line.trim())
  return loadedFiles
}

function isLoadFileLine(line) {
  const trimmedLine = line.trim()
  return trimmedLine.length >= 1 && !isCommentLine(trimmedLine)
}

const COMMENT_LINE_REGEXP = /^##/

function isCommentLine(line) {
  return COMMENT_LINE_REGEXP.test(line)
}

await generateFile()
