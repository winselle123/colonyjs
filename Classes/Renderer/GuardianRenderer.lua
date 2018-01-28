local Collision = require('Classes.System.Collision')
local DisplayObject = require('Classes.System.DisplayObject')
local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')
local EventRenderer = require('Classes.Renderer.EventRenderer')

local GuardianRenderer = {
  activeGuardian = nil
} 

function GuardianRenderer:prepare(parent, options) 
  local guardianGroup = display.newGroup() 

  -- SETUP GO-ALONG INFORMATION
  guardianGroup.health = display.newText(guardianGroup, 'Health: ' .. parent.health, 0, -60, native.systemFont, 24)
  guardianGroup.class = display.newText(guardianGroup, parent.class, 0, 60, native.systemFont, 24)

  -- SETUP TOGGLEABLE DISPLAYS
  local toggleables = display.newGroup() 
  toggleables.sightRadius = display.newCircle(toggleables, 0, 0, parent.sightRadius) -- sight radius
  toggleables.sightRadius.collision = Collision:newCircle(parent, parent.sightRadius, { isSensor = true })
  timer.performWithDelay(10, function() 
    local charSet = Collision:filterSensors(toggleables.sightRadius.collision.collidedObjects)
    
    -- FILTER ENEMIES AND GUARDIANS
    local enemySet, guardianSet = {}, {}
    for i, v in ipairs(charSet) do
      if v.parent.side == 'guardian' then
        table.insert(guardianSet, v)
      elseif v.parent.side == 'monster' then 
        table.insert(enemySet, v)
      end
    end

    -- REQUEST ONENEMYSEEN EXECUTE IF ENEMY SET HAS NUMBER, ELSE ONALLYSEEN ON SAME SCENARIO, ELSE NONE
    if #enemySet > 0 then 
      parent.onEnemySeen(enemySet[1].parent)
    elseif #guardianSet > 0 then
      parent.events.eventSet['onAllySeen'].target = guardianSet[1]
      parent.events.execute('onAllySeen', 1)
    end
  end, 0)
  toggleables.sightRadius:setFillColor(1, 0.25)
  toggleables.skillButton = display.newCircle(toggleables, 75, 0, 30)
  toggleables.skillButton:addEventListener('touch', function(event) 
    if event.phase == 'ended' then
      parent.events.view = EventRenderer:prepareEventList(parent.events)
      parent.events.view.isVisible = true
    end
  end)
  toggleables.itemButton = display.newCircle(toggleables, 150, 0, 30)
  toggleables.isVisible = false
  guardianGroup.toggleables = toggleables
  guardianGroup:insert(toggleables)

  -- SETUP SPRITE
  guardianGroup.sprite = SpriteRenderer:draw(parent, options)
  guardianGroup.sprite.collision = Collision:newRectangle(parent, guardianGroup.sprite.width, guardianGroup.sprite.height)
  guardianGroup.sprite:addEventListener('touch', function(event)
    local focus = event.target
    local stage = display.getCurrentStage()
    if event.phase == 'began' then
      stage:setFocus(focus, event.id)
      focus.isFocus = true

      -- ALLOWS ONE GUARDIAN TO BE SELECTED
      if GuardianRenderer.activeGuardian then
        GuardianRenderer.activeGuardian.view.toggleables.isVisible = false
        parent.info.isVisible = false
        if parent == GuardianRenderer.activeGuardian then
          GuardianRenderer.activeGuardian = nil
        else
          GuardianRenderer.activeGuardian = parent
          GuardianRenderer.activeGuardian.view.toggleables.isVisible = true
          parent.info = GuardianRenderer:prepareInfo(parent)
          parent.info.isVisible = true
        end
      else
        GuardianRenderer.activeGuardian = parent
        GuardianRenderer.activeGuardian.view.toggleables.isVisible = true
        parent.info = GuardianRenderer:prepareInfo(parent)
        parent.info.isVisible = true
      end
    elseif event.phase == 'moved' then
      guardianGroup.sprite.animate('Drag')
      parent.x = event.x
      parent.y = event.y
    elseif event.phase == 'ended' or event.phase == 'cancelled' then
      guardianGroup.sprite.animate('StandingDown')
      stage:setFocus(focus, nil)
      focus.isFocus = false
    end    
    return true
  end)
  guardianGroup.sprite:addEventListener('tap', function(event) 
    if event.numTaps >= 2 then
      parent.destroy()
    end
    return true
  end)
  guardianGroup.sprite.isVisible = true
  guardianGroup:insert(guardianGroup.sprite)

  -- SETUP QUESTION SPRITE 
  guardianGroup.question = display.newText('Ummm... What will I do?', 0, guardianGroup.health.y - guardianGroup.health.height / 2 - 20, native.systemFont, 24)
  guardianGroup.question.isVisible = false
  guardianGroup:insert(guardianGroup.question)

  -- SETUP DESTROY SPRITE
  local smoke = { class = 'Smoke' }
  guardianGroup.smokeSprite = SpriteRenderer:draw(smoke)
  guardianGroup.smokeSprite.isVisible = false
  guardianGroup:insert(guardianGroup.smokeSprite)

  -- ANIMATE SPRITE IF OPTIONS DICTATE START
  if options.isStart then
    guardianGroup.sprite.y = -50
    guardianGroup.sprite.animate('Drop')
    transition.to(guardianGroup.sprite, {
      y = 0,
      time = 125
    }) 
  end

  -- REMOVE ALL DISPLAYS OF INFOS
  parent.info = GuardianRenderer:prepareInfo(parent)
  parent.info.isVisible = true

  -- SETUP DISPLAY GROUP
  local displayGroup = display.newGroup()
  displayGroup:insert(guardianGroup)
  displayGroup:insert(parent.info)

  guardianGroup.isVisible = false
  return guardianGroup
end

function GuardianRenderer:prepareInfo(parent)
  -- WINDOW GROUP
  local windowGroup = display.newGroup()

  -- BACKGROUND
  local background = display.newRect(windowGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
  background.alpha = 0
  background:setFillColor(0, 0.75)
  background:addEventListener('touch', function(event) return true end)

  -- INFORMATION DISPLAY
  local string = 
parent.desc .. '\n\n' .. 
[[{
    guardian.class = "]] .. parent.class .. [[" 
    guardian.baseHealth = ]] .. parent.health .. [[ 
    guardian.attack = ]] .. parent.attack .. [[ 
    guardian.defense = ]] .. parent.defense .. [[ 
    guardian.speed = ]] .. parent.speed .. [[ 
    guardian.slackTime = ]] .. parent.slackTime .. [[ 
    guardian.sightRadius = ]] .. parent.sightRadius .. [[

} ]]
  local infoGroup = display.newGroup()
  infoGroup.container = display.newRoundedRect(infoGroup, 0, 0, 500, 750, 10)
  infoGroup.iconContainer = display.newCircle(infoGroup, 0, -(infoGroup.container.height / 2), 75)
  infoGroup.icon = display.newCircle(infoGroup, 0, -(infoGroup.container.height / 2), 50)
  infoGroup.icon.fill = {
    type = 'image', 
    filename = 'Assets/ClassIcons/' .. parent.class .. 'White.png'
  }
  infoGroup.text = display.newText({
    parent = infoGroup,
    text = string, 
    width = 400,
    x = infoGroup.container.x, 
    font = native.systemFont, 
    fontSize = 24,
  })
  infoGroup.text.y = -(infoGroup.container.height / 2) + (infoGroup.icon.height / 2) + (infoGroup.text.height / 2) + 50, 
  infoGroup.text:setFillColor(0)

  infoGroup.x = display.contentCenterX
  infoGroup.y = display.contentHeight + (infoGroup.height / 2) - 125
  local yStatic = infoGroup.y
  infoGroup:addEventListener('touch', function(event) 
    if event.phase == 'moved' then
      if event.yStart > event.y then
        transition.fadeIn(background, { time = 100 })
        transition.to(infoGroup, {
          time = 100, 
          y = yStatic - infoGroup.height + 150
        })
      elseif event.yStart < event.y then
        transition.fadeOut(background, { time = 100 })
        transition.to(infoGroup, {
          time = 100, 
          y = yStatic
        })
      end
    end
    return true
  end)
  windowGroup:insert(infoGroup)

  table.insert(DisplayObject.displayObjectSet, windowGroup)
  windowGroup.isVisible = false
  return windowGroup
end

function GuardianRenderer:draw(parent, options)
  if parent.hasChanged then
    parent.view:removeSelf() 
    parent.view.isVisible = false
    parent.view = GuardianRenderer:prepare(parent, { xScale = options.xScale, yScale = options.yScale })
    parent.hasChanged = false
  end

  -- MAKE THE GUARDIAN VISIBLE IN THE GIVEN X AND Y
  parent.view.x = parent.x
  parent.view.y = parent.y 
  parent.view.isVisible = true
end

return GuardianRenderer 