import puppeteer from 'puppeteer'
import { writeFile } from '@sanjo/write-file'

async function refuseAll() {
  await page.goto('https://www.wowhead.com/quests?filter=30:30;2:4;0:0')
  await page.click('#onetrust-reject-all-handler')
  await page.waitForSelector('#onetrust-reject-all-handler', { hidden: true })
}

async function copyAllNPCs(page, baseURL) {
  const totalNumberOfQuests = await determineTotalNumberOfQuests(page, baseURL)

  let NPCs = []
  let from = 1
  const maxResultSize = 1000
  do {
    const to = from + maxResultSize - 1
    NPCs = NPCs.concat(await copyNPCs(page, baseURL, from, to))
    from = to + 1
  } while (NPCs.length < totalNumberOfQuests)

  return NPCs
}

async function determineTotalNumberOfQuests(page, baseURL) {
  await page.goto(baseURL)
  const numberOfQuests = await page.evaluate(() => {
    function parseNumber(numberText) {
      return parseInt(numberText.replaceAll(',', ''), 10)
    }

    const element = document.querySelector('#lv-NPCs > div.listview-band-top > div.listview-note')
    const text = element.textContent
    const match = /^[\d,]+/.exec(text)
    let numberOfQuests
    if (match) {
      numberOfQuests = parseNumber(match[0])
    } else {
      const element2 = document.querySelector(
        '#lv-NPCs > div.listview-band-top > div.listview-nav.listview-nav-nocontrols > span > b:nth-child(3)')
      const text = element2.textContent
      numberOfQuests = parseNumber(text)
    }
    return numberOfQuests
  })
  return numberOfQuests
}

async function copyNPCs(page, baseURL, from, to) {
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
    const quest = await copyNPC(ID)
    quests.push(quest)
  }
  return quests
}

async function copyNPC(id) {
  await page.goto('http://www.wowhead.com/npc=' + id)

  const info = await page.evaluate(() => {
    const LIs = Array.from(document.querySelectorAll('#infobox-contents-0 > ul > li'))
    const object = {}
    LIs.forEach((li) => {
      const text = li.textContent
      if (text == 'Can repair') {
        object.canRepair = true
      }
    })
    return object
  })

  let coordinates
  const hasPin = await page.evaluate(() => {
    return Boolean(document.querySelector('.mapper .pin > a'))
  })
  if (hasPin) {
    await page.click('.mapper .pin > a')
    const numberOfMenuItems = await page.evaluate(() => {
      return document.querySelectorAll('.menu .menu-item').length
    })
    if (numberOfMenuItems >= 6) {
      await page.click('.menu .menu-item:nth-child(7) > a')
    } else {
      await page.click('.menu .menu-item:nth-child(3) > a')
    }
    const coordinatesText = await page.evaluate(() => {
      return navigator.clipboard.readText()
    })
    const regExp = /worldmap:(\d+):([\d\.]+):([\d\.]+)/
    coordinates = coordinatesText.split('\n').map(command => {
      const match = regExp.exec(command)
      return [Number(match[1]), Number(match[2]) / 100, Number(match[3]) / 100]
    })
  } else {
    coordinates = []
  }

  const NPC = {
    id,
    coordinates,
    ...info,
  }

  const h1Text = await page.evaluate(() => {
    return document.querySelector('h1').textContent
  })
  const innkeeperRegExp = /<Innkeeper>$/
  if (innkeeperRegExp.test(h1Text)) {
    NPC.isInnkeeper = true
  }

  const gryphonMasterRegExp = /<Gryphon Master>$/
  if (gryphonMasterRegExp.test(h1Text)) {
    NPC.isGryphonMaster = true
  }

  const isVendor = await page.evaluate(() => {
    const elements = Array.from(document.querySelectorAll('.tabs-container .tabs li'))
    const regExp = /^Sells/
    return elements.some(element => regExp.test(element.textContent))
  })
  if (isVendor) {
    NPC.isVendor = true
  }

  return NPC
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

const IDs = [

]

const NPCs = []

for (const ID of IDs) {
  console.log(ID)
  NPCs.push(await copyNPC(ID))
}

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
  } else if (type === 'boolean') {
    result = String(value)
  } else if (type === 'undefined') {
    result = 'nil'
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

const content = 'NPCs = ' + convertToLua(NPCs)
await writeFile('NPCs.lua', content)
