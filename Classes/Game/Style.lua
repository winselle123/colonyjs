local StyleRenderer = require('Classes.Renderer.StyleRenderer')

local Style = {} 

function Style:render()
  StyleRenderer:renderStyle()
end

function load(class)


end

return Style