local Widget = require('widget')

local String = require('Classes.System.String')
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

  return displayGroup
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

      local isDisplayed = true
      local skill = {
        name = skillName, 
        type = String:filterLetters(skillType),
        desc = skillDesc,
      }

      -- DO NOT SHOW ATTACK IF NOT IS OFFENSIVE
      if skill.type == 'offense' then
        isDisplayed = options.isOffensive
      end

      if isDisplayed then
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
      end

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
      displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.text = paramSplit[2]
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
          paramKeyValue[ paramSplit[1] ] = displayGroup.infoGroup.paramSetGroup[ paramSplit[1] ].paramField.text

          param = paramFile:read()
        end
        io.close(paramFile)
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
end

return SkillRenderer