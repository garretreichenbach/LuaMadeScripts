--- Simple enemy detector for LuaMade.
--- Author: TheDerpGamer

local entity = console:getBlock():getEntity()
local faction = entity:getFaction()
local channelName = "EnemyDetector[" .. entity:getName() .. "]"
local password = "gaatrot"

function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, password) end
    return channel
end

function sleep(n)
    local t0 = console:getTime()
    while console:getTime() - t0 <= n do end
end

function detect()
    local enemyMass = 0
    local enemyDetected = false
    local nearbyEntities = entity:getNearbyEntities()
    if nearbyEntities == nil or nearbyEntities == {} then return end
    for i = 1, #nearbyEntities do
        local nearbyEntity = nearbyEntities[i]
        if(nearbyEntity ~= nil) then
            local otherFaction = nearbyEntity:getFaction()
            if(otherFaction ~= nil and otherFaction ~= faction and faction:isEnemy(otherFaction)) then
                enemyMass = enemyMass + nearbyEntity:getMass()
                enemyDetected = true
            end
        end
    end
    if(not enemyDetected) then console:print("No enemies detected")
    else
        local line = "Enemies detected with a total mass of " .. enemyMass
        local color = {0.7, 0.27, 0.27, 0.9}
        console:printColor(color, line)
        local channel = getChannel()
        channel:sendMessage(password, line)
    end
end

while(true) do
    detect()
    sleep(10)
end