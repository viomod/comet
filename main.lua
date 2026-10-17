print("reworken teleporter initialized..")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId
local currentJobId = game.JobId
local LocalPlayer = Players.LocalPlayer

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

print("teleporting..")

utility:Fire({
    Players = targets,
    GameID = 125328885809247
})

print("looking for signs of life...")

local Players = game:GetService("Players")
local startTime = os.clock()
local timeout = 120

repeat
    task.wait(0.5)

    local remaining = 0

    for _, player in ipairs(targets) do
        if Players:FindFirstChild(player.Name) == player then
            remaining += 1
        end
    end

    print("Players remaining: " .. remaining)

    if remaining == 0 then
        break
    end
until os.clock() - startTime >= timeout

local remaining = 0

for _, player in ipairs(targets) do
    if Players:FindFirstChild(player.Name) == player then
        remaining += 1
    end
end

if remaining > 0 then
    warn(remaining .. " player(s) are still in this server; not confirmed teleported.")
else
    print("All target players have left the server.")
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
