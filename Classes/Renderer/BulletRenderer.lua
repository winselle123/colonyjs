local Collision = require('Classes.System.Collision')
local DisplayObject = require('Classes.System.DisplayObject')
local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

local BulletRenderer = {} 

function BulletRenderer:draw(parent, options) 
  local bulletGroup = display.newGroup()

  -- SETUP SPRITE
  local bullet = { class = parent.parent.class .. 'Attack' }
  bulletGroup.sprite = SpriteRenderer:draw(bullet)
  bulletGroup.sprite.isVisible = true
  bulletGroup:insert(bulletGroup.sprite)
  bulletGroup.isVisible = false

  table.insert(DisplayObject.displayObjectSet, bulletGroup)
  return bulletGroup
end

return BulletRenderer 