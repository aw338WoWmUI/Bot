import { request } from '@sanjo/request'
import { writeFile } from '@sanjo/write-file'
import { extractNPCIds, generateLuaListTable } from './lib.js'

const response = await request('https://www.wowhead.com/npcs?filter=21;1;0')
const content = response.body
const IDs = extractNPCIds(content)

const content2 = 'flightMasterNPCIDs = ' + generateLuaListTable(IDs)
await writeFile('flight_master_npc_ids.lua', content2)
