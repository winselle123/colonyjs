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

  events.execute = function(name, index)
    local index = index and index or 1
    local executable = events.eventSet[name].skillSet[index]

    -- MOVEMENT ACTIONS
    if index <= #events.eventSet[name].skillSet then
      -- VALIDATION 1) IF OFFENSE CARD AND NOT OFFENSE EVENT THEN WONDER
      if executable.type == 'offense' and events.eventSet[name].isOffensive then
        parent.wonder(function() parent.events.execute(name, index + 1) end)
        return
      end

      -- EXECUTE IF NO ERROR
      if executable.name == 'moveLeft' then
        parent.walkLeft(executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })
      end
      if executable.name == 'moveRight' then
        parent.walkRight(executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })
      end
      if executable.name == 'moveUp' then
        parent.walkUp(executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })
      end
      if executable.name == 'moveDown' then
        parent.walkDown(executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })
      end
    end
  end

  return events
end

return Event