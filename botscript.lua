-- Main script with all commands, including game-specific ones

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local VoiceChatService = game:GetService("VoiceChatService")

local botPlayer = game.Players.LocalPlayer
local currentGameId = game.PlaceId

local Owner = game.Players:GetPlayerByUserId(174142107)
local whitelist = {}
local commands = {}

-- Function to simulate key press
local function pressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Function to set power and set the ball
local function setPowerCommand(args)
    local power = tonumber(args[2]) -- Extract power from argument
    if not power or power < 1 then
        print("Invalid power value.")
        return
    end

    -- Reset power to 1
    pressKey("Z")

    -- Increase power (press 'E' (power - 1) times)
    for i = 1, power - 1 do
        pressKey("E")
        task.wait(0.1)
    end

    -- Spawn the ball
    pressKey("G")

    -- Wait for 1.75 seconds
    task.wait(1.75)

    -- Set the ball
    pressKey("F")

    print("Set executed with power:", power)
end

-- Load game-specific commands
if currentGameId == 3840352284 then
    commands["set"] = setPowerCommand
end

-- Teleport command
commands["to"] = function(args)
    local targetName = args[2]:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #targetName) == targetName then
            botPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            return
        end
    end
    print("Player not found")
end
commands["tp"] = commands["to"] -- Alias

-- Reset command
commands["reset"] = function()
    botPlayer.Character:BreakJoints()
end

-- Fling command
commands["fling"] = function(args)
    local targetName = args[2]:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #targetName) == targetName then
            for _, part in ipairs(botPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            local thrust = Instance.new("BodyThrust", botPlayer.Character.HumanoidRootPart)
            thrust.Force = Vector3.new(9999,9999,9999)
            thrust.Name = "YeetForce"
            repeat
                botPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                thrust.Location = player.Character.HumanoidRootPart.Position
                RunService.Heartbeat:Wait()
            until not player.Character:FindFirstChild("Head")
        end
    end
end

-- Leave command
commands["leave"] = function()
    botPlayer:Kick("Disconnected")
end
commands["dc"] = commands["leave"] -- Alias

-- Rejoin command
commands["rj"] = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, botPlayer)
end
commands["rejoin"] = commands["rj"] -- Alias

-- Safe command
commands["safe"] = function()
    local safePart = Instance.new("Part")
    safePart.Size = Vector3.new(10,1,10)
    safePart.Position = botPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,1000,0)
    safePart.Anchored = true
    safePart.Parent = game.Workspace
    task.wait(0.5)
    botPlayer.Character.HumanoidRootPart.CFrame = safePart.CFrame + Vector3.new(0,5,0)
    botPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
end

-- Whitelist commands
commands["whitelist"] = function(args)
    local target = Players:FindFirstChild(args[2])
    if target then
        whitelist[target.UserId] = true
        print(target.Name .. " has been whitelisted.")
    end
end
commands["wl"] = commands["whitelist"]

commands["unwhitelist"] = function(args)
    local target = Players:FindFirstChild(args[2])
    if target and target ~= Owner then
        whitelist[target.UserId] = nil
        print(target.Name .. " has been unwhitelisted.")
    elseif target == Owner then
        whitelist[botPlayer.UserId] = nil
        print("You have unwhitelisted yourself.")
    end
end
commands["uwl"] = commands["unwhitelist"]

-- Spin & Sit commands
commands["spin"] = function()
    botPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,50,0)
end
commands["unspin"] = function()
    botPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
end
commands["sit"] = function()
    botPlayer.Character:FindFirstChildWhichIsA("Humanoid"):Sit(true)
end
commands["jump"] = function()
    botPlayer.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end
commands["unsit"] = commands["jump"] -- Alias

-- Unsuspend VC
commands["unsuspend"] = function()
    VoiceChatService:JoinVoice()
end
commands["unsuspendvc"] = commands["unsuspend"] -- Alias

-- Listen for chat commands
game.Players.LocalPlayer.Chatted:Connect(function(message)
    if message:sub(1, 1) == "." then
        local parts = message:sub(2):split(" ")
        local command = parts[1]
        if commands[command] then
            commands[command](parts)
        else
            print("Unknown command:", command)
        end
    end
end)
