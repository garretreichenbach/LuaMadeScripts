--- FleetCarrier.lua
--- Version: 1.0
--- Author: TheDerpGamer
--- DovTech Corporation
--- Fleet carrier script that launch and manage fleet ships.

-- Settings
local channelName = "<channel_name>" -- The name of the channel to read messages from
local password = "<password>" -- The password used to receive messages through the channel'
local shipCount = 10 -- The number of ships to launch
local shipBaseName = "Fleet Carrier Ship" -- The base name of the ships to launch

-- Variables
local entity = console:getBlock():getEntity()

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

function waitUntilDone()
    while not getShipyard():isFinished() do
        sleep(5)
    end
end

function sendMessage(message)
    console:print("[" .. entity:getId() .. "]: " .. message)
    getChannel():sendMessage("[" .. entity:getId() .. "]: " .. message, password)
end

function getFleet()
    return entity:getFleet()
end

function getShipyard()
    return entity:getShipyards()[1]
end

function getShips()
    local ships = console:getVar("ships")
    if(ships == nil) then
        ships = {}
        console:setVar("ships", ships)
    end
    return ships
end

function addShip(ship)
    local ships = getShips()
    if(#ships >= shipCount) then return end
    table.insert(ships, ship)
    console:setVar("ships", ships)
    getFleet():addMember(ship)
    console:print("Added ship " .. ship:getName())
end

function removeShip(ship)
    local ships = getShips()
    for i = 1, #ships do
        if ships[i] == ship then
            table.remove(ships, i)
            getFleet():removeMember(ship)
            console:print("Removed ship " .. ship:getName())
            break
        end
    end
    console:setVar("ships", ships)
end

function disassembleCurrent()
    local shipyard = getShipyard()
    if shipyard:isDocked() then
        console:print("Disassembling ship...")
        shipyard:sendCommand("DECONSTRUCT_RECYCLE")
    end
end

function assembleShip()
    if(#getShips() >= shipCount) then
        console:print("Ship limit reached.")
        return
    end

    local shipyard = getShipyard()
    if(shipyard:isDocked()) then disassembleCurrent() end
    waitUntilDone()

    console:print("Loading design...")
    shipyard:sendCommand("LOAD_DESIGN", 0)
    waitUntilDone()

    console:print("Assembling ship...")
    shipyard:sendCommand("SPAWN_DESIGN", shipBaseName .. " " .. #getShips() + 1)
    waitUntilDone()
    addShip(shipyard:getDocked())
    shipyard:undock()
end

function listenOnChannel()
    local channel = getChannel()
    while true do
        local message = channel:getLatestMessage(password)
        if message ~= nil then
            console:print("[" .. channelName .. "]: " .. message)
            if message == "assemble" then
                assembleShip()
            elseif message == "disassemble" then
                disassembleCurrent()
            end
        end
        coroutine.yield()
    end
end

console:print("Fleet carrier script started.")
coroutine.wrap(listenOnChannel)()