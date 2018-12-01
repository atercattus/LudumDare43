local fontName = fontName

local display = display
local require = require
local math = math
local unpack = unpack

local mathRandom = math.random

local config = require("data.config")
--local epoches = config.epoches
--local chips = config.chips

local ui_utils = require("libs.ui_utils")

local M = {}

function M.createRow(scene, parentRow)
    local rowHeight = parentRow.contentHeight
    local rowWidth = parentRow.contentWidth
    local rowIdx = parentRow.index

    parentRow.objects = {}

    local bg0 = display.newRect(parentRow, 0, 0, rowWidth, rowHeight)
    bg0.anchorX = 0
    bg0.anchorY = 0
    bg0:setFillColor(0, 0, 0)
    parentRow:insert(bg0)

    local bg = display.newRect(parentRow, 0, 0, rowWidth, rowHeight - 4)
    parentRow.bg = bg
    parentRow.objects.bg = bg
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.8, 0.8, 0.7)
    parentRow:insert(bg)

    local posX = 5

    local iconSize = 64
    local icon = display.newRect(0, 0, iconSize, iconSize)
    parentRow:insert(icon)
    parentRow.objects.icon = icon
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
    --local chipName = "Outel Kernel j" .. rowIdx
    local rowTitle = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtName = rowTitle
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = posX
    rowTitle.y = rowHeight - 10
    rowTitle.anchorY = 1

    local rowTitle = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtOutput = rowTitle
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = posX
    rowTitle.y = 10
    rowTitle.anchorY = 0

    local rowTitle = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtConsumption = rowTitle
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = posX + 250
    rowTitle.y = 10
    rowTitle.anchorY = 0

    local rowTitle = display.newText({ parent = parentRow, text = 'BUY', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtBuy = rowTitle
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = rowWidth - 10
    rowTitle.y = 10
    rowTitle.anchorY = 0
    rowTitle.anchorX = 1

    local rowTitle = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtCost = rowTitle
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = rowWidth - 10
    rowTitle.anchorX = 1
    rowTitle.anchorY = 1
    rowTitle.y = rowHeight - 10

    local chipInfo = config.chips[parentRow.params.idx]

    M.updateByState(scene, parentRow, chipInfo)
end

function M.updateByState(scene, row, chipInfo)
    local gameState = scene.gameState

    row.objects.icon.fill.frame = chipInfo.epoch

    row.objects.txtName.text = chipInfo.name
    ui_utils.updateTxt_Hsec(row.objects.txtOutput, chipInfo.output)
    ui_utils.updateTxt_Wsec(row.objects.txtConsumption, chipInfo.output)
    ui_utils.updateTxt_cost(row.objects.txtCost, chipInfo.cost)

    local isMoneyEnough = gameState.coins >= chipInfo.cost

    local buyCostColor = isMoneyEnough and { 0, 0.7, 0 } or { 0.8, 0, 0 }
    row.objects.txtCost:setFillColor(unpack(buyCostColor))

    local buyColor = isMoneyEnough and { 0, 0.7, 0 } or { 0.7, 0.7, 0.7 }
    row.objects.txtBuy:setFillColor(unpack(buyColor))

    local bgColor = isMoneyEnough and { 0.9, 0.9, 0.9 } or { 0.6, 0.6, 0.6 }
    row.objects.bg:setFillColor(unpack(bgColor))
end

return M
