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
## Interface: 30400

${addOnName}.lua
`
  await writeFile(join(addOnPath, `${addOnName}_Vanilla.toc`), content)
}

{
  const content =
`local addOnName, AddOn = ...
${addOnName} = ${addOnName} or {}
local _ = {}
`
  await writeFile(join(addOnPath, `${addOnName}.lua`), content)
}

{
  const content = await readFile(join(directoryPath, '..', 'LICENSE'))
  await writeFile(join(addOnPath, 'LICENSE'), content)
}
