--- LoiteringMunition.lua
--- Version: 1.4
--- Author: TheDerpGamer
--- DovTech Corporation
--- Loitering weapons platform that will stay hidden in an enemy's system until it detects a nearby hostile.
--- Once it detects a hostile, it will attack the hostile with it's warhead. If the self destruct feature is enabled,
--- place a warhead directly behind the console block and it will be activated 15 seconds after the warhead is launched.

--// Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to send messages through the channel
local maxEngageDistance = 2 -- The maximum distance in sectors the munition will engage targets at.\
local selfDestruct = false -- Whether or not the munition will self destruct after it's warhead is launched

--// Variables
local entity = console:getBlock():getEntity()
local reactor = entity:getReactor() -- TODO: Add scanner support?
local faction = entity:getFaction()
local ai = entity:getAI()
local target = entity
local lastTime = 0

--// Functions
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

function destroy()
    sendMessage("Self destructing in 15 seconds...")
    sleep(15)
    local pos = console:getBlock():getPos()
    pos:setZ(pos:getZ() + 1)
    local block = entity:getBlockAt(pos)
    if block ~= nil then block:activate()
    else sendMessage("ERROR: No block found at position " .. pos:toString()) end
end

function inLaunchRange()
    return target ~= nil and 
end

function launchWarhead()

end

function attack()
    if target ~= nil then
        ai:setTarget(entity)
        ai:setActive(true)
        if inLaunchRange() then
            launchWarhead()
            if(selfDestruct) then destroy()
        end
    else
        ai:stop()
        startup()
    end
end

function validTarget()
    return target ~= nil and getSectorDistance(target:getSector()) <= maxEngageDistance
end

function startup()
    local ownerFaction = getSystemOwner()
    if(ownerFaction ~= nil and ownerFaction:isEnemy(faction)) then activateStealth() end
    while(target == nil) do
        target = searchForTarget()
        sleep(10)
        activateStealth()
    end

    if(validTarget()) then
        sendMessage("Target acquired, starting attack routine.")
        while(validTarget()) do
            attack()
            sleep(5)
        end
    else
        sendMessage("Target lost, restarting search routine.")
        startup()
    end
end

startup()