local userId = "174142107"
local botPlayer = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Owner = game.Players:GetPlayerByUserId(userId)

-- Function to find a player that matches the input name (with autofill)
local function findPlayerByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name:lower() then
            return player
        end
    end
    return nil
end

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        if message:sub(1, 1) == "." then
            local parts = message:sub(2):split(" ")
            local command = parts[1]
            
            if player == Owner then
                if command == "come" then
                    -- Teleport bot to the owner
                    botPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                elseif command == "reset" then
                    -- Reset the bot player's character
                    if botPlayer.Character then
                        botPlayer.Character:BreakJoints()
                    end
                elseif command == "to" or command == "tp" then
                    -- Teleport bot to another player
                    local targetPlayerName = parts[2]
                    local targetPlayer = findPlayerByName(targetPlayerName)
                    if targetPlayer then
                        botPlayer.Character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
                    else
                        print("Player not found: " .. targetPlayerName)
                    end
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
