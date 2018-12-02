local gameName = gameName
local fontName = fontName

local display = display

local composer = require("composer")

local scene = composer.newScene()

-- ===========================================================================================

function scene:create(event)
    local W, H = display.contentWidth, display.contentHeight
    local sceneGroup = self.view

    local bg = display.newRect(sceneGroup, 0, 0, W, H)
    bg.anchorX = 0
    bg.anchorY = 0
    bg:setFillColor(0, 0, 0)

    local titleText = display.newText({ text = gameName, width = W, font = fontName, fontSize = 98, align = 'center' })
    sceneGroup:insert(titleText)
    titleText:setFillColor(1, 1, 0.4)
    titleText.anchorX = 0.5
    titleText.anchorY = 0
    titleText.x = W / 2
    titleText.y = 10

    local descr = 'Build you own mining farm!'
    local descrText = display.newText({ text = descr, width = W, font = fontName, fontSize = 50, align = 'center' })
    sceneGroup:insert(descrText)
    descrText:setFillColor(1, 1, 1)
    descrText.anchorX = 0.5
    descrText.anchorY = 0.5
    descrText.x = W / 2
    descrText.y = H / 2 - 50

    local descr = 'Electricity is not free.'
    local descrText = display.newText({ text = descr, width = W, font = fontName, fontSize = 40, align = 'center' })
    sceneGroup:insert(descrText)
    descrText:setFillColor(0.8, 0.8, 0.8)
    descrText.anchorX = 0.5
    descrText.anchorY = 0.5
    descrText.x = W / 2
    descrText.y = H / 2 + 100

    bg:addEventListener("touch", function(event)
        if event.phase == 'began' then
            composer.gotoScene('scenes.game')
        end
        return true
    end)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", function()
    composer.removeHidden() -- Выгружаю сцену с фермой
end)

return scene
