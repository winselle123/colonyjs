local Collision = {
  isDetecting = false, 
  collisionObjectSet = {}
}

function Collision:newCircle(parent, radius, options)
  local collisionObject = {
    shape = 'circle',
    parent = parent, 
    radius = radius, 
    tag = options and options.tag or nil,
    isSensor = options.isSensor,
    collidedObjects = {}
  }

  -- SETUP POINTS
  collisionObject.center = { x = parent.x, y = parent.y }

  -- UPDATE 
  timer.performWithDelay(1, function() 
    collisionObject.center = { x = parent.x, y = parent.y }
  end, 0)

  table.insert(Collision.collisionObjectSet, collisionObject)

  -- SETUP COLLIDED OBJECTS IF COLLISION DETECTION IS INITIATED
  timer.performWithDelay(1, function() 
    collisionObject.collidedObjects = {}
    if Collision.isDetecting and #Collision.collisionObjectSet > 0 then
      for i, v in ipairs(Collision.collisionObjectSet) do
        if v.parent ~= collisionObject.parent then
          -- FIRST CASE: circle to circle
          if v.shape == 'circle' and Collision:detectCircleCollision(v, collisionObject) then table.insert(collisionObject.collidedObjects, v) end

          -- SECOND CASE: circle to rectangle 
          if v.shape == 'rectangle' and Collision:detectCircleRectangleCollision(v, collisionObject) then table.insert(collisionObject.collidedObjects, v) end
        end
      end
    end
  end, 0)

  return collisionObject
end

function Collision:newRectangle(parent, width, height, options)
  local collisionObject = {
    shape = 'rectangle', 
    parent = parent, 
    width = width, 
    height = height, 
    tag = options and options.tag or nil,
    isSensor = options and options.isSensor or nil,
    collidedObjects = {}
  }

  -- SETUP POINTS 
  local center = { x = parent.x, y = parent.y }
  collisionObject.center = center
  collisionObject.p1 = { x = center.x - width / 2, y = center.y - height / 2 }
  collisionObject.p2 = { x = center.x + width / 2, y = center.y - height / 2 }
  collisionObject.p3 = { x = center.x - width / 2, y = center.y + height / 2 }
  collisionObject.p4 = { x = center.x + width / 2, y = center.y + height / 2 }

  -- UPDATE 
  timer.performWithDelay(1, function() 
    collisionObject.center = { x = parent.x, y = parent.y }
    local x, y = collisionObject.center.x, collisionObject.center.y

    if x and y then
      collisionObject.p1 = { x = x - width / 2, y = y - height / 2 }
      collisionObject.p2 = { x = x + width / 2, y = y - height / 2 }
      collisionObject.p3 = { x = x - width / 2, y = y + height / 2 }
      collisionObject.p4 = { x = x + width / 2, y = y + height / 2 }
    end
  end, 0)

  table.insert(Collision.collisionObjectSet, collisionObject)

  -- SETUP COLLIDED OBJECTS IF COLLISION DETECTION IS INITIATED
  timer.performWithDelay(1, function() 
    collisionObject.collidedObjects = {}
    if Collision.isDetecting and #Collision.collisionObjectSet > 0 then
      for i, v in ipairs(Collision.collisionObjectSet) do
        if v.parent ~= collisionObject.parent then
          -- FIRST CASE: rectangle to rectangle
          if v.shape == 'rectangle' and Collision:detectRectangleCollision(v, collisionObject) then table.insert(collisionObject.collidedObjects, v) end

          -- SECOND CASE: circle to rectangle 
          if v.shape == 'circle' and Collision:detectCircleRectangleCollision(v, collisionObject) then table.insert(collisionObject.collidedObjects, v) end
        end
      end
    end
  end, 0)
  
  return collisionObject
end

function Collision:filterSensors(collidedObjects)
  local counter = #collidedObjects
  for i = 1, counter do
    if collidedObjects[i].isSensor then
      collidedObjects[i] = nil
    end
  end
  local j = 0
  for i = 1, counter do 
    if collidedObjects[i] ~= nil then
      j = j + 1 
      collidedObjects[j] = collidedObjects[i] 
    end
  end
  for i = j + 1, counter do 
    collidedObjects[i] = nil
  end

  return collidedObjects
end

function Collision:deleteByParent(parent)
  local counter = #Collision.collisionObjectSet
  for i = 1, counter do
    if Collision.collisionObjectSet[i].parent == parent then
      Collision.collisionObjectSet[i] = nil
    end
  end
  local j = 0
  for i = 1, counter do 
    if Collision.collisionObjectSet[i] ~= nil then
      j = j + 1 
      Collision.collisionObjectSet[j] = Collision.collisionObjectSet[i] 
    end
  end
  for i = j + 1, counter do 
    Collision.collisionObjectSet[i] = nil
  end
end

function Collision:deleteByTag(tag)
  local counter = #Collision.collisionObjectSet
  for i = 1, counter do
    if Collision.collisionObjectSet[i].tag == tag then
      Collision.collisionObjectSet[i] = nil
    end
  end
  local j = 0
  for i = 1, counter do 
    if Collision.collisionObjectSet[i] ~= nil then
      j = j + 1 
      Collision.collisionObjectSet[j] = Collision.collisionObjectSet[i] 
    end
  end
  for i = j + 1, counter do 
    Collision.collisionObjectSet[i] = nil
  end
end

function Collision:detectCircleRectangleCollision(o1, o2)
  local circle = o1.shape == 'circle' and o1 or o2
  local rectangle = o1.shape == 'rectangle' and o1 or o2

  if circle.center.x and circle.center.y and rectangle.center.x and rectangle.center.y then
    local circleDistance = {
      x = math.abs(circle.center.x - rectangle.center.x),
      y = math.abs(circle.center.y - rectangle.center.y)
    }

    if circleDistance.x > (rectangle.width / 2 + circle.radius) or circleDistance.y > (rectangle.height / 2 + circle.radius) then 
      return false
    end

    if circleDistance.x <= (rectangle.width / 2) or circleDistance.y <= (rectangle.height / 2) then 
      return true
    end

    local cornerDistance = math.pow(circleDistance.x - rectangle.width / 2, 2) + math.pow(circleDistance.y - rectangle.height / 2, 2)
    return cornerDistance <= math.pow(circle.radius, 2)  
  end
end

function Collision:detectCircleCollision(o1, o2)
  if o1.center.x and o1.center.y and o2.center.x and o2.center.y then
    local dx = o2.center.x - o1.center.x
    local dy = o2.center.y - o1.center.y
    local radii = o1.radius + o2.radius

    if math.pow(dx, 2) + math.pow(dy, 2) <= math.pow(radii, 2) then
      return true
    end

    return false
  end
end

function Collision:detectRectangleCollision(o1, o2)
  return o1.p2.x >= o2.p1.x and o1.p1.x <= o2.p2.x and o1.p3.y >= o2.p1.y and o1.p1.y <= o2.p3.y
end

return Collision