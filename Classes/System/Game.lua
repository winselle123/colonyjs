local Guardian = require('Classes.Game.Guardian')

local Game = {
  savedData = nil
}

function Game:_init()
  -- Initialize the game before going onto the battle proper

  Game:prepare() 
end

function Game:prepare()
  local g = Guardian:new('Archer')
  timer.performWithDelay(1000, function() g.destroy() end)
end

function Game:battle() 

end

return Game