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

local function flingPlayer(targetPlayer)
    local character = botPlayer.Character
    if not character then return end
    
    -- Set the bot's CFrame to the target player's CFrame
    character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
    
    -- Spin the bot really fast
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0  -- Stop movement
        local bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)  -- Enable strong spinning torque
        bodyGyro.CFrame = character.PrimaryPart.CFrame
        
        -- Begin spinning the player
        while humanoid and humanoid.Health > 0 do
            bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, math.rad(500), 0)
            wait(0.01)  -- Adjust the speed of spinning
        end
        bodyGyro:Destroy()
    end
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
                elseif command == "fling" then
                    -- Fling the player to the target player
                    local targetPlayerName = parts[2]
                    local targetPlayer = findPlayerByName(targetPlayerName)
                    if targetPlayer then
                        local startTime = tick()
                        flingPlayer(targetPlayer)
                        
                        -- Monitor if the player is moving fast
                        while tick() - startTime < 3 do
                            if botPlayer.Character and botPlayer.Character:FindFirstChild("Humanoid") then
                                local humanoid = botPlayer.Character.Humanoid
                                if humanoid and humanoid.MoveDirection.magnitude > 10 then  -- Checks if moving fast
                                    print("Fling successful, player is moving quickly!")
                                    return
                                end
                            end
                            wait(0.1)
                        end
                        
                        -- If not flung in 3 seconds, cancel and stop
                        print("Fling failed or took too long, stopping.")
                        if botPlayer.Character then
                            botPlayer.Character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
                        end
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
