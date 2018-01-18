local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')
local Game = require('Classes.System.Game')

local composer = require( "composer" )

local scene = composer.newScene()

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  
  local placeholder = display.newText('Main menu', display.contentCenterX, display.contentCenterY, native.systemFont, 24)
  sceneGroup:insert(placeholder)

  local btn_Continue = ComponentRenderer:renderButton(Game.savedData and 'Assets/Buttons/Btn_Continue.png' or 'Assets/Buttons/Btn_ContinueDisabled.png', { 
    filename_clicked = Game.savedData and 'Assets/Buttons/Btn_ContinueClicked.png' or nil,
    width = 300, 
    height = 86,
    x = display.contentCenterX, 
    isDisabled = not Game.savedData
  })
  btn_Continue.y = (display.contentHeight - btn_Continue.height / 2) - 340
  btn_Continue:addEventListener('touch', function(event)
    if Game.savedData then
      if event.phase == 'ended' then
        composer.gotoScene('Classes.Scenes.UpgradeTree')
      end
    end
  end)
  sceneGroup:insert(btn_Continue)
  
  local btn_StartNewGame = ComponentRenderer:renderButton('Assets/Buttons/Btn_NewGame.png', {
    filename_clicked = 'Assets/Buttons/Btn_NewGameClicked.png',
    width = 300,
    height = 86,
    x = display.contentCenterX, 
  })
  btn_StartNewGame.y = (display.contentHeight - btn_StartNewGame.height / 2) - 220
  btn_StartNewGame:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      Game.savedData = nil
      composer.gotoScene('Classes.Scenes.UpgradeTree')
    end
  end)
  sceneGroup:insert(btn_StartNewGame)

  local btn_Leaderboard = ComponentRenderer:renderButton('Assets/Buttons/Btn_Leaderboard.png', {
    filename_clicked = 'Assets/Buttons/Btn_LeaderboardClicked.png',
    width = 300,
    height = 86,
    x = display.contentCenterX, 
  })
  btn_Leaderboard.y = (display.contentHeight - btn_Leaderboard.height / 2) - 100
  btn_Leaderboard:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      composer.gotoScene('Classes.Scenes.Leaderboard')
    end
  end)
  sceneGroup:insert(btn_Leaderboard)

  local btn_Options = ComponentRenderer:renderButton('Assets/Buttons/Btn_Settings.png', {
    filename_clicked = 'Assets/Buttons/Btn_SettingsClicked.png',
    width = 86, 
    height = 86,
  })
  btn_Options.x, btn_Options.y = (display.contentWidth - btn_Options.width / 2) - 25, (btn_Options.height / 2) + 25
  btn_Options:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      composer.gotoScene('Classes.Scenes.Options')
    end
  end)
  sceneGroup:insert(btn_Options)
end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    Game.sceneActivated = 'Main menu'

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