--- ConsoleReader.lua
--- Version: 1.0
--- Author: TheDerpGamer
--- DovTech Corporation
--- Console reader that will read messages from a channel and display them on a nearby display module.

--// Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to receive messages through the channel'
local displayOffset = {0, 1, 0} -- The relative offset of the display module from the console
local updateTime = 5 -- The time in seconds between each update

--// Variables
local lastMessage
local entity = console:getBlock():getEntity()

--// Functions
function getChannel()
    local channel = console:getChannel(channelName)
    if channel == nil then channel = console:createChannel(channelName, password) end
    return channel
end

function getDisplay()
    local pos = console:getBlock():getPos()
    pos:add(displayOffset[1], displayOffset[2], displayOffset[3]);
    return entity:getBlockAt(pos)
end

function updateDisplay()
    local display = getDisplay()
    if display ~= nil and display:getId() == 479 then
        local newMessage = getChannel():getLatestMessage()
        if(newMessage ~= lastMessage) then
            display:setDisplayText(newMessage)
            lastMessage = newMessage
        end
    else console:printError("No display found at position (~" .. displayOffset[1] .. ", ~" .. displayOffset[2] .. ", ~" .. displayOffset[3] .. ")") end
end

while(true) do
    updateDisplay()
    sleep(updateTime)
end