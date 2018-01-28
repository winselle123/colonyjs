local String = require('Classes.System.String')
local Collision = require('Classes.System.Collision')
local GameObject = require('Classes.System.GameObject')
local Wave = require('Classes.System.Wave')

local Event = require('Classes.Game.Event')
local Bullet = require('Classes.Game.Bullet')

local GuardianRenderer = require('Classes.Renderer.GuardianRenderer')
local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

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
      side = 'guardian',
      class = String:filterLetters(classFile:read()), 
      desc = classFile:read(),
      rangeType = String:filterLetters(classFile:read()),
      attack = String:filterNumbers(classFile:read()), 
      defense = String:filterNumbers(classFile:read()), 
      speed = (String:filterNumbers(classFile:read())), 
      slackTime = String:filterNumbers(classFile:read()), 
      health = String:filterNumbers(classFile:read()), 
      sightRadius = String:filterNumbers(classFile:read()),

      isWalking = false,
      isDestroyed = false,
      hasChanged = false
    }
    guardian.id = guardian.class .. Guardian.guardianIndex
    guardian.x = display.contentCenterX
    guardian.y = display.contentCenterY

    timer.performWithDelay(10, function() guardian.events = Event:newSet(guardian) end)

    guardian.info = GuardianRenderer:prepareInfo(guardian)
    guardian.view = GuardianRenderer:prepare(guardian, {
      xScale = 1.75, 
      yScale = 1.75,
      isStart = true
    }) 

    -- RECURSIVE FUNCTIONS WITH CALLBACK FUNCTIONS
    guardian.move = function(x, y, callback, options)
      local direction = 'none'
      local xStart, yStart = guardian.x, guardian.y
      local xFinish, yFinish = tonumber(x), tonumber(y)

      -- PREPARE DIRECTIONS
      local direction
      if xStart == xFinish then
        direction = yStart > yFinish and 'up' or 'down' 
      else
        direction = xStart > xFinish and 'left' or 'right'
      end

      time = timer.performWithDelay(1, function() if guardian and guardian.isWalking then guardian.x, guardian.y = guardian.view.x, guardian.view.y end end, 0)
      transition.moveTo(guardian.view, {
        x = x, 
        y = y, 
        time = math.sqrt(math.pow(xStart - xFinish, 2) + math.pow(yStart - yFinish, 2)) / guardian.speed * 1000,
        onStart = function() 
          guardian.view.sprite.animate('Walking' .. String:toTitleCase(direction))
          guardian.isWalking = true
        end, 
        onComplete = function() 
          guardian.view.sprite.animate('Standing' .. String:toTitleCase(direction))
          guardian.isWalking = false
          callback()
          return
        end
      })
    end
    guardian.dash = function(callback, options)
      if options and options.isStart then
        guardian.view.sprite.animate('Walking' .. String:toTitleCase(options.direction))
      end

      timer.performWithDelay(200, function() 
        if options.direction == 'up' then
          guardian.y = guardian.y - 75
        elseif options.direction == 'right' then
          guardian.x = guardian.x + 75
        elseif options.direction == 'down' then
          guardian.y = guardian.y + 75
        elseif options.direction == 'left' then
          guardian.x = guardian.x - 75
        end
        guardian.view.sprite.animate('Standing' .. String:toTitleCase(options.direction))
        callback()
      end)
    end
    guardian.launch = function(callback, options) 
      if options and options.isStart then
        guardian.view.sprite.animate('Walking' .. String:toTitleCase(options.direction))
      end

      timer.performWithDelay(1000, function() 
        if options.direction == 'up' then
          guardian.y = guardian.y - 200
        elseif options.direction == 'right' then
          guardian.x = guardian.x + 200
        elseif options.direction == 'down' then
          guardian.y = guardian.y + 200
        elseif options.direction == 'left' then
          guardian.x = guardian.x - 200
        end
        guardian.view.sprite.animate('Standing' .. String:toTitleCase(options.direction))
        callback()
      end)
    end
    guardian.wonder = function(callback, options) 
      guardian.view.question.isVisible = true

      timer.performWithDelay(2000, function() 
        guardian.view.question.isVisible = false
        callback() 
      end)
      return
    end

    -- ATTACK FUNCTIONS
    guardian.attackEnemy = function(target, callback, options) 
      if guardian.health > 0 then
        if guardian.rangeType == 'ranged' then
          -- RANGED
          if options and options.charged then
            guardian.attack = guardian.attack * 1.5

            local bullet = Bullet:new(guardian, target, { xScale = 1, yScale = 1 })
            bullet.view.isVisible = false
            timer.performWithDelay(2000, function() bullet.view.isVisible = true bullet.shoot(function() guardian.attack = guardian.attack / 1.5 callback() end) end)
          elseif options and options.poisoned then
            guardian.attack = guardian.attack / 2
            local bullet = Bullet:new(guardian, target, { isPoisoned = true })
            timer.performWithDelay(2, function() bullet.shoot(function() guardian.attack = guardian.attack * 2 callback() end) end)
          else  
            local bullet = Bullet:new(guardian, target)
            timer.performWithDelay(2, function() bullet.shoot(callback) end)
          end
        elseif guardian.rangeType == 'melee' then
          local attack = { class = guardian.class .. 'Attack' }
          guardian.view.attackSprite = SpriteRenderer:draw(attack)
          if options and options.charged then 
            guardian.view.attackSprite.xScale, guardian.view.attackSprite.yScale = 1.25, 1.25 
            guardian.view.attackSprite.isVisible = false
          end
          guardian.view:insert(guardian.view.attackSprite)

          function spriteListener(event)
            if event.phase == 'began' then
              guardian.view.attackSprite.isVisible = true
            elseif event.phase == 'ended' then
              local attackCollision = Collision:newRectangle(guardian, guardian.view.attackSprite.width, guardian.view.attackSprite.height, { tag = 'Attack' .. guardian.id })
              timer.performWithDelay(2, function(event) 
                local charSet = Collision:filterSensors(attackCollision.collidedObjects)

                -- FILTER ENEMIES AND GUARDIANS
                for i, v in ipairs(charSet) do
                  if v.parent.side == 'monster' then
                    if guardian.health > 0 and (v.parent and v.parent.health > 0) then
                      if options and options.isPoisoned then v.parent.onPoisoned() end 
                      v.parent.onDamaged(guardian)
                    end
                  end
                end

                if callback then timer.performWithDelay(guardian.slackTime * 1000, callback) end

                guardian.view.attackSprite:removeEventListener('sprite', spriteListener)
                timer.performWithDelay(1, function() Collision:deleteByTag('Attack' .. guardian.id) end)
              end)
              guardian.view.attackSprite.isVisible = false
            end
          end
          guardian.view.attackSprite:addEventListener('sprite', spriteListener)

          if options and options.charged then 
            timer.performWithDelay(2000, function() guardian.view.attackSprite.animate('Attack') end)
          else
            guardian.view.attackSprite.animate('Attack')
          end
        end
      end
    end

    guardian.destroy = function() 
      -- REMOVE GUARDIAN FROM GUARDIAN SET
      local index = 0
      for i, v in ipairs(Guardian.guardianSet) do
        if v.id == guardian.id then
          index = i
          break
        end
      end
      table.remove(Guardian.guardianSet, index)

      -- REMOVE GUARDIAN FROM GAME OBJECTS
      local index = 0
      for i, v in ipairs(GameObject.gameObjectSet) do
        if v.id == guardian.id then
          index = i
          break
        end
      end
      table.remove(GameObject.gameObjectSet, index)

      -- REMOVE COLLIDABLES 
      Collision:deleteByParent(guardian)    

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
          guardian.isDestroyed = true
        end
      end)
      guardian.view.smokeSprite.animate('Poof')
    end

    guardian.onDamaged = function(source, options)
      if guardian.health > 0 then
        local damage = (options and options.isDefenseNulled) and source.attack or math.floor(source.attack - guardian.defense / 2)
        guardian.health = guardian.health - damage

        guardian.view.health.text = 'Health: ' .. guardian.health

        if guardian.health <= 0 then
          -- GUARDIAN COUNT 
          Wave.guardianCount = Wave.guardianCount - 1
          Wave.guardianKilled = Wave.guardianKilled + 1
          guardian.destroy()
        end
      end
    end
    guardian.onEnemySeen = function(enemy)
      if guardian.health > 0 then
        if #guardian.events.eventSet['onEnemySeen'].skillSet ~= 0 then 
          if not guardian.target then
            if enemy.health > 0 then
              guardian.view.sprite.animate('Standing' .. (enemy.x > guardian.x and 'Right' or 'Left'))
              transition.cancel(guardian.view)
              guardian.target = enemy 

              -- RANGED
              timer.performWithDelay(1, function() 
                guardian.events.eventSet['onEnemySeen'].target = enemy
                guardian.events.execute('onEnemySeen')
              end)  
            end
          end
        end
      end
    end
    guardian.onPoisoned = function()
      if guardian.health > 0 then 
        timer.performWithDelay(2000, function() guardian.onDamaged({ attack = 5 }, { isDefenseNulled = true }) end, 5)
      end
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