local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')
local Game = require('Classes.System.Game')

local composer = require( "composer" )

local scene = composer.newScene()

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local placeholder = display.newText('Upgrade tree with start game', display.contentCenterX, display.contentCenterY, native.systemFont, 24)
  sceneGroup:insert(placeholder)

  local btn_StartGame = ComponentRenderer:renderButton('Assets/Buttons/Btn_Play.png', {
    filename_clicked = 'Assets/Buttons/Btn_PlayClicked.png',
    width = 300,
    height = 86,
    x = display.contentCenterX, 
  })
  btn_StartGame.y = (display.contentHeight - btn_StartGame.height / 2) - 100
  btn_StartGame:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      composer.gotoScene('Classes.Scenes.BattleProper')
    end
  end)
  sceneGroup:insert(btn_StartGame)
end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    Game.sceneActivated = 'Upgrade tree'

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