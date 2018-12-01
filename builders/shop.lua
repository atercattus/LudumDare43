local fontName = fontName

local display = display
local require = require
local math = math

local mathRandom = math.random

local M = {}

function M.createRow(scene, farm, parentRow)
    local rowHeight = parentRow.contentHeight
    local rowWidth = parentRow.contentWidth
    local rowIdx = parentRow.index

    local bg = display.newRect(parentRow, 0, 0, rowWidth, rowHeight)
    parentRow.bg = bg
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(mathRandom(1000) / 1000, mathRandom(1000) / 1000, mathRandom(1000) / 1000)
    parentRow:insert(bg)

    local posX = 5

    local iconSize = 64
    local icon = display.newRect(0, 0, iconSize, iconSize)
    parentRow:insert(icon)
    local chipIdx = rowIdx
    if chipIdx > 3 then
        chipIdx = (chipIdx % 3) + 1
    end
    icon.fill = { type = "image", sheet = scene.chipsImageSheet, frame = chipIdx }
    icon.x = posX
    icon.y = 5 + rowHeight / 2
    icon.anchorX = 0
    icon.anchorY = 0.5
    posX = posX + iconSize + 10

    local textHeight = 30
    local chipName = "Outel Kernel j" .. rowIdx
    local rowTitle = display.newText({ parent = parentRow, text = chipName, font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor({ 1, 1, 1 })
    rowTitle.anchorX = 0
    rowTitle.x = posX
    rowTitle.y = rowHeight - 10
    rowTitle.anchorY = 1

    local chipName = (42 * rowIdx) .. " Mh/sec"
    local rowTitle = display.newText({ parent = parentRow, text = chipName, font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor({ 1, 1, 1 })
    rowTitle.anchorX = 0
    rowTitle.x = posX
    rowTitle.y = 10
    rowTitle.anchorY = 0

    local chipName = (60 * rowIdx) .. " W/sec"
    local rowTitle = display.newText({ parent = parentRow, text = chipName, font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor({ 1, 1, 1 })
    rowTitle.anchorX = 0
    rowTitle.x = posX + 250
    rowTitle.y = 10
    rowTitle.anchorY = 0

    local rowTitle = display.newText({ parent = parentRow, text = "BUY", font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor({ 1, 1, 1 })
    rowTitle.anchorX = 0
    rowTitle.x = rowWidth - 10
    rowTitle.y = 10
    rowTitle.anchorY = 0
    rowTitle.anchorX = 1
end

return M
