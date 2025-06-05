-- ✅ BlockSpin PvP Script (versión final sin sistema de key)
-- Uso autorizado solo con permiso del autor original

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local autoAttack = true
local flyEnabled = false
local espEnabled = false

local bodyGyro, bodyVel

-- 🧠 ESP
local function createESP(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if head then
        if head:FindFirstChild("ESP") then
            head.ESP:Destroy()
        end

        local esp = Instance.new("BillboardGui", head)
        esp.Name = "ESP"
        esp.Size = UDim2.new(0, 100, 0, 40)
        esp.StudsOffset = Vector3.new(0, 3, 0)
        esp.AlwaysOnTop = true

        local label = Instance.new("TextLabel", esp)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.TextScaled = true
    end
end

local function enableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                createESP(player)
            end)
        end
    end
end

-- 🎯 Silent Aim (apunta a la cabeza)
local function getClosestTarget()
    local closest = nil
    local shortest = math.huge
    local cam = Workspace.CurrentCamera

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPoint, onScreen = cam:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - UIS:GetMouseLocation()).Magnitude
                if onScreen and distance < shortest then
                    closest = player
                    shortest = distance
                end
            end
        end
    end

    return closest
end

-- 🔫 Auto Attack (visual)
RunService.RenderStepped:Connect(function()
    if autoAttack then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid:TakeDamage(2) -- Solo visual
        end
    end

    -- 🕊️ Fly movimiento
    if flyEnabled and bodyGyro and bodyVel then
        local cam = Workspace.CurrentCamera.CFrame
        bodyGyro.CFrame = cam
        bodyVel.Velocity = cam.LookVector * 60
    end
end)

-- ⌨️ Controles
UIS.InputBegan:Connect(function(input, isTyping)
    if isTyping then return end

    if input.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        print("✈️ Fly " .. (flyEnabled and "Activado" or "Desactivado"))

        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if flyEnabled and hrp then
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.D = 500

            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        elseif bodyGyro and bodyVel then
            bodyGyro:Destroy()
            bodyVel:Destroy()
            bodyGyro, bodyVel = nil, nil
        end

    elseif input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        print("👁️ ESP " .. (espEnabled and "Activado" or "Desactivado"))
        if espEnabled then
            enableESP()
        end
    end
end)

print("✅ BlockSpin PvP Script (final sin key) cargado correctamente.")
