local Collision = require('Classes.System.Collision')
local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

local RockRenderer = {} 

function RockRenderer:prepare(parent, options) 
  local rockGroup = display.newGroup() 

  -- SETUP GO-ALONG INFORMATION
  rockGroup.health = display.newText(rockGroup, 'Health: ' .. parent.health, 0, -52, native.systemFont, 24)

  -- SETUP SPRITE
  rockGroup.sprite = SpriteRenderer:draw(parent, options)
  rockGroup.sprite.collision = Collision:newRectangle(parent, rockGroup.sprite.width, rockGroup.sprite.height)
  rockGroup.sprite:addEventListener('touch', function(event)
    local focus = event.target
    local stage = display.getCurrentStage()
    if event.phase == 'ended' then
      if not parent.isTimedOut then
        rockGroup.attackSprite.isVisible = true
        rockGroup.attackSprite.animate('Pulse')
      end
    end
    return true
  end)
  rockGroup.sprite.isVisible = true
  rockGroup:insert(rockGroup.sprite)

  -- SETUP ATTACK SPRITE
  local attack = { class = parent.class .. 'Attack' }
  rockGroup.attackSprite = SpriteRenderer:draw(attack, { 
    xScale = 0.75, 
    yScale = 0.75
  })
  rockGroup.attackSprite.isVisible = false
  rockGroup.attackSprite:addEventListener('sprite', function(event) 
    if event.phase == 'ended' then
      local attackCollision = Collision:newCircle(parent, rockGroup.attackSprite.width / 2, { tag = 'AttackRock' })
      timer.performWithDelay(2, function(event) 
        local charSet = Collision:filterSensors(attackCollision.collidedObjects)

        -- FILTER ENEMIES AND MONSTERS
        for i, v in ipairs(charSet) do
          if v.parent.side == 'monster' then
            if parent.health > 0 then
              v.parent.health = 0
              v.parent.destroy()
            end
          end
        end

        parent.isTimedOut = true
        parent.beginTimer()
        timer.performWithDelay(1, function() Collision:deleteByTag('AttackRock') end)
      end)
      rockGroup.attackSprite.isVisible = false
    end
  end)
  rockGroup:insert(rockGroup.attackSprite)

  -- SETUP DESTROY SPRITE
  local smoke = { class = 'Smoke' }
  rockGroup.smokeSprite = SpriteRenderer:draw(smoke)
  rockGroup.smokeSprite.isVisible = false
  rockGroup:insert(rockGroup.smokeSprite)

  rockGroup.isVisible = false
  return rockGroup
end

function RockRenderer:draw(parent, options)
  if parent.hasChanged then
    parent.view:removeSelf() 
    parent.view.isVisible = false
    parent.view = RockRenderer:prepare(parent, { xScale = options.xScale, yScale = options.yScale })
    parent.hasChanged = false
  end

  -- MAKE THE MONSTER VISIBLE IN THE GIVEN X AND Y
  parent.view.x = parent.x
  parent.view.y = parent.y 
  parent.view.isVisible = true
end

return RockRenderer 