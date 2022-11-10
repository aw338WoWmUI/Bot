import puppeteer from 'puppeteer'
import { writeFile } from '@sanjo/write-file'

async function refuseAll() {
  await page.goto('https://www.wowhead.com/quests?filter=30:30;2:4;0:0')
  await page.click('#onetrust-reject-all-handler')
  await page.waitForSelector('#onetrust-reject-all-handler', { hidden: true })
}

async function copyAllQuests(page, baseURL) {
  const totalNumberOfQuests = await determineTotalNumberOfQuests(page, baseURL)

  let quests = []
  let from = 1
  const maxResultSize = 1000
  do {
    const to = from + maxResultSize - 1
    quests = quests.concat(await copyQuests(page, baseURL, from, to))
    from = to + 1
  } while (quests.length < totalNumberOfQuests)

  return quests
}

async function determineTotalNumberOfQuests(page, baseURL) {
  await page.goto(baseURL)
  const numberOfQuests = await page.evaluate(() => {
    function parseNumber(numberText) {
      return parseInt(numberText.replaceAll(',', ''), 10)
    }

    const element = document.querySelector('#lv-quests > div.listview-band-top > div.listview-note')
    const text = element.textContent
    const match = /^[\d,]+/.exec(text)
    let numberOfQuests
    if (match) {
      numberOfQuests = parseNumber(match[0])
    } else {
      const element2 = document.querySelector(
        '#lv-quests > div.listview-band-top > div.listview-nav.listview-nav-nocontrols > span > b:nth-child(3)')
      const text = element2.textContent
      numberOfQuests = parseNumber(text)
    }
    return numberOfQuests
  })
  return numberOfQuests
}

async function copyQuests(page, baseURL, from, to) {
  await page.goto(baseURL + '?filter=30:30;2:4;' + from + ':' + to)
  {
    const selector = '.listview-option-button.fa-clipboard'
    if (await page.$(selector) === null) {
      return []
    }
    await page.waitForSelector(selector, { visible: true })
    await page.click(selector)
  }
  const selector = '.menu .menu-item:nth-child(2) > a'
  await page.waitForSelector(selector)
  await page.click(selector)
  const text = await page.evaluate(() => {
    return navigator.clipboard.readText()
  })
  const IDs = text.split(', ').map(Number)
  const quests = []
  for (const ID of IDs) {
    const quest = await copyQuest(ID)
    quests.push(quest)
  }
  return quests
}

async function copyQuest(id) {
  await page.goto('http://www.wowhead.com/quest=' + id)
  const info = await page.evaluate(() => {
    const LIs = Array.from(document.querySelectorAll('#infobox-contents-0 > ul > li'))
    const object = {}
    const requiresLevelRegExp = /^Requires level (\d+)$/
    const npcIDRegExp = /npc=(\d+)/
    LIs.forEach((li) => {
      const text = li.textContent
      const match = requiresLevelRegExp.exec(text)
      if (match) {
        object.requiredLevel = parseInt(match[1], 10)
      } else if (text.startsWith('Start: ')) {
        const elements = Array.from(li.querySelectorAll('a'))
        object.starterIDs = []
        for (const element of elements) {
          const href = element.href
          const match = npcIDRegExp.exec(href)
          if (match) {
            object.starterIDs.push(parseInt(match[1], 10))
          }
        }
      }  else if (text.startsWith('End: ')) {
        const a = li.querySelector('a')
        const href = a.href
        const match = npcIDRegExp.exec(href)
        if (match) {
          object.enderID = parseInt(match[1], 10)
        }
      } else {
        const sideRegExp = /^Side: (.+)$/
        const match = sideRegExp.exec(text)
        if (match) {
          object.sides = [match[1]]
        } else {
          const classesRegExp = /^Class(?:es)?: (.+)$/
          const match = classesRegExp.exec(text)
          if (match) {
            object.classes = match[1].split(', ').map(klass => klass.trim())
          } else {
            const racesRegExp = /^Races?: (.+)$/
            const match = racesRegExp.exec(text)
            if (match) {
              object.races = match[1].split(', ').map(race => race.trim())
            }
          }
        }
      }
    })
    return object
  })

  const preQuestIDs = await page.evaluate(() => {
    const elements = Array.from(document.querySelectorAll('.series td'))
    const preQuestIDs = []
    for (const element of elements) {
      const a = element.querySelector('a')
      if (a) {
        const href = a.href
        const match = /quest=(\d+)/.exec(href)
        if (match) {
          const id = parseInt(match[1], 10)
          preQuestIDs.push(id)
        }
      } else {
        break
      }
    }
    return preQuestIDs
  })

  const storylinePreQuestIDs = await page.evaluate(() => {
    const elements = Array.from(document.querySelectorAll('.quick-facts-storyline-list li'))
    const storylinePreQuestIDs = []
    for (const element of elements) {
      const a = element.querySelector('a')
      if (a) {
        const href = a.href
        const match = /quest=(\d+)/.exec(href)
        if (match) {
          const id = parseInt(match[1], 10)
          storylinePreQuestIDs.push(id)
        }
      } else {
        break
      }
    }
    return storylinePreQuestIDs
  })

  const quest = {
    id,
    ...info,
    preQuestIDs,
    storylinePreQuestIDs
  }

  return quest
}

const browser = await puppeteer.launch({
  headless: false,
})
await browser
  .defaultBrowserContext()
  .overridePermissions('https://www.wowhead.com', ['clipboard-read', 'clipboard-write'])
const page = await browser.newPage()
await page.setViewport({
  width: 1024,
  height: 768,
})
await page.setRequestInterception(true)
page.on('request', request => {
  const resourceType = request.resourceType()
  if (resourceType === 'image' || resourceType == 'font' || resourceType == 'other') {
    request.abort()
  } else {
    request.continue()
  }
})

await refuseAll()

const baseURL = 'https://www.wowhead.com/quests/eastern-kingdoms/westfall'
// const baseURL = 'https://www.wowhead.com/quests'
const quests = await copyAllQuests(page, baseURL)

browser.close()

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
