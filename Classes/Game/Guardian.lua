local GuardianRenderer = require('Classes.Renderer.GuardianRenderer')

local Guardian = {
  guardianIndex = 1,
  guardianSet = {}
} 

function Guardian:new(class) 
  local classFileName = 'Contents/Guardians/' .. class .. '.txt'
  local classPath = system.pathForFile(classFileName) 
  local classFile, err = io.open(classPath, 'r') 

  local guardian
  if not classFile then 
    -- LOG FILE CLASS NOT FOUND
    return nil
  else
    guardian = {
      class = classFile:read(), 
      attack = classFile:read(), 
      defense = classFile:read(), 
      speed = classFile:read(), 
      attackSpeed = classFile:read(), 
      health = classFile:read(), 
      sightRadius = classFile:read(),
    }
    guardian.id = guardian.class .. Guardian.guardianIndex
    guardian.x = display.contentCenterX
    guardian.y = display.contentCenterY

    guardian.view = GuardianRenderer:prepare(guardian, {
      xScale = 0.75, 
      yScale = 0.75
    }) 

    guardian.destroy = function() 
      -- DEAL WITH DISPLAY; MAKE IT NOT VISIBLE
      guardian.view.smokeSprite.isVisible = true
      guardian.view.smokeSprite:addEventListener('sprite', function(event)
        if event.phase == 'ended' then
          -- DEAL WITH GLOBALS; MAKE THE OBJECT NOT PART OF THE GLOBAL GUARDIAN SET
          for i, v in ipairs(Guardian.guardianSet) do
            if v.id == guardian.id then
              table.remove(Guardian.guardianSet, i)
              break
            end
          end

          guardian.view.isVisible = false
          guardian = nil
        end
      end)
      guardian.view.smokeSprite.animate('Poof')
    end

    Guardian.guardianIndex = Guardian.guardianIndex + 1
    table.insert(Guardian.guardianSet, guardian)
    return guardian 
  end 
end

return Guardian