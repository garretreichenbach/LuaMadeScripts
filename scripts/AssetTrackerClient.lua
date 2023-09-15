--- AssetTrackerClient.lua
--- Version: 1.0
--- Author: TheDerpGamer
--- DovTech Corporation
--- Description: Sends info on the current entity to the AssetTracker server.

--// Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to receive messages through the channel
local updateTime = 10 -- The time in seconds between each update

--// Variables
local entity = console:getBlock():getEntity()

--// Functions
function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, password) end
    return channel
end

function sendMessage(message)
    console:print("[" .. entity:getId() .. "]: " .. message)
    getChannel():sendMessage("[" .. entity:getId() .. "]: " .. message, password)
end

function sleep(n)
    local currentTime = console:getTime()
    while console:getTime() < currentTime + n do
        coroutine.yield()
    end
end

function getUpdateTable()
    local updateTable = {}
    updateTable["name"] = entity:getName()
    updateTable["faction"] = entity:getFaction():getName()
    updateTable["mass"] = entity:getMass()
    updateTable["hp"] = entity:getReactorHP()
    updateTable["max_hp"] = entity:getMaxReactorHP()
    updateTable["shield_hp"] = entity:getShieldSystem():getCurrent()
    updateTable["max_shield_hp"] = entity:getShieldSystem():getCapacity()
    return updateTable
end

while(true) do
    sendMessage(json.encode(getUpdateTable()))
    sleep(updateTime)
end

