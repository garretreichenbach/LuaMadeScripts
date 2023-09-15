--- FleetCarrierTerminal.lua
--- Version: 1.0
--- Author: TheDerpGamer
--- DovTech Corporation
--- Input Script for Fleet Carrier.

-- Settings
local channelName = "test_channel" -- The name of the channel to read messages from
local password = "password" -- The password used to receive messages through the channel'
local shipCount = 10 -- The number of ships to launch
local shipBaseName = "TestDesign" -- The base name of the ships to launch

-- Variables
local entity = console:getBlock():getEntity()
local lastText = ""

-- Functions
function getDisplay()
    local pos = console:getBlock():getPos()
    pos:setY(pos:getY() + 1)
    local block = console:getBlock():getWorld():getBlock(pos)
    if(block:isDisplayModule()) then return block end
    return nil
end

function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, password) end
    return channel
end

function sleep(n)
    local currentTime = console:getTime()
    while console:getTime() < currentTime + n do
        coroutine.yield()
    end
end

function sendMessage(message)
    console:print("[" .. entity:getId() .. "]: " .. message)
    getChannel():sendMessage("[" .. entity:getId() .. "]: " .. message, password)
end

while(true) do
    local display = getDisplay()
    if(display ~= nil) then
        console:print("Display found")
        local text = display:getDisplayText();
        if(text ~= lastText) then
            lastText = text
            sendMessage(text)
            console:print("Sent message: " .. text)
        end
    end
    sleep(5)
end