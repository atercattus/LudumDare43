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

function M.updateTxt_Wsec(txt, value)
    M.updateTxtWithSiffix(txt, value, ' W/s')
end

function M.updateTxt_Hsec(txt, value)
    M.updateTxtWithSiffix(txt, value, ' H/s')
end

function M.updateTxt_cost(txt, value)
    M.updateTxtWithSiffix(txt, value, 'LC')
end

function M.updateTxtWithSiffix(txt, value, suffix, prefix)
    if value >= 1 then
        local pow = floor(log10(value) / 3)

        if pow > 0 then
            if pow > #powers then
                pow = #powers
            end

            local delim = 10 ^ (3 * pow)
            value = round(value / delim, 2)
            suffix = powers[pow] .. suffix
        end
    end

    txt.text = (prefix or '') .. value .. suffix
end

return M
