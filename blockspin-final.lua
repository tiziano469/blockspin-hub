-- ✅ BlockSpin PvP Móvil: ESP + Armas + Silent Aim + FOV
-- Creado por ChatGPT | Libre uso

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
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

-- 🎯 Silent Aim + FOV + Amigos
local FOV_RADIUS = 120
local Friends = {
    ["NombreAmigo1"] = true,
    ["NombreAmigo2"] = true,
}

-- Dibujar círculo FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 2
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled =
