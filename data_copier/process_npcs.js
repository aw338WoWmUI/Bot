import { writeFile } from '@sanjo/write-file'
import { readFile } from '@sanjo/read-file'
import { readdir } from 'node:fs/promises'

function concurrent(things, numberOfSimultaneousRuns, run) {
  return new Promise(resolve => {
    let nextIndex = 0
    let numberOfRunning = 0
    let hasResolved = false

    function runNext() {
      if (nextIndex < things.length) {
        const thing = things[nextIndex]
        nextIndex++
        run(thing).finally(runNext)
      } else if (!hasResolved) {
        hasResolved = true
        resolve()
      }
    }

    while (numberOfRunning < numberOfSimultaneousRuns) {
      runNext()
      numberOfRunning++
    }
  })
}

async function processNPC(id) {
  const content = await readFile('npcs/' + id + '.html')

  const NPC = {
    id,
  }

  const canRepair = Boolean(/Can repair/.exec(content))
  if (canRepair) {
    NPC.canRepair = true
  }

  const coordinates = []

  const match = /g_mapperData = (.+);/.exec(content)
  if (match) {
    const data = JSON.parse(match[1])
    for (const [zoneID, values] of Object.entries(data)) {
      if (Array.isArray(values)) {
        for (const value of values) {
          for (const coordinates2 of value.coords) {
            coordinates.push([
              value.uiMapId,
              coordinates2[0] / 100,
              coordinates2[1] / 100,
            ])
          }
        }
      } else if (typeof values === 'object') {
        let uiMapID
        for (const [level, value] of Object.entries(values)) {
          for (const coordinates2 of value.coords) {
            coordinates.push([
              value.uiMapId || uiMapID || null,
              coordinates2[0] / 100,
              coordinates2[1] / 100,
              level,
            ])
            if (value.uiMapId) {
              uiMapID = value.uiMapId
            }
          }
        }
      }
    }
  }

  NPC.coordinates = coordinates

  const h1Text = /<h1 class="heading-size-1(?: h1-icon)?">(.*?)<\/h1>/.exec(content)[1]
  const innkeeperRegExp = /&lt;Innkeeper&gt;$/
  if (innkeeperRegExp.test(h1Text)) {
    NPC.isInnkeeper = true
  }

  const gryphonMasterRegExp = /&lt;Gryphon&nbsp;Master&gt;$/
  if (gryphonMasterRegExp.test(h1Text)) {
    NPC.isGryphonMaster = true
  }

  const isVendor = Boolean(/WH\.TERMS\.sells/.exec(content))
  if (isVendor) {
    NPC.isVendor = isVendor
  }

  return NPC
}

function generateLuaListTable(list, indention) {
  let result = '{\n'
  for (const element of list) {
    result += indent(convertToLua(element, indention) + ',', 1) + '\n'
  }
  result += '}'
  return result
}

function generateLuaTable(object, indention) {
  let result = '{\n'
  for (const [key, value] of Object.entries(object)) {
    result += indent(`['${ key }'] = ${ convertToLua(value, indention) },`, 1) + '\n'
  }
  result += '}'
  return result
}

function convertToLua(value, indention = 0) {
  const type = typeof value
  let result
  if (type === 'string') {
    result = `'${ value }'`
  } else if (type === 'number') {
    result = String(value)
  } else if (Array.isArray(value)) {
    result = generateLuaListTable(value, indention + 1)
  } else if (type === 'undefined' || value === null) {
    result = 'nil'
  } else if (type === 'object') {
    result = generateLuaTable(value, indention + 1)
  } else if (type === 'boolean') {
    result = String(value)
  } else {
    throw new Error(`Unhandled case for type "${ type }".`)
  }
  return result
}

function indent(value, indention) {
  const lines = value.split('\n')
  const indentedLines = lines.map(line => '  '.repeat(indention) + line)
  return indentedLines.join('\n')
}

const files = await readdir('npcs')
const IDs = []
const fileNameRegExp = /(\d+)\.html/
for (const file of files) {
  const match = fileNameRegExp.exec(file)
  if (match) {
    const id = parseInt(match[1], 10)
    IDs.push(id)
  }
}

const NPCs = []
await concurrent(IDs, 1000, async function (ID) {
  const NPC = await processNPC(ID)
  if (NPC) {
    NPCs.push(NPC)
  }
})

const content = 'NPCs = ' + convertToLua(NPCs)
await writeFile('NPCs.lua', content)
