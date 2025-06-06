local DiscordLib = loadstring(game:HttpGet"https://pastebin.com/raw/KRf0xDXQ")()
local Win1 = DiscordLib:Window("Aimbot R6 | V1 | HUB | TIZI MODS") 
local Tab1 = Win1:Server("TIZI MODS.", "") 
-- Aimbot 50% Bugs
local aimbotSettings = {
    enabled = false, 
    wallCheck = false, 
    teamCheck = false,
    ignoreDead = false,
    targetPart = "Head",
    fov = math.huge,
    maxDistance = math.huge, 
    smoothness = 1,
    prioritizeClosest = false,
    wallCheckPrecision = 3 
}

local RunServiceAimbotXP = game:GetService("RunService")
local targetLocked = nil
local touchButton = nil

local function isVisible(targetPosition, targetCharacter)
    if not aimbotSettings.wallCheck or not targetCharacter then 
        return true 
    end
    
    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (targetPosition - origin).Unit
    local distance = (targetPosition - origin).Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Players.LocalPlayer.Character, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    for i = 1, aimbotSettings.wallCheckPrecision do
        local raycastResult = workspace:Raycast(
            origin + Vector3.new(math.random(-0.3, 0.3), math.random(-0.3, 0.3), math.random(-0.3, 0.3)),
            direction * distance,
            raycastParams
        )

        if raycastResult then
            local hitPart = raycastResult.Instance
            if not hitPart:IsDescendantOf(targetCharacter) then
                return false
            end
        end
    end
    
    return true
end

local function shouldIgnore(player)
    return player == Players.LocalPlayer
end

local function isEnemy(player)
    if not aimbotSettings.teamCheck then return true end
    return player.Team ~= Players.LocalPlayer.Team
end

local function isValidTarget(player)
    if shouldIgnore(player) then return false end
    if not isEnemy(player) then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    if aimbotSettings.ignoreDead and humanoid.Health <= 0 then return false end
    
    return true, character, rootPart
end

local function findBestTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    
    local localChar = Players.LocalPlayer.Character
    if not localChar then return nil end
    
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        local valid, character, rootPart = isValidTarget(player)
        if valid then
            local distance = (rootPart.Position - localRoot.Position).Magnitude
            if distance < closestDistance and distance <= aimbotSettings.maxDistance then
                if isVisible(rootPart.Position, character) then
                    closestDistance = distance
                    closestTarget = rootPart
                    targetLocked = player
                end
            end
        end
    end
    
    return closestTarget
end

local function updateAimbot()
    if not aimbotSettings.enabled then 
        targetLocked = nil
        return 
    end
    
    if targetLocked then
        local valid, character, rootPart = isValidTarget(targetLocked)
        if not valid or not isVisible(rootPart.Position, character) then
            targetLocked = nil
        end
    end
    
    if not targetLocked then
        findBestTarget()
    end
    
    if targetLocked and targetLocked.Character then
        local rootPart = targetLocked.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local currentCF = workspace.CurrentCamera.CFrame
            local targetPos = rootPart.Position
            local newCF = CFrame.new(currentCF.Position, targetPos)
            workspace.CurrentCamera.CFrame = currentCF:Lerp(newCF, aimbotSettings.smoothness)
        end
    end
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    targetLocked = nil
end)

local success, err = pcall(function()
    RunServiceAimbotXP.RenderStepped:Connect(updateAimbot)
end)

local TabGuiV1 = Tab1:Channel("AIMBOT")
TabGuiV1:Label("AIMBOT | SETINGS / CHANGE / MOD / BETA")
TabGuiV1:Toggle("Activate Aimbot",false, function(Y)
if Y then
        aimbotSettings.enabled = true
        targetLocked = nil
else
        aimbotSettings.enabled = false
        targetLocked = nil
end
end)
TabGuiV1:Toggle("Wall Check",false, function(HD)
if HD then
aimbotSettings.wallCheck = true
else
aimbotSettings.wallCheck = false
end
end)
TabGuiV1:Toggle("Team Check",false, function(HD)
if HD then
aimbotSettings.teamCheck = true
else
aimbotSettings.teamCheck = false
end
end)
TabGuiV1:Toggle("Ignore Dead",false, function(HD)
if HD then
aimbotSettings.ignoreDead = true
else
aimbotSettings.ignoreDead = false
end
end)
TabGuiV1:Dropdown("Target Part", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, function(Value)
aimbotSettings.targetPart = Value
end)
TabGuiV1:Textbox("Fov", "Default Is Infinite", false, function(txt)
a = tonumber(txt) or 0;
aimbotSettings.fov = a
end) 
TabGuiV1:Textbox("Max Distance", "Default Is Infinite", false, function(txt)
a = tonumber(txt) or 0;
aimbotSettings.maxDistance = a
end) 
TabGuiV1:Textbox("Smoothness", "Default Is 1", false, function(txt)
a = tonumber(txt) or 0;
aimbotSettings.smoothness = a
end) 
TabGuiV1:Toggle("Prioritize Closest",false, function(HD)
if HD then
aimbotSettings.prioritizeClosest = true
else
aimbotSettings.prioritizeClosest = false
end
end)
TabGuiV1:Textbox("Wall Check Precision Level", "Default Is 3", false, function(txt)
a = tonumber(txt) or 0;
aimbotSettings.wallCheckPrecision = a
end) 
