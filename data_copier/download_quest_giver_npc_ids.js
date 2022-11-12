import puppeteer from 'puppeteer'
import { writeFile } from '@sanjo/write-file'

async function refuseAll() {
  await page.goto('https://www.wowhead.com/npcs?filter=7:37:37;1:2:4;0:0:0')
  await page.click('#onetrust-reject-all-handler')
  await page.waitForSelector('#onetrust-reject-all-handler', { hidden: true })
}

async function copyIDs(page, from, to) {
  await page.goto('https://www.wowhead.com/npcs?filter=7:37:37;1:2:4;0:' + from + ':' + to)
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
  return text.split(', ').map(Number)
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

let npcIDs = []

let IDs
let from = 1
const maxResultSize = 1000
do {
  const to = from + maxResultSize - 1
  IDs = await copyIDs(page, from, to)
  npcIDs = npcIDs.concat(IDs)
  from = to + 1
} while (IDs.length >= 1)

npcIDs.sort()

browser.close()

function generateLuaTable(list) {
  let result = '{\n'
  for (const element of list) {
    result += '  ' + element + ',\n'
  }
  result += '}'
  return result
}

const content = 'questGiverIDs = ' + generateLuaTable(npcIDs)
await writeFile('quest_giver_npc_ids.lua', content)
