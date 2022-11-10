import puppeteer from 'puppeteer'
import { writeFile } from '@sanjo/write-file'

const timeout = 0

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
    } else if (numberOfMenuItems >= 3) {
      await page.click('.menu .menu-item:nth-child(3) > a')
    }
    if (numberOfMenuItems >= 3) {
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
await page.setDefaultTimeout(timeout)
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
  596,
  626,
  599,
  94226,
  104476,
  111034,
  7024,
  108630,
  42702,
  844,
  106893,
  106894,
  95405,
  107198,
  109538,
  108126,
  107107,
  105901,
  42683,
  48840,
  520,
  102262,
  102296,
  42425,
  821,
  105713,
  392,
  71464,
  42669,
  620,
  8934,
  93595,
  99778,
  93228,
  110945,
  111879,
  834,
  833,
  6250,
  42311,
  6182,
  107197,
  104453,
  104418,
  106891,
  106892,
  104452,
  104451,
  49769,
  71461,
  594,
  449,
  590,
  589,
  6180,
  92629,
  92917,
  94736,
  104462,
  112149,
  104463,
  104456,
  104287,
  104467,
  107120,
  104430,
  107111,
  92811,
  104465,
  104449,
  104448,
  111358,
  107730,
  42697,
  15577,
  107238,
  42342,
  104875,
  104423,
  104416,
  110395,
  237,
  233,
  106327,
  92113,
  105954,
  98371,
  112552,
  106430,
  104986,
  106651,
  94589,
  109710,
  112570,
  90645,
  104431,
  104282,
  104286,
  94143,
  94154,
  104281,
  104429,
  104487,
  104427,
  104428,
  104426,
  104446,
  104445,
  105569,
  106383,
  93348,
  106867,
  25962,
  104464,
  107106,
  107117,
  107115,
  1109,
  573,
  104435,
  109741,
  89715,
  108378,
  843,
  105809,
  95211,
  157,
  107121,
  107798,
  154,
  239,
  111111,
  95729,
  95070,
  107122,
  107124,
  106200,
  115,
  114,
  42655,
  104474,
  42399,
  42401,
  42403,
  42402,
  42406,
  42384,
  42386,
  106186,
  106187,
  106188,
  106189,
  42575,
  42357,
  52183,
  104447,
  108123,
  108486,
  94426,
  104450,
  171447,
  94746,
  106277,
  106176,
  106175,
  8931,
  110583,
  95205,
  92386,
  42653,
  42498,
  49736,
  107776,
  95206,
  10045,
  1236,
  98478,
  93734,
  4305,
  107703,
  104280,
  572,
  42308,
  42558,
  104432,
  842,
  43011,
  107847,
  107110,
  42497,
  119390,
  94615,
  104442,
  234,
  94599,
  1424,
  97561,
  106850,
  42656,
  16781,
  1670,
  105810,
  104283,
  42677,
  107728,
  6271,
  126,
  458,
  456,
  513,
  517,
  515,
  127,
  171,
  108629,
  111880,
  582,
  65648,
  391,
  108596,
  42385,
  42381,
  91801,
  2620,
  49749,
  43948,
  96985,
  487,
  94674,
  870,
  94657,
  869,
  94658,
  489,
  94670,
  490,
  94659,
  874,
  94675,
  876,
  94676,
  488,
  94666,
  491,
  105789,
  42413,
  104285,
  94698,
  104433,
  52189,
  42635,
  452,
  54371,
  124,
  54372,
  117,
  501,
  54373,
  123,
  453,
  500,
  1065,
  98,
  846,
  480,
  235,
  106328,
  830,
  878,
  105714,
  820,
  831,
  42407,
  94677,
  94602,
  111942,
  506,
  49745,
  104420,
  104421,
  104419,
  94258,
  60761,
  1216,
  92770,
  92784,
  49741,
  623,
  519,
  42390,
  106184,
  106185,
  104475,
  94745,
  104425,
  104424,
  104489,
  104488,
  6491,
  107231,
  50595,
  107496,
  94765,
  95233,
  95010,
  105888,
  106268,
  106292,
  106473,
  106668,
  107488,
  42309,
  42559,
  94600,
  94957,
  94958,
  106472,
  94357,
  26401,
  71462,
  111878,
  99370,
  109493,
  523,
  110587,
  42651,
  42387,
  42426,
  111895,
  42383,
  95149,
  106179,
  52190,
  42405,
  42560,
  832,
  625,
  624,
  94734,
  107309,
  107777,
  99357,
  42371,
  103676,
  238,
  104436,
  107112,
  462,
  105999,
  42391,
  42400,
  94739,
  106180,
  51915,
  25910,
  6670,
  111875,
  1668,
  105812,
  104444,
  104443,
  105546,
  199,
  454,
  110748,
  93921,
  49760,
  105900,
  106163,
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
