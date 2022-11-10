import { writeFile } from '@sanjo/write-file'
import { request } from '@sanjo/request'
import { escapeForRegExp } from '@sanjo/escape-for-reg-exp'

async function copyAllQuests(baseURL) {
  const totalNumberOfQuests = await determineTotalNumberOfQuests(baseURL)

  let quests = []
  let from = 1
  const maxResultSize = 1000
  do {
    const to = from + maxResultSize - 1
    quests = quests.concat(await copyQuests(baseURL, from, to))
    from = to + 1
  } while (quests.length < totalNumberOfQuests)

  return quests
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

async function copyQuests(baseURL, from, to) {
  const quests = []

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
      const quest = await copyQuest(ID)
      quests.push(quest)
    }))
  }

  return quests
}

let i = 0
let startTime

const infoBoxContentRegExp = /WH\.markup\.printHtml.+?;/s
const requiresLevelRegExp = /Requires level (\d+)/
const sideRegExp = /Side: ([^\[]+)/
const classesRegExp = /Class(?:es)?: (.+)/
const racesRegExp = /Races?: ([^\\]+)/
const seriesRegExp = /<table class="series">(.*?)<\/table>/
const questRegExp = /quest=(\d+)/
const storylineRegExp = /<div class="quick-facts-storyline-list">(.*?)<\/div>/s

async function copyQuest(id) {
  const redirectResponse = await request('https://www.wowhead.com/quest=' + id)
  const location = redirectResponse.headers.location
  const response = await request('https://www.wowhead.com' + location)
  const content = response.body

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

  quest.starterIDs = extractObjectIDs(infoBoxContent, '[icon name=quest-start]Start')
  quest.enderID = extractObjectIDs(infoBoxContent, '[icon name=quest-end]End')

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

  i++

  if (i % 1000 == 0) {
    console.log(i, ((Date.now() - startTime) / i) / 60)
  }

  return quest
}

function extractObjectIDs(content, label) {
  const IDs = []
  const startsWithRegExp = new RegExp('\\[li\\]' + escapeForRegExp(label) + ': .*?\\[\\\\\\/li\\]')
  const match = startsWithRegExp.exec(content)
  if (match) {
    const npcIDRegExp = /(?:npc|object)=(\d+)/g
    let match2
    while (match2 = npcIDRegExp.exec(match[0])) {
      const starterID = parseInt(match2[1], 10)
      IDs.push(starterID)
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

const baseURL = 'https://www.wowhead.com/quests'
// const baseURL = 'https://www.wowhead.com/quests'
startTime = Date.now()
const quests = await copyAllQuests(baseURL)

// const quests = [await copyQuest2(24545)]

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
  } else if (type === 'object') {
    result = generateLuaTable(value, indention + 1)
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

const content = 'quests = ' + convertToLua(quests)
await writeFile('quests.lua', content)
