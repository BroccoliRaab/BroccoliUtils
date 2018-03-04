local scenes = require("utils/scenes")


local object = {}
object.__index= object

local guiLib = {}

object.pos = {}
object.size = {}
object.pos.x = nil
object.pos.y = nil
object.rot = nil
object.size.x = nil
object.size.y = nil
object.scale = {}
object.scale.x = nil
object.scale.y = nil
object.id = nil
object.borderSize = 0
object.borderColor = {0, 0, 0, 255}
object.color = {255, 255, 255, 255}
object.events = {}
object.events.__index = object.events

guiLib.events = {
  HOVERON = "hoverOn",
  HOVEROFF = "hoverOff",
  BUTTON1PRESS = "button1press",
  BUTTON1RELEASE = "button1release",
  BUTTON2PRESS = "button2press",
  BUTTON2RELEASE = "button2release",
  }

object.events[guiLib.events.BUTTON1PRESS] = (function() end)
object.events[guiLib.events.BUTTON2PRESS] = (function() end)
object.events[guiLib.events.BUTTON1RELEASE] = (function() end)
object.events[guiLib.events.BUTTON2RELEASE] = (function() end)
object.events[guiLib.events.HOVERON] = (function() end)
object.events[guiLib.events.HOVEROFF] = (function() end)

function object:addFunct(funct, guiEvent)
  self.events[guiEvent] = funct
end

function object:destroy()
  self.gui.objects[self.id] = nil
  self.gui:removeObject(self.id)
end


local function setupObj(gui, obj, id, posx,posy,sizex,sizey,rot,visible, scalex, scaley)
  setmetatable(obj, object)
  
  obj.pos = {}
  obj.size = {}
  obj.scale = {}
  obj.pos.x = nil
  obj.pos.y = nil
  obj.rot = nil
  obj.size.x = nil
  obj.size.y = nil
  obj.id = nil
  obj.scale.x = nil
  obj.scale.y = nil
  
  obj.events = {}
  setmetatable(obj.events, object.events)
  
  object.borderSize = 0
  object.borderColor = {0, 0, 0, 255}
  object.color = {255, 255, 255, 255}
  
  
  obj.gui = gui
  obj.id = id 
  obj.id = id
  obj.pos.x = posx
  obj.pos.y = posy
  obj.size.x = sizex
  obj.size.y = sizey
  obj.scale.x = scalex or 1
  obj.scale.y = scaley or 1
  obj.rot = rot or 0
  obj.visible = visible or false
end

local function checkForObj(x, y, gui)
  for id, obj in pairs(gui.objects) do

    if (x>obj.pos.x) and (x<(obj.pos.x+obj.size.x)) and (y>obj.pos.y) and (y<(obj.pos.y+obj.size.y)) and (obj.visible == true)then
        return obj   
    end
  end
end

function guiLib.newGui(id)
  
  local gui = scenes.newScene("gui"..id)
  gui.objects ={}
  
  function gui:rawObj(id, posx,posy,sizex,sizey,rot, visible)
    local obj = {}
    
    setupObj(self, obj, id, posx,posy,sizex,sizey,rot, visible)
    
    function obj:renderTo(funct)
      self.canvas = love.graphics.newCanvas(self.size.x, self.size.y)
      self.canvas:renderTo(funct)
    end
    function obj:render()
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setBlendMode("alpha", "premultiplied")
      love.graphics.draw(self.canvas, self.pos.x, self.pos.y, self.rot)
      love.graphics.setBlendMode("alpha")
    end
    self:renderTo((function()
        obj:render()
    end), id, obj)
    self.objects[id] = obj
    return obj 
  end
  
  function gui:newButton(id, posx,posy,sizex,sizey,rot,  color, border, borderColor)
    local button = {}
   --[[ setmetatable(button, object)
    
    button.id = id
    button.pos.x = posx
    button.pos.y = posy
    button.size.x = sizex
    button.size.y = sizey
    

    
    button.borderSize = border]]
    
    setupObj(self, button, id, posx,posy,sizex,sizey,rot, border)
    
    button.color = color
    button.borderColor = borderColor

    function button:image(img)

    end
  
    function button:text(text,font)
      
    end
    
    function button:renderTo(rFunct)
      
    end
    
    self.objects[id] = button
    return button
  end

  function gui:newImage(id, posx,posy,sizex,sizey,rot, border)
    local img = {}
    --setmetatable(img, object)
    
    setupObj(self, img, id, posx, posy, sizex, sizey, rot, border)
    
    self.objects[id] = img
    return img
  end

  function gui:newText(id, posx,posy,rot,text,font,visible, scalex, scaley)
    local txt = {}
    --setmetatable(txtBox, object)

  
    txt.font = font
    txt.text = text
    txt.background = background
    txt.textGObj = love.graphics.newText(font, text)
    local sx, sy = txt.textGObj:getDimensions()

    setupObj(self, txt, id, posx,posy,sx, sy,rot,visible, scalex, scaley)
    function txt:defaultRender()
      love.graphics.draw(self.textGObj, self.pos.x,self.pos.y, self.rot, self.scale.x, self.scale.y)
    end
    txt.render = txt.defaultRender
    self:renderTo((function()
       -- love.graphics.draw(txtBox.textGObj, txtBox.pos.x,txtBox.pos.y,txtBox.size.x,txtBox.size.y,txtBox.rot)
       txt:render()
    end), id, txt)
    
    
    self.objects[id] = txt
    return txt
  end
  
  ---TRANSLATING EVENTS TO SPECIFIC OBJECT BASED EVENTS---
  
  function gui.mousepressed(x, y, button)
    local obj = checkForObj(x, y, gui)
   
    if not obj then return end
    if button == 1 then
      obj.events[guiLib.events.BUTTON1PRESS]()
    elseif button == 2 then
      obj.events[guiLib.events.BUTTON2PRESS]()
    
    end
  end
  gui:addFunct(gui.mousepressed,"mousepressed")
  
  function gui.mousereleased(x, y, button)
    local obj = checkForObj(x, y, gui)
   
    if not obj then return end
    if button == 1 then
      obj.events[guiLib.events.BUTTON1RELEASE]()
    elseif button == 2 then
      obj.events[guiLib.events.BUTTON2RELEASE]()
    
    end
  end
  gui:addFunct(gui.mousereleased,"mousereleased")
  
  function gui.mousemoved(x, y, dx, dy)

    local obj = checkForObj(x, y, gui)
    local px = x-dx
    local py = y-dy
    local pobj = checkForObj(px, py, gui)
    if obj == pobj then return end
    if obj then
      obj.events[guiLib.events.HOVERON]()
    elseif pobj then
      pobj.events[guiLib.events.HOVEROFF]()
    end
  end
  gui:addFunct(gui.mousemoved, "mousemoved")
  
  
  
  return gui
end



--[[
function guiLib.update()
  function love.mousepressed(x, y, button)
    local obj = checkForObj(x, y)
    if obj and button == 1 and obj.clicked then
      obj.clicked()
    end
  end
    function love.mousereleased(x, y, button)
    local obj = checkForObj(x, y)
    if obj and button == 1 and obj.released then
      obj.released()
    end
  end
end
]]

return guiLib
