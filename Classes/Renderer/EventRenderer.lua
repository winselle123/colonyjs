local Panel = require('Classes.System.Panel')

local Widget = require('widget')
local SkillRenderer = require('Classes.Renderer.SkillRenderer')
local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local EventRenderer = {
  activeEvent = 'onStart'
}

function EventRenderer:prepareEventPanel(parent)
  local eventGroup = display.newGroup() 

  eventGroup.eventContainer = display.newRoundedRect(eventGroup, 0, 0, display.contentWidth - 100, 150, 10)
  
  -- EVENT ICON
  eventGroup.eventIcon = display.newCircle(eventGroup, -(eventGroup.eventContainer.width / 2) + 75, 0, 50)
  eventGroup.eventIcon.strokeWidth = 3 
  eventGroup.eventIcon:setStrokeColor(0)
  eventGroup.eventIcon.fill = {
    type = 'image', 
    filename = 'Assets/EventIcons/Placeholder.png'
  }

  -- EVENT NAME
  eventGroup.eventName = display.newText(eventGroup, parent.name, 0, 0, native.systemFont, 28)
  eventGroup.eventName.x = eventGroup.eventIcon.x + eventGroup.eventIcon.width / 2 + eventGroup.eventName.width / 2 + 25 
  eventGroup.eventName.y = -(eventGroup.eventIcon.height / 2) + eventGroup.eventName.height / 2
  eventGroup.eventName:setFillColor(0)
  
  -- EVENT DESCRIPTION
  eventGroup.eventDescription = display.newText({ 
    parent = eventGroup, 
    text = parent.description, 
    font = native.systemFont, 
    fontSize = 20,
    width = eventGroup.eventContainer.width - eventGroup.eventIcon.width / 2 - 125
  })
  eventGroup.eventDescription.x = eventGroup.eventIcon.x + eventGroup.eventIcon.width / 2 + eventGroup.eventDescription.width / 2 + 25 
  eventGroup.eventDescription.y = eventGroup.eventName.y + eventGroup.eventName.height / 2 + eventGroup.eventDescription.height / 2 + 10
  eventGroup.eventDescription:setFillColor(0)

  eventGroup.isVisible = false
  return eventGroup
end

function EventRenderer:prepareEventList(parent)
  local displayGroup = display.newGroup()

  -- SKILL VIEW 
  displayGroup.skillView = SkillRenderer:prepareSkillList(parent.eventSet[EventRenderer.activeEvent])
  displayGroup.skillView.y = display.contentHeight - displayGroup.skillView.height / 2
  displayGroup:insert(displayGroup.skillView)

  -- SCROLL VIEW
  displayGroup.eventList = Widget.newScrollView({
    width = display.contentWidth,
    height = display.contentHeight * 0.85,
    left = -(display.contentWidth / 2),
    autoHideScrollBar = false,
    backgroundColor = { 0, 0, 0 },
    horizontalScrollDisabled = true,
  }) 

  local index = 1
  for k, v in pairs(parent.eventSet) do
    v.view.isVisible = true
    v.view.x = display.contentCenterX
    v.view.y = v.view.height / 2 + (index - 1) * v.view.height + index * 50
    v.view.xScale, v.view.yScale = 1, 1
    v.view:addEventListener('touch', function(event) 
      if event.phase == 'began' then
        -- ALLOWS ONE EVENT TO BE SELECTED
        if v ~= parent.eventSet[EventRenderer.activeEvent] then
          transition.to(parent.eventSet[EventRenderer.activeEvent].view, {
            xScale = 1, 
            yScale = 1, 
            time = 50, 
            onComplete = function() 
              EventRenderer.activeEvent = k
            end
          })
          transition.to(v.view, {
            xScale = 1.1,
            yScale = 1.1, 
            time = 50, 
            onComplete = function() 
              displayGroup.skillView.isVisible = false
              displayGroup.skillView = SkillRenderer:prepareSkillList(parent.eventSet[EventRenderer.activeEvent])
              displayGroup.skillView.y = display.contentHeight - displayGroup.skillView.height / 2
              displayGroup:insert(displayGroup.skillView)
            end
          })
        end
      end
    end)
    index = index + 1

    -- ENLARGE IF ACTIVE EVENT
    if v == parent.eventSet[EventRenderer.activeEvent] then
      v.view.xScale, v.view.yScale = 1.1, 1.1
    end

    displayGroup.eventList:insert(v.view)
  end
  displayGroup:insert(displayGroup.eventList)

  -- CLOSE BUTTON
  displayGroup.btn_Closer = ComponentRenderer:renderButton('Assets/Buttons/Btn_Close.png', {
    filename_clicked = 'Assets/Buttons/Btn_CloseClicked.png',
    width = 86, 
    height = 86,
  })
  displayGroup.btn_Closer.x = display.contentWidth / 2 - displayGroup.btn_Closer.width / 2
  displayGroup.btn_Closer.y = displayGroup.btn_Closer.height / 2
  displayGroup.btn_Closer:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      transition.fadeOut(displayGroup, {
        time = 100, 
        onComplete = function() 
          displayGroup.isVisible = false
        end
      })
      transition.fadeOut(displayGroup.eventList, {
        time = 100, 
        onComplete = function() 
          displayGroup.isVisible = false
        end
      })
    end
    return true
  end)
  displayGroup:insert(displayGroup.btn_Closer)

  displayGroup.x = display.contentCenterX
  displayGroup.isVisible = false
  table.insert(Panel.panelSet, displayGroup)
  return displayGroup
end

return EventRenderer