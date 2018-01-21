local EventRenderer = require('Classes.Renderer.EventRenderer')
local Skill = require('Classes.Game.Skill')

local Event = {} 

function Event:newSet(parent) 
  local events = {
    eventSet = {
      ['onStart'] = {
        isOffensive = false, 
        description = 'This event happens when user starts the wave.'
      },
      ['onEnemySeen'] = {
        isOffensive = true, 
        description = 'This event happens when a monster enters your sight.'
      },
      ['onLowHealth'] = {
        isOffensive = false, 
        description = 'This event happens when current health of the guardian is lower than 25% of the base health.'
      },
      ['onAllySeen'] = {
        isOffensive = false, 
        description = 'This event happens when an ally enters your sight.'
      },
      ['onIdle'] = {
        isOffensive = false, 
        description = 'This event happens when the guardian has not moved for the past three seconds.'
      },
      ['onGuardianStoneAttacked'] = {
        isOffensive = true,
        description = 'This event happens when the guardian stone has been attacked by an enemy.'
      }
    }
  }
  for k, v in pairs(events.eventSet) do
    v.name = k
    v.skillSet = Skill:newSet(v) 
    v.view = EventRenderer:prepareEventPanel(v)
  end

  return events
end

return Event