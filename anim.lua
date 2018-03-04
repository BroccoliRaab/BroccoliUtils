local dim4 = require("utils/dim4")


local anim = {}

anim.animations = {}

function anim.folderToData(path)
  local files = love.filesystem.getDirectoryItems(path)
  
  local fileNames = {}
  local finalTable ={}
  
  local function findFileExt(table, str)
    for i,v in pairs(table) do    
      if string.match(v, "%d+") == str then 
        local ind1, ind2 = string.find(v, "%.")
        if not ind1 then return end
        return string.sub(v, ind1)
      end
    end
  end
  for i, v in pairs(files) do
        fileNames[i] = tonumber(string.match(v, "%d+"))
  end
  table.sort(fileNames)
  for i, v in pairs(fileNames) do 
     local ext = findFileExt(files, tostring(v)) or ""
    finalTable[i] = love.graphics.newImage(path.."/"..v..ext)
  end

  return finalTable
end


function anim.newAnimation(data, dataType, looping, fps, x, y, r)
  local animation = {}
  animation.data = data
  animation.dataType = dataType
  animation.isRunning = false
  animation.isLooping = looping
  animation.currentFrame = 1
  animation.pos = {}
  animation.pos.x = x
  animation.pos.y = y
  animation.rot = r
  animation.size= {}
  animation.numOfFrames = nil
  
  assert((dataType == "folder" or dataType == "quads"), "Invalid data type for animation data")
  
  if dataType == "folder" then
    animation.size.x = animation.data[1]:getWidth()
    animation.size.y = animation.data[1]:getHeight()
    
    animation.numOfFrames = #animation.data
    
  else
    local qpx, qpy, qsx, qsy = animation.data.quads[1]:getViewport()
  -- print(#animation.data.quads)
    animation.size.x  = qsx
    animation.size.y = qsy
    animation.numOfFrames = #animation.data.quads
      
  end

  animation.canvas = love.graphics.newCanvas(animation.size.x, animation.size.y)

  
  
  animation.clock = dim4:newTimer(true, fps^-1, (function() 
   -- print(animation.currentFrame)
    animation.canvas:renderTo(function()
        animation:renderFrame()
               -- print(2)
    end)    
    if animation.currentFrame == animation.numOfFrames then
    --  print("soup")
      if animation.isLooping then
        animation:reset(true)
      else
        animation:reset(false)
      end
    end
      
    
    animation.currentFrame = animation.currentFrame +1
  end))
  function animation:clear()
    self.canvas:renderTo(function()
      love.graphics.clear()
      --print("cleared", self.currentFrame)
    end)
  end
  function animation:renderFrame()
      -- self:clear()
      love.graphics.clear()
     -- print("cleared", self.currentFrame)
     if self.currentFrame == 0 then
       self.currentFrame = 1
      end
      if animation.dataType == "quads" then
        love.graphics.draw(self.data.img, self.data.quads[self.currentFrame], 0, 0, 0)
       -- print(animation.data.quads[animation.currentFrame]:getViewport())
      else
       -- print(animation.currentFrame)
        love.graphics.draw(self.data[self.currentFrame], 0, 0, 0)
      end

  end
  function animation:render()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.canvas, self.pos.x, self.pos.y, self.rot)
  	love.graphics.setBlendMode("alpha")
  end
  function animation:play()
 --   if self.currentFrame == 1 then self.clock.funct() end
    self.clock:start()
  end
  function animation:stop()
    self.clock:stop()
  end
  function animation:reset(runOnReset)
    self.currentFrame = 0
   --[[ self.canvas:renderTo(function()
    
      love.graphics.clear()
      
    -- self:renderFrame()
    end)]]
    self.clock.cycleOnCreation = true 
    self.clock:reset(runOnReset)
  end
  
  table.insert(anim.animations, animation)
  
  return animation
end

--[[function anim.renderAll()
  for i, v in pairs(anim.animations) do
    v:render()
  end
end
]]

return anim