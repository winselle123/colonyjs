local String = require('Classes.System.String')
local GameObject = require('Classes.System.GameObject')
local Panel = require('Classes.System.Panel')

local Guardian = require('Classes.Game.Guardian')

local Game = {
  savedData = nil
}

function Game:_init()
  -- INITIALIZE DRAW TIMER/RENDER TIMER
  timer.performWithDelay(10, function()
    for i, v in ipairs(GameObject.gameObjectSet) do
      v.object.draw()
    end
  end, 0)


  Game:prepare() 
end

function Game:_destroy() 
  -- SAVE PROGRESS
  -- DESTROY ALL GAME OBJECTS
  for i, v in ipairs(GameObject.gameObjectSet) do
    v.view:removeSelf()
    v.view.isVisible = false
  end
  for i, v in ipairs(GameObject.gameObjectSet) do v = nil end
  GameObject.gameObjectSet = {}

  -- DESTROY ALL PANELS
  for i, v in ipairs(Panel.panelSet) do
    v:removeSelf()
    v.isVisible = false
  end
  for i, v in ipairs(Panel.panelSet) do v = nil end
  Panel.panelSet = {}
end

function Game:prepare()
  -- INITIATE PANEL FOR PICKER
  local pickerGroup = display.newGroup() 
  pickerGroup.header = display.newImageRect(pickerGroup, 'Assets/ClassIcons/Header.png', 90, 86)
  pickerGroup.header:addEventListener('touch', function(event) 
    if event.phase == 'ended' then
      if pickerGroup.pickerScroll.isVisible then
        pickerGroup.header.xScale, pickerGroup.header.yScale = 1, 1
      else
        pickerGroup.header.xScale, pickerGroup.header.yScale = 0.75, 0.75
      end
      pickerGroup.pickerScroll.isVisible = not pickerGroup.pickerScroll.isVisible and true or false
      return true
    end
  end)
  pickerGroup.pickerScroll = display.newGroup()

  local classesFileName = 'Contents/Guardians/GuardianSet.txt'
  local classesPath = system.pathForFile(classesFileName)
  local classesFile, err = io.open(classesPath, 'r')
  if not classesFile then
    -- LOG CLASS FILE NOT FOUND
  else
    local index = 1
    pickerGroup.pickerScroll.classSet = {}
    for line in classesFile:lines() do
      line = String:filterLetters(line)
      pickerGroup.pickerScroll.classSet[line] = display.newImageRect(pickerGroup.pickerScroll, 'Assets/ClassIcons/' .. line .. '.png', 60, 60)
      pickerGroup.pickerScroll.classSet[line].y = (pickerGroup.pickerScroll.classSet[line].height / 2) + ((index - 1) * (pickerGroup.pickerScroll.classSet[line].height + 20))
      pickerGroup.pickerScroll.classSet[line]:addEventListener('touch', function(event) 
        if event.phase == 'ended' then
          Guardian:new(line)
        end
        return true
      end)
      pickerGroup:insert(pickerGroup.pickerScroll)
      index = index + 1
    end
    pickerGroup.pickerScroll.y = pickerGroup.header.y + pickerGroup.header.height / 2 + 25
    pickerGroup.pickerScroll.isVisible = false
  end 

  pickerGroup.x = pickerGroup.header.width / 2 + 25
  pickerGroup.y = pickerGroup.header.height / 2 + 25
  table.insert(Panel.panelSet, pickerGroup)
end

function Game:battle() 

end

return Game