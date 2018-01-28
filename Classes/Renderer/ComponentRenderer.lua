local SpriteRenderer = require('Classes.Renderer.SpriteRenderer')

local ComponentRenderer = {}

function ComponentRenderer:renderButton(filename, attributes)
  local buttonGroup = display.newGroup() 
  local button = display.newImageRect(filename, attributes.width, attributes.height)
  buttonGroup:insert(button)

  local buttonClicked
  if attributes.filename_clicked then
    buttonClicked = display.newImageRect(attributes.filename_clicked, attributes.width, attributes.height)
    buttonClicked.isVisible = false
    buttonGroup:insert(buttonClicked)
  end

  if not attributes.isDisabled then
    local invisibleTrigger = display.newRect(0, 0, attributes.width, attributes.height)
    invisibleTrigger.isVisible = false
    invisibleTrigger.isHitTestable = true
    buttonGroup:insert(invisibleTrigger)
    invisibleTrigger:addEventListener('touch', function(event)
      if event.phase == 'began' then
        buttonClicked.isVisible = true
        button.isVisible = false
      elseif event.phase == 'ended' then
        buttonClicked.isVisible = false
        button.isVisible = true
      end
    end)
  end

  buttonGroup.x = attributes.x and attributes.x or 0
  buttonGroup.y = attributes.y and attributes.y or 0
  return buttonGroup
end

function ComponentRenderer:renderClicker(x, y)
  local touch = { class = 'Touch' }
  local ripple = SpriteRenderer:draw(touch)
  ripple:addEventListener('sprite', function(event) 
    if event.phase == 'ended' then
      ripple.isVisible = false
      ripple = nil
    end
  end)
  ripple.xScale, ripple.yScale = 1.5, 1.5
  ripple.x, ripple.y = x, y
  ripple.animate('Ripple')
end

return ComponentRenderer