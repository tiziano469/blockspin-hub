--// ESP + Armas para Blockspin
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

function createESP(player)
    if player == localPlayer then return end
    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Crear Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    -- Crear Texto
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESP_Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    -- Actualizar texto dinámicamente
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Head") then
            local weapon = "Sin arma"
            local backpack = player:FindFirstChild("Backpack")
            if backpack and #backpack:GetChildren() > 0 then
                weapon = backpack:GetChildren()[1].Name
            end
            -- También puede estar equipada directamente
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("Tool") then
                    weapon = v.Name
                end
            end
            textLabel.Text = player.Name .. " [" .. weapon .. "]"
        else
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
        end
    end)
end

-- Aplicar ESP a jugadores existentes
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

-- Nuevos jugadores
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        createESP(player)
    end)
end)

-- Refrescar en cambio de personaje
Players.PlayerRemoving:Connect(function(player)
    local esp = player.Character and player.Character:FindFirstChild("ESP_Billboard")
    if esp then esp:Destroy() end
end)
