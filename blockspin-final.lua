-- // Configuración Principal
local SilentAimEnabled = false
local FieldOfView = 100
local FOVColor = Color3.fromRGB(0, 255, 0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- // Dibujo del FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = FOVColor
FOVCircle.Thickness = 1
FOVCircle.Radius = FieldOfView
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Visible = true

-- // GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SilentAimGUI"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Silent Aim Settings"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Position = UDim2.new(0, 10, 0, 35)
ToggleButton.Size = UDim2.new(1, -20, 0, 30)
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

local FOVSliderLabel = Instance.new("TextLabel", Frame)
FOVSliderLabel.Position = UDim2.new(0, 10, 0, 70)
FOVSliderLabel.Size = UDim2.new(1, -20, 0, 20)
FOVSliderLabel.Text = "FOV: 100"
FOVSliderLabel.TextColor3 = Color3.new(1, 1, 1)
FOVSliderLabel.BackgroundTransparency = 1
FOVSliderLabel.TextScaled = true

local FOVSlider = Instance.new("TextButton", Frame)
FOVSlider.Position = UDim2.new(0, 10, 0, 95)
FOVSlider.Size = UDim2.new(1, -20, 0, 25)
FOVSlider.Text = "Click to Increase FOV"
FOVSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
FOVSlider.TextColor3 = Color3.new(1, 1, 1)

local ColorButton = Instance.new("TextButton", Frame)
ColorButton.Position = UDim2.new(0, 10, 0, 125)
ColorButton.Size = UDim2.new(1, -20, 0, 25)
ColorButton.Text = "Change FOV Color"
ColorButton.BackgroundColor3 = FOVColor
ColorButton.TextColor3 = Color3.new(1, 1, 1)

-- // GUI Funcionalidad
ToggleButton.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    ToggleButton.Text = "Silent Aim: " .. (SilentAimEnabled and "ON" or "OFF")
    ToggleButton.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(70, 70, 70)
end)

FOVSlider.MouseButton1Click:Connect(function()
    FieldOfView = (FieldOfView >= 200) and 50 or (FieldOfView + 25)
    FOVSliderLabel.Text = "FOV: " .. FieldOfView
    FOVCircle.Radius = FieldOfView
end)

ColorButton.MouseButton1Click:Connect(function()
    local newColor = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
    FOVColor = newColor
    FOVCircle.Color = newColor
    ColorButton.BackgroundColor3 = newColor
end)

-- // Silent Aim Targeting
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = FieldOfView

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if onScreen and dist < shortestDistance then
                shortestDistance = dist
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- // Hook del método Raycast para Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if SilentAimEnabled and method == "Raycast" and self == workspace then
        local args = {...}
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            args[2] = (target.Character.HumanoidRootPart.Position - args[1]).Unit * 1000
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

-- // ESP Setup
local ESPTable = {}

local function CreateESP(player)
    if ESPTable[player] then return end

    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Font = 2
    nameText.Visible = false

    local weaponText = Drawing.new("Text")
    weaponText.Size = 13
    weaponText.Center = true
    weaponText.Outline = true
    weaponText.Color = Color3.fromRGB(200, 200, 100)
    weaponText.Font = 2
    weaponText.Visible = false

    ESPTable[player] = {
        name = nameText,
        weapon = weaponText
    }
end

local function RemoveESP(player)
    if ESPTable[player] then
        for _, drawing in pairs(ESPTable[player]) do
            drawing:Remove()
        end
        ESPTable[player] = nil
    end
end

-- // Actualización de FOV y ESP
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPTable[player] then
                CreateESP(player)
            end

            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
            local tool = player.Character:FindFirstChildOfClass("Tool")
            local weaponName = tool and tool.Name or "Sin arma"
            local esp = ESPTable[player]

            if onScreen then
                esp.name.Position = Vector2.new(pos.X, pos.Y)
                esp.name.Text = player.Name
                esp.name.Visible = true

                esp.weapon.Position = Vector2.new(pos.X, pos.Y + 14)
                esp.weapon.Text = "[" .. weaponName .. "]"
                esp.weapon.Visible = true
            else
                esp.name.Visible = false
                esp.weapon.Visible = false
            end
        else
            RemoveESP(player)
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)
