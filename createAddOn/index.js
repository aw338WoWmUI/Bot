import { mkdir } from 'node:fs/promises'
import { argv } from 'node:process'
import { dirname, join } from 'path'
import { fileURLToPath } from 'url'
import { writeFile } from '@sanjo/write-file'
import { readFile } from '@sanjo/read-file'

const directoryPath = dirname(fileURLToPath(import.meta.url))

const args = argv.slice(2)
const addOnName = args[0]

const addOnPath = join(directoryPath, '..', 'AddOns', addOnName)
await mkdir(addOnPath, {
  recursive: true
})

{
  const content =
`## Title: ${addOnName}
## Interface: 100002

${addOnName}.lua
`
  await writeFile(join(addOnPath, `${addOnName}.toc`), content)
}

{
  const content =
`## Title: ${addOnName}
## Interface: 30400

${addOnName}.lua
`
  await writeFile(join(addOnPath, `${addOnName}_Wrath.toc`), content)
}

{
  const content =
`## Title: ${addOnName}
## Interface: 11403

${addOnName}.lua
`
  await writeFile(join(addOnPath, `${addOnName}_Vanilla.toc`), content)
}

{
  const content =
`${addOnName} = ${addOnName} or {}
local addOnName, AddOn = ...
local _ = {}
`
  await writeFile(join(addOnPath, `${addOnName}.lua`), content)
}

{
  const content = await readFile(join(directoryPath, '..', 'LICENSE'))
  await writeFile(join(addOnPath, 'LICENSE'), content)
}

{
  const createSymbolicLinksScriptPaths = [
    join(directoryPath, '..', 'create_symbolic_links.template.bat'),
    join(directoryPath, '..', 'create_symbolic_links.bat')
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
        `  mklink /D "%path%\\_${ version }_\\Interface\\AddOns\\${ addOnName }" "%~dp0\\AddOns\\${ addOnName }"`
      )
      content = content.substr(0, match.indices[2][0]) +
        mklinkStatements.join('\n') +
        '\n' +
        content.substr(match.indices[2][1])
    }
    await writeFile(createSymbolicLinksScriptPath, content)
  }
}
