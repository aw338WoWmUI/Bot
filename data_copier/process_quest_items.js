import { escapeForRegExp } from '@sanjo/escape-for-reg-exp'
import { readFile } from '@sanjo/read-file'
import { writeFile } from '@sanjo/write-file'
import { readdir } from 'node:fs/promises'
import { concurrent, convertToLua, sortIDs } from './lib.js'

async function processQuestItem(id) {
  const content = await readFile('quest_items/' + id + '.html')

  const questItem = {
    id,
  }

  questItem.containedIn = extractContainedIn(content)
  questItem.droppedBy = extractDroppedBy(content)

  return questItem
}

function extractContainedIn(content) {
  return extractListIDs(content, 'containedin')
}

function extractDroppedBy(content) {
  return extractListIDs(content, 'droppedby')
}

function extractListIDs(content, identifier) {
  const IDs = []
  const match = new RegExp(`new Listview.*?${escapeForRegExp(identifier)}.*?;`, 's').exec(content)
  if (match) {
    const content2 = match[0]
    const idRegExp = /"id":(\d+)/g
    let match2
    while (match2 = idRegExp.exec(content2)) {
      IDs.push(parseInt(match2[1], 10))
    }
  }
  return IDs
}

const files = await readdir('quest_items')
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

const questItems = []
await concurrent(IDs, 1000, async function (ID) {
  const questItem = await processQuestItem(ID)
  if (questItem) {
    questItems.push(questItem)
  }
})

const content = 'questItems = ' + convertToLua(questItems)
await writeFile('questItems.lua', content)
