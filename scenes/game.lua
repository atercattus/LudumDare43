local fontName = fontName

local display = display
local ipairs = ipairs
local pairs = pairs

local getTimer = system.getTimer

local composer = require("composer")
local graphics = require("graphics")
local widget = require("widget")

local transitionTo = transition.to

local ui_utils = require("libs.ui_utils")
local tableMouseScroller = ui_utils.tableMouseScroller

local farmBuilder = require("builders.farm")
local shopBuilder = require("builders.shop")

local configEpoches = require("data.config").epoches

local newGameState = require("state").newGameState

local scene = composer.newScene()

-- ===========================================================================================

function scene:getChipFrame(chipIdx)
    if chipIdx <= 9 then -- CPU
        return chipIdx
    elseif chipIdx < 19 then -- GPU
        return chipIdx + 1 * (-9 + 16)
    else -- ASIC
        return chipIdx + 2 * (-9 + 16)
    end

    return chipIdx
end

function scene:loadResources()
    --self.chipsCount = 16*4
    local options = {
        width = 64,
        height = 64,
        numFrames = 16 * 4,
    }
    self.chipsImageSheet = graphics.newImageSheet("data/chips.png", options)

    local options = {
        width = 64,
        height = 64,
        numFrames = 2,
    }
    self.turboButtonImageSheet = graphics.newImageSheet("data/turbo.png", options)
end

function scene:setup()
    local W, H = display.contentWidth, display.contentHeight

    local objects = {}
    self.objects = objects

    self.farmRowHeight = 130

    local txtCoins = display.newText({ text = '', width = W, font = fontName, fontSize = 32, align = 'left' })
    txtCoins:setFillColor(1, 1, 0.4)
    txtCoins.anchorX = 0
    txtCoins.anchorY = 0
    txtCoins.x = 5
    txtCoins.y = 0
    self.view:insert(txtCoins)
    objects.txtCoins = txtCoins

    local txtExchange = display.newText({ text = '', width = W, font = fontName, fontSize = 32, align = 'center' })
    txtExchange:setFillColor(1, 1, 0.4)
    txtExchange.anchorX = 0
    txtExchange.anchorY = 0
    txtExchange.x = 0
    txtExchange.y = 0
    self.view:insert(txtExchange)
    objects.txtExchange = txtExchange

    local txtHashPerSec = display.newText({ text = '', width = W - 5, font = fontName, fontSize = 32, align = 'right' })
    txtHashPerSec:setFillColor(1, 1, 0.4)
    txtHashPerSec.anchorX = 0
    txtHashPerSec.anchorY = 0
    txtHashPerSec.x = 1
    txtHashPerSec.y = 0
    self.view:insert(txtHashPerSec)
    objects.txtHashPerSec = txtHashPerSec

    scene:setupFarmTableAndTitle()
    scene:setupShopTableAndTitle()

    local bgLooser = display.newRect(self.view, 0, 0, W, H)
    bgLooser.anchorX = 0
    bgLooser.anchorY = 0
    bgLooser:setFillColor(0, 0, 0, 0.5)
    objects.bgLooser = bgLooser
    bgLooser.isVisible = false

    local txtLooser = display.newText({ text = 'You are short of money\nclick to repeat', width = W, font = fontName, fontSize = 80, align = 'center' })
    txtLooser:setFillColor(1, 0.2, 0.2)
    txtLooser.anchorX = 0.5
    txtLooser.anchorY = 0.5
    txtLooser.x = W / 2
    txtLooser.y = H / 2
    self.view:insert(txtLooser)
    objects.txtLooser = txtLooser
    txtLooser.isVisible = false

    bgLooser:addEventListener('touch', function(event)
        if event.phase == 'began' then
            print('restart')
            composer.gotoScene('scenes.menu')
        end
        return true
    end)
end

function scene:setupFarmTableAndTitle()
    local W, H = display.contentWidth, display.contentHeight

    local farmPercentWidth = 60

    local function onFarmRowRender(event)
        farmBuilder.createRow(scene, event.row)
    end

    local farmTopY = 100
    local tblFarm = widget.newTableView({
        width = W * (farmPercentWidth / 100),
        height = H - farmTopY - 5,
        isBounceEnabled = false,
        onRowRender = onFarmRowRender,
    })
    tblFarm.x = 5
    tblFarm.y = farmTopY
    tblFarm.anchorX = 0
    tblFarm.anchorY = 0
    tblFarm.noLines = true

    local bg = display.newRect(tblFarm, 0, -tblFarm.height / 2, tblFarm.width, tblFarm.height)
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.3, 0.3, 0.3)
    tblFarm:insert(bg)

    local tblfarmScroller = tableMouseScroller(self.farmRowHeight)
    tblFarm:addEventListener("mouse", function(event) tblfarmScroller(event) end)

    self.view:insert(tblFarm)
    scene.objects.tblFarm = tblFarm

    local txtFarm = display.newText({ text = "Farm", width = W, font = fontName, fontSize = 40, align = 'left' })
    txtFarm:setFillColor(1, 1, 1)
    txtFarm.anchorX = 0
    txtFarm.anchorY = 0
    txtFarm.x = 10
    txtFarm.y = 50
    self.view:insert(txtFarm)
    scene.objects.txtFarm = txtFarm

    local txtElecBill = display.newText({ text = '', width = W, font = fontName, fontSize = 28, align = 'right' })
    txtElecBill:setFillColor(0.8, 1, 1)
    txtElecBill.anchorX = 1
    txtElecBill.anchorY = 1
    txtElecBill.x = tblFarm.contentBounds.xMax - 5
    txtElecBill.y = tblFarm.contentBounds.yMin - 5
    self.view:insert(txtElecBill)
    scene.objects.txtElecBill = txtElecBill
end

function scene:setupShopTableAndTitle()
    local W, H = display.contentWidth, display.contentHeight

    local rowHeight = 100

    local function onRowRender(event)
        shopBuilder.createRow(scene, event.row)
    end

    local function onRowTouch(event)
        if event.phase ~= 'tap' then
            return
        end
        scene:buy(event.target.index)
    end

    local shopTopY = 100
    local tblShop = widget.newTableView({
        width = W - self.objects.tblFarm.width - 25,
        height = H - shopTopY - 5,
        isBounceEnabled = false,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
    })
    tblShop.x = self.objects.tblFarm.contentBounds.xMax + 15
    tblShop.y = shopTopY
    tblShop.anchorX = 0
    tblShop.anchorY = 0
    tblShop.noLines = true

    local bg = display.newRect(tblShop, 0, -tblShop.height / 2, tblShop.width, tblShop.height)
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.3, 0.3, 0.3)
    tblShop:insert(bg)

    local tblfarmScroller = tableMouseScroller(rowHeight)
    tblShop:addEventListener("mouse", function(event) tblfarmScroller(event) end)

    self.view:insert(tblShop)
    self.objects.tblShop = tblShop
    self:buildShop()

    local txtShop = display.newText({ text = "Shop", width = W, font = fontName, fontSize = 40, align = 'left' })
    txtShop:setFillColor(1, 1, 1)
    txtShop.anchorX = 0
    txtShop.anchorY = 0
    txtShop.x = tblShop.x + 10
    txtShop.y = 50
    self.view:insert(txtShop)
    self.objects.txtShop = txtShop

    self:setupShopTableAndTitle_multipliers()
    self:setupShopTableAndTitle_chipTypeTabs()
end

function scene:setupShopTableAndTitle_multipliers()
    local tblShop = self.objects.tblShop

    local offsets = { [0] = 0, [1] = 65, [2] = 150 }

    self.objects.txtBuyMultipliers = {}

    local function onMultChanged(mult)
        if scene.gameState:setBuyMultiplier(mult) then
            scene:updateTxtBuyMultiplier()
            scene:updateShop()
        end
    end

    for multIdx = 0, 2 do
        local mult = 10 ^ multIdx

        local txtMult = display.newText({ text = 'x' .. mult, width = tblShop.width, font = fontName, fontSize = 36, align = 'left' })
        txtMult:setFillColor(0.5, 0.5, 0.5)
        txtMult.anchorX = 0
        txtMult.anchorY = 0
        txtMult.x = tblShop.x + 370 + offsets[multIdx]
        txtMult.y = 50
        self.view:insert(txtMult)
        self.objects.txtBuyMultipliers[mult] = txtMult

        txtMult:addEventListener('touch', function(event)
            if event.phase == 'began' then
                onMultChanged(mult)
            end
            return true
        end)
    end

    scene:updateTxtBuyMultiplier()
end

function scene:setupShopTableAndTitle_chipTypeTabs()
    local iconSize = 54

    self.objects.iconChipTypes = {}
    self.objects.iconBgChipTypes = {}

    for _, chipTypeIdx in pairs(configEpoches) do
        local iconBg = display.newRect(0, 0, iconSize + 4, iconSize + 4)
        if self.gameState.shopChipType == chipTypeIdx then
            iconBg:setFillColor(0.9, 0.9, 0.9)
        else
            iconBg:setFillColor(0, 0, 0)
        end

        iconBg.x = self.objects.txtShop.x + 100 + (chipTypeIdx - 1) * (iconSize + 2 + 4)
        iconBg.y = 42
        iconBg.anchorX = 0
        iconBg.anchorY = 0

        local icon = display.newRect(0, 0, iconSize, iconSize)
        local fidx = { [configEpoches.cpu] = 1, [configEpoches.gpu] = 10, [configEpoches.asic] = 19 }
        icon.fill = { type = "image", sheet = self.chipsImageSheet, frame = self:getChipFrame(fidx[chipTypeIdx]) }
        icon.x = iconBg.x + 2
        icon.y = iconBg.y + 2
        icon.anchorX = 0
        icon.anchorY = 0

        self.view:insert(iconBg)
        self.view:insert(icon)
        self.objects.iconChipTypes[chipTypeIdx] = icon
        self.objects.iconBgChipTypes[chipTypeIdx] = iconBg

        if self.gameState.epoch < chipTypeIdx then
            icon.isVisible = false
        end

        icon:addEventListener('touch', function(event)
            if event.phase ~= 'began' then
            elseif self.gameState.shopChipType == chipTypeIdx then
            else
                self.objects.iconBgChipTypes[self.gameState.shopChipType]:setFillColor(0, 0, 0)
                self.objects.iconBgChipTypes[chipTypeIdx]:setFillColor(0.9, 0.9, 0.9)

                if scene.gameState:switchShopType(chipTypeIdx) then
                    scene.objects.tblShop:deleteAllRows()
                    scene:buildShop()
                end
            end
            return true
        end)
    end
end

function scene:updateShopChipTypeTabs()
    local epoch = self.gameState.epoch

    for _, chipTypeIdx in pairs(configEpoches) do
        if epoch < chipTypeIdx then
            -- skip
        elseif not self.objects.iconChipTypes[chipTypeIdx].isVisible then
            self.objects.iconChipTypes[chipTypeIdx].isVisible = true
        end
    end
end

function scene:buildShop()
    local list = scene.gameState:getAllowedShopList()

    for _, chip in pairs(list) do
        scene.objects.tblShop:insertRow({
            rowHeight = 100,
            params = {
                idx = chip.idx,
            },
        })
    end
end

function scene:updateTxtCoins()
    local state = self.gameState
    self.objects.txtCoins.text = 'LudumCoins: ' .. ui_utils.formatWithSiffix(state.coins)
end

function scene:updateTxtExchange()
    local state = self.gameState
    self.objects.txtExchange.text = '(mining ' .. ui_utils.format_H(state.xchg) .. ' for +1 LC)'
end

function scene:updateTxtOutput()
    local state = self.gameState
    self.objects.txtHashPerSec.text = ui_utils.format_H(state.outputTotal) .. ' (' .. ui_utils.format_Hsec(state.output) .. ')'
end

function scene:updateTxtElecBill()
    local state = self.gameState
    self.objects.txtElecBill.text = 'Costs ' .. ui_utils.format_Wsec(state.consumption) .. ': -' .. ui_utils.format_LCsec(state.consumptionCost)
end

function scene:updateTxtBuyMultiplier()
    local state = self.gameState

    for mult, txt in pairs(self.objects.txtBuyMultipliers) do
        local isActive = mult == state.buyMultiplier
        local color = isActive and 1 or 0.5
        txt:setFillColor(color, color, color)
    end
end

function scene:buy(idx)
    local shopRow = self.objects.tblShop:getRowAtIndex(idx)
    if shopRow == nil then
        print('WTF wrong buy idx' .. idx)
        return
    end

    if self.gameState:tryToBuy(shopRow.params.idx) then
        -- удалось
        self:updateTxtCoins()
        self:updateFarm()
        self:updateShop()
    else
        -- не удалось
    end
end

function scene:buyOrThrowOutChip(idx, count)
    local needToUpdate = false

    if count > 0 then
        needToUpdate = self.gameState:tryToBuy(idx, count)
    elseif count < 0 then
        needToUpdate = self.gameState:tryToThrowOut(idx, -count)
    end

    if needToUpdate then
        self:updateTxtCoins()
        self:updateFarm()
        self:updateShop()
    end
end

function scene:updateFarm()
    local tblFarm = self.objects.tblFarm
    local chipsList = self.gameState.chipsList

    local chipIdx2TblRow = {}
    for i = 1, tblFarm:getNumRows() do
        local row = tblFarm:getRowAtIndex(i)
        chipIdx2TblRow[row.params.idx] = i
    end

    for _, chips in ipairs(chipsList) do
        local tblRowIdx = chipIdx2TblRow[chips.idx]
        if tblRowIdx ~= nil then
            -- такая строка уже есть, нужно пересчитать
            local tblFarmRow = tblFarm:getRowAtIndex(tblRowIdx)
            farmBuilder.updateByState(self, tblFarmRow)
        else
            -- появилась новая строка
            self.objects.tblFarm:insertRow({
                rowHeight = self.farmRowHeight,
                params = {
                    idx = chips.idx,
                },
            })

            -- Строки добавляются в конец, т.к. что я знаю номер новой
            chipIdx2TblRow[chips.idx] = self.objects.tblFarm:getNumRows()
        end
    end

    -- удаление строк
    local needToReload = false
    for chipIdx, rowIdx in pairs(chipIdx2TblRow) do
        local found = false
        for _, chips in ipairs(chipsList) do
            if chips.idx == chipIdx then
                found = true
                break
            end
        end

        if not found then
            needToReload = true
            break
        end
    end

    if needToReload then
        -- Из-за бага в Короне после удаления строк ломается их индексация.
        -- Так что приходится перезагружать все заново
        self.objects.tblFarm:deleteAllRows()
        self:updateFarm() -- Рекурсия!
    end
end

function scene:updateShop()
    local tblShop = self.objects.tblShop
    for i = 1, tblShop:getNumRows() do
        local row = tblShop:getRowAtIndex(i)
        shopBuilder.updateByState(self, row)
    end
end

function scene:updateCounters()
    local now = getTimer()
    local shortInfo = self.gameState:processingTick((now - self.updateCountersDt) / 1000)
    self.updateCountersDt = now

    if shortInfo.changedCoins then
        self:updateTxtCoins()
        if self.gameState.coins <= 0 then
            -- проигрыш
            self.objects.tblFarm:deleteAllRows()
            self.gameState:clearChipsList()

            self.objects.bgLooser.isVisible = true
            self.objects.txtLooser.isVisible = true
            return
        end
        if self.gameState:tryToOpenNewChipType() then
            self:updateShopChipTypeTabs()
        end
    end

    if shortInfo.changedOutput then
        self:updateTxtOutput()
    end

    if shortInfo.changedXchg then
        self:updateTxtExchange()
    end

    if shortInfo.changedConsumption then
        self:updateTxtElecBill()
    end

    if shortInfo.changedShopList then
        scene.objects.tblShop:deleteAllRows()
        scene:buildShop()
    else
        self:updateShop()
    end

    if shortInfo.changedFarm then
        self:updateFarm()
    end
end

scene:addEventListener("show", function(event)
    if (event.phase == "will") then
        scene.gameState = newGameState()

        Runtime:addEventListener('key', function(event)
            if event.phase ~= 'down' then
                return false
            elseif event.keyName == 'f5' then
                scene.gameState.coins = scene.gameState.coins + 1000

                scene:updateTxtCoins()
                if scene.gameState:tryToOpenNewChipType() then
                    scene:updateShopChipTypeTabs()
                end
            elseif event.keyName == 'f6' then
                scene.gameState.coins = scene.gameState.coins + 10 * 1000 * 1000

                scene:updateTxtCoins()
                if scene.gameState:tryToOpenNewChipType() then
                    scene:updateShopChipTypeTabs()
                end
            elseif event.keyName == 'f7' then
                scene.gameState.coins = -1000
                scene:updateTxtCoins()
            end
        end)

        scene:loadResources()
        scene:setup()
        scene:updateTxtOutput()
        scene:updateTxtCoins()
        scene:updateTxtExchange()
        scene:updateTxtElecBill()

        scene.updateCountersDt = getTimer()
        scene.updateCountersTimer = timer.performWithDelay(150, function() scene:updateCounters() end, 0)
    end
end)

scene:addEventListener("hide", function(event)
    timer.cancel(scene.updateCountersTimer)
end)

return scene
