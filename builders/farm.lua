local fontName = fontName

local display = display

local abs = math.abs

local ui_utils = require("libs.ui_utils")

local config = require("data.config")

local M = {}

function M.createRow(scene, parentRow)
    local rowHeight = parentRow.contentHeight
    local rowWidth = parentRow.contentWidth

    parentRow.objects = {}

    local bg0 = display.newRect(parentRow, 0, 0, rowWidth, rowHeight)
    bg0.anchorX = 0
    bg0.anchorY = 0
    bg0:setFillColor(0, 0, 0)
    parentRow:insert(bg0)

    local bg = display.newRect(parentRow, 0, 0, rowWidth, rowHeight - 4)
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
    icon.fill = { type = "image", sheet = scene.chipsImageSheet, frame = 1 }
    icon.x = posX
    icon.y = 5
    icon.anchorX = 0
    icon.anchorY = 0
    posX = posX + iconSize + 10

    M.createRow_setupTurboButton(scene, parentRow, icon)

    local textHeight = 30
    local txtName = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight, align = 'left' })
    parentRow.objects.txtName = txtName
    txtName:setFillColor(0, 0, 0)
    txtName.anchorX = 0
    txtName.x = posX
    txtName.y = icon.y + icon.height + 10
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

    local iconChipDelete = display.newRect(0, 0, iconSize, iconSize)
    parentRow:insert(iconChipDelete)
    parentRow.objects.iconChipDelete = iconChipDelete
    iconChipDelete.fill = { type = "image", sheet = scene.plusMinusImageSheet, frame = 1 }
    iconChipDelete.x = posX + 800
    iconChipDelete.y = 10
    iconChipDelete.anchorX = 0
    iconChipDelete.anchorY = 0

    local txtCount = display.newText({ parent = parentRow, text = '', font = fontName, fontSize = textHeight + 2, align = 'left' })
    parentRow.objects.txtCount = txtCount
    txtCount:setFillColor(0, 0, 0)
    txtCount.anchorX = 0
    txtCount.x = posX + 450
    txtCount.y = 20
    txtCount.anchorY = 0

    local iconChipAdd = display.newRect(0, 0, iconSize, iconSize)
    parentRow:insert(iconChipAdd)
    parentRow.objects.iconChipAdd = iconChipAdd
    iconChipAdd.fill = { type = "image", sheet = scene.plusMinusImageSheet, frame = 2 }
    iconChipAdd.x = posX + 700
    iconChipAdd.y = 10
    iconChipAdd.anchorX = 0
    iconChipAdd.anchorY = 0

    local function onChangeCount(event)
        if event.phase ~= 'began' then
            return true
        end

        local count = scene.gameState.buyMultiplier

        if event.target == iconChipAdd then
            -- ok
        elseif event.target == iconChipDelete then
            count = -count
        else
            return
        end

        scene:buyOrThrowOutChip(parentRow.params.idx, count)

        return true
    end

    iconChipAdd:addEventListener('touch', onChangeCount)
    iconChipDelete:addEventListener('touch', onChangeCount)

    M.updateByState(scene, parentRow)
end

function M.createRow_setupTurboButton(scene, parentRow, chipIcon)
    local rowHeight = parentRow.contentHeight
    local rowWidth = parentRow.contentWidth

    local function onTurboClick()
        scene.gameState:turboBoost(parentRow.params.idx)
        parentRow.objects.turboIcon.fill.frame = 2
    end

    local iconSize = 64
    local turboPanelBg = display.newRect(0, 0, rowWidth - (chipIcon.x + iconSize / 2), 36)
    parentRow:insert(turboPanelBg)
    parentRow.objects.turboPanelBg = turboPanelBg
    turboPanelBg.x = chipIcon.x + iconSize / 2
    turboPanelBg.y = rowHeight - 40
    turboPanelBg.anchorX = 0
    turboPanelBg.anchorY = 0

    turboPanelBg:addEventListener("touch", function(event)
        if event.phase == 'began' then
            onTurboClick()
        end
        return true
    end)

    local turboPanel = display.newRect(0, 0, 0, turboPanelBg.height)
    parentRow:insert(turboPanel)
    parentRow.objects.turboPanel = turboPanel
    turboPanel.x = turboPanelBg.x
    turboPanel.y = turboPanelBg.y
    turboPanel.anchorX = 0
    turboPanel.anchorY = 0
    turboPanel:setFillColor(0.8, 0.2, 0.2)

    local textHeight = 30
    local txtTurbo = display.newText({ parent = parentRow, text = "click for Turbo mode!", font = fontName, fontSize = textHeight })
    txtTurbo:setFillColor(0, 0, 0)
    txtTurbo.x = turboPanelBg.x + iconSize / 2
    txtTurbo.y = turboPanelBg.y
    txtTurbo.anchorX = 0
    txtTurbo.anchorY = 0

    local iconSize = 64
    local turboIcon = display.newRect(0, 0, iconSize, iconSize)
    parentRow:insert(turboIcon)
    parentRow.objects.turboIcon = turboIcon
    turboIcon.fill = { type = "image", sheet = scene.turboButtonImageSheet, frame = 1 }
    turboIcon.x = chipIcon.x
    turboIcon.y = rowHeight
    turboIcon.anchorX = 0
    turboIcon.anchorY = 1

    turboIcon:addEventListener("touch", function(event)
        if event.phase == 'began' then
            onTurboClick()
        end
        return true
    end)
end

function M.updateByState(scene, row)
    local gameState = scene.gameState

    local chipIdx = row.params.idx
    local chipInfo = config.chips[chipIdx]
    local shopChipInfo = gameState:getShopChipInfo(chipIdx)

    local turboBoost = shopChipInfo.turboBoost
    if turboBoost > 0 then
        local perc = turboBoost / 100
        local turboWidth = perc * row.objects.turboPanelBg.width
        if abs(turboWidth - row.objects.turboPanel.width) >= 1 then
            row.objects.turboPanel.width = turboWidth
            if perc <= gameState.overheatPercentage / 100 then
                row.objects.turboPanel:setFillColor(0, 1, 0.2)
            else
                row.objects.turboPanel:setFillColor(perc, 1 - perc, 0.2)
            end
        end
    elseif (row.objects.turboIcon.fill.frame == 2) then
        -- Turbo закончился
        row.objects.turboIcon.fill.frame = 1
    end

    row.objects.icon.fill.frame = scene:getChipFrame(chipIdx)
    row.objects.txtName.text = chipInfo.name

    row.objects.txtCount.text = ui_utils.format_count(shopChipInfo.count)

    local boostCount = shopChipInfo:turboBoostCount()

    local hashes = boostCount * chipInfo.output
    row.objects.txtOutput.text = ui_utils.format_Hsec(hashes)

    local watts = shopChipInfo.count * chipInfo.power_consumption -- без boostCount
    row.objects.txtConsumption.text = ui_utils.format_Wsec(watts)
end

return M
