--- LoiteringMunition.lua
--- Version: 1.2
--- Author: TheDerpGamer
--- DovTech Corporation
--- Loitering weapons platform that will stay hidden in an enemy's system until it detects a nearby hostile.
--- Once it detects a hostile, it will attack the hostile with it's warhead.

--// Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to send messages through the channel
local maxEngageDistance = 2 -- The maximum distance in sectors the munition will engage targets at.

--// Variables
local entity = console:getBlock():getEntity()
local reactor = entity:getReactor() -- TODO: Add scanner support?
local faction = entity:getFaction()
local ai = entity:getAI()
local target

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

function getSystemOwner()
    return entity:getSystemOwner()
end

function getSectorDistance(otherSector)
    local sector = entity:getSector()
    local x = sector:getX() - otherSector:getX()
    local y = sector:getY() - otherSector:getY()
    local z = sector:getZ() - otherSector:getZ()
    return math.sqrt(x * x + y * y + z * z)
end

function activateStealth()
    if(entity:canJam() or entity:canCloak()) then -- These only work half the time, no idea why
        entity:activateJamming(true)
        entity:activateCloaking(true)
    end
end

function searchForTarget()
    local entities = entity:getNearbyEntities()
    for i = 1, #entities do
        local otherEntity = entities[i]
        if otherEntity:getFaction() ~= faction and otherEntity:getFaction() ~= nil and otherEntity:getFaction():isEnemy(faction) and getSectorDistance(otherEntity:getSector()) <= maxEngageDistance then
            target = otherEntity
            sendMessage("Target acquired: " .. target:getId())
            return
        end
    end
    return nil
end

function attack()
    if target ~= nil then
        if target:getSector() ~= entity:getSector() then ai:moveToSector(target:getSector()) end
        ai:setTarget(target)
        ai:moveToEntity(target)
    else startup() end
end

function validTarget()
    return target ~= nil and getSectorDistance(target:getSector()) <= maxEngageDistance
end

function startup()
    local ownerFaction = getSystemOwner()
    if(ownerFaction:isEnemy(faction)) then
        sendMessage("Enemy system detected, starting hide routine.")
        activateStealth()

        while(target == nil) do
            target = searchForTarget()
            sleep(10)
            activateStealth()
        end

        if(validTarget()) then
            sendMessage("Target acquired, starting attack routine.")
            while(validTarget()) do
                attack()
                sleep(10)
            end
        else
            sendMessage("Target lost, restarting search routine.")
            startup()
        end
    end
end

startup()