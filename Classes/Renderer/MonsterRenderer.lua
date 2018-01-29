local Collision = require('Classes.System.Collision')
local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

local MonsterRenderer = {
  activeMonster = nil
} 

function MonsterRenderer:prepare(parent, options) 
  local monsterGroup = display.newGroup() 

  -- SETUP GO-ALONG INFORMATION
  monsterGroup.health = display.newText(monsterGroup, 'Health: ' .. parent.health, 0, -52, native.systemFont, 24)
  monsterGroup.class = display.newText(monsterGroup, parent.class, 0, 52, native.systemFont, 24)

  -- SETUP TOGGLEABLE DISPLAYS
  local toggleables = display.newGroup() 
  toggleables.sightRadius = display.newCircle(toggleables, 0, 0, parent.sightRadius) -- sight radius
  toggleables.sightRadius.collision = Collision:newCircle(parent, parent.sightRadius, { isSensor = true })
  timer.performWithDelay(10, function() 
    local charSet = Collision:filterSensors(toggleables.sightRadius.collision.collidedObjects)
    
    -- FILTER ENEMIES AND MONSTERS
    local enemySet, monsterSet = {}, {}
    for i, v in ipairs(charSet) do
      if v.parent.side == 'monster' then
        table.insert(monsterSet, v)
      elseif v.parent.side == 'guardian' then 
        table.insert(enemySet, v)
      end
    end

    -- REQUEST ONENEMYSEEN EXECUTE IF ENEMY SET HAS NUMBER, ELSE ONALLYSEEN ON SAME SCENARIO, ELSE NONE
    if #enemySet > 0 then
      local index = nil
      if parent.health > parent.baseHealth * 0.45 then
        for i, v in ipairs(enemySet) do
          if v.parent.id == 'rock' then 
            index = i 
            break
          end
        end
      elseif parent.health <= parent.baseHealth * 0.45 and parent.health > 0 then
        if parent.target.id == 'rock' then parent.target = nil end
        for i, v in ipairs(enemySet) do
          if v.parent.id ~= 'rock' then
            index = i
            break
          end
        end

        if not index then 
          for i, v in ipairs(enemySet) do
            if v.parent.id == 'rock' then 
              index = i 
              break
            end
          end
        end
      end

      if index then parent.onEnemySeen(enemySet[index].parent) end
    elseif #monsterSet > 0 then
    end
  end, 0)
  toggleables.sightRadius:setFillColor(1, 0.1)
  monsterGroup.toggleables = toggleables
  toggleables.isVisible = false
  monsterGroup:insert(toggleables)

  -- SETUP ATTACK SPRITE
  local attack = { class = parent.class .. 'Attack' }
  monsterGroup.attackSprite = SpriteRenderer:draw(attack)
  monsterGroup.attackSprite.isVisible = false
  monsterGroup:insert(monsterGroup.attackSprite)

  -- SETUP SPRITE
  monsterGroup.sprite = SpriteRenderer:draw(parent, options)
  monsterGroup.sprite.collision = Collision:newRectangle(parent, monsterGroup.sprite.width, monsterGroup.sprite.height)
  monsterGroup.sprite:addEventListener('touch', function(event)
    local focus = event.target
    local stage = display.getCurrentStage()
    if event.phase == 'ended' then
      -- ALLOWS ONE MONSTER TO BE SELECTED
      if activeMonster then
        activeMonster.view.toggleables.isVisible = false
        if parent == activeMonster then
          activeMonster = nil
        else
          activeMonster = parent
          activeMonster.view.toggleables.isVisible = true
        end
      else
        activeMonster = parent
        activeMonster.view.toggleables.isVisible = true
      end
    end
    return true
  end)
  monsterGroup.sprite.isVisible = true
  monsterGroup:insert(monsterGroup.sprite)

  -- SETUP DESTROY SPRITE
  local smoke = { class = 'Smoke' }
  monsterGroup.smokeSprite = SpriteRenderer:draw(smoke)
  monsterGroup.smokeSprite.isVisible = false
  monsterGroup:insert(monsterGroup.smokeSprite)

  -- ANIMATE SPRITE IF OPTIONS DICTATE START
  if options.isStart then
    monsterGroup.sprite.y = -50
    monsterGroup.sprite.animate('Drop')
    transition.to(monsterGroup.sprite, {
      y = 0,
      time = 125
    }) 
  end

  monsterGroup.isVisible = false
  return monsterGroup
end

function MonsterRenderer:draw(parent, options)
  if parent.hasChanged then
    parent.view:removeSelf() 
    parent.view.isVisible = false
    parent.view = MonsterRenderer:prepare(parent, { xScale = options.xScale, yScale = options.yScale })
    parent.hasChanged = false
  end

  -- MAKE THE MONSTER VISIBLE IN THE GIVEN X AND Y
  parent.view.x = parent.x
  parent.view.y = parent.y 
  parent.view.isVisible = true
end

return MonsterRenderer 