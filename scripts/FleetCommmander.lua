--- FleetCommander.lua
--- Version: 1.0
--- Author: TheDerpGamer
--- DovTech Corporation
--- Quickly and easily command your fleet to defend a sector relative to your position using inner ship remotes.

-- Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to send messages through the channel
local fleetNames = {} -- The list of fleets to command, separate each fleet name with a comma (e.g. {"Fleet 1", "Fleet 2"})
local defaultCommand = "defend ~ ~ ~" -- The default command to give to the fleet if no command is given. Relative coords (relative to the computer block) are specified with ~ (e.g. "defend ~ ~ ~" or "defend ~ ~ 5").
local commands = {} -- The list of commands that you want to be usable. Separate each command using commas (e.g. {"defend ~ ~ ~", "attack ~ ~ ~1"}). The size of this list be equal to the number of Inner Ship Remotes you want to have.
local remotePositions = {"~ ~ ~1"} -- The list of positions where the Inner Ship Remotes are placed. Relative coords are specified with ~ (e.g. "~ ~ ~1" or "~ ~ ~2"). The size of this list be equal to the number of Inner Ship Remotes you want to have.

-- Variables
local entity = console:getBlock():getEntity()
local ai = entity:getAI()

-- Functions
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

function getRemote(position)
    try(
        local computerPos = console:getBlock():getPos()
        local x = computerPos:getX()
        local y = computerPos:getY()
        local z = computerPos:getZ()
        local coords = position:split(" ")

        -- If the coord starts with ~, then it is relative to the computer block
        if coords[1]:startsWith("~") then x = x + tonumber(coords[1]:sub(2))
        else x = tonumber(coords[1]) end
        if coords[2]:startsWith("~") then y = y + tonumber(coords[2]:sub(2))
        else y = tonumber(coords[2]) end
        if coords[3]:startsWith("~") then z = z + tonumber(coords[3]:sub(2))
        else z = tonumber(coords[3]) end

        local block = console:getBlock():getSector():getBlock(x, y, z)
        if(block ~= nil and block:getBlockInfo():getName() == "Inner Ship Remote") then return block
        else return nil end
    ) catch(return nil)
end