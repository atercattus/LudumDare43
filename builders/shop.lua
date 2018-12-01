local fontName = fontName

local display = display
local require = require
local math = math
local unpack = unpack

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
    parentRow:insert(bg)
    parentRow.objects.bg = bg
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.8, 0.8, 0.7)

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
    local txtName = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtName = txtName
    txtName:setFillColor(0, 0, 0)
    txtName.anchorX = 0
    txtName.x = posX
    txtName.y = rowHeight - 10
    txtName.anchorY = 1

    local txtOutput = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtOutput = txtOutput
    txtOutput:setFillColor(0, 0, 0)
    txtOutput.anchorX = 0
    txtOutput.x = posX
    txtOutput.y = 10
    txtOutput.anchorY = 0

    local txtConsumption = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtConsumption = txtConsumption
    txtConsumption:setFillColor(0, 0, 0)
    txtConsumption.anchorX = 0
    txtConsumption.x = posX + 250
    txtConsumption.y = 10
    txtConsumption.anchorY = 0

    local txtBuy = display.newText({ parent = parentRow, text = 'BUY', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtBuy = txtBuy
    txtBuy:setFillColor(0, 0, 0)
    txtBuy.anchorX = 0
    txtBuy.x = rowWidth - 10
    txtBuy.y = 10
    txtBuy.anchorY = 0
    txtBuy.anchorX = 1

    local txtCost = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight+4, align = 'left' })
    parentRow.objects.txtCost = txtCost
    txtCost:setFillColor(0, 0, 0)
    txtCost.anchorX = 0
    txtCost.x = rowWidth - 10
    txtCost.anchorX = 1
    txtCost.anchorY = 1
    txtCost.y = rowHeight - 10

    M.updateByState(scene, parentRow, parentRow.params.idx)
end

function M.updateByState(scene, row, chipIdx)
    local gameState = scene.gameState

    local chipInfo = config.chips[chipIdx]

    row.objects.icon.fill.frame = chipInfo.epoch

    row.objects.txtName.text = chipInfo.name
    ui_utils.updateTxt_Hsec(row.objects.txtOutput, chipInfo.output)
    ui_utils.updateTxt_Wsec(row.objects.txtConsumption, chipInfo.power_consumption)
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
