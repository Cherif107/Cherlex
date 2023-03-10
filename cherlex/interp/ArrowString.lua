local util = require 'cherlex.util.StringUtil'
---@class ArrowString yes
local ArrowString = function(text, pos_start, pos_end)
    local result = ''

    local idx_start = math.max(util.rfind(text, '\n', 0, pos_start.idx), 1)
    local idx_end = text:find('\n', idx_start+1) or 0
    if idx_end < 1 then
        idx_end = #text
    end

    local line_count = pos_end.ln-pos_start.ln+1
    for i = 1, line_count do
        local line = text:sub(idx_start, idx_end)
        local col_start = (i == 1 and pos_start.col or 0)
        local col_end = ((i == line_count) and pos_end.col or #line-1)
        
        result = result..line..'\n'
        result = result..string.rep(' ', col_start-1)..string.rep('^', col_end-col_start)

        idx_start = idx_end
        idx_end = text:find('\n', idx_start+1) or 0
        if idx_end < 1 then idx_end = #text end
    end
    return result:gsub('\t', '')
end
return ArrowString