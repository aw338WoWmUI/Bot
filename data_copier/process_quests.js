import { readFile } from '@sanjo/read-file'
import { writeFile } from '@sanjo/write-file'
import { escapeForRegExp } from '@sanjo/escape-for-reg-exp'
import { readdir } from 'node:fs/promises'
import { concurrent, convertToLua, sortIDs } from './lib.js'
import { parse } from 'node-html-parser'

const infoBoxContentRegExp = /WH\.markup\.printHtml.+?;/s
const requiresLevelRegExp = /Requires level (\d+)/
const sideRegExp = /Side: .*?([a-zA-Z]+?)\[\\/
const classesRegExp = /Class(?:es)?: (.+)/
const racesRegExp = /Races?: ([^\\]+)/
const seriesRegExp = /<table class="series">(.*?)<\/table>/
const questRegExp = /quest=(\d+)/
const storylineRegExp = /<div class="quick-facts-storyline-list">(.*?)<\/div>/s

async function processQuest(id) {
  const content = await readFile('quests/' + id + '.html')

  const quest = {
    id,
  }

  let infoBoxContent
  {
    const match = infoBoxContentRegExp.exec(content)
    infoBoxContent = match[0]
  }

  {
    const match = requiresLevelRegExp.exec(infoBoxContent)
    if (match) {
      quest.requiredLevel = parseInt(match[1], 10)
    }
  }

  quest.starters = extractObjects(infoBoxContent, '[icon name=quest-start]Start')
  quest.enders = extractObjects(infoBoxContent, '[icon name=quest-end]End')

  {
    const match = sideRegExp.exec(infoBoxContent)
    if (match) {
      quest.sides = [match[1]]
    }
  }

  {
    const match = classesRegExp.exec(infoBoxContent)
    if (match) {
      const content2 = match[1]
      const classRegExp = /class=(\d+)/g
      let match2
      quest.classes = []
      while (match2 = classRegExp.exec(content2)) {
        const classID = parseInt(match2[1], 10)
        quest.classes.push(classID)
      }
    }
  }

  const match = racesRegExp.exec(infoBoxContent)
  if (match) {
    const content2 = match[0]
    const raceRegExp = /race=(\d+)/g
    let match2
    quest.races = []
    while (match2 = raceRegExp.exec(content2)) {
      const raceID = parseInt(match2[1], 10)
      quest.races.push(raceID)
    }
  }

  quest.preQuestIDs = extractPreQuestIDs(content)
  quest.storylinePreQuestIDs = extractStorylinePreQuestIDs(content)
  quest.objectives = extractObjectives(content)

  return quest
}

function extractObjects(content, label) {
  const IDs = []
  const startsWithRegExp = new RegExp('\\[li\\]' + escapeForRegExp(label) + ': .*?\\[\\\\\\/li\\]')
  const match = startsWithRegExp.exec(content)
  if (match) {
    const npcIDRegExp = /(npc|object|item)=(\d+)/g
    let match2
    while (match2 = npcIDRegExp.exec(match[0])) {
      const id = parseInt(match2[2], 10)
      IDs.push({
        type: match2[1],
        id
      })
    }
  }
  return IDs
}

function extractPreQuestIDs(content) {
  const preQuestIDs = []
  const match = seriesRegExp.exec(content)
  if (match) {
    const content2 = match[1]
    const regExp2 = /<td>(.*?)<\/td>/g
    let match2
    while (match2 = regExp2.exec(content2)) {
      const content3 = match2[1]
      const match = questRegExp.exec(content3)
      if (match) {
        const id = parseInt(match[1], 10)
        preQuestIDs.push(id)
      } else {
        break
      }
    }
  }

  return preQuestIDs
}

function extractStorylinePreQuestIDs(content) {
  const storylinePreQuestIDs = []
  const match = storylineRegExp.exec(content)
  if (match) {
    const content2 = match[1]
    const regExp2 = /<li.*?>(.*?)<\/li>/g
    let match2
    while (match2 = regExp2.exec(content2)) {
      const content3 = match2[1]
      const match = questRegExp.exec(content3)
      if (match) {
        const id = parseInt(match[1], 10)
        storylinePreQuestIDs.push(id)
      } else {
        break
      }
    }
  }

  return storylinePreQuestIDs
}

const objectiveIDRegExp = /(npc|object|item)=(\d+)/

function extractObjectives(content) {
  const objectives = []
  const match = /(<table class="icon-list">.*?)<script/s.exec(content)
  if (match) {
    const content2 = match[1]
    const html = parse(content2)
    const table = html.querySelector('table')
    const TRs = table.childNodes.filter(element => element.tagName === 'TR')
    for (const TR of TRs) {
      const As = TR.querySelectorAll('a')
      const objective = []
      for (const A of As) {
        const match2 = objectiveIDRegExp.exec(A.getAttribute('href'))
        if (match2) {
          const id = parseInt(match2[2], 10)
          objective.push({
            type: match2[1],
            id
          })
        }
      }
      objectives.push(objective)
    }
  }
  return objectives
}

const files = await readdir('quests')
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

const quests = []
await concurrent(IDs, 1000, async function (ID) {
  const quest = await processQuest(ID)
  if (quest) {
    quests.push(quest)
  }
})

const content = 'quests = ' + convertToLua(quests)
await writeFile('quests.lua', content)
