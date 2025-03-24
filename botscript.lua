local userId = "174142107"
local botPlayer = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Owner = game.Players:GetPlayerByUserId(userId)

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        if message:sub(1, 1) == "." then
            local parts = message:sub(2):split(" ")
            local command = parts[1]
            
            if player == Owner then
                if command == "come" then
                    botPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                end
            end
        end
    end)
end

if Owner then
    print("Welcome, " .. Owner.Name)
    return Owner
else
    print("User not found, retrying!")
    return nil
end
