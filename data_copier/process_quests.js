import { escapeForRegExp } from '@sanjo/escape-for-reg-exp'
import { readFile } from '@sanjo/read-file'
import { writeFile } from '@sanjo/write-file'
import { parse } from 'node-html-parser'
import { readdir } from 'node:fs/promises'
import { concurrent, convertToLua, sortIDs } from './lib.js'

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

  const questDoesNotExistRegExp = new RegExp(`Quest #${id} doesn't exist.`)
  if (questDoesNotExistRegExp.test(content)) {
    return null
  }

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

  quest.starters = extractObjects(infoBoxContent, '\\[icon name=quest-start(?:-campaign)?\\]Start')
  quest.enders = extractObjects(infoBoxContent, '\\[icon name=quest-end(?:-campaign)?\\]End')

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

  quest.preQuestIDs = extractSeriesPreQuestIDs(content)
  quest.storylinePreQuestIDs = extractStorylinePreQuestIDs(content)
  quest.followUpQuestIDs = extractSeriesFollowUpQuestIDs(content)
  quest.storylineFollowUpQuestIDs = extractStorylineFollowUpQuestIDs(content)
  quest.requiresQuestIDs = extractRequiresQuestIDs(content)
  quest.unlockedQuestIDs = extractUnlockedQuestIDs(content)
  quest.objectives = extractObjectives(content)

  const DRAGONSCALE_EXPEDITION = 2507
  const MARUUK_CENTAUR = 2503
  const ISKAARA_TUSKARR = 2511
  const VALDRAKKEN_ACCORD = 2510

  quest.reputation = {
    [DRAGONSCALE_EXPEDITION]: extractReputationForDragonscaleExpedition(content),
    [MARUUK_CENTAUR]: extractReputationForMaruukCentaur(content),
    [ISKAARA_TUSKARR]: extractReputationForIskaaraTuskarr(content),
    [VALDRAKKEN_ACCORD]: extractReputationForValdrakkenAccord(content),
  }

  return quest
}

function extractReputationForIskaaraTuskarr(content) {
  const regExp = /<span>(\d+)<\/span> reputation with <a href="\/faction=2511\/iskaara-tuskarr">Iskaara Tuskarr/
  const match = regExp.exec(content)
  if (match) {
    return parseInt(match[1], 10)
  } else {
    return 0
  }
}

function extractReputationForMaruukCentaur(content) {
  const regExp = /<span>(\d+)<\/span> reputation with <a href="\/faction=2503\/maruuk-centaur">Maruuk Centaur/
  const match = regExp.exec(content)
  if (match) {
    return parseInt(match[1], 10)
  } else {
    return 0
  }
}

function extractReputationForValdrakkenAccord(content) {
  const regExp = /<span>(\d+)<\/span> reputation with <a href="\/faction=2510\/valdrakken-accord">Valdrakken Accord/
  const match = regExp.exec(content)
  if (match) {
    return parseInt(match[1], 10)
  } else {
    return 0
  }
}

function extractReputationForDragonscaleExpedition(content) {
  const regExp = /<span>(\d+)<\/span> reputation with <a href="\/faction=2507\/dragonscale-expedition">Dragonscale Expedition/
  const match = regExp.exec(content)
  if (match) {
    return parseInt(match[1], 10)
  } else {
    return 0
  }
}

function extractObjects(content, label) {
  const IDs = []
  const startsWithRegExp = new RegExp('\\[li\\]' + label + ': .*?\\[\\\\\\/li\\]')
  const match = startsWithRegExp.exec(content)
  if (match) {
    const npcIDRegExp = /(npc|object|item)=(\d+)/g
    let match2
    while (match2 = npcIDRegExp.exec(match[0])) {
      const id = parseInt(match2[2], 10)
      IDs.push({
        type: match2[1],
        id,
      })
    }
  }
  return IDs
}

function extractSeriesPreQuestIDs(content) {
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

function extractSeriesFollowUpQuestIDs(content) {
  const followUpQuestIDs = []
  const match = seriesRegExp.exec(content)
  let hasQuestBeenFound = false
  if (match) {
    const content2 = match[1]
    const regExp2 = /<td>(.*?)<\/td>/g
    let match2
    while (match2 = regExp2.exec(content2)) {
      const content3 = match2[1]
      const match = questRegExp.exec(content3)
      if (match) {
        if (hasQuestBeenFound) {
          const id = parseInt(match[1], 10)
          followUpQuestIDs.push(id)
        }
      } else {
        hasQuestBeenFound = true
      }
    }
  }

  return followUpQuestIDs
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

function extractStorylineFollowUpQuestIDs(content) {
  const storylineFollowUpQuestIDs = []
  const match = storylineRegExp.exec(content)
  if (match) {
    const regExp3 = /<li class="current">(.*?)<\/li>/
    const content2 = match[1]
    const match3 = regExp3.exec(content2)
    if (match3) {
      const content3 = content2.substr(match3.index + match3[0].length)
      const regExp2 = /<li.*?>(.*?)<\/li>/g
      let match2
      while (match2 = regExp2.exec(content3)) {
        const content3 = match2[1]
        const match = questRegExp.exec(content3)
        if (match) {
          const id = parseInt(match[1], 10)
          storylineFollowUpQuestIDs.push(id)
        } else {
          break
        }
      }
    }
  }

  return storylineFollowUpQuestIDs
}

function extractRequiresQuestIDs(content) {
  const questIDs = []
  const infoBoxContent1RegExp = /WH\.markup\.printHtml.+?infobox-contents-1/
  const match = infoBoxContent1RegExp.exec(content)
  if (match) {
    const content2 = match[0]
    const questRegExp = /quest=(\d+)/g
    let match2
    while (match2 = questRegExp.exec(content2)) {
      const questID = parseInt(match2[1], 10)
      questIDs.push(questID)
    }
  }
  return questIDs
}

function extractUnlockedQuestIDs(content) {
  const questIDs = []
  const infoBoxContent2RegExp = /WH\.markup\.printHtml.+?infobox-contents-2/
  const match = infoBoxContent2RegExp.exec(content)
  if (match) {
    const content2 = match[0]
    const questRegExp = /quest=(\d+)/g
    let match2
    while (match2 = questRegExp.exec(content2)) {
      const questID = parseInt(match2[1], 10)
      questIDs.push(questID)
    }
  }
  return questIDs
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
            id,
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

const content = 'local addOnName, AddOn = ...\n\nAddOn.quests = ' + convertToLua(quests)
await writeFile('quests.lua', content)
