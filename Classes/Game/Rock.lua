local Collision = require('Classes.System.Collision')
local GameObject = require('Classes.System.GameObject')
local Wave = require('Classes.System.Wave')

local Guardian = require('Classes.Game.Guardian')

local RockRenderer = require('Classes.Renderer.RockRenderer')

local Rock = {}

function Rock:new()
  local rock = {
    id = 'rock',
    side = 'guardian',
    class = 'Rock',
    health = 500,
    isTimedOut = false
  }
  rock.x = display.contentCenterX
  rock.y = display.contentCenterY

  rock.view = RockRenderer:prepare(rock, {
    xScale = 0.5, 
    yScale = 0.5
  }) 
  rock.view.sprite:addEventListener('sprite', function(event) 
    if event.phase == 'ended' and rock.view.sprite.sequence == 'Damage' then
      rock.view.sprite.animate('Stand')
    end
  end)

  rock.destroy = function() 
    -- REMOVE MONSTER FROM GAME OBJECTS
    local index = 0
    for i, v in ipairs(GameObject.gameObjectSet) do
      if v.id == rock.id then
        index = i
        break
      end
    end
    table.remove(GameObject.gameObjectSet, index)

    -- REMOVE COLLIDABLES 
    Collision:deleteByParent(rock)

    -- DEAL WITH DISPLAY; MAKE IT NOT VISIBLE
    rock.view.smokeSprite.isVisible = true
    rock.view.smokeSprite:addEventListener('sprite', function(event)
      if event.phase == 'ended' then
        rock.view.isVisible = false
      end
    end)
    rock.view.smokeSprite.animate('Poof')
  end

  rock.onDamaged = function(source)
    if rock.health > 0 then
      rock.view.sprite.animate('Damage')

      local damage = source.attack
      rock.health = rock.health - damage

      rock.view.health.text = 'Health: ' .. rock.health

      for i, v in ipairs(Guardian.guardianSet) do
        v.events.execute('onGuardianStoneAttacked')
      end

      if rock.health <= 0 then
        -- MONSTER COUNT
        Wave.rockDestroyed = true
        rock.destroy()
      end
    end
  end
  rock.onPoisoned = function() print('Rock cannot be poisoned') end

  rock.beginTimer = function() 
    timer.performWithDelay(60000, function() rock.isTimedOut = false end)
  end

  rock.draw = function() 
    RockRenderer:draw(rock, {
      xScale = 0.5,
      yScale = 0.5
    })
  end

  table.insert(GameObject.gameObjectSet, { id = rock.id, object = rock })
  return rock 
end 

return Rock