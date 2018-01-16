local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')
local Game = require('Classes.System.Game')

local composer = require( "composer" )

local scene = composer.newScene()

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local placeholder = display.newText('Battle proper', display.contentCenterX, display.contentCenterY, native.systemFont, 24)
  sceneGroup:insert(placeholder)

  local btn_OptionsBattle = ComponentRenderer:renderButton('Assets/Buttons/Btn_Settings.png', {
    filename_clicked = 'Assets/Buttons/Btn_SettingsClicked.png',
    width = 86, 
    height = 86,
  })
  btn_OptionsBattle:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      composer.gotoScene('Classes.Scenes.OptionsBattle')
    end
  end)
  btn_OptionsBattle.x, btn_OptionsBattle.y = (display.contentWidth - btn_OptionsBattle.width / 2) - 25, (btn_OptionsBattle.height / 2) + 25
  sceneGroup:insert(btn_OptionsBattle)
end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    Game.sceneActivated = 'Battle proper'
    Game:_init()

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