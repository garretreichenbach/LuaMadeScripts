local entity = console:getBlock():getEntity()
local ai = entity:getAI()
local channelName = "TargetTagger[" .. entity:getName() .. "]"

function sleep(n)
    local t0 = console:getTime()
    while console:getTime() - t0 <= n do end
end

function massFormat(mass)
    -- If mass is >= 1000, format it as K
    if mass >= 1000 then return (mass / 1000) .. "k"
    else return mass end
end

function targetToString(target)
    return target:getName() .. "[" .. target:getFaction():getName() .. "] - " .. massFormat(target:getMass())
end

function getTargetNameFromString(targetString)
    return string.match(targetString, ".-%[")
end

function getTargetFactionFromString(targetString)
    return string.match(targetString, "%[.-%]")
end

function getTargetMassFromString(targetString)
    local mass = string.match(targetString, "%d+k")
    if mass ~= nil then return tonumber(string.sub(tostring(mass), 1, string.len(tostring(mass)) - 1)) * 1000
    else return tonumber(string.match(targetString, "%d+")) end
end

function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, "password") end
    return channel
end

function getNearbyEntityByName(name)
    local nearbyEntities = entity:getNearbyEntities()
    if nearbyEntities[1] ~= nil then
        for i = 1, #nearbyEntities do
            local nearbyEntity = nearbyEntities[i]
            if nearbyEntity ~= nil then
                if nearbyEntity:getName() == name then return nearbyEntity end
            end
        end
    end
    return nil
end

function sendTarget()
    if ai ~= nil then
        local target = ai:getTarget()
        if target ~= nil then
            local channel = getChannel()
            channel:sendMessage("password", targetToString(target))
            console:print("Sent target " .. targetToString(target))
        end
    end
end

--- Cut out the below code if computer is sender only
function receiveTarget()
    local channel = getChannel()
    local message = channel:getLatestMessage()
    if message ~= nil then
        local target = getNearbyEntityByName(getTargetNameFromString(message))
        if target ~= nil and ai ~= nil then
            ai:setTarget(target)
            console:print("Received target " .. message)
        end
    end
end

while(true) do
    detect()
    sleep(10)
end