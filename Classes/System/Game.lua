local String = require('Classes.System.String')
local Collision = require('Classes.System.Collision')
local GameObject = require('Classes.System.GameObject')
local DisplayObject = require('Classes.System.DisplayObject')
local Wave = require('Classes.System.Wave')

local ComponentRenderer = require('Classes.Renderer.ComponentRenderer')

local Guardian = require('Classes.Game.Guardian')
local Monster = require('Classes.Game.Monster')
local Event = require('Classes.Game.Event')

local Game = {
  wave = 0,
  waveGuardianCount = 0,
  waveMonsterCount = 0,

  save = nil
}

function Game:_init()
  -- INITIALIZE BACKGROUND 
  Game.background = display.newImageRect('Assets/Backgrounds/Grass.png', display.contentWidth, display.contentHeight)
  Game.background.x, Game.background.y = display.contentCenterX, display.contentCenterY

  -- INITIALIZE DRAW TIMER/RENDER TIMER
  timer.performWithDelay(1, function()
    for i, v in ipairs(GameObject.gameObjectSet) do
      v.object.draw()
    end
  end, 0)


  Game:prepare() 
end

function Game:_destroy() 
  -- SAVE PROGRESS

  -- DESTROY BACKGROUND
  Game.background.isVisible = false
  Game.background = nil

  -- EMPTY COLLIDABLE SET
  for i, v in ipairs(Collision.collisionObjectSet) do v = nil end
  Collision.collisionObjectSet = {}

  -- EMPTY GUARDIAN SET AND MONSTER SET
  for i, v in ipairs(Guardian.guardianSet) do v = nil end
  Guardian.guardianSet = {}
  for i, v in ipairs(Monster.monsterSet) do v = nil end
  Monster.monsterSet = {}

  -- DESTROY ALL GAME OBJECTS
  for i, v in ipairs(GameObject.gameObjectSet) do
    if v.object then
      transition.cancel(v.object.view)
      v.object.view.sprite:pause()

      v.object.view:removeSelf()
      v.object.view.isVisible = false
    end
  end
  for i, v in ipairs(GameObject.gameObjectSet) do v = nil end
  GameObject.gameObjectSet = {}

  -- DESTROY ALL PANELS
  for i, v in ipairs(DisplayObject.displayObjectSet) do
    if v ~= nil then
      transition.cancel(v)

      v:removeSelf()
      v.isVisible = false
    end
  end
  for i, v in ipairs(DisplayObject.displayObjectSet) do v = nil end
  DisplayObject.displayObjectSet = {}

  Game.wave = 0
end

function Game:prepare()
  Game.wave = Game.wave + 1

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

  -- BUTTON FOR GOING TO BATTLE
  local btn_Battle = ComponentRenderer:renderButton('Assets/Buttons/Btn_Play.png', { 
    filename_clicked = 'Assets/Buttons/Btn_PlayClicked.png',
    width = 300, 
    height = 86
  })
  btn_Battle.x = display.contentCenterX 
  btn_Battle.y = btn_Battle.height / 2 + 25
  btn_Battle:addEventListener('touch', function(event)
    if event.phase == 'ended' then
      pickerGroup.isVisible = false
      btn_Battle.isVisible = false
      Game:battle()
    end
    return true
  end)
  table.insert(DisplayObject.displayObjectSet, btn_Battle)

  pickerGroup.x = pickerGroup.header.width / 2 + 25
  pickerGroup.y = pickerGroup.header.height / 2 + 25
  table.insert(DisplayObject.displayObjectSet, pickerGroup)
end

function Game:battle() 
  for i, v in ipairs(Guardian.guardianSet) do
    v.events.execute('onStart')
  end

  local wavesFileName = 'Contents/Waves/' .. tostring(Game.wave) .. '.txt'
  local wavesPath = system.pathForFile(wavesFileName)
  local wavesFile, err = io.open(wavesPath, 'r')
  if not wavesFile then
    -- LOG CLASS WAVE NOT FOUND
  else
    local guardianCount = #Guardian.guardianSet 
    local monsterCount = 0
    for line in wavesFile:lines() do
      monsterCount = monsterCount + 1
      local lineSplit = String:split(line, ' ')
      timer.performWithDelay(tonumber(lineSplit[2]), function()
        Monster:new(lineSplit[1], tonumber(lineSplit[3]), tonumber(lineSplit[4]))
      end)
    end

    local waveTime = Wave:new(Game, guardianCount, monsterCount)
  end 
end

return Game