-- Aimbot básico para BlockSpin
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuración
local FOV_RADIUS = 150 -- Radio del área de detección del aimbot
local aimbotEnabled = true

-- Función para obtener el enemigo más cercano al mouse
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = FOV_RADIUS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos = player.Character.Head.Position
            local screenPoint, onScreen = Camera:WorldToViewportPoint(headPos)

            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = player
                end
            end
        end
    end

    return closestEnemy
end

-- Bucle para apuntar
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
