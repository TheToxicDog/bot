local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local userID = 174142107  -- Allowed user ID
local Whitelist = {[userID] = true}  -- Stores whitelisted users
local RecognitionService = game:GetService("RecognitionService") -- Hypothetical service for voice recognition

-- Helper function to get a player by name
local function getPlayer(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name:lower() then
            return player
        end
    end
    return nil
end

-- Command handling function
local function processCommand(sender, message)
    if not sender or not sender.UserId then return end -- Ensure sender is valid
    if not Whitelist[sender.UserId] then return end -- Ignore non-whitelisted users
    
    local args = message:lower():split(" ")
    local command = args[1]

    if command == "kill" then
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end

    elseif command == "to" and args[2] then
        local target = getPlayer(args[2])
        if target and target.Character and LocalPlayer.Character then
            LocalPlayer.Character:SetPrimaryPartCFrame(target.Character.PrimaryPart.CFrame)
        end

    elseif command == "come" and args[2] then
        local target = getPlayer(args[2])
        if target and target.Character and LocalPlayer.Character then
            target.Character:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame)
        end

    elseif command == "whitelist" and args[2] then
        local target = getPlayer(args[2])
        if target then
            Whitelist[target.UserId] = true
        end

    elseif command == "unwhitelist" and args[2] then
        local target = getPlayer(args[2])
        if target then
            Whitelist[target.UserId] = nil
        end

    elseif command == "fling" then
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(math.random(-100, 100), 200, math.random(-100, 100))
        end

    elseif command == "noclip" then
        game:GetService("RunService").Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)

    elseif command == "clip" then
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

    elseif command == "speed" and args[2] then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2]) or 16
        end

    elseif command == "jump" and args[2] then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = tonumber(args[2]) or 50
        end

    elseif command == "reset" then
        LocalPlayer:LoadCharacter()
    end
end

-- Function to handle recognized voice commands
local function onVoiceCommandRecognized(player, message)
    processCommand(player, message)
end

-- Connect voice recognition to command processing
RecognitionService.VoiceCommandRecognized:Connect(onVoiceCommandRecognized)
