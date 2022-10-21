function findIn(table, searchTerm)
    searchTerm = string.lower(searchTerm)
    for name in pairs(table) do
        if string.match(string.lower(name), searchTerm) then
            print(name)
        end
    end
end

function findInGMR(searchTerm)
    findIn(GMR, searchTerm)
end
