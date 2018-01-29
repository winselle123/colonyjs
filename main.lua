local Game = require('Classes.System.Game')

local composer = require('composer')
composer.gotoScene('Classes.Scenes.MainMenu')
Runtime:addEventListener('key', function(event) 
  if event.keyName == 'back' and event.phase == 'up' then 
    local backActions = {
      ['Upgrade tree'] = function()
        print('Upgrade')
        composer.gotoScene('Classes.Scenes.MainMenu')
      end,
      ['Battle proper'] = function() 
        print('Battle')
        composer.gotoScene('Classes.Scenes.UpgradeTree')
      end,
      ['Change looks'] = function() 
        print('Battle')
        composer.gotoScene('Classes.Scenes.UpgradeTree')
      end,
      ['Options from battle'] = function() 
        print('Options battle')
        composer.gotoScene('Classes.Scenes.BattleProper')
      end,
      ['Options from main menu'] = function() 
        print('Options')
        composer.gotoScene('Classes.Scenes.MainMenu')
      end,
      ['Leaderboard'] = function()
        print('Leaderboard') 
        composer.gotoScene('Classes.Scenes.MainMenu')
      end
    }

    local backScene = backActions[Game.sceneActivated]
    if backScene then
      backScene()
      return true
    end

    return false
  end
end) 

-- RIPPLE TOUCH
local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')
Runtime:addEventListener('touch', function(event)
  if event.phase == 'began' then
    local Guardian = require('Classes.Game.Guardian')
    local GuardianRenderer = require('Classes.Renderer.GuardianRenderer')
    GuardianRenderer.activeGuardian = nil
    for i, v in ipairs(Guardian.guardianSet) do
      v.info.isVisible = false
      v.view.toggleables.isVisible = false
    end
    ComponentRenderer:renderClicker(event.x, event.y)
  end
end)


system.setIdleTimer(false)