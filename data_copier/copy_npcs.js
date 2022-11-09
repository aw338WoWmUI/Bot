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
    ...info
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

await refuseAll()

const baseURL = 'https://www.wowhead.com/quests/eastern-kingdoms/northshire'
// const baseURL = 'https://www.wowhead.com/quests'
// const NPCs = await copyAllNPCs(page, baseURL)

const IDs = [
  246,
  112805,
  810,
  114409,
  43292,
  1632,
  112829,
  48875,
  110625,
  1215,
  583,
  2046,
  98840,
  844,
  101451,
  114100,
  114102,
  114098,
  113986,
  101425,
  101427,
  113637,
  101452,
  113836,
  114099,
  101453,
  114101,
  16510,
  113022,
  43278,
  11996,
  151298,
  116,
  63258,
  465,
  23482,
  42983,
  46983,
  26267,
  247,
  22816,
  42937,
  49874,
  49871,
  114404,
  53408,
  797,
  6866,
  35337,
  34653,
  22985,
  112813,
  113561,
  113655,
  113847,
  99094,
  66037,
  66038,
  66024,
  113330,
  24484,
  151,
  152,
  952,
  951,
  925,
  927,
  12376,
  39480,
  51077,
  805,
  31788,
  6368,
  66163,
  51665,
  12375,
  620,
  5917,
  103098,
  126632,
  54,
  24519,
  111704,
  2442,
  111744,
  37214,
  38065,
  166185,
  94,
  6374,
  113275,
  804,
  6373,
  146010,
  14849,
  54345,
  958,
  42259,
  6093,
  113018,
  883,
  963,
  190,
  99076,
  47194,
  6846,
  6927,
  6367,
  114400,
  114398,
  114401,
  114399,
  53728,
  99167,
  1250,
  459,
  113564,
  196,
  1975,
  11328,
  99165,
  15562,
  15565,
  1103,
  108487,
  34710,
  25898,
  51519,
  23507,
  98839,
  99337,
  111745,
  111696,
  801,
  880,
  6749,
  14390,
  14393,
  6774,
  890,
  472,
  114403,
  113025,
  99078,
  113926,
  25962,
  55088,
  55089,
  55093,
  30,
  89715,
  107979,
  108015,
  65153,
  46942,
  51666,
  255,
  52548,
  51947,
  178377,
  50039,
  1213,
  327,
  23511,
  43000,
  248,
  175692,
  1922,
  34675,
  51934,
  51701,
  113303,
  99125,
  50926,
  100,
  12423,
  261,
  62,
  146793,
  99338,
  98902,
  6306,
  114410,
  6172,
  1218,
  46941,
  42401,
  42403,
  448,
  894,
  152561,
  50526,
  98828,
  113565,
  165542,
  171447,
  114411,
  50047,
  295,
  99331,
  13159,
  78,
  383,
  34744,
  802,
  99099,
  91405,
  15310,
  50527,
  806,
  915,
  811,
  796,
  258,
  98897,
  64330,
  179437,
  50412,
  142656,
  384,
  52064,
  112823,
  113929,
  917,
  799,
  198,
  11979,
  3937,
  112830,
  113528,
  114325,
  114326,
  11072,
  113028,
  476,
  40,
  475,
  74,
  42938,
  800,
  101449,
  146794,
  98917,
  50916,
  1651,
  47384,
  99157,
  807,
  911,
  119,
  98895,
  113026,
  15892,
  15895,
  15898,
  71938,
  913,
  244,
  39478,
  46940,
  525,
  99328,
  63014,
  795,
  395,
  240,
  294,
  197,
  42256,
  98094,
  794,
  906,
  251,
  6778,
  11940,
  2329,
  16781,
  9296,
  43,
  46932,
  99,
  473,
  959,
  471,
  50413,
  285,
  46,
  732,
  735,
  88241,
  79,
  99287,
  31790,
  91406,
  32781,
  32836,
  105136,
  1642,
  11260,
  98843,
  151297,
  151299,
  99118,
  53869,
  250,
  155185,
  5406,
  99296,
  5405,
  109685,
  375,
  377,
  330,
  99169,
  118,
  1645,
  1249,
  112807,
  113566,
  46943,
  1198,
  4732,
  113925,
  6121,
  241,
  5403,
  478,
  97,
  11994,
  524,
  14388,
  474,
  105134,
  60,
  99288,
  31791,
  31792,
  108488,
  50528,
  113023,
  278,
  955,
  823,
  1949,
  23543,
  128056,
  114405,
  60565,
  1933,
  112814,
  146702,
  99237,
  113531,
  46982,
  514,
  114412,
  50942,
  798,
  52497,
  114406,
  114407,
  6491,
  32799,
  99324,
  113,
  42216,
  68,
  1423,
  49869,
  140146,
  49540,
  42218,
  42096,
  53702,
  26401,
  99292,
  113530,
  10616,
  123602,
  123892,
  123957,
  123976,
  124056,
  124057,
  124116,
  124118,
  124120,
  124123,
  124124,
  124129,
  124132,
  124136,
  124138,
  124151,
  881,
  112806,
  14561,
  14559,
  14560,
  63015,
  50752,
  113337,
  48873,
  113415,
  51014,
  1650,
  66,
  34823,
  34822,
  34819,
  34824,
  34812,
  313,
  111743,
  23510,
  61,
  98898,
  99098,
  98901,
  3935,
  105135,
  1430,
  252,
  23712,
  44548,
  65310,
  105133,
  113919,
  113363,
  112824,
  113931,
  112808,
  113933,
  98835,
  896,
  113558,
  112815,
  175145,
  51699,
  32820,
  253,
  34682,
  43291,
  99335,
  113934,
  26502,
  44564,
  50918,
  822,
  299,
  328,
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
