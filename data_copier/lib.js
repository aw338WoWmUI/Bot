export function concurrent(things, numberOfSimultaneousRuns, run) {
  return new Promise(resolve => {
    let nextIndex = 0
    let numberOfRunning = 0
    let hasResolved = false

    function runNext() {
      if (nextIndex < things.length) {
        const thing = things[nextIndex]
        nextIndex++
        run(thing).finally(runNext)
      } else if (!hasResolved) {
        hasResolved = true
        resolve()
      }
    }

    while (numberOfRunning < numberOfSimultaneousRuns) {
      runNext()
      numberOfRunning++
    }
  })
}

export function generateLuaListTable(list, indention) {
  let result = '{\n'
  for (const element of list) {
    result += indent(convertToLua(element, indention) + ',', 1) + '\n'
  }
  result += '}'
  return result
}

export function generateLuaTable(object, indention) {
  let result = '{\n'
  for (const [key, value] of Object.entries(object)) {
    result += indent(`['${ key }'] = ${ convertToLua(value, indention) },`, 1) + '\n'
  }
  result += '}'
  return result
}

export function convertToLua(value, indention = 0) {
  const type = typeof value
  let result
  if (type === 'string') {
    result = `'${ value }'`
  } else if (type === 'number') {
    result = String(value)
  } else if (Array.isArray(value)) {
    result = generateLuaListTable(value, indention + 1)
  } else if (type === 'undefined' || value === null) {
    result = 'nil'
  } else if (type === 'object') {
    result = generateLuaTable(value, indention + 1)
  } else if (type === 'boolean') {
    result = String(value)
  } else {
    throw new Error(`Unhandled case for type "${ type }".`)
  }
  return result
}

export function indent(value, indention) {
  const lines = value.split('\n')
  const indentedLines = lines.map(line => '  '.repeat(indention) + line)
  return indentedLines.join('\n')
}

const npcsRegExp = /new Listview.+/

export function extractNPCIds(content) {
  const IDs = []
  const match2 = npcsRegExp.exec(content)
  if (match2) {
    const content2 = match2[0]
    const idRegExp = /"id":(\d+)/g
    let match
    while (match = idRegExp.exec(content2)) {
      const ID = Number(match[1])
      IDs.push(ID)
    }
  }
  return IDs
}

export function sortIDs(IDs) {
  IDs.sort(compareIDs)
}

function compareIDs(a, b) {
  return a < b ? -1 : a > b ? 1 : 0
}

