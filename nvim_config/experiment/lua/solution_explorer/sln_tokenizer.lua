local M = {}

local common = require("common")
local stack = require("stack")

local TokenType = {
    KEYWORD = "KEYWORD",
    TEXT = "TEXT",
    DELIMITER = "DELIMITER",

    UNKNOWN = "UNKNOWN"
}

local Keywords = {
    Project = "Project"

}

local function tokenize(input)
    local tokens = {}
    local buffer = ""
    local insideQuotation = false
    local paranthesisStack = stack:Create()

    paranthesisStack:push("{", "}")
    print(paranthesisStack:peek())
    print(paranthesisStack:peek())
    print(paranthesisStack:peek())
    print(paranthesisStack:peek())

    common.print_table(paranthesisStack:list() or { 0 })

    for char in input:gmatch(".") do
        if char == ' ' then
            -- vim.notify(buffer)
            buffer = ""
        else
            buffer = buffer .. char
        end
    end

    return tokens
end

function M.tokenize_file(filePath)
    local projects = {}

    local folders = {}
    local project_tree = {}

    local file = io.open(filePath, "r")
    if not file then
        print("Could not open file: " .. filePath)
        return
    end

    for line in file:lines() do
        local tokens = tokenize(line)
        -- common.print_table(tokens)
    end

    file:close()

    return {}
end

return M
