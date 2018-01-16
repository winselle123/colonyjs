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

return ComponentRenderer