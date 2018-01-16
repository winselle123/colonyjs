local String = require('Classes.System.String')

local SpriteRenderer = {} 

function SpriteRenderer:prepare(parent, options)
  local spriteFileName = 'Contents/Sprites/' .. parent.class .. '.txt'
  local spritePath = system.pathForFile(spriteFileName)
  local spriteFile, err = io.open(spritePath, 'r')

  if not spriteFile then
    -- LOG FILE SPRITE NOT FOUND
    return nil
  else
    -- PARSE FILE
    local sheetWidth = spriteFile:read() 
    local sheetHeight = spriteFile:read()

    local seqOptions
    local index = 1
    local coorTable, seqTable = {}, {}
    local line = spriteFile:read()
    while line do
      local filterLine = String:filterAlphaNumeric(line)
      if filterLine == 'start' then
        local seq = spriteFile:read() 
        local seqSplit = String:split(seq, ' ') 
        seqOptions = {
          name = seqSplit[1],  
          time = seqSplit[2],
          loopCount = seqSplit[3],
          frames = {}
        }
      elseif filterLine == 'end' then
        table.insert(seqTable, seqOptions)
        seqOptions = nil
      else
        local lineSplit = String:split(line, ' ')
        local coorOptions = {
          x = tonumber(lineSplit[1]), 
          y = tonumber(lineSplit[2]), 
          width = tonumber(lineSplit[3]), 
          height = tonumber(lineSplit[4])
        }
        table.insert(coorTable, coorOptions)
        table.insert(seqOptions.frames, index)
        index = index + 1
      end

      line = spriteFile:read()
    end

    -- SETUP SPRITE
    local sheetOptions = {
      frames = coorTable, 
      sheetContentWidth = sheetWidth, 
      sheetContentHeight = sheetHeight
    }
    local sequenceData = seqTable
    local imageSheet = graphics.newImageSheet('Assets/Sprites/' .. parent.class .. '.png', sheetOptions)
    local sprite = display.newSprite(imageSheet, sequenceData)
    if options and options.xScale and options.yScale then sprite:scale(options.xScale, options.yScale) end
    sprite.isVisible = true

    sprite.animate = function(sequence) 
      sprite:setSequence(sequence)
      sprite:play()
    end 

    return sprite
  end
end

return SpriteRenderer