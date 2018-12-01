local M = {}

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

function M.updateTxtWithSiffix(txt, value, siffux)
    txt.text = value .. siffux
end

return M
