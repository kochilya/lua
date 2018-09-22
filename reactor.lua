local com = require ( "component" )
local side = require ( "sides" )
local ic = com.transposer
local rs = com.redstone


-- classes

--[[
class Cell
--]]
Cell = {}

Cell.slots = {1,5,8,12,17,19,24,31,36,38,43,47,50,54}
Cell.count = #Cell.slots
Cell.max_heat = 50
Cell.slot = ic.getStackInSlot

function Cell:getState(ns)
  return self.slot(side.up, ns)
end

function Cell:getCount()
  return self.count
end

function Cell:getAllSlots()
  return self.slots
end


--[[
class Repeat
--]]

Reload = {}
Reload.reactor = side.up
Reload.heated = side.west
Reload.cooled = side.south

function Reload:removeHeat(ns)
  return ic.transferItem(self.reactor, self.heated, 1, ns)
end

function Reload:insertCool(ns)
  return ic.transferItem(self.cooled, self.reactor, 1, 2, ns)
end

--[[
class Reactor
--]]
Reactor = {}
Reactor.state = false
Reactor.off = 0
Reactor.on = 15
Reactor.reactor = side.up

function Reactor:disable()
  if rs.setOutput(self.reactor, self.off) == 0 then
    self.state = false
    return true
  end
end

function Reactor:enable()
  if rs.setOutput(self.reactor, self.on) == 15 then
    self.state = true
    return true
  end
end

function Reactor:getState()
  return self.state
end
local reload = {}
setmetatable (reload, {__index = Reload})
--[[
functions
--]]
function Reactor:loadCell(ns)
  if self:getState() == true then
    print ('Reactor stop')
    if self:disable() == true then
      print ('The reactor is stopped')
      if reload:insertCool(ns) == true then
        return true
      end
    end
  end
  if self:getState() == false then
    if reload:insertCool(ns) == true then
      return true
    end
  end
end

function Reactor:reloadCell(ns)
  if self:getState() == true then
    print ('Reactor stop')
    if self:disable() == true then
      print ('The reactor is stopped')
      if reload:removeHeat(ns) == true then
        if reload:insertCool(ns) == true then
          return true
        end
      end
    end
  end
end

-- init

local cell = {}
setmetatable (cell, {__index = Cell})
local reactor = {}
setmetatable (reactor, {__index = Reactor})
local reload = {}
setmetatable (reload, {__index = Reload})

count = cell:getCount()
all = cell:getAllSlots()
local marker = false
local j = 1

while j ~= nil do
  for i=1, count do
    ns = all[i]
    marker = true
    state = cell:getState(ns)
    -- 1. Слот реактора пуст
    if state == nil then
      print ('Empty slot '.. ns)
      marker = false
      marker = reactor:loadCell(ns)
--      print ('marker = '..marker)
    end

    -- 2. Слот реактора заполнен
    if state ~= nil then
      -- 3. В слоте правильный предмет
      if state.label == '360k He Coolant Cell' or state.label == '360k NaK Coolantcell' then
        for q,w in pairs( state ) do
          if q == 'name' or q == 'damage' then
            if q == 'damage' and w >= 90 then
              marker = false
              marker = reactor:reloadCell(ns)
            end
          end
        end
        -- 4. В слоте неправльиный предмет
      else
        marker = false
        marker = reactor:reloadCell(ns)
      end
    end
--    os.sleep(0.5)
  end
  os.sleep(.25)
  if marker == true then
    reactor:enable()
    print ( 'Check-cycle number '..j.. ' done.' )
    j = j+1
  end
end