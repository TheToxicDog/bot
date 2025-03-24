local userId = "174142107"
local botPlayer = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Owner = game.Players:GetPlayerByUserId(userId)
local TeleportService = game:GetService("TeleportService")

local whitelist = {}  -- Table to store whitelisted players

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

-- Fling player (using previously mentioned fling)
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

-- Safe command implementation
local function safeCommand()
    local character = botPlayer.Character
    if not character then return end
    
    -- Create a part in the sky (1 million studs high)
    local safePart = Instance.new("Part")
    safePart.Size = Vector3.new(10, 10, 10)  -- You can adjust the size of the safe part
    safePart.Position = Vector3.new(0, 1000000, 0)  -- Position it 1 million studs in the sky
    safePart.Anchored = true
    safePart.CanCollide = false
    safePart.Parent = workspace

    -- Move the client to the part, placing the bot on top of the part
    character:SetPrimaryPartCFrame(CFrame.new(safePart.Position + Vector3.new(0, 5, 0)))  -- Position the player slightly above the part

    -- Remove velocity from the client
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)  -- Remove velocity
        humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)  -- Remove rotational velocity
    end

    print("Player is now safe and in the sky!")
end

-- Whitelist command implementation
local function whitelistCommand(playerName)
    if playerName:lower() == Owner.Name:lower() then
        print("You cannot whitelist the owner!")
        return
    end

    local player = findPlayerByName(playerName)
    if player then
        whitelist[player.UserId] = player
        print(player.Name .. " has been added to the whitelist.")
    else
        print("Player not found.")
    end
end

-- Unwhitelist command implementation
local function unwhitelistCommand(playerName)
    if playerName:lower() == Owner.Name:lower() then
        -- If someone tries to unwhitelist the owner, they get unwhitelisted instead
        if whitelist[botPlayer.UserId] then
            whitelist[botPlayer.UserId] = nil
            print("You have been unwhitelisted for trying to unwhitelist the owner.")
        end
        return
    end

    local player = findPlayerByName(playerName)
    if player then
        whitelist[player.UserId] = nil
        print(player.Name .. " has been removed from the whitelist.")
    else
        print("Player not found.")
    end
end

-- WalkTo command implementation
local function walkToPlayer(targetPlayer)
    local character = botPlayer.Character
    if character and targetPlayer.Character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position

        if humanoid then
            humanoid:MoveTo(targetPosition)
        end
    end
end

-- TweenTo command implementation
local function tweenToPlayer(targetPlayer)
    local character = botPlayer.Character
    if not character then return end
    
    local tweenService = game:GetService("TweenService")
    local goal = {Position = targetPlayer.Character.HumanoidRootPart.Position}
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local tween = tweenService:Create(character, tweenInfo, goal)
    tween:Play()
end

-- Spin command implementation
local function spinCommand()
    local character = botPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local spin = Instance.new("BodyGyro", humanoidRootPart)
        spin.MaxTorque = Vector3.new(400000, 400000, 400000)
        spin.CFrame = humanoidRootPart.CFrame
        spin.D = 5000
        
        -- Spin continuously
        while true do
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)  -- Spin around Y axis
            game:GetService("RunService").Heartbeat:Wait()
        end
    end
end

-- Say command implementation
local function sayCommand(message)
    local chatEvents = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
    chatEvents:FireServer(message, "All")
end

-- Command listener
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        if message:sub(1, 1) == "." then
            local parts = message:sub(2):split(" ")
            local command = parts[1]

            if player == Owner or whitelist[player.UserId] then
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
                elseif command == "leave" or command == "dc" then
                    -- Disconnect the bot from the game
                    botPlayer:Kick("Disconnected by command.")  -- Optional message can be added
                elseif command == "rj" or command == "rejoin" then
                    -- Rejoin the game
                    local placeId = game.PlaceId
                    local teleportData = {}  -- Optional, can be used to send data on rejoin
                    TeleportService:Teleport(placeId, botPlayer, teleportData)
                elseif command == "safe" then
                    -- Call the safe command
                    safeCommand()
                elseif command == "whitelist" or command == "wl" then
                    -- Whitelist a player
                    whitelistCommand(parts[2])
                elseif command == "unwhitelist" or command == "uwl" then
                    -- Unwhitelist a player
                    unwhitelistCommand(parts[2])
                elseif command == "walkto" then
                    -- Walk to a player
                    local targetPlayerName = parts[2]
                    local targetPlayer = findPlayerByName(targetPlayerName)
                    if targetPlayer then
                        walkToPlayer(targetPlayer)
                    else
                        print("Player not found: " .. targetPlayerName)
                    end
                elseif command == "tweento" then
                    -- Tween to a player
                    local targetPlayerName = parts[2]
                    local targetPlayer = findPlayerByName(targetPlayerName)
                    if targetPlayer then
                        tweenToPlayer(targetPlayer)
                    else
                        print("Player not found: " .. targetPlayerName)
                    end
                elseif command == "spin" then
                    -- Spin the player
                    spinCommand()
                elseif command == "say" then
                    -- Send a message using Say
                    local message = table.concat(parts, " ", 2)
                    sayCommand(message)
                end
            else
                print("You are not authorized to use this bot.")
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
