-- ✅ BlockSpin PvP Móvil: ESP + Armas + Silent Aim
-- Creado por ChatGPT | Libre uso

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BlockSpinMobileGUI"

local espEnabled = false
local silentAimEnabled = false
local autoEquipWeapons = false

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
        label.TextColor3 = Color3.fromRGB(0, 255, 100)
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

-- 🎯 Silent Aim
local function getClosestTarget()
    local closest = nil
    local shortest = math.huge
    local cam = Workspace.CurrentCamera
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPoint, onScreen = cam:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
            if onScreen and distance < shortest then
                closest = head
                shortest = distance
            end
        end
    end
    return closest
end

-- 🔫 Armas
local function autoEquip()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = LocalPlayer.Character
            end
        end
    end
end

-- 🚀 Silent Aim Hook (simulado)
local function hookSilentAim()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if method == "FireServer" and tostring(self):lower():find("remote") and silentAimEnabled then
            local target = getClosestTarget()
            if target then
                args[2] = target.Position -- modifica dirección del ataque
                return old(self, unpack(args))
            end
        end

        return old(self, ...)
    end)
end

-- 📱 GUI botones
local function createButton(text, pos, callback)
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 140, 0, 45)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.TextScaled = true
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
end

-- Botones GUI
createButton("👁️ ESP", UDim2.new(0, 20, 0, 60), function()
    espEnabled = not espEnabled
    print("ESP " .. (espEnabled and "✅ Activado" or "❌ Desactivado"))
    if espEnabled then
        enableESP()
    end
end)

createButton("🗡️ Equipar armas", UDim2.new(0, 20, 0, 120), function()
    autoEquipWeapons = not autoEquipWeapons
    print("Equipar armas: " .. (autoEquipWeapons and "ON" or "OFF"))
    if autoEquipWeapons then
        autoEquip()
    end
end)

createButton("🎯 Silent Aim", UDim2.new(0, 20, 0, 180), function()
    silentAimEnabled = not silentAimEnabled
    print("Silent Aim: " .. (silentAimEnabled and "✅ Activado" or "❌ Desactivado"))
end)

-- ⏱️ Loop auto-equip
RunService.RenderStepped:Connect(function()
    if autoEquipWeapons then
        autoEquip()
    end
end)

-- 🧠 Inicializa
hookSilentAim()
print("✅ Script BlockSpin Móvil (ESP + Armas + Silent Aim) cargado.")
