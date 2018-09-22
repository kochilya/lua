local component = require("component")
local rs = component.redstone

local signalOnTime = 0.2
local signalOffTime = 0.0

local dirtFrequency = 1
local woodFrequency = 2
local pushFrontFrequency = 3
local pushFrequency = 4
local pileIgniterFrequency = 5

function WirelessPulse(frequency)
    rs.setWirelessFrequency(frequency)
    rs.setWirelessOutput(true)
    os.sleep(signalOnTime)
    rs.setWirelessOutput(false)
    os.sleep(signalOffTime)
end
                            
function LineDirt()
    for i = 1, 7 do
        WirelessPulse(dirtFrequency)               
        WirelessPulse(pushFrontFrequency)               
    end
end

function LineWood()
    for i = 1, 7 do
        WirelessPulse(woodFrequency)               
        WirelessPulse(pushFrontFrequency)               
    end
end
             
function FirstBlock()
    WirelessPulse(pushFrequency)
    
    LineDirt()
    WirelessPulse(pushFrequency)
    
    for i = 1, 5 do
        LineWood()
        WirelessPulse(pushFrequency)
    end

    LineDirt()
    WirelessPulse(pushFrequency)
end

function NextBlockPartA()
    for i = 1, 4 do
        LineWood()
        WirelessPulse(pushFrequency)
    end
    LineWood()
end

function NextBlockPartB()
    WirelessPulse(pushFrequency)

    LineDirt()
    WirelessPulse(pushFrequency)
end

os.sleep(5)

FirstBlock()
while true do
    NextBlockPartA()
    
    rs.setWirelessFrequency(pileIgniterFrequency)
    i = 0
    while not rs.getWirelessInput() and i < 120 do
        os.sleep(1)
        i = i + 1    
    end
    
    NextBlockPartB()
end
