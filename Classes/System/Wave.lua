
local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local Wave = {
  guardianCount = 0,
  monsterCount = 0,

  monsterKilled = 0, 
  guardianKilled = 0, 
}

function Wave:new(parent, guardianCount, monsterCount) 
  Wave.monsterKilled, Wave.guardianKilled = 0, 0
  Wave.guardianCount = guardianCount
  Wave.monsterCount = monsterCount

  local waveTime = {}
  function waveTime:timer(event) 
    if Wave.guardianCount <= 0 then
      local survived = display.newText({
        text = 'The land has been conquered by the dark forces\nMonsters subdued: ' .. Wave.monsterKilled .. '\nGuardians sacrificed: ' .. Wave.guardianKilled,
        align = 'center',
        fontSize = 20
      })
      survived.x = display.contentCenterX
      survived.y = survived.height / 2 + 25

      timer.cancel(event.source)
    end

    if Wave.monsterCount <= 0 then
      local survived = display.newText({
        text = 'You have survived the wave\nMonsters subdued: ' .. Wave.monsterKilled .. '\nGuardians sacrificed: ' .. Wave.guardianKilled,
        align = 'center',
        fontSize = 20
      })
      survived.x = display.contentCenterX
      survived.y = survived.height / 2 + 25

      local btn_Continue = ComponentRenderer:renderButton('Assets/Buttons/Btn_Continue.png', { 
        filename_clicked = 'Assets/Buttons/Btn_ContinueClicked.png',
        width = 300, 
        height = 86,
        x = display.contentCenterX
      })
      btn_Continue.y = display.contentCenterY + 250
      btn_Continue:addEventListener('touch', function(event) 
        survived.isVisible = false
        btn_Continue.isVisible = false
        parent.wave = parent.wave + 1
        parent:prepare()
      end)

      timer.cancel(event.source)
    end
  end

  timer.performWithDelay(1, waveTime, 0)
end

return Wave