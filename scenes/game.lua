--local gameName = gameName
local fontName = fontName

local display = display
local require = require
local math = math

local composer = require("composer")
local graphics = require("graphics")
local widget = require("widget")

local mathRandom = math.random

local ui_utils = require("libs.ui_utils")
local tableMouseScroller = ui_utils.tableMouseScroller

--local utils = require("libs.utils")
--local mathSign = utils.sign

local farmBuilder = require("builders.farm")
local shopBuilder = require("builders.shop")

local newGameState = require("state").newGameState

local scene = composer.newScene()

-- ===========================================================================================

function scene:loadResources()
    self.chipsCount = 4
    local options = {
        width = 64,
        height = 64,
        numFrames = self.chipsCount,
    }
    self.chipsImageSheet = graphics.newImageSheet("data/chips.png", options)
end

function scene:setup()
    local W, H = display.contentWidth, display.contentHeight

    local objects = {}
    scene.objects = objects

    local txtCoins = display.newText({ text = '', width = W, font = fontName, fontSize = 32, align = 'left' })
    txtCoins:setFillColor(1, 1, 0.4)
    txtCoins.anchorX = 0
    txtCoins.anchorY = 0
    txtCoins.x = 5
    txtCoins.y = 0
    self.view:insert(txtCoins)
    objects.txtCoins = txtCoins

    local txtExchange = display.newText({ text = '', width = W - 5, font = fontName, fontSize = 32, align = 'right' })
    txtExchange:setFillColor(1, 1, 0.4)
    txtExchange.anchorX = 0
    txtExchange.anchorY = 0
    txtExchange.x = 0
    txtExchange.y = 0
    self.view:insert(txtExchange)
    objects.txtExchange = txtExchange

    local txtHashPerSec = display.newText({ text = '', width = W, font = fontName, fontSize = 32, align = 'center' })
    txtHashPerSec:setFillColor(1, 1, 0.4)
    txtHashPerSec.anchorX = 0
    txtHashPerSec.anchorY = 0
    txtHashPerSec.x = 0
    txtHashPerSec.y = 0
    self.view:insert(txtHashPerSec)
    objects.txtHashPerSec = txtHashPerSec

    scene:setupFarmTableAndTitle()
    scene:setupShopTableAndTitle()
end

function scene:setupFarmTableAndTitle()
    local W, H = display.contentWidth, display.contentHeight

    local farmPercentWidth = 60
    local farmRowHeight = 100

    local function onFarmRowRender(event)
        farmBuilder.createRow(scene, event.row)
    end

    local tblFarm = widget.newTableView({
        width = W * (farmPercentWidth / 100),
        height = H - farmRowHeight - 5,
        isBounceEnabled = false,
        onRowRender = onFarmRowRender,
    })
    tblFarm.x = 5
    tblFarm.y = 100
    tblFarm.anchorX = 0
    tblFarm.anchorY = 0
    tblFarm.noLines = true

    local bg = display.newRect(tblFarm, 0, -tblFarm.height / 2, tblFarm.width, tblFarm.height)
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0.3, 0.3, 0.3)
    tblFarm:insert(bg)

    local tblfarmScroller = tableMouseScroller(farmRowHeight)
    tblFarm:addEventListener("mouse", function(event) tblfarmScroller(event) end)

    self.view:insert(tblFarm)
    scene.objects.tblFarm = tblFarm
    --    for i = 1, 20 do
    --        tblFarm:insertRow({
    --            rowHeight = 100,
    --            rowColor = { 0, 0, 0, 1 },
    --            lineColor = { 0, 0, 0, 1 },
    --        })
    --    end

    local txtFarm = display.newText({ text = "Farm", width = W, font = fontName, fontSize = 40, align = 'left' })
    txtFarm:setFillColor(1, 1, 1)
    txtFarm.anchorX = 0
    txtFarm.anchorY = 0
    txtFarm.x = 10
    txtFarm.y = 50
    self.view:insert(txtFarm)
    scene.objects.txtFarm = txtFarm

    local txtElecBill = display.newText({ text = "Total 2000 W/sec: -0.1 LC/sec", width = W, font = fontName, fontSize = 28, align = 'right' })
    txtElecBill:setFillColor(0.8, 1, 1)
    txtElecBill.anchorX = 1
    txtElecBill.anchorY = 1
    txtElecBill.x = tblFarm.contentBounds.xMax
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

    local tblShop = widget.newTableView({
        width = W - scene.objects.tblFarm.width - 25,
        height = H - rowHeight - 5,
        isBounceEnabled = false,
        onRowRender = onRowRender,
    })
    tblShop.x = scene.objects.tblFarm.contentBounds.xMax + 15
    tblShop.y = 100
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
    scene.objects.tblShop = tblShop
    scene:buildShop()
    --    for i = 1, 3 do
    --        tblShop:insertRow({
    --            rowHeight = 100,
    --            rowColor = { 0, 0, 0, 1 },
    --            lineColor = { 0, 0, 0, 1 },
    --        })
    --    end

    local txtShop = display.newText({ text = "Shop", width = W, font = fontName, fontSize = 40, align = 'left' })
    txtShop:setFillColor(1, 1, 1)
    txtShop.anchorX = 0
    txtShop.anchorY = 0
    txtShop.x = tblShop.x + 10
    txtShop.y = 50
    self.view:insert(txtShop)
    scene.objects.txtShop = txtShop
end

function scene:buildShop()
    local list = scene.gameState:getAllowedShopList()

    for _, chip in pairs(list) do
        scene.objects.tblShop:insertRow({
            rowHeight = 100,
            --rowColor = { 0, 0, 0, 1 },
            --lineColor = { 0, 0, 0, 1 },
            params = {
                idx = chip.idx,
            },
        })
    end
end

function scene:updateTxtCoins()
    ui_utils.updateTxtWithSiffix(self.objects.txtCoins, scene.gameState.coins, '', 'LudumCoins: ')
end

function scene:updateTxtOutput()
    ui_utils.updateTxtWithSiffix(self.objects.txtHashPerSec, scene.gameState.output, 'h/sec')
end

function scene:updateTxtExchange()
    ui_utils.updateTxtWithSiffix(self.objects.txtExchange, scene.gameState.xchg, 'h/LC', 'xchg: ')
end

scene:addEventListener("show", function(event)
    if (event.phase == "will") then
        scene.gameState = newGameState()

        scene:loadResources()
        scene:setup()
        scene:updateTxtCoins()
        scene:updateTxtOutput()
        scene:updateTxtExchange()
    end
end)

return scene
