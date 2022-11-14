import { readFile } from '@sanjo/read-file'
import { writeFile } from '@sanjo/write-file'
import { readdir } from 'node:fs/promises'
import { concurrent, convertToLua, sortIDs } from './lib.js'

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

  const isVendor = Boolean(/WH\.TERMS\.sells/.exec(content))
  if (isVendor) {
    NPC.isVendor = isVendor
  }

  return NPC
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
sortIDs(IDs)

const NPCs = []
await concurrent(IDs, 1000, async function (ID) {
  const NPC = await processNPC(ID)
  if (NPC) {
    NPCs.push(NPC)
  }
})

const content = 'NPCs = ' + convertToLua(NPCs)
await writeFile('NPCs.lua', content)
