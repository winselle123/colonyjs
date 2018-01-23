local String = require('Classes.System.String')
local GameObject = require('Classes.System.GameObject')

local Event = require('Classes.Game.Event')

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
      class = String:filterLetters(classFile:read()), 
      desc = classFile:read(),
      attack = String:filterNumbers(classFile:read()), 
      defense = String:filterNumbers(classFile:read()), 
      speed = String:filterNumbers(classFile:read()), 
      attackSpeed = String:filterNumbers(classFile:read()), 
      health = String:filterNumbers(classFile:read()), 
      sightRadius = String:filterNumbers(classFile:read()),

      hasChanged = false
    }
    guardian.id = guardian.class .. Guardian.guardianIndex
    guardian.x = display.contentCenterX
    guardian.y = display.contentCenterY

    timer.performWithDelay(10, function() guardian.events = Event:newSet(guardian) end)

    guardian.info = GuardianRenderer:prepareInfo(guardian)
    guardian.view = GuardianRenderer:prepare(guardian, {
      xScale = 0.75, 
      yScale = 0.75,
      isStart = true
    }) 

    -- RECURSIVE FUNCTIONS WITH CALLBACK FUNCTIONS
    guardian.walkUp = function(steps, callback, options) 
      -- LOOK FOR OPTIONS
      if options and options.isStart then
        guardian.view.sprite.animate('WalkingRight')
      end

      if tonumber(steps) <= 0 then
        guardian.view.sprite.animate('StandingRight')
        callback()
        return
      else
        guardian.y = guardian.y - 1
        timer.performWithDelay(10, function() guardian.walkUp(steps - 1, callback) end)
      end
    end

    guardian.walkRight = function(steps, callback, options) 
      -- LOOK FOR OPTIONS
      if options and options.isStart then
        guardian.view.sprite.animate('WalkingRight')
      end

      if tonumber(steps) <= 0 then
        guardian.view.sprite.animate('StandingRight')
        callback()
        return
      else
        guardian.x = guardian.x + 1
        timer.performWithDelay(10, function() guardian.walkRight(steps - 1, callback) end)
      end
    end

    guardian.walkDown = function(steps, callback, options) 
      -- LOOK FOR OPTIONS
      if options and options.isStart then
        guardian.view.sprite.animate('WalkingRight')
      end

      if tonumber(steps) <= 0 then
        guardian.view.sprite.animate('StandingRight')
        callback()
        return
      else
        guardian.y = guardian.y + 1
        timer.performWithDelay(10, function() guardian.walkDown(steps - 1, callback) end)
      end
    end

    guardian.walkLeft = function(steps, callback, options) 
      -- LOOK FOR OPTIONS
      if options and options.isStart then
        guardian.view.sprite.animate('WalkingLeft')
      end

      if tonumber(steps) <= 0 then
        guardian.view.sprite.animate('StandingLeft')
        callback()
        return
      else
        guardian.x = guardian.x - 1
        timer.performWithDelay(10, function() guardian.walkLeft(steps - 1, callback) end)
      end
    end

    guardian.wonder = function(callback, options) 
      -- LOOK FOR OPTIONS
      if options and options.isStart then
        guardian.view.sprite.animate('WalkingLeft')
      end

      timer.performWithDelay(2000, function() callback() end)
      return
    end

    guardian.destroy = function() 
      -- REMOVE GUARDIANS FROM GAME OBJECTS
      local index = 0
      for i, v in ipairs(GameObject.gameObjectSet) do
        if v.id == guardian.id then
          index = i
          break
        end
      end
      table.remove(GameObject.gameObjectSet, index)

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

          guardian.info.isVisible = false
          guardian.view.isVisible = false
        end
      end)
      guardian.view.smokeSprite.animate('Poof')
    end

    guardian.draw = function() 
      GuardianRenderer:draw(guardian, {
        xScale = 0.75,
        yScale = 0.75
      })
    end

    Guardian.guardianIndex = Guardian.guardianIndex + 1
    table.insert(Guardian.guardianSet, guardian)
    table.insert(GameObject.gameObjectSet, { id = guardian.id, object = guardian })
    return guardian 
  end 
end

return Guardian