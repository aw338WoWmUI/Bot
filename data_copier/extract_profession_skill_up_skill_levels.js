import { request } from '@sanjo/request'
import { writeFile } from '@sanjo/write-file'
import { convertToLua } from './lib.js'

const response = await request('https://www.wowhead.com/spells/professions/blacksmithing/dragon-isles-plans')
const content = response.body
const match = /var listviewspells = (.+);/.exec(content)
if (match) {
  const dataString = match[1]
  const data = eval(dataString)
  const data2 = Object.fromEntries(data.map(entry => [entry.id, entry.colors]))
  const content2 = 'professionSkillUpSkillLevels = ' + convertToLua(data2)
  await writeFile('professionSkillUpSkillLevels.lua', content2)
}
