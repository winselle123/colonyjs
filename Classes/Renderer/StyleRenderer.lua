local Widget = require('widget')
local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local StyleRenderer = {}

function StyleRenderer:renderStyle()
  local background = display.newImageRect('Assets/Backgrounds/grass.png', display.contentWidth, display.contentHeight)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local chooseGroup = display.newGroup()
  local guardianIcon
  local xIcons = display.contentWidth * .05
  local ctr = 1
  local count = 1
  local num3
  local itemGroup = display.newGroup()
  local containerGroup = display.newGroup()
  local class = ''
  local item = {}
  local itemList = {}
  local currentItem = {}
  local saveItem = ''
  local temp = ''
  local rectContainer
  local sprite

  function tryIt (params)
    local ctr2 = 1
    local pathTwo = system.pathForFile('Contents/Styles/' .. class .. '.txt', system.ResourceDirectory) 
    local filed = io.open(pathTwo, 'r')
    while ctr2 <= #item do
      table.remove(item, ctr2)
    end
    for val in filed:lines() do
      if string.find(val, itemList[params]) then
        table.insert(item, val)
	  end
	end
	filed:close()
  end

  local chooseContain = display.newRect(chooseGroup, 0, 0, display.contentWidth * 2, display.contentHeight * .2 )
  chooseContain:setFillColor(1, 1, 1)
  local scrollGuardian = Widget.newScrollView({
    width = display.contentWidth * 2,
    height = display.contentHeight * 0.2,
    left = (display.contentWidth * .1),
    autoHideScrollBar = false,
    backgroundColor = { 0, 0, 0 },
    hideBackground = true,
    verticalScrollDisabled = true,
  }) 
  chooseGroup:insert(scrollGuardian)
	
  local path = system.pathForFile('Contents/Guardians/GuardianSet.txt', system.ResourceDirectory) 
  local file = io.open(path, 'r')
	
  if not file then
    display.newText('File not found', display.contentCenterX, 900, native.systemFont, 24)
  else
    for line in file:lines() do
      guardianIcon = Widget.newButton{
	    width = 50,
	    height = 50,
	    id = ctr,
	    x = xIcons,
	    y = display.contentHeight *.06,
	    defaultFile = 'Assets/ClassIcons/' .. line .. '.png',
	    overFile = 'Assets/ClassIcons/' .. line .. '.png',
	    onEvent = function( event )
		    if event.phase == 'ended' then
			    if saveButton ~= nil then
			      display.remove(saveButton)
				end
			
			sprite = display.newImageRect('Assets/Sprites/SpriteTry.png', 75, 100)
			sprite.x = display.contentCenterX + 170
			sprite.y = display.contentCenterY 
			
			saveButton = ComponentRenderer:renderButton('Assets/Buttons/Btn_Play.png', {
				filename_clicked = 'Assets/Buttons/Btn_PlayClicked.png', width =250, height = 86,
			})
			saveButton.x = display.contentWidth * .75
			saveButton.y = display.contentHeight* .75
			saveButton:addEventListener('touch', function (event)
			  if event.phase == 'ended' then
				saveItem = ''
				local num = count - 1 
				while num >= 1 do
				  if currentItem[num] == nil then
				    path = system.pathForFile(class .. '.txt', system.DocumentsDirectory) 
					file = io.open(path, 'r')
					if not file then
					  path = system.pathForFile('Contents/Preference/' .. class .. '.txt', system.ResourceDirectory)
					  file = io.open(path, 'r')
					  num3 = num
					  while num3 > 0 do
						temp = file:read()
						num3 = num3 - 1
					  end
					else
					  num3 = num
					  while num3 > 0 do
						temp = file:read()
						num3 = num3 - 1
					  end
					end
				  file:close()
				  currentItem[num] = temp
				  end
				saveItem = currentItem[num] .. '\n' .. saveItem
				num = num - 1
				end
				
				path = system.pathForFile(class .. '.txt', system.DocumentsDirectory) 
				file = io.open(path, 'w')
				if not file then
				  display.newText('File not found', display.contentCenterX, 900, native.systemFont, 24)
				else
				  file:write(saveItem)
				  io.close(file)
				end
			  end
			  return true
			end)
			
			if containerGroup ~= nil then
			  display.remove(containerGroup)
			  containerGroup=display.newGroup()
			end
			if itemGroup ~= nil then
			  display.remove(itemGroup)
			  itemGroup=display.newGroup()
			end
			
			itemList = {}
			currentItem = {}
			item = {}
			local itemIndex = 0
			count = 1
			local num2 = 1
			local sentence
			local saveButton
			local showImage
			local xOfButton = display.contentWidth * .1
			local xOfButton2 = xOfButton + 215
			local yOfButton = display.contentHeight * .2
			class = line
			local image

			local arrowsContain = display.newRoundedRect(containerGroup, display.contentWidth * .25, display.contentHeight * .54, display.contentWidth * .4, display.contentHeight *.87, 25 )
			chooseContain:setFillColor(1, 1, 1)
			path = system.pathForFile('Contents/Styles/StyleChange.txt', system.ResourceDirectory) 
			file = io.open(path, 'r')
			if not file then
			  display.newText('File not found', display.contentCenterX, 900, native.systemFont, 24)	
			else
			  while true do
				sentence = file:read()
				if sentence == nil then break end
				if string.find(sentence, class) then
				  sentence = sentence:gsub(class, '')
				  table.insert(itemList, sentence)
				  
				  leftButton = Widget.newButton{
					width = 50,
					height = 50,
					id = count,
					x = xOfButton,
					y = yOfButton,
					defaultFile = 'Assets/Buttons/Btn_Left.png',
					overFile = 'Assets/Buttons/Btn_Left.png',
					onEvent = function( event )
					  if event.phase == 'ended' then
					    tryIt(event.target.id)
					    itemIndex = itemIndex - 1
					    if itemIndex <= 0 then
						  itemIndex = 1
					    end
					    if currentItem[itemIndex] ~= nil then
						  table.remove(currentItem, event.target.id) 
						end
					    table.insert(currentItem, event.target.id, item[itemIndex])
					    showImage = display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[event.target.id] .. '/' .. currentItem[event.target.id] .. '.png', 75, 100)
					    showImage.x = display.contentCenterX + 170
					    showImage.y = display.contentCenterY
					    showImage = display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[event.target.id] .. '/' .. currentItem[event.target.id] .. '.png', 75, 100)
					    showImage.x = xOfButton2 - xOfButton * 1.5
					    showImage.y = display.contentHeight * .2 + ((event.target.id - 1 ) * 250)
					  end
				    end
				    }
				  
				  rectContainer = display.newRect(itemGroup, xOfButton2 - xOfButton * 1.5, yOfButton, 100, 100)
				  rectContainer:setFillColor(0, 0, 0)
				  
				  rightButton = Widget.newButton{
					width = 50,
					height = 50,
					id = count,
					x = xOfButton2,
					y = yOfButton,
					defaultFile = 'Assets/Buttons/Btn_Right.png',
					overFile = 'Assets/Buttons/Btn_Right.png',
					onEvent = function( event )
					  if event.phase == 'ended' then
					    tryIt(event.target.id)
					    itemIndex = itemIndex + 1
					    if itemIndex > #item then
						  itemIndex = itemIndex - 1
					    end
					    if currentItem[itemIndex] ~= nil then
						  table.remove(currentItem, event.target.id)
						end
					    table.insert(currentItem, event.target.id, item[itemIndex])	  
					    showImage = display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[event.target.id] .. '/' .. currentItem[event.target.id] .. '.png', 75, 100)
					    showImage.x = display.contentCenterX + 170
					    showImage.y = display.contentCenterY
					    showImage = display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[event.target.id] .. '/' .. currentItem[event.target.id] .. '.png', 75, 100)
					    showImage.x = xOfButton2 - xOfButton * 1.5
					    showImage.y = display.contentHeight * .2 + ((event.target.id - 1 ) * 250)
					  end
				    end
				    }
				  containerGroup:insert(leftButton)
				  containerGroup:insert(rightButton)
				  count = count + 1
				  yOfButton = yOfButton + 250
				end
			  end
			end
			file:close()
			path = system.pathForFile(class .. '.txt', system.DocumentsDirectory) 
			file = io.open(path, 'r')
			if not file then
			  path = system.pathForFile('Contents/Preference/' .. class .. '.txt', system.ResourceDirectory)
			  file = io.open(path, 'r')
			  for line in file:lines() do
				image=display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[num2] .. '/' .. line .. '.png', 75, 100)
				image.x = display.contentCenterX + 170
				image.y = display.contentCenterY
				num2 = num2 + 1
			  end
			else
			  for line in file:lines() do
				image=display.newImageRect(itemGroup, 'Assets/Style/' .. itemList[num2] .. '/' .. line .. '.png', 75, 100)
				image.x = display.contentCenterX + 170
				image.y = display.contentCenterY
				num2 = num2 + 1
			  end
			  file:close()
			end	
		  end
		end
		}		
		ctr = ctr + 1
		xIcons = xIcons + 75
		scrollGuardian:insert(guardianIcon)
		end
		file:close()
	end

	local leftMe = display.newImageRect(chooseGroup, 'Assets/Buttons/Btn_Left.png', 40, 40)
	leftMe.x = display.contentWidth * .05
	leftMe.y = display.contentHeight * .055
	leftMe.xScale = .5

	local rightMe = display.newImageRect(chooseGroup, 'Assets/Buttons/Btn_Right.png', 40, 40)
	rightMe.x = display.contentWidth * .95
	rightMe.y = display.contentHeight * .055
	rightMe.xScale = .5

end
return StyleRenderer