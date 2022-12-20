import { readFile } from '@sanjo/read-file'
import { writeFile } from '@sanjo/write-file'
import { dirname, join } from 'node:path'
import { argv } from 'node:process'
import { fileURLToPath } from 'node:url'
import { createAddOn } from './createAddOn/createAddOn.js'

const directoryPath = dirname(fileURLToPath(import.meta.url))

const args = argv.slice(2)
const addOnName = args[0]

const addOnPath = join(directoryPath, '..', 'AddOns', addOnName)
await createAddOn(addOnPath)
await addSymbolicLinkStatementsToCreateSymbolicLinksScripts(addOnName)

async function addSymbolicLinkStatementsToCreateSymbolicLinksScripts(addOnName) {
  const createSymbolicLinksScriptPaths = [
    join(directoryPath, '..', 'create_symbolic_links.template.bat'),
    join(directoryPath, '..', 'create_symbolic_links.bat'),
  ]
  for (const createSymbolicLinksScriptPath of createSymbolicLinksScriptPaths) {
    let content
    try {
      content = await readFile(createSymbolicLinksScriptPath)
    } catch (error) {
      if (error.code == 'ENOENT') {
        continue
      } else {
        throw error
      }
    }
    const regExp = /if exist "%path%\\_(.+?)_" \(\n  if not exist "%path%\\_.+?_\\Interface" mkdir "%path%\\_.+?_\\Interface"\n  if not exist "%path%\\_.+?_\\Interface\\AddOns" mkdir "%path%\\_.+?_\\Interface\\AddOns"\n(.*?)\)/sdg
    let match
    while (match = regExp.exec(content)) {
      const version = match[1]
      let mklinkStatements = match[2].split('\n')
      mklinkStatements = mklinkStatements.slice(0, mklinkStatements.length - 1)
      const addOnNameRegExp = /mklink \/D "%path%\\_.+?_\\Interface\\AddOns\\(.+?)"/
      const addOnNames = mklinkStatements.map(statement => addOnNameRegExp.exec(statement)[1])
      const addOnNameLowerCase = addOnName.toLowerCase()
      const index = addOnNames.findIndex(addOnName2 => addOnNameLowerCase < addOnName2.toLowerCase())
      mklinkStatements.splice(
        index,
        0,
        `  mklink /D "%path%\\_${ version }_\\Interface\\AddOns\\${ addOnName }" "%~dp0\\AddOns\\${ addOnName }"`,
      )
      content = content.substr(0, match.indices[2][0]) +
        mklinkStatements.join('\n') +
        '\n' +
        content.substr(match.indices[2][1])
    }
    await writeFile(createSymbolicLinksScriptPath, content)
  }
}
