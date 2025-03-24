loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
local playerService = game:GetService("Players")
local targetUserId = 174142107
local speaker = game.Players.LocalPlayer
local function execCmd(cmdStr, speaker)
    -- Replace this with your actual command execution logic.
    print("Executing command: " .. cmdStr .. " for " .. speaker.Name)
    if cmdStr == "rj" then
        playerService:FindFirstChild(speaker.Name).Character.Humanoid.Health = 0 --simple rejoin command
    -- add other commands here
    elseif cmdStr == "test" then
        print("test command executed")
    end
end

playerService.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if player.UserId == targetUserId and message:sub(1, 1) == "." then
            local command = message:sub(2) -- Remove the leading dot
            execCmd(command, speaker)
        end
    end)
end)

for _, player in ipairs(playerService:GetPlayers()) do
    player.Chatted:Connect(function(message)
        if player.UserId == targetUserId and message:sub(1, 1) == "." then
            local command = message:sub(2) -- Remove the leading dot
            execCmd(command, player)
        end
    end)
end
