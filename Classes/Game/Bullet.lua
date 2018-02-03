local Collision = require('Classes.System.Collision')
local BulletRenderer = require('Classes.Renderer.BulletRenderer')

local Bullet = {}

function Bullet:new(parent, target, options) 
  local bullet = {
    parent = parent, 
    target = target
  } 
  bullet.view = BulletRenderer:draw(bullet)
  bullet.view.x, bullet.view.y = parent.x, parent.y
  bullet.view.xScale, bullet.view.yScale = (options and options.xScale) and options.xScale or 0.5, (options and options.yScale) and options.yScale or 0.5 
  bullet.view.sprite.animate('Travel')
  bullet.view.isVisible = true

  bullet.shoot = function(callback) 
    time = timer.performWithDelay(1, function() bullet.x, bullet.y = bullet.view.x, bullet.view.y end, 0)
    transition.to(bullet.view, {
      x = target.x, 
      y = target.y, 
      time = 300, 
      onStart = function() 
        bullet.view.sprite.animate('Travel')
      end, 
      onComplete = function() 
        -- AOE DAMAGE
        function spriteListener(event)
          if event.phase == 'ended' then
            local attackCollision = Collision:newRectangle(bullet, bullet.view.sprite.width, bullet.view.sprite.height, { tag = 'Attack' .. parent.id })
            timer.performWithDelay(2, function(event) 
              local charSet = Collision:filterSensors(attackCollision.collidedObjects)

              -- FILTER ENEMIES AND MONSTERS
              for i, v in ipairs(charSet) do
                if v.parent.side ~= bullet.parent.side then 
                  if parent.health > 0 and (v.parent and v.parent.health > 0) then
                    if options and options.isPoisoned then v.parent.onPoisoned(parent) end 
                    v.parent.onDamaged(parent)
                  end
                end
              end

              bullet.view.sprite:removeEventListener('sprite', spriteListener)
              timer.performWithDelay(1, function() Collision:deleteByTag('Attack' .. parent.id) end)
            end)
            bullet.view.sprite.isVisible = false
          end
        end
        bullet.view.sprite:addEventListener('sprite', spriteListener)

        bullet.view.sprite.animate('Explode')
      end
    })

    if callback then callback() end
  end

  return bullet
end

return Bullet