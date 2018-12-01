local fontName = fontName

local display = display

local ui_utils = require("libs.ui_utils")

local config = require("data.config")

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

    local bg = display.newRect(parentRow, 0, 0, rowWidth, rowHeight-4)
    parentRow.bg = bg
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.8, 0.8, 0.8)
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
    local txtName = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtName = txtName
    txtName:setFillColor(0, 0, 0)
    txtName.anchorX = 0
    txtName.x = posX
    txtName.y = rowHeight - 10
    txtName.anchorY = 1

    local txtOutput = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtOutput = txtOutput
    txtOutput:setFillColor(0, 0, 0)
    txtOutput.anchorX = 0
    txtOutput.x = posX
    txtOutput.y = 10
    txtOutput.anchorY = 0

    local txtConsumption = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtConsumption = txtConsumption
    txtConsumption:setFillColor(0, 0, 0)
    txtConsumption.anchorX = 0
    txtConsumption.x = posX + 250
    txtConsumption.y = 10
    txtConsumption.anchorY = 0

    local rowTitle = display.newText({ parent = parentRow, text = "-", font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = posX + 500
    rowTitle.y = 10
    rowTitle.anchorY = 0

    local txtCount = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtCount = txtCount
    txtCount:setFillColor(0, 0, 0)
    txtCount.anchorX = 0
    txtCount.x = posX + 600
    txtCount.y = 10
    txtCount.anchorY = 0

    local rowTitle = display.newText({ parent = parentRow, text = "+", font = fontName, fontSize = textHeight, align = 'left' })
    rowTitle:setFillColor(0, 0, 0)
    rowTitle.anchorX = 0
    rowTitle.x = posX + 800
    rowTitle.y = 10
    rowTitle.anchorY = 0

    M.updateByState(scene, parentRow)
end

function M.updateByState(scene, row)
    local gameState = scene.gameState

    local chipIdx = row.params.idx
    local chipInfo = config.chips[chipIdx]
    local shopChipInfo = gameState:getShopChipInfo(chipIdx)

    row.objects.icon.fill.frame = chipInfo.epoch
    row.objects.txtName.text = chipInfo.name

    row.objects.txtCount.text = ui_utils.format_count(shopChipInfo.count)

    local hashes = shopChipInfo.count * chipInfo.output
    row.objects.txtOutput.text = ui_utils.format_Hsec(hashes)

    local watts = shopChipInfo.count * chipInfo.power_consumption
    row.objects.txtConsumption.text = ui_utils.format_Wsec(watts)
end

return M
