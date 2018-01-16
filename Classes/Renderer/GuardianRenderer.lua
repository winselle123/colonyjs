local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

local GuardianRenderer = {} 

function GuardianRenderer:prepare(parent, options) 
  local guardianGroup = display.newGroup() 

  -- SETUP TOGGLEABLE DISPLAYS
  local toggleables = display.newGroup() 
  toggleables.sightRadius = display.newCircle(toggleables, 0, 0, parent.sightRadius) -- sight radius
  toggleables.sightRadius:setFillColor(1, 0.5)
  toggleables.health = display.newText(toggleables, 'Health: ' .. parent.health, 0, -52, native.systemFont, 24)
  toggleables.class = display.newText(toggleables, parent.class, 0, 52, native.systemFont, 24)
  toggleables.isVisible = false
  guardianGroup.toggleables = toggleables
  guardianGroup:insert(toggleables)

  -- SETUP SPRITE
  guardianGroup.sprite = SpriteRenderer:prepare(parent, options)
  guardianGroup:insert(guardianGroup.sprite)

  -- SETUP DESTROY SPRITE
  local smoke = { class = 'Smoke' }
  guardianGroup.smokeSprite = SpriteRenderer:prepare(smoke)
  guardianGroup.smokeSprite.isVisible = false
  guardianGroup:insert(guardianGroup.smokeSprite)

  guardianGroup.x = parent.x
  guardianGroup.y = parent.y
  return guardianGroup
end

return GuardianRenderer 