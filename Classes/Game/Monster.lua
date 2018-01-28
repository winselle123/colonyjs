local String = require('Classes.System.String')
local Collision = require('Classes.System.Collision')
local GameObject = require('Classes.System.GameObject')
local Wave = require('Classes.System.Wave')

local MonsterRenderer = require('Classes.Renderer.MonsterRenderer')

local Monster = {
  monsterIndex = 1, 
  monsterSet = {}
}

function Monster:new(class, x, y) 
  local classFileName = 'Contents/Monsters/' .. class .. '.txt'
  local classPath = system.pathForFile(classFileName) 
  local classFile, err = io.open(classPath, 'r') 

  local monster
  if not classFile then 
    -- LOG FILE CLASS NOT FOUND
    return nil
  else
    monster = {
      side = 'monster',
      class = String:filterLetters(classFile:read()), 
      desc = classFile:read(),
      attack = String:filterNumbers(classFile:read()), 
      defense = String:filterNumbers(classFile:read()), 
      speed = (String:filterNumbers(classFile:read())), 
      slackTime = String:filterNumbers(classFile:read()), 
      health = String:filterNumbers(classFile:read()), 
      sightRadius = String:filterNumbers(classFile:read()),

      hasChanged = false,
      target = nil
    }
    monster.id = monster.class .. Monster.monsterIndex
    monster.x = x and x or display.contentCenterX
    monster.y = y and y or display.contentCenterY

    monster.view = MonsterRenderer:prepare(monster, {
      xScale = 3, 
      yScale = 3,
      isStart = true
    }) 

    monster.move = function(x, y, callback, options)
      if monster.x and monster.y then
        local direction = 'none'
        local xStart, yStart = monster.x, monster.y
        local xFinish, yFinish = tonumber(x), tonumber(y)

        -- PREPARE DIRECTIONS
        local direction
        if xStart == xFinish then
          direction = yStart > yFinish and 'up' or 'down' 
        else
          direction = xStart > xFinish and 'left' or 'right'
        end

        time = timer.performWithDelay(1, function() monster.x, monster.y = monster.view.x, monster.view.y end, 0)
        transition.to(monster.view, {
          x = x, 
          y = y,
          delay = 1,
          time = math.sqrt(math.pow(xStart - xFinish, 2) + math.pow(yStart - yFinish, 2)) / monster.speed * 1000,
          onStart = function() 
            if monster then monster.view.sprite.animate('Walking' .. String:toTitleCase(direction)) end
          end, 
          onComplete = function() 
            monster.view.sprite.animate('Standing' .. String:toTitleCase(direction))
            if callback then callback() end
            return
          end
        })
      end
    end

    monster.attackEnemy = function(target, callback)
      if monster.health > 0 then
        monster.view.attackSprite.isVisible = true

        function spriteListener(event)
          if event.phase == 'ended' then
            local attackCollision = Collision:newRectangle(monster, monster.view.attackSprite.width, monster.view.attackSprite.height, { tag = 'Attack' .. monster.id })
            timer.performWithDelay(2, function(event) 
              local charSet = Collision:filterSensors(attackCollision.collidedObjects)

              -- FILTER ENEMIES AND MONSTERS
              for i, v in ipairs(charSet) do
                if v.parent.side == 'guardian' then
                  if monster.health > 0 then
                    v.parent.onDamaged(monster)
                  end
                end
              end

              if callback then timer.performWithDelay(monster.slackTime * 1000, callback) end

              monster.view.attackSprite:removeEventListener('sprite', spriteListener)
              timer.performWithDelay(1, function() Collision:deleteByTag('Attack' .. monster.id) end)
            end)
            monster.view.attackSprite.isVisible = false
          end
        end
        monster.view.attackSprite:addEventListener('sprite', spriteListener)

        monster.view.attackSprite.animate('Attack')
      end
    end

    monster.destroy = function() 
      -- REMOVE MONSTER FROM MONSTER SET
      local index = 0
      for i, v in ipairs(Monster.monsterSet) do
        if v.id == monster.id then
          index = i
          break
        end
      end
      table.remove(Monster.monsterSet, index)

      -- REMOVE MONSTER FROM GAME OBJECTS
      local index = 0
      for i, v in ipairs(GameObject.gameObjectSet) do
        if v.id == monster.id then
          index = i
          break
        end
      end
      table.remove(GameObject.gameObjectSet, index)

      -- REMOVE COLLIDABLES 
      Collision:deleteByParent(monster)

      -- DEAL WITH DISPLAY; MAKE IT NOT VISIBLE
      monster.view.smokeSprite.isVisible = true
      monster.view.smokeSprite:addEventListener('sprite', function(event)
        if event.phase == 'ended' then
          -- DEAL WITH GLOBALS; MAKE THE OBJECT NOT PART OF THE GLOBAL MONSTER SET
          for i, v in ipairs(Monster.monsterSet) do
            if v.id == monster.id then
              table.remove(Monster.monsterSet, i)
              break
            end
          end

          monster.view.isVisible = false
        end
      end)
      monster.view.smokeSprite.animate('Poof')
    end

    monster.onDamaged = function(source)
      if monster.health > 0 then
        local damage = (options and options.isDefenseNulled) and source.attack or math.floor(source.attack - monster.defense / 2)
        monster.health = monster.health - damage

        monster.view.health.text = 'Health: ' .. monster.health

        if monster.health <= 0 then
          -- MONSTER COUNT
          Wave.monsterCount = Wave.monsterCount - 1
          Wave.monsterKilled = Wave.monsterKilled + 1
          monster.destroy()
        end
      end
    end
    monster.onEnemySeen = function(enemy)
      if monster.health > 0 then
        if not monster.target then
          transition.cancel(monster.view)
          monster.target = enemy

          -- MELEE 
          timer.performWithDelay(1, function() 
            monster.move(monster.target.x, monster.target.y, function() 
              if enemy.health > 0 then  
                local charSet = Collision:filterSensors(monster.view.toggleables.sightRadius.collision.collidedObjects)
                
                -- FILTER ENEMIES AND MONSTERS
                local targetFound
                for i, v in ipairs(charSet) do
                  if v.parent == enemy then targetFound = true end 
                end

                if targetFound then
                  monster.attackEnemy(enemy, function() 
                    if enemy.health > 0 then
                      monster.target = nil
                      monster.onEnemySeen(enemy)
                    else
                      monster.target = nil
                      monster.move(display.contentCenterX, display.contentCenterY)
                    end
                  end)
                else
                  if not enemy.isDestroyed then
                    monster.target = nil
                    monster.onEnemySeen(enemy)
                  else
                    monster.target = nil
                    monster.move(display.contentCenterX, display.contentCenterY)
                  end
                end
              else
                monster.target = nil
                monster.move(display.contentCenterX, display.contentCenterY)
              end
            end)
          end)
        end
      end
    end
    monster.onPoisoned = function()
      if monster.health > 0 then 
        timer.performWithDelay(2000, function() monster.onDamaged({ attack = 5 }, { isDefenseNulled = true }) end, 5)
      end
    end

    monster.draw = function() 
      MonsterRenderer:draw(monster, {
        xScale = 0.75,
        yScale = 0.75
      })
    end

    monster.move(display.contentCenterX, display.contentCenterY)

    Monster.monsterIndex = Monster.monsterIndex + 1
    table.insert(Monster.monsterSet, monster)
    table.insert(GameObject.gameObjectSet, { id = monster.id, object = monster })
    return monster 
  end 
end

return Monster