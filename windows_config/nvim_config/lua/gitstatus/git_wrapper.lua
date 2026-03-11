local M = {}

local shell = require("gitstatus.shell")

---@param path string
---@param on_update fun(branch_name: string|nil): nil
function M.update_branch(path, on_update)
    shell.run_async("git branch --show-current", path, function(data)
        on_update(data)
    end)
end

---@param path string
---@param on_update fun(lines: gitstatus.FileStatus[]): nil
function M.update_git_status(path, on_update)
    shell.run_async("git status --porcelain", path, function(data)
        ---@type gitstatus.FileStatus[]
        local result = {}

        if data ~= nil then
            local lines = vim.split(data, '\n')

            local temp = vim.tbl_map(function(line)
                if line ~= "" then
                    local status, file_path = line:match("^(..)%s(.+)$")

                    local sep = package.config:sub(1, 1)
                    local full_path = path .. sep .. file_path
                    full_path = full_path:gsub("[/\\]", sep)
                    local current_path = vim.fn.fnamemodify(full_path, ":~:.")

                    ---@type gitstatus.FileStatus
                    return {
                        full_path = full_path,
                        git_path = file_path,
                        relative_cwd_path = current_path,
                        status = status,
                        diffs = {}
                    }
                end

                return nil
            end, lines)


            result = vim.tbl_filter(function(v)
                return v ~= nil
            end, temp)
        end

        for _, file_status in ipairs(result) do
            M.update_git_diff_file(path, file_status.git_path, function(diffs)
                file_status.diffs = diffs

                on_update(result)
            end)
        end

        on_update(result)
    end)
end

---@param path string
---@param file_path string
---@param on_update fun(diffs: gitstatus.Diff[]): nil
function M.update_git_diff_file(path, file_path, on_update)
    shell.run_async("git diff --no-color -- " .. file_path, path, function(data)

        ---@type gitstatus.Diff[]
        local result = {}

        if data ~= nil and #data > 0 then
            -- ignore binary diffs or cases where git reports binary files
            if data:match("Binary files") then
                on_update(result)
                return
            end

            local lines = vim.split(data, "\n")
            local current_hunk = nil

            for _, line in ipairs(lines) do
                -- Hunk header: @@ -a,b +c,d @@ (b or d may be omitted)
                local a, b, c, d = line:match('^@@%s+%-(%d+),?(%d*)%s+%+(%d+),?(%d*)%s+@@')
                if a then
                    local start_old = tonumber(a)
                    local count_old = (b ~= nil and b ~= "") and tonumber(b) or 1
                    local start_new = tonumber(c)
                    local count_new = (d ~= nil and d ~= "") and tonumber(d) or 1

                    current_hunk = {
                        start_old_line = start_old,
                        end_old_line = start_old + (count_old or 1) - 1,
                        start_new_line = start_new,
                        end_new_line = start_new + (count_new or 1) - 1,
                        old_content = {},
                        new_content = {},
                    }

                    table.insert(result, current_hunk)
                else
                    -- If we're inside a hunk, collect lines
                    if current_hunk then
                        local first = line:sub(1, 1)
                        -- Some lines could be empty strings (end of file) — treat them as context if prefixed by space
                        if first == ' ' then
                            -- table.insert(current_hunk.old_content, line:sub(2))
                            -- table.insert(current_hunk.new_content, line:sub(2))
                        elseif first == '-' then
                            table.insert(current_hunk.old_content, line:sub(2))
                        elseif first == '+' then
                            table.insert(current_hunk.new_content, line:sub(2))
                        else
                            -- ignore other lines (diff headers, index, file markers, \ No newline ...)
                            -- handle the '\ No newline at end of file' marker by skipping
                            if line:match('^\\ No newline') then
                                -- do nothing
                            end
                        end
                    end
                end
            end

            -- As a fallback, ensure end_* reflect collected content if counts were absent or mismatched
            for _, h in ipairs(result) do
                if (not h.end_old_line) or h.end_old_line < h.start_old_line then
                    h.end_old_line = h.start_old_line + #h.old_content - 1
                end
                if (not h.end_new_line) or h.end_new_line < h.start_new_line then
                    h.end_new_line = h.start_new_line + #h.new_content - 1
                end
            end

            on_update(result)
        end

        on_update(result)
    end)
end

---@param path string
---@param limit integer
---@param on_update fun(lines: GitCommit[]): nil
function M.update_git_last_commits(path, limit, on_update)
    shell.run_async(
        "git log -n " .. tostring(limit) .. " --pretty=format:\"%h|%an|%ar|%s\"", path, function(data)
            local result = {}

            if data ~= nil and #data > 0 then
                for _, line in ipairs(vim.split(data, '\n')) do
                    local hash, author, date, message = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")

                    if hash then
                        table.insert(result, {
                            hash = hash,
                            author = author,
                            date = date,
                            message = message,
                        })
                    end
                end
            end

            on_update(result)
        end)
end

return M
