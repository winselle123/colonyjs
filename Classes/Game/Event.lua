local EventRenderer = require('Classes.Renderer.EventRenderer')
local Skill = require('Classes.Game.Skill')

local Event = {
  isExecutable = true
} 

function Event:newSet(parent) 
  local events = {
    parent = parent,
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
        isOffensive = false,
        description = 'This event happens when the guardian stone has been attacked by an enemy.'
      }
    }
  }
  for k, v in pairs(events.eventSet) do
    v.name = k
    v.skillSet = Skill:newSet(v) 
    v.view = EventRenderer:prepareEventPanel(v)
  end

  events.eventExecuted = nil
  events.execute = function(name, index)
    if not events.parent.isDestroyed then
      -- PRIORITIZATION OF EVENTS
      local priority = { 'onGuardianStoneAttacked', 'onLowHealth', 'onEnemySeen', 'onAllySeen', 'onIdle', 'onStart' }
      for i, v in ipairs(priority) do
        if v == name or v == events.eventExecuted then 
          if #events.eventSet[v].skillSet ~= 0 then
            events.eventExecuted = v
            break
          end
        end   
      end 

      if name == events.eventExecuted then 
        local index = index and index or 1
        local executable = events.eventSet[name].skillSet[index]

        -- MOVEMENT ACTIONS
        if index <= #events.eventSet[name].skillSet then
          -- VALIDATION 1) IF OFFENSE CARD AND NOT OFFENSE EVENT THEN WONDER
          if executable.type == 'offense' then
            if not events.eventSet[name].isOffensive then
              parent.wonder(function() parent.events.execute(name, index + 1) end)
              return
            end
          end

          local executableSet = {
            ['moveLeft'] = function() 
              parent.move(parent.x - executable.params.steps, parent.y, function() parent.events.execute(name, index + 1) end, { isStart = true }) 
            end, 
            ['moveRight'] = function()
              parent.move(parent.x + executable.params.steps, parent.y, function() parent.events.execute(name, index + 1) end, { isStart = true })
            end,
            ['moveUp'] = function()
              parent.move(parent.x, parent.y - executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })
            end,
            ['moveDown'] = function()
              parent.move(parent.x, parent.y + executable.params.steps, function() parent.events.execute(name, index + 1) end, { isStart = true })        
            end, 
            ['dashLeft'] = function()
              parent.dash(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'left' })
            end, 
            ['dashRight'] = function()
              parent.dash(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'right' })
            end, 
            ['dashUp'] = function()
              parent.dash(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'up' })
            end, 
            ['dashDown'] = function()
              parent.dash(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'down' })
            end, 
            ['launchLeft'] = function()
              parent.launch(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'left' })
            end, 
            ['launchRight'] = function()
              parent.launch(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'right' })
            end, 
            ['launchUp'] = function()
              parent.launch(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'up' })
            end, 
            ['launchDown'] = function()
              parent.launch(function() parent.events.execute(name, index + 1) end, { isStart = true, direction = 'down' })
            end,
            ['moveToX'] = function()
              parent.move(executable.params.xCoordinate, parent.y, function() parent.events.execute(name, index + 1) end, { isStart = true })
            end,
            ['moveToY'] = function()
              parent.move(parent.x, executable.params.yCoordinate, function() parent.events.execute(name, index + 1) end, { isStart = true })
            end,
            ['teleportToStone'] = function()
              parent.teleport(display.contentCenterX, display.contentCenterY, function() parent.events.execute(name, index + 1) end, { isStart = true })
            end,
            ['teleportToEnemy'] = function()
              if name == 'onEnemySeen' then
                parent.teleport(events.eventSet[name].target.x, events.eventSet[name].target.y, function() parent.events.execute(name, index + 1) end, { isStart = true })
              else
                parent.wonder(function() parent.events.execute(name, index + 1) end)
              end
            end,
            ['teleportToAlly'] = function()
              if name == 'onAllySeen' then
                parent.teleport(events.eventSet[name].target.x, events.eventSet[name].target.y, function() parent.events.execute(name, index + 1) end, { isStart = true })
              else
                parent.wonder(function() parent.events.execute(name, index + 1) end)
              end
            end,
            ['attack'] = function()
              if parent.target and parent.target.health > 0 then
                parent.attackEnemy(events.eventSet[name].target, function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end)
              else
                parent.wonder(function() parent.events.execute(name, index + 1) end)
              end
            end,
            ['chargedAttack'] = function()
              if parent.target and parent.target.health > 0 then
                parent.attackEnemy(events.eventSet[name].target, function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end, { charged = true })
              else
                parent.wonder(function() parent.events.execute(name, index + 1) end)
              end
            end,
            ['poisonedAttack'] = function()
              if parent.target and parent.target.health > 0 then
                parent.attackEnemy(events.eventSet[name].target, function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end, { poisoned = true })
              else
                parent.wonder(function() parent.events.execute(name, index + 1) end)
              end
            end,
            ['shield'] = function()
              parent.shield(function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end)
            end,
            ['chargedShield'] = function()
              parent.shield(function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end, { charged = true })
            end,
            ['chargedShieldField'] = function()
              parent.shieldField(function() timer.performWithDelay(parent.slackTime * 1000, function() parent.events.execute(name, index + 1) end) end)
            end,
            ['repeat'] = function()
              parent.events.execute(name)
            end,
            ['doNothing'] = function()
              timer.performWithDelay(parent.slackTime * 1000, parent.events.execute(name, index + 1))
            end
          }

          if executable.name == 'random' then 
            local randomableSkill = { 'dashLeft', 'dashRight', 'dashUp', 'dashDown', 'launchLeft', 'launchRight', 'launchUp', 'launchDown', 'teleportToStone', 'shield', 'chargedShield', 'chargedShieldField', 'doNothing' }
            math.randomseed(os.time())
            executable.name = randomableSkill[math.random(#randomableSkill)]
          end 

          if executableSet[executable.name] then executableSet[executable.name]() end
        else
          events.eventExecuted = nil
          parent.target, parent.ally  = nil, nil
        end
      end
    end
  end

  return events
end

return Event