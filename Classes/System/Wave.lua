local DisplayObject = require('Classes.System.DisplayObject')

local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local Wave = {
  waveNumber = 0, 
  
  guardianCount = 0,
  monsterCount = 0,

  monsterKilled = 0, 
  guardianKilled = 0, 
}

function Wave:new(parent, guardianCount, monsterCount) 
  Wave.monsterKilled, Wave.guardianKilled = 0, 0
  Wave.guardianCount = guardianCount
  Wave.monsterCount = monsterCount
  Wave.rockDestroyed = false

  local waveTime = {}
  function waveTime:timer(event)  
    if Wave.guardianCount <= 0 or Wave.rockDestroyed then
      local displayGroup = display.newGroup()
      local message = display.newText({
        text = 'The land has been conquered by the dark forces\nMonsters subdued: ' .. Wave.monsterKilled .. '\nGuardians sacrificed: ' .. Wave.guardianKilled,
        align = 'center',
        fontSize = 20
      })
      message.x = 0
      message.y = -display.contentHeight / 2 + message.height / 2 + 25

      displayGroup:insert(message)
      displayGroup.x, displayGroup.y = display.contentCenterX, display.contentCenterY
      table.insert(DisplayObject.displayObjectSet, displayGroup)
      timer.cancel(event.source)
    end

    if Wave.monsterCount <= 0 then
      local displayGroup = display.newGroup()
      local message = display.newText({
        text = 'You have message the wave\nMonsters subdued: ' .. Wave.monsterKilled .. '\nGuardians sacrificed: ' .. Wave.guardianKilled,
        align = 'center',
        fontSize = 20
      })
      message.x = 0
      message.y = -display.contentHeight / 2 + message.height / 2 + 25

      local btn_Continue = ComponentRenderer:renderButton('Assets/Buttons/Btn_Continue.png', { 
        filename_clicked = 'Assets/Buttons/Btn_ContinueClicked.png',
        width = 300, 
        height = 86,
        x = display.contentCenterX
      })
      btn_Continue.y = display.contentCenterY + 250
      btn_Continue:addEventListener('touch', function(event) 
        message.isVisible = false
        btn_Continue.isVisible = false
        parent.wave = parent.wave + 1
        parent:prepare()
      end)

      displayGroup:insert(message)
      displayGroup:insert(btn_Continue)
      displayGroup.x, displayGroup.y = display.contentCenterX, display.contentCenterY
      table.insert(DisplayObject.displayObjectSet, displayGroup)
      timer.cancel(event.source)
    end

  end

  timer.performWithDelay(1, waveTime, 0)
end

return Wave