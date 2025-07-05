-- ESP para Delta: muestra armas equipadas y de mochila
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local function createESP(player)
    if player == localPlayer then return end

    local function onCharacterAdded(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        if head:FindFirstChild("ESP_TAG") then return end

        local esp = Instance.new("BillboardGui")
        esp.Name = "ESP_TAG"
        esp.Size = UDim2.new(0, 150, 0, 20)
        esp.Adornee = head
        esp.AlwaysOnTop = true
        esp.StudsOffset = Vector3.new(0, 2.8, 0)
        esp.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(0, 255, 0)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.SourceSansBold
        label.TextScaled = true
        label.Text = "Cargando..."
        label.Parent = esp

        RunService.RenderStepped:Connect(function()
            if not player.Character then return end

            local weaponEquipped = nil
            for _, item in ipairs(player.Character:GetChildren()) do
                if item:IsA("Tool") then
                    weaponEquipped = item.Name
                    break
                end
            end

            local weaponBackpack = nil
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        weaponBackpack = item.Name
                        break
                    end
                end
            end

            local text = player.Name
            if weaponEquipped then
                text = text .. " [Usa: " .. weaponEquipped .. "]"
            elseif weaponBackpack then
                text = text .. " [Tiene: " .. weaponBackpack .. "]"
            else
                text = text .. " [Sin arma]"
            end

            label.Text = text
        end)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then onCharacterAdded(player.Character) end
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)
