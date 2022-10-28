local function printTableWithIndention(table, indention)
  if table == nil then
    print('nil')
  else
    for key, value in pairs(table) do
      local outputtedKey
      if type(key) == 'number' then
        outputtedKey = '[' .. tostring(key) .. ']'
      elseif type(key) == 'string' then
        if string.match(key, ' ') then
          outputtedKey = '["' .. tostring(key) .. '"]'
        else
          outputtedKey = tostring(key)
        end
      else
        outputtedKey = '[' .. tostring(key) .. ']'
      end
      if type(value) == 'table' then
        print(string.rep('  ', indention) .. outputtedKey .. '={')
        printTableWithIndention(value, indention + 1)
        print(string.rep('  ', indention) .. '}')
      else
        print(string.rep('  ', indention) .. outputtedKey .. '=' .. tostring(value))
      end
    end
  end
end

function printTable(table)
  printTableWithIndention(table, 0)
end
