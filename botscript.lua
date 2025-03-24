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

-- Function to disable collision on all parts of a character
local function disableCollisions(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Function to restore collision on all parts of a character
local function restoreCollisions(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local function flingPlayer(targetPlayer)
    local character = botPlayer.Character
    if not character then return end
    
    -- Disable collisions for the bot and target player
    disableCollisions(character)
    disableCollisions(targetPlayer.Character)
    
    -- Create BodyThrust to fling the bot
    local thrust = Instance.new("BodyThrust", character.HumanoidRootPart)
    thrust.Force = Vector3.new(9999, 9999, 9999)  -- Very high force to fling the bot
    thrust.Name = "YeetForce"
    
    -- Keep the bot near the target player and apply the thrust force
    local startTime = tick()
    repeat
        character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        thrust.Location = targetPlayer.Character.HumanoidRootPart.Position
        game:GetService("RunService").Heartbeat:Wait()

        -- Stop if player starts moving quickly (arbitrary speed threshold)
        if character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 50 then
            break
        end
    until tick() - startTime > 3  -- Stop after 3 seconds if no fling detected
    
    -- Cleanup
    thrust:Destroy()

    -- Restore collisions
    restoreCollisions(character)
    restoreCollisions(targetPlayer.Character)
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
                        flingPlayer(targetPlayer)
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
