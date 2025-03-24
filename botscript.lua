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
    
    -- Create a part in the sky
    local safePart = Instance.new("Part")
    safePart.Size = Vector3.new(10, 10, 10)  -- You can adjust the size of the safe part
    safePart.Position = Vector3.new(0, 1000000, 0)  -- Position it 1 million studs in the sky
    safePart.Anchored = true
    safePart.CanCollide = false
    safePart.Parent = workspace

    -- Move the client to the part
    character:SetPrimaryPartCFrame(CFrame.new(safePart.Position + Vector3.new(0, 5, 0)))  -- Position the player slightly above the part

    -- Remove velocity from the client
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)  -- Remove velocity
        humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)  -- Remove rotational velocity
    end

    print("Player is now safe and in the sky!")
end

-- Add a player to the whitelist
local function whitelistPlayer(player)
    if not whitelist[player.UserId] then
        whitelist[player.UserId] = player
        print(player.Name .. " has been whitelisted.")
    else
        print(player.Name .. " is already whitelisted.")
    end
end

-- Remove a player from the whitelist
local function unwhitelistPlayer(player)
    if whitelist[player.UserId] then
        whitelist[player.UserId] = nil
        print(player.Name .. " has been unwhitelisted.")
    else
        print(player.Name .. " is not in the whitelist.")
    end
end

-- Handle command input from a whispered message
local function onWhisper(message, player)
    if not message then return end  -- Early return if no message
    
    -- Ensure the message is a string and check the prefix
    if type(message) == "string" and message:sub(1, 1) == "." then
        local parts = message:sub(2):split(" ")
        local command = parts[1]

        -- Only process commands from whitelisted players
        if whitelist[player.UserId] or player == Owner then
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
                -- Add player to whitelist
                local targetPlayerName = parts[2]
                local targetPlayer = findPlayerByName(targetPlayerName)
                if targetPlayer then
                    whitelistPlayer(targetPlayer)
                else
                    print("Player not found: " .. targetPlayerName)
                end
            elseif command == "unwhitelist" or command == "uwl" then
                -- Remove player from whitelist
                local targetPlayerName = parts[2]
                local targetPlayer = findPlayerByName(targetPlayerName)
                if targetPlayer then
                    unwhitelistPlayer(targetPlayer)
                else
                    print("Player not found: " .. targetPlayerName)
                end
            end
        else
            print("You are not whitelisted to use the bot commands.")
        end
    end
end

-- Listen for whispers
Players.PlayerChatted:Connect(function(player, message)
    if player == botPlayer then
        -- Ignore the bot itself
        return
    end
    onWhisper(message, player)
end)

-- Example setup for whitelisting/unwhitelisting a player directly
whitelistPlayer(Owner)  -- The bot owner is automatically whitelisted.
