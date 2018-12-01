local appScale = appScale
local gameName = gameName
local fontName = fontName

local display = display

local composer = require("composer")

local scene = composer.newScene()

-- ===========================================================================================

function scene:create(event)
    local W, H = display.contentWidth, display.contentHeight
    local sceneGroup = self.view

    local titleText = display.newText({ text = gameName, width = W, font = fontName, fontSize = appScale * 90, align = 'center' })
    sceneGroup:insert(titleText)
    titleText:setFillColor(1, 1, 0.4)
    titleText.anchorX = 0.5
    titleText.anchorY = 0
    titleText.x = W / 2
    titleText.y = 10

    composer.gotoScene('scenes.game')
end

scene:addEventListener("create", scene)

return scene
