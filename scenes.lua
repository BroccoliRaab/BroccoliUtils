local scenes = {}

scenes.cScene = nil
scenes.cGui = nil
scenes.oldFramecScene = nil



function scenes.newScene(name, track)
	scene = {}
	--scene.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
	scene.track = track
  scene.animations = {}
  scene.renderData = {}
  scene.events = { }


	function scene:renderTo(funct, id, objectTab)
		--self.canvas:renderTo(funct)
    
    local mtable = {}
    local obj= {}
    obj.funct = funct
    obj.id = id or #scene.renderData+1
    obj.obj = objectTab
    setmetatable(obj, mtable)
    function mtable.__call(tab)
      tab.funct()
    end
  
    table.insert(self.renderData, obj)
	end
  function scene:removeObject(id)
    
    for i, v in pairs(self.renderData) do
      print(i, v, v.id, id)
      if v.id == id then
        self.renderData[i] = nil
      end
    end
  end
--[[	function scene:edit()
		love.graphics.setCanvas(self.canvas)
	end]]

	function scene:setCurrent()
		scenes.cScene = self
    if not self.track then return end
		self.track:setLooping(true)
		self.track:play()
	end
  function scene:setCurrentGui()
		scenes.cGui = self
    if not self.track then return end
		self.track:setLooping(true)
		self.track:play()
	end

	scenes[name] = scene
  
  function scene:addFunct(funct, event)
    print(scene, scene.events, event, funct)
    self.events[event] = funct
    return self
  end
  

  	
  --scene:handleEvents = coroutine.wrap(function ()
  --[[function scene:handleEvents()
  -- print(1)
      --for i = 1, 10 do
       -- print(2)
    local e, a, b, c, d = love.event.wait( )
         -- print(3)
    if self.events[e] then
      self.events[e](a, b, c, d)
    end
    
  end--)]]
  --scene.handleEvents(scene)
	return scene			
end

function scenes.setCurrentScene(scene)	 		
	scenes.cScene = scene
  if not scene.track then return end
	scene.track:setLooping(true)
	scene.track:play()
end

function scenes.setGuiScene(guiscene)	 		
	scenes.cGui = guiscene
  --[[if not scene.track then return end
	scene.track:setLooping(true)
	scene.track:play()]]
end
function scenes.removeGui()
  scenes.cGui = nil
end
function scenes.renderTo(scene, funct, id, objectTab)
  
  local mtable = {}
  local obj = {}
  obj.funct = funct
  obj.id = id or #scene.renderData+1
  obj.obj = objectTab 
  setmetatable(obj, mtable)
  function mtable.__call(tab)
    tab.funct()
  end
--	scene.canvas:renderTo(funct)
  table.insert(scene.renderData, obj)
end


function scenes.drawCurrentScene()
--[[	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(scenes.cScene.canvas)
	love.graphics.setBlendMode("alpha")]]
  
  for index, drawFunct in ipairs(scenes.cScene.renderData) do
   --[[ if drawFunct.obj then
      if drawFunct.obj.visible then
        
        drawFunct()
      end
    else]]
      drawFunct()
    --end
  end
  if not scenes.cGui then return end
  for GIndex, GDrawFunct in ipairs(scenes.cGui.renderData) do
    
    if GDrawFunct.obj.visible then
      GDrawFunct()
    end
  end
 -- scenes.cScene:triggerCallbacks()
end
--[[function scenes.stopEdits()
	love.graphics.setCanvas()
end]]
function scenes.draw()
   if not scenes.cScene then return end

	if scenes.cScene ~= scenes.oldFramecScene then 
    love.graphics.clear()
    scenes.oldFramecScene = scenes.cScene
  end

  scenes:drawCurrentScene() 
end
return scenes