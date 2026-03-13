local M = {}

local utf8 = require("utf8")

local function to_codepoints(s)
    local t = {}
    for _, cp in utf8.codes(s) do t[#t + 1] = cp end
    return t
end

-- Builds DP table, returns dp (m+1 x n+1), and length dp[m][n]
local function build_dp(A, B)
    local m, n = #A, #B
    local dp = {}
    for i = 0, m do
        dp[i] = {}
        for j = 0, n do dp[i][j] = 0 end
    end
    for i = 1, m do
        for j = 1, n do
            if A[i] == B[j] then
                dp[i][j] = dp[i - 1][j - 1] + 1
            else
                dp[i][j] = (dp[i - 1][j] >= dp[i][j - 1]) and dp[i - 1][j] or dp[i][j - 1]
            end
        end
    end
    return dp
end

-- Compute LCS, DP table, and produce edit opcodes
-- Returns: lcs_string, length, dp_table, ops (merged)
function M.lcs_with_ops(a, b)
    local A = to_codepoints(a)
    local B = to_codepoints(b)
    local m, n = #A, #B
    if m == 0 then return "", 0, build_dp(A, B), (n > 0 and { { op = "insert", a = "", b = b } } or {}) end
    if n == 0 then return "", 0, build_dp(A, B), (m > 0 and { { op = "delete", a = a, b = "" } } or {}) end

    local dp = build_dp(A, B)

    -- backtrack producing fine-grained ops (per codepoint)
    local i, j = m, n
    local raw = {}
    while i > 0 and j > 0 do
        if A[i] == B[j] then
            raw[#raw + 1] = { op = "equal", a = A[i], b = B[j] }
            i, j = i - 1, j - 1
        elseif dp[i - 1][j] >= dp[i][j - 1] then
            raw[#raw + 1] = { op = "delete", a = A[i] }
            i = i - 1
        else
            raw[#raw + 1] = { op = "insert", b = B[j] }
            j = j - 1
        end
    end
    while i > 0 do
        raw[#raw + 1] = { op = "delete", a = A[i] }; i = i - 1
    end
    while j > 0 do
        raw[#raw + 1] = { op = "insert", b = B[j] }; j = j - 1
    end

    -- reverse raw to forward order and merge consecutive ops into spans
    local ops = {}
    for idx = #raw, 1, -1 do
        local r = raw[idx]
        local last = ops[#ops]
        if last and last.op == r.op then
            if r.op == "equal" then
                last.a[#last.a + 1] = r.a
                last.b[#last.b + 1] = r.b
            elseif r.op == "delete" then
                last.a[#last.a + 1] = r.a
            else -- insert
                last.b[#last.b + 1] = r.b
            end
        else
            if r.op == "equal" then
                ops[#ops + 1] = { op = "equal", a = { r.a }, b = { r.b } }
            elseif r.op == "delete" then
                ops[#ops + 1] = { op = "delete", a = { r.a }, b = {} }
            else
                ops[#ops + 1] = { op = "insert", a = {}, b = { r.b } }
            end
        end
    end

    -- convert codepoint arrays to strings
    for k = 1, #ops do
        ops[k].a = table.concat(ops[k].a)
        ops[k].b = table.concat(ops[k].b)
    end

    -- build LCS string by collecting equal spans
    local lcs_parts = {}
    local lcs_len = dp[m][n]
    for _, op in ipairs(ops) do
        if op.op == "equal" and op.a ~= "" then lcs_parts[#lcs_parts + 1] = op.a end
    end
    local lcs_str = table.concat(lcs_parts)

    return lcs_str, lcs_len, dp, ops
end


return M
