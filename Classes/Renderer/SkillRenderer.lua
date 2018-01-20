local SkillRenderer = {}

function SkillRenderer:prepareSkillList(parent) 
  local displayGroup = display.newGroup()

  -- CONTAINER
  displayGroup.skillContainer = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight * 0.15)

  -- TEXT
  displayGroup.temp = display.newText(displayGroup, parent.name, 0, 0, native.systemFont, 24)
  displayGroup.temp:setFillColor(0)

  return displayGroup
end

return SkillRenderer