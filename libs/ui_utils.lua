local M = {}

local log10 = math.log10
local floor = math.floor

local utils = require("libs.utils")
local round = utils.round

local powers = { 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' }

function M.tableMouseScroller(rowHeight)
    return function(event)
        local tbl = event.target
        if event.scrollY ~= 0 then
            local y = tbl:getContentPosition() - event.scrollY
            local contHeight = tbl:getNumRows() * rowHeight
            if contHeight <= tbl.height then
                return
            end
            local minY = tbl.height - contHeight
            if y < minY then
                y = minY
            elseif y > 0 then
                y = 0
            end
            tbl:scrollToY({ y = y, time = 50 })
        end
    end
end

function M.format_Wsec(value)
    return M.formatWithSiffix(value, ' W/s')
end

function M.format_Hsec(value)
    return M.formatWithSiffix(value, ' h/s')
end

function M.format_H(value)
    return M.formatWithSiffix(value, ' h')
end

function M.format_cost(value)
    return M.formatWithSiffix(value, 'LC')
end

function M.format_count(value)
    return M.formatWithSiffix(value, 'pcs')
end

function M.formatWithSiffix(value, suffix)
    suffix = suffix or ''

    if value >= 1 then
        local pow = floor(log10(value) / 3)

        if pow > 0 then
            if pow > #powers then
                pow = #powers
            end

            local delim = 10 ^ (3 * pow)
            value = value / delim
            suffix = powers[pow] .. suffix
        end
    end

    value = (value < 100) and round(value, 2) or round(value, 0)

    return value .. suffix
end

return M
