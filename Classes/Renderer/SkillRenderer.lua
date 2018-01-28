local Widget = require('widget')

local String = require('Classes.System.String')
local DisplayObject = require('Classes.System.DisplayObject')
local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local SkillRenderer = {}

function SkillRenderer:prepareSkillList(parent, options) 
  local displayGroup = display.newGroup()

  -- CONTAINER
  displayGroup.skillContainer = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight * 0.15)

  -- CARDS
  displayGroup.cardSetGroup = display.newGroup()
  
  local index = 1
  for i, v in ipairs(parent) do
    displayGroup.cardSetGroup[v] = {}
    displayGroup.cardSetGroup[v].cardGroup = display.newGroup()
    displayGroup.cardSetGroup[v].cardGroup.cardContainer = display.newRoundedRect(displayGroup.cardSetGroup[v].cardGroup, 0, 0, 130, 175, 10)
    displayGroup.cardSetGroup[v].cardGroup.cardContainer.fill = {
      type = 'image',
      filename = 'Assets/SkillIcons/Placeholder.png'
    }
    displayGroup.cardSetGroup[v].cardGroup.cardContainer.strokeWidth = 3
    displayGroup.cardSetGroup[v].cardGroup.cardContainer:setStrokeColor(0)
    displayGroup.cardSetGroup[v].cardGroup.x = displayGroup.cardSetGroup[v].cardGroup.width / 2 + (index - 1) * displayGroup.cardSetGroup[v].cardGroup.width + index * 10
    displayGroup.cardSetGroup[v].cardGroup.cardContainer:addEventListener('touch', function(event) 
      if event.phase == 'ended' then
        SkillRenderer:updateSkill(v)
      end
      return true
    end)

    displayGroup.cardSetGroup[v].cardGroup.cardRemover = ComponentRenderer:renderButton('Assets/Buttons/Btn_Remove.png', {
      filename_clicked = 'Assets/Buttons/Btn_RemoveClicked.png',
      width = 50, 
      height = 50,
    })
    displayGroup.cardSetGroup[v].cardGroup.cardRemover.x = displayGroup.cardSetGroup[v].cardGroup.cardContainer.x
    displayGroup.cardSetGroup[v].cardGroup.cardRemover.y = displayGroup.cardSetGroup[v].cardGroup.cardContainer.y + displayGroup.cardSetGroup[v].cardGroup.cardContainer.height / 2 - displayGroup.cardSetGroup[v].cardGroup.cardRemover.height / 2
    displayGroup.cardSetGroup[v].cardGroup.cardRemover:addEventListener('touch', function(event) 
      if event.phase == 'ended' then
        local index = 0 
        for i, r in ipairs(parent) do -- WHERE R IS THE VARIABLE FOR THE SKILL TO BE REMOVED
          if r == v then
            index = i
          end
        end
        table.remove(parent, index)

        -- UPDATE SKILL DISPLAY
        options.skillDisplay.isVisible = false
        options.skillDisplay = SkillRenderer:prepareSkillList(parent, { skillDisplay = options.skillDisplay, skillDisplayGroup = options.skillDisplayGroup, isOffensive = options.isOffensive })
        options.skillDisplay.y = display.contentHeight - options.skillDisplay.height / 2
        options.skillDisplayGroup:insert(options.skillDisplay)
        options.skillDisplay.isVisible = true
      end
      return true
    end)
    displayGroup.cardSetGroup[v].cardGroup:insert(displayGroup.cardSetGroup[v].cardGroup.cardRemover)

    displayGroup.cardSetGroup:insert(displayGroup.cardSetGroup[v].cardGroup)

    index = index + 1
  end
  if index <= 5 then
    displayGroup.cardSetGroup.addCardGroup = display.newGroup()
    displayGroup.cardSetGroup.addCardGroup.addCardContainer = display.newRoundedRect(displayGroup.cardSetGroup.addCardGroup, 0, 0, 130, 175, 10)
    displayGroup.cardSetGroup.addCardGroup.addCardContainer.fill = {
      type = 'image', 
      filename = 'Assets/SkillIcons/AddCard.png'
    }
    displayGroup.cardSetGroup.addCardGroup.addCardContainer.strokeWidth = 3
    displayGroup.cardSetGroup.addCardGroup.addCardContainer:setStrokeColor(0)
    displayGroup.cardSetGroup.addCardGroup.x = displayGroup.cardSetGroup.addCardGroup.width / 2 + (index - 1) * displayGroup.cardSetGroup.addCardGroup.width + index  * 10

    -- EVENT LISTENER FOR THE ADD CARD
    displayGroup.cardSetGroup.addCardGroup:addEventListener('touch', function(event) 
      if event.phase == 'ended' then
        SkillRenderer:pickSkill(parent, options)
      end
      return true
    end)

    displayGroup.cardSetGroup:insert(displayGroup.cardSetGroup.addCardGroup)
  end
  displayGroup.cardSetGroup.x = -(display.contentWidth / 2)
  displayGroup:insert(displayGroup.cardSetGroup)

  table.insert(DisplayObject.displayObjectSet, displayGroup)
  return displayGroup
end

function SkillRenderer:updateSkill(skill)
  local displayGroup = display.newGroup()

  -- BACKGROUND
  displayGroup.background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight)
  displayGroup.background:setFillColor(0, 0.9) 
  displayGroup:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      displayGroup:removeSelf()
      displayGroup.isVisible = false
    end
    return true
  end)

  -- CARD INFORMATION
  displayGroup.infoGroup = display.newGroup()
  displayGroup.infoGroup.card = display.newRoundedRect(displayGroup.infoGroup, 0, 0, 200, 270, 10)
  displayGroup.infoGroup.card.fill = {
    type = 'image', 
    filename = 'Assets/SkillIcons/Placeholder.png'
  }  
  displayGroup.infoGroup.cardName = display.newText(displayGroup.infoGroup, skill.name .. '()', 0, displayGroup.infoGroup.card.y + displayGroup.infoGroup.card.height / 2 + 48, native.systemFont, 36)
  displayGroup.infoGroup.cardDescription = display.newText({
    parent = displayGroup.infoGroup, 
    text = skill.desc, 
    y = displayGroup.infoGroup.cardName.y + displayGroup.infoGroup.cardName.height / 2 + 100,
    width = display.contentWidth - 100, 
    align = 'center',
    fontSize = 24
  })

  -- PARAMETERS
  if skill.params then
    local index = 1
    displayGroup.infoGroup.paramSetGroup = display.newGroup()
    for k, v in pairs(skill.params) do
      displayGroup.infoGroup.paramSetGroup[k] = display.newGroup()
      displayGroup.infoGroup.paramSetGroup[k].paramContainer = display.newRoundedRect(displayGroup.infoGroup.paramSetGroup[k], 0, 0, 200, 50, 10)
      
      displayGroup.infoGroup.paramSetGroup[k].paramField = native.newTextField(displayGroup.infoGroup.paramSetGroup[k].paramContainer.x, displayGroup.infoGroup.paramSetGroup[k].paramContainer.y, displayGroup.infoGroup.paramSetGroup[k].paramContainer.width, displayGroup.infoGroup.paramSetGroup[k].paramContainer.height)
      displayGroup.infoGroup.paramSetGroup[k].paramField.placeholder = v
      displayGroup.infoGroup.paramSetGroup[k].paramField.hasBackground = false
      displayGroup.infoGroup.paramSetGroup[k]:insert(displayGroup.infoGroup.paramSetGroup[k].paramField)

      displayGroup.infoGroup.paramSetGroup[k].paramText = display.newText({
        parent = displayGroup.infoGroup.paramSetGroup[k],
        text = k .. ': ',
        fontSize = 28
      })
      displayGroup.infoGroup.paramSetGroup[k].paramText.x = -(displayGroup.infoGroup.paramSetGroup[k].paramContainer.width / 2) - displayGroup.infoGroup.paramSetGroup[k].paramText.width / 2 - 25

      displayGroup.infoGroup.paramSetGroup[k].y = displayGroup.infoGroup.paramSetGroup[k].height / 2 + (index - 1) * displayGroup.infoGroup.paramSetGroup[k].height + index * 25
      displayGroup.infoGroup.paramSetGroup:insert(displayGroup.infoGroup.paramSetGroup[k])
      
      index = index + 1
    end
    displayGroup.infoGroup.paramSetGroup.y = displayGroup.infoGroup.cardDescription.y + displayGroup.infoGroup.cardDescription.height / 2 + 100
    displayGroup.infoGroup:insert(displayGroup.infoGroup.paramSetGroup)
  end

  displayGroup.infoGroup.y = -(displayGroup.infoGroup.height / 2)
  displayGroup:insert(displayGroup.infoGroup)

  -- UPDATE BUTTON
  displayGroup.btn_Equip = ComponentRenderer:renderButton('Assets/Buttons/Btn_Update.png', {
    filename_clicked = 'Assets/Buttons/Btn_UpdateClicked.png',
    width = 300, 
    height = 86,
  })
  displayGroup.btn_Equip.x = -(displayGroup.btn_Equip.width / 2 + 25)
  displayGroup.btn_Equip.y = (display.contentHeight / 2 - displayGroup.btn_Equip.height / 2) - 150
  displayGroup.btn_Equip:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      -- PREPARE PARAMETERS IF ANY
      local paramKeyValue = nil

      -- HIDE DISPLAY GROUPS
      for k, v in pairs(skill.params) do
        skill.params[k] = displayGroup.infoGroup.paramSetGroup[k].paramField.text ~= '' and displayGroup.infoGroup.paramSetGroup[k].paramField.text or v -- TRIM TEXT
      end
      displayGroup:removeSelf()
      displayGroup.isVisible = false
    end
    return true
  end)
  displayGroup:insert(displayGroup.btn_Equip)

  -- CANCEL BUTTON
  displayGroup.btn_Cancel = ComponentRenderer:renderButton('Assets/Buttons/Btn_Cancel.png', {
    filename_clicked = 'Assets/Buttons/Btn_CancelClicked.png',
    width = 300, 
    height = 86,
  })
  displayGroup.btn_Cancel.x = displayGroup.btn_Cancel.width / 2 + 25
  displayGroup.btn_Cancel.y = (display.contentHeight / 2 - displayGroup.btn_Cancel.height / 2) - 150
  displayGroup.btn_Cancel:addEventListener('touch', function(event)
    if event.phase == 'ended' then 
      displayGroup:removeSelf()
      displayGroup.isVisible = false
    end
    return true
  end)
  displayGroup:insert(displayGroup.btn_Cancel)

  displayGroup.x = display.contentCenterX
  displayGroup.y = display.contentCenterY  

  table.insert(DisplayObject.displayObjectSet, displayGroup)
end

function SkillRenderer:pickSkill(parent, options)
  local displayGroup = display.newGroup() 

  -- HEADER
  displayGroup.header = display.newRect(displayGroup, 0, 0, display.contentWidth, 150)
  displayGroup.header.y = -(display.contentHeight / 2) + displayGroup.header.height / 2

  -- CARD PICKER
  displayGroup.cardPicker = Widget.newScrollView({
    width = display.contentWidth, 
    height = display.contentHeight - 300, 
    left = -(display.contentWidth / 2),
    autoHideScrollBar = false, 
    backgroundColor = { 0, 0, 0 },
    horizontalScrollDisabled = true
  })
  displayGroup.cardPicker.y = 0
  displayGroup:insert(displayGroup.cardPicker)

  local skillFileName = 'Contents/Skills/SkillSet.txt'
  local skillPath = system.pathForFile(skillFileName)
  local skillFile, err = io.open(skillPath, 'r') 
  if not skillFile then
    -- LOG SKILL FILE NOT FOUND
  else
    local xIndex, yIndex = 1, 1
    local skillName, skillType, skillDesc = skillFile:read(), skillFile:read(), skillFile:read() 
    while skillName do
      if not skillName then break end

      local skill = {
        name = String:filterLetters(skillName), 
        type = String:filterLetters(skillType),
        desc = skillDesc,
      }

      local card = display.newRoundedRect(0, 0, 130, 175, 10)
      card.fill = {
        type = 'image', 
        filename = 'Assets/SkillIcons/Placeholder.png'
      }
      card.x = card.width / 2 + (xIndex - 1) * card.width + xIndex * 50
      card.y = card.height / 2 + (yIndex - 1) * card.height + yIndex * 50
      card:addEventListener('touch', function(event) 
        if event.phase == 'ended' then
          options.parentDisplay = displayGroup
          SkillRenderer:displayCardInformation(parent, skill, options)
        end
        return true
      end) 
      displayGroup.cardPicker:insert(card)

      yIndex = xIndex >= 4 and yIndex + 1 or yIndex 
      xIndex = xIndex >= 4 and 1 or xIndex + 1

      skillName, skillType, skillDesc = skillFile:read(), skillFile:read(), skillFile:read()
    end
  end

  -- CONTAINER FOR CANCEL BUTTON 
  displayGroup.cancelContainer = display.newRect(displayGroup, 0, display.contentHeight / 2 - 75, display.contentWidth, 150)

  -- CANCEL BUTTON
  displayGroup.btn_Cancel = ComponentRenderer:renderButton('Assets/Buttons/Btn_Cancel.png', {
    filename_clicked = 'Assets/Buttons/Btn_CancelClicked.png',
    width = 300, 
    height = 86,
  })
  displayGroup.btn_Cancel.y = display.contentHeight / 2 - 75
  displayGroup.btn_Cancel:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      displayGroup.isVisible = false
    end
  end)
  displayGroup:insert(displayGroup.btn_Cancel)

  displayGroup.x = display.contentCenterX
  displayGroup.y = display.contentCenterY

  table.insert(DisplayObject.displayObjectSet, displayGroup)
end

function SkillRenderer:displayCardInformation(parent, skill, options)
  -- READY PARAMETER FILE
  local paramFileName = 'Contents/Skills/' .. String:toTitleCase(skill.name) .. '.txt'
  local paramPath = system.pathForFile(paramFileName)
  local paramFile = paramPath and io.open(paramPath, 'r') or nil

  local displayGroup = display.newGroup() 

  -- BACKGROUND
  displayGroup.background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight)
  displayGroup.background:setFillColor(0, 0.9) 
  displayGroup:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      displayGroup:removeSelf()
      displayGroup.isVisible = false
    end
    return true
  end)

  -- CARD INFORMATION
  displayGroup.infoGroup = display.newGroup()
  displayGroup.infoGroup.card = display.newRoundedRect(displayGroup.infoGroup, 0, 0, 200, 270, 10)
  displayGroup.infoGroup.card.fill = {
    type = 'image', 
    filename = 'Assets/SkillIcons/Placeholder.png'
  }  
  displayGroup.infoGroup.cardName = display.newText(displayGroup.infoGroup, skill.name .. '()', 0, displayGroup.infoGroup.card.y + displayGroup.infoGroup.card.height / 2 + 48, native.systemFont, 36)
  displayGroup.infoGroup.cardDescription = display.newText({
    parent = displayGroup.infoGroup, 
    text = skill.desc, 
    y = displayGroup.infoGroup.cardName.y + displayGroup.infoGroup.cardName.height / 2 + 100,
    width = display.contentWidth - 100, 
    align = 'center',
    fontSize = 24
  })

  -- PARAMETERS
  if paramPath then
    displayGroup.infoGroup.paramSetGroup = display.newGroup()
    local index = 1
    local param = paramFile:read() 
    while param do
      local paramSplit = String:split(param, ' ')

      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ] = display.newGroup()
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer = display.newRoundedRect(displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ], 0, 0, 200, 50, 10)
      
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField = native.newTextField(displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer.x, displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer.y, displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer.width, displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer.height)
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.placeholder = paramSplit[2]
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.hasBackground = false
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ]:insert(displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField)

      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramText = display.newText({
        parent = displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ],
        text = paramSplit[1] .. ': ',
        fontSize = 28
      })
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramText.x = -(displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramContainer.width / 2) - displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramText.width / 2 - 25

      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].y = displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].height / 2 + (index - 1) * displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].height + index * 25
      displayGroup.infoGroup.paramSetGroup:insert(displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ])
      
      index = index + 1
      param = paramFile:read()
    end
    io.close(paramFile)
    displayGroup.infoGroup.paramSetGroup.y = displayGroup.infoGroup.cardDescription.y + displayGroup.infoGroup.cardDescription.height / 2 + 100
    displayGroup.infoGroup:insert(displayGroup.infoGroup.paramSetGroup)
  end

  displayGroup.infoGroup.y = -(displayGroup.infoGroup.height / 2)
  displayGroup:insert(displayGroup.infoGroup)

  -- EQUIP BUTTON
  displayGroup.btn_Equip = ComponentRenderer:renderButton('Assets/Buttons/Btn_Equip.png', {
    filename_clicked = 'Assets/Buttons/Btn_EquipClicked.png',
    width = 300, 
    height = 86,
  })
  displayGroup.btn_Equip.x = -(displayGroup.btn_Equip.width / 2 + 25)
  displayGroup.btn_Equip.y = (display.contentHeight / 2 - displayGroup.btn_Equip.height / 2) - 150
  displayGroup.btn_Equip:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      -- PREPARE PARAMETERS IF ANY
      local paramKeyValue = nil

      -- HIDE DISPLAY GROUPS
      if paramPath then
        paramKeyValue = {}
        paramFile = io.open(paramPath, 'r')
        local param = paramFile:read()
        while param do 
          local paramSplit = String:split(param, ' ')
          paramKeyValue[ paramSplit[1] ] = displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.text ~= '' and displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.text or paramSplit[2] -- TRIM TEXT

          param = paramFile:read()
        end
        io.close(paramFile)

        skill.params = paramKeyValue
      end
      options.parentDisplay.isVisible = false
      displayGroup:removeSelf()
      displayGroup.isVisible = false

      -- INSERT SKILL
      table.insert(parent, skill)

      -- UPDATE SKILL LIST
      options.skillDisplay.isVisible = false
      options.skillDisplay = SkillRenderer:prepareSkillList(parent, { skillDisplay = options.skillDisplay, skillDisplayGroup = options.skillDisplayGroup, isOffensive = options.isOffensive })
      options.skillDisplay.y = display.contentHeight - options.skillDisplay.height / 2
      options.skillDisplayGroup:insert(options.skillDisplay)
      options.skillDisplay.isVisible = true
    end
    return true
  end)
  displayGroup:insert(displayGroup.btn_Equip)

  -- CANCEL BUTTON
  displayGroup.btn_Cancel = ComponentRenderer:renderButton('Assets/Buttons/Btn_Cancel.png', {
    filename_clicked = 'Assets/Buttons/Btn_CancelClicked.png',
    width = 300, 
    height = 86,
  })
  displayGroup.btn_Cancel.x = displayGroup.btn_Cancel.width / 2 + 25
  displayGroup.btn_Cancel.y = (display.contentHeight / 2 - displayGroup.btn_Cancel.height / 2) - 150
  displayGroup.btn_Cancel:addEventListener('touch', function(event)
    if event.phase == 'ended' then 
      displayGroup:removeSelf()
      displayGroup.isVisible = false
    end
    return true
  end)
  displayGroup:insert(displayGroup.btn_Cancel)

  displayGroup.x = display.contentCenterX
  displayGroup.y = display.contentCenterY
  
  table.insert(DisplayObject.displayObjectSet, displayGroup)
end

return SkillRenderer