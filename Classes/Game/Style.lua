local StyleRenderer = require('Classes.Renderer.StyleRenderer')

local Style = {} 

function Style:render()
  StyleRenderer:renderStyle()
end

function Style:load(class)


end

return Style