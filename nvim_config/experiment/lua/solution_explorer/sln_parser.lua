local M = {}

local NodeType = {
    Folder = 0,
    DotNetCore = 1,

    Unknown = -1
}

local function get_project_type_from_guid(guid)
    if guid == nil then
        return NodeType["Unknown"]
    end

    local guid_to_type = {
        ["9A19103F-16F7-4668-BE54-9A1E7A4F7556"] = NodeType["DotNetCore"],
        ["2150E333-8FDC-42A3-9474-1A3956D46DE8"] = NodeType["Folder"],
    }

    local normalized_guid = guid:upper()

    return guid_to_type[normalized_guid]
end

function M.tokenize_file(filePath)
    local projects = {}

    local folders = {}
    local project_tree = {}

    -- Open the .sln file for reading
    local file = io.open(filePath, "r")
    if not file then
        print("Could not open file: " .. filePath)
        return
    end

    -- Read the file line by line
    for line in file:lines() do
        local tokens = tokenize(line)
        common.print_table(tokens)

        -- Match project lines
        local project_type, project_name, project_path, project_guid =
            line:match('Project%("{(.*)%}"%) = "(.*)", "(.*)", "%{(.*)%}"')

        if project_type and project_name and project_path and project_guid then
            table.insert(projects, {
                type = project_type,
                name = project_name,
                path = project_path,
                guid = project_guid,
            })
        end

        -- -- Match folder lines
        local folder_guid = line:match('ProjectSection%("SolutionItems"%)%s*=%s*preProject%s*{([^}]+)}')
        if folder_guid then
            table.insert(folders, folder_guid)
        end
    end

    -- Close the file after reading
    file:close()

    -- Create the tree structure combining projects and folders
    for _, project in ipairs(projects) do
        local node = {
            name = project.name,
            path = project.path,
            guid = project.guid,
            type = get_project_type_from_guid(project.type),
            typeId = project.type,
        }

        table.insert(project_tree, node)
    end

    for _, folder in ipairs(folders) do
        table.insert(project_tree, {
            name = "Solution Folder",
            guid = folder,
        })
    end

    -- common.print_table(project_tree)
    return project_tree
end

return M
