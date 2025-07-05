--// ESP + Armas con Nombre Real para BlockSpin
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cambiá esto si la carpeta está en otro lugar
local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")

-- Mapeo nombre máquina → nombre legible
local weaponNames = {}
if weaponsFolder then
    for _, w in pairs(weaponsFolder:GetChildren()) do
        if w:IsA("Tool") or w:IsA("Model") then
            weaponNames[w.Name] = w:FindFirstChild("DisplayName") and w.DisplayName.Value or w.Name
        end
    end
end

local localPlayer = Players.LocalPlayer

function createESP(player)
    if player == localPlayer then return end
    local function onCharacter(char)
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end

        local billboard = head:FindFirstChild("ESP_Billboard") or Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local textLabel = billboard:FindFirstChild("ESP_Label") or Instance.new("TextLabel")
        textLabel.Name = "ESP_Label"
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 85, 0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextScaled = false
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboard

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Head") then
                local wName = "Sin arma"
                local backpack = player:FindFirstChild("Backpack")
                for _, obj in ipairs(player.Character:GetChildren()) do
                    if obj:IsA("Tool") then
                        wName = obj.Name
                        break
                    end
                end
                if wName == "Sin arma" and backpack then
                    for _, obj in ipairs(backpack:GetChildren()) do
                        if obj:IsA("Tool") then
                            wName = obj.Name
                            break
                        end
                    end
                end
                -- Reemplazar con nombre legible
                if weaponNames[wName] then
                    wName = weaponNames[wName]
                end
                textLabel.Text = player.Name .. " [" .. wName .. "]"
            else
                billboard:Destroy()
            end
        end)
    end

    player.CharacterAdded:Connect(onCharacter)
    if player.Character then onCharacter(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do
    createESP(p)
end
Players.PlayerAdded:Connect(createESP)
