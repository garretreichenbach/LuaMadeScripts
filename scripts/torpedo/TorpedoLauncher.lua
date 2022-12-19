local entity = console:getBlock():getEntity()
local ai = entity:getAI()
local channelName = "TorpedoController[" .. entity:getName() .. "]"

function sleep(n)
    local t0 = console:getTime()
    while console:getTime() - t0 <= n do end
end

function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, "password") end
    return channel
end

function getNearbyEntityById(id)
    local nearbyEntities = entity:getNearbyEntities()
    if nearbyEntities[1] ~= nil then
        for i = 1, #nearbyEntities do
            local nearbyEntity = nearbyEntities[i]
            if nearbyEntity ~= nil then
                if nearbyEntity:getId() == id then return nearbyEntity end
            end
        end
    end
    return nil
end

function getDockedEntityById(id)
    local dockedEntities = entity:getDocked()
    if dockedEntities[1] ~= nil then
        for i = 1, #dockedEntities do
            local dockedEntity = dockedEntities[i]
            if dockedEntity ~= nil then
                if dockedEntity:getId() == id then return dockedEntity end
            end
        end
    end
    return nil
end

function getIndex()
    if(console:getVar("index") == nil) then console:setVar("index", 0) end
    return console:getVar("index")
end

function resetIndex()
    console:setVar("index", 0)
end

--- Gets the total number of torpedoes by counting the number of consoles that reply to the "getTorpedoCount" message.
function getCapacity()
    count = 0
    channel = getChannel()
    channel:sendMessage("password", "getTorpedoCount")
    sleep(5)
    local messages = channel:getMessages()
    for i = 1, #messages do
        local message = messages[i]
        if message ~= nil then
            if message ~= "getTorpedoCount" then
                -- Reply format is "torpedoCount: <number>"
                local countString = string.match(message, "torpedoCount: %d+")
                if countString ~= nil then count = count + tonumber(string.sub(tostring(countString), 14)) end
            end
        end
    end
    return count
end

--- Launches a torpedo at the given target.
function launch(target)
    -- Get the current index of the torpedo launcher
    local index = getIndex()
    if index < getCapacity() then
        -- Send the launch command to the torpedo launcher
        channel = getChannel()
        channel:sendMessage("password", "launch:" .. target:getId())
        sleep(5) -- Allow time for the torpedo to receive the target and plot course
        undock(index)
        -- Increment the index
        console:setVar("index", index + 1)
    end
end

--- Gets the currently selected target.
function getTarget()
    if ai ~= nil then
        local target = ai:getTarget()
        if target ~= nil then return target end
    end
    return nil
end

--- Iterates through the list of docked entities and returns an array of the ones that are torpedoes.
--- It does this by sending a "getTorpedoes" message through the channel, and each reply should contain the entity id of the torpedo.
function getTorpedoes()
    local torpedoes = {}
    channel = getChannel()
    channel:sendMessage("password", "getTorpedoes")
    sleep(5)
    local messages = channel:getMessages()
    for i = 1, #messages do
        local message = messages[i]
        if message ~= nil then
            if message ~= "getTorpedoes" then
                -- Reply format is "torpedo: <id>"
                local idString = string.match(message, "torpedo: %d+")
                if idString ~= nil then
                    local id = tonumber(string.sub(tostring(idString), 9))
                    local torpedo = getDockedEntityById(id)
                    if torpedo ~= nil then table.insert(torpedoes, torpedo) end
                end
            end
        end
    end
    return torpedoes
end