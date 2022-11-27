import { readFile } from '@sanjo/read-file'
import { open, rm } from 'node:fs/promises'
import * as path from 'path'

const entryPoints = [
  'Bot',
  'MeshNet'
]

const dependencies = new Map()
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
  const addOnDependencies = match ? match[1].split(', ') : []
  dependencies.set(addOn, addOnDependencies)
  for (const addOn of addOnDependencies) {
    if (!resolvedAddOns.has(addOn)) {
      await resolveDependencies(addOn)
    }
  }
  const addOnsStillToLoad = addOnDependencies.filter(addOn => !alreadyLoadedAddOns.has(addOn))
  addOnsStillToLoad.forEach(addAddOnToLoadOrder)
  if (!alreadyLoadedAddOns.has(addOn)) {
    addAddOnToLoadOrder(addOn)
  }
}

function addAddOnToLoadOrder(addOn) {
  loadOrder.push(addOn)
  alreadyLoadedAddOns.add(addOn)
}

for (const entryPointAddOnName of entryPoints) {
  await resolveDependencies(entryPointAddOnName)
}

async function generateFile() {
  const outputPath = 'output.lua'
  await rm(outputPath, {
    force: true,
  })
  const file = await open(outputPath, 'a')
  await file.appendFile('local modules = {};\n\n')
  for (const addOnName of loadOrder) {
    const addOnPath = determineAddOnPath(addOnName)
    const modulesVariable = `modules['${ addOnName }']`
    await file.appendFile('-- ' + addOnPath + ':\n')
    await file.appendFile(modulesVariable + ' = {};\n')
    await file.appendFile('(function (...)\n')
    const tocFileContent = await readTOCFile(addOnName)
    const listedFiles = extractListedFiles(tocFileContent)
    for (const listedFile of listedFiles) {
      const filePath = path.join(addOnPath, listedFile)
      const content = await readFile(filePath)
      const before = 'do\n-- ' + filePath + ':\n'
      await file.appendFile(before)
      await file.appendFile(content)
      const after = '\nend\n'
      await file.appendFile(after)
    }
    const dependenciesList = dependencies.get(addOnName).map(addOnName => `['${addOnName}'] = modules['${addOnName}']`).join(', ')
    const imports = dependenciesList.length >= 1 ? `{ ${dependenciesList} }` : '{}'
    await file.appendFile('end)(\'' + addOnName + '\', {}, ' + modulesVariable + `, ${imports});\n\n`)
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
