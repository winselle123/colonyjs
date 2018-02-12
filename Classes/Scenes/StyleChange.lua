local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')
local Game = require('Classes.System.Game')
local Style = require('Classes.Game.Style')

local composer = require( "composer" )

local scene = composer.newScene()

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local placeholder = display.newText('Change looks', display.contentCenterX, display.contentCenterY, native.systemFont, 24)
  sceneGroup:insert(placeholder)
end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
	--INITIALIZE BACKGROUND
	local background = display.newImageRect('Assets/Backgrounds/Grass.png', display.contentWidth, display.contentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    Game.sceneActivated = 'Change looks'
	Style:render()

  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen

  end
end

-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen

  end
end

-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene