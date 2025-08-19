--[[
    ESP Fachero ✨
    - Glow con Highlight
    - NameTag con gradiente + distancia
    - Tracers 2D desde la parte baja de la pantalla
    Hotkeys:
      [RightShift]  -> Toggle ESP
      [N]           -> Toggle Nombres
      [T]           -> Toggle Tracers
      [Y]           -> Toggle TeamCheck (no marca a tu equipo)
    Ajustes rápidos en la tabla SETTINGS.
--]]

--== Ajustes ==--
local SETTINGS = {
    Enabled = true,
    ShowNames = true,
    ShowTracers = true,
    TeamCheck = true,
    EnemyColor = Color3.fromRGB(255, 70, 90),
    FriendColor = Color3.fromRGB(80, 220, 255),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.75,
    OutlineTransparency = 0,
    Font = Enum.Font.GothamSemibold,
    NameTextSize = 14,
    TracerThickness = 2,
    TracerBaseY = 0.92, -- 92% de la pantalla (más abajo = más cerca del borde)
    FancyGradient = true, -- gradiente arcoíris suave en el name tag
}

--== Servicios ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--== UI raíz ==--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Fachero_UI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local LinesFolder = Instance.new("Folder")
LinesFolder.Name = "TracerLines"
LinesFolder.Parent = ScreenGui

-- Utilidades
local function safeGetHead(model)
    if not model then return end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    -- fallback: PrimaryPart o Torso
    if model.PrimaryPart then return model.PrimaryPart end
    local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    return torso
end

local function isTeammate(p)
    if not SETTINGS.TeamCheck then return false end
    if not LocalPlayer or not p then return false end
    if p.Team and LocalPlayer.Team then
        return p.Team == LocalPlayer.Team
    end
    -- fallback por TeamColor/Neutral
    if p.Neutral ~= nil or LocalPlayer.Neutral ~= nil then
        if p.Neutral or LocalPlayer.Neutral then
            return false
        end
    end
    if p.TeamColor and LocalPlayer.TeamColor then
        return p.TeamColor == LocalPlayer.TeamColor
    end
    return false
end

-- Registro por jugador
local Tracked = {} -- [Player] = { highlight=Highlight, bill=BillboardGui, tracer=Frame }

local function makeLine()
    local f = Instance.new("Frame")
    f.Name = "Tracer"
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Size = UDim2.new(0, SETTINGS.TracerThickness, 0, 100)
    f.BorderSizePixel = 0
    f.BackgroundTransparency = 0
    f.Visible = SETTINGS.Enabled and SETTINGS.ShowTracers
    f.Parent = LinesFolder
    return f
end

local function makeNameBillboard()
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_NameTag"
    bill.Size = UDim2.new(0, 200, 0, 36)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 0.25
    txt.TextScaled = false
    txt.TextSize = SETTINGS.NameTextSize
    txt.Font = SETTINGS.Font
    txt.TextColor3 = Color3.new(1,1,1)
    txt.TextStrokeTransparency = 0.3
    txt.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    txt.BorderSizePixel = 0
    txt.Parent = bill

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = txt

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    stroke.Parent = txt

    if SETTINGS.FancyGradient then
        local grad = Instance.new("UIGradient")
        grad.Rotation = 0
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 100, 100)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 200, 120)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(120, 180, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(180, 120, 255)),
        }
        grad.Parent = txt

        -- animación suave
        task.spawn(function()
            local t = 0
            while bill.Parent do
                t += RunService.Heartbeat:Wait()
                grad.Rotation = (t * 15) % 360
            end
        end)
    end

    return bill
end

local function ensureForPlayer(p)
    if p == LocalPlayer then return end
    if not p.Character then return end
    local char = p.Character
    if not Tracked[p] then Tracked[p] = {} end
    local reg = Tracked[p]

    -- Highlight
    if not reg.highlight or not reg.highlight.Parent then
        local h = Instance.new("Highlight")
        h.Name = "ESP_Highlight"
        h.FillTransparency = SETTINGS.FillTransparency
        h.OutlineTransparency = SETTINGS.OutlineTransparency
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = char
        h.Parent = char
        reg.highlight = h
    end

    -- Name tag
    if not reg.bill or not reg.bill.Parent then
        local bill = makeNameBillboard()
        bill.Parent = char:FindFirstChild("Head") or char
        reg.bill = bill
    end

    -- Tracer
    if not reg.tracer or not reg.tracer.Parent then
        reg.tracer = makeLine()
    end
end

local function cleanupPlayer(p)
    local reg = Tracked[p]
    if not reg then return end
    if reg.tracer then reg.tracer:Destroy() end
    if reg.bill then reg.bill:Destroy() end
    if reg.highlight and reg.highlight.Parent then reg.highlight:Destroy() end
    Tracked[p] = nil
end

-- Conexiones de Players
for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            ensureForPlayer(p)
        end)
        p.CharacterRemoving:Connect(function()
            cleanupPlayer(p)
        end)
        ensureForPlayer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function()
        task.wait(0.1)
        ensureForPlayer(p)
    end)
    p.CharacterRemoving:Connect(function()
        cleanupPlayer(p)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    cleanupPlayer(p)
end)

-- Input (hotkeys)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        SETTINGS.Enabled = not SETTINGS.Enabled
        LinesFolder.Enabled = SETTINGS.Enabled and SETTINGS.ShowTracers
        for p,reg in pairs(Tracked) do
            if reg.bill then reg.bill.Enabled = SETTINGS.Enabled and SETTINGS.ShowNames end
            if reg.highlight then reg.highlight.Enabled = SETTINGS.Enabled end
            if reg.tracer then reg.tracer.Visible = SETTINGS.Enabled and SETTINGS.ShowTracers end
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        SETTINGS.ShowNames = not SETTINGS.ShowNames
    elseif input.KeyCode == Enum.KeyCode.T then
        SETTINGS.ShowTracers = not SETTINGS.ShowTracers
        for _,reg in pairs(Tracked) do
            if reg.tracer then reg.tracer.Visible = SETTINGS.Enabled and SETTINGS.ShowTracers end
        end
    elseif input.KeyCode == Enum.KeyCode.Y then
        SETTINGS.TeamCheck = not SETTINGS.TeamCheck
    end
end)

-- Loop principal de render
RunService.RenderStepped:Connect(function()
    if not SETTINGS.Enabled then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local reg = Tracked[p]
            if char and reg then
                local head = safeGetHead(char)
                if head then
                    -- Teammate/Enemy colores
                    local isFriend = isTeammate(p)
                    local color = isFriend and SETTINGS.FriendColor or SETTINGS.EnemyColor

                    if reg.highlight then
                        reg.highlight.FillColor = color
                        reg.highlight.OutlineColor = SETTINGS.OutlineColor
                        reg.highlight.Enabled = true
                    end

                    -- NameTag
                    if reg.bill and reg.bill:FindFirstChild("Label") then
                        local dist = (Camera.CFrame.Position - head.Position).Magnitude
                        local label = reg.bill.Label
                        label.Visible = SETTINGS.ShowNames
                        label.Text = string.format("%s  |  %dm", p.DisplayName or p.Name, math.floor(dist + 0.5))
                        label.BackgroundColor3 = color:Lerp(Color3.new(0,0,0), 0.75)
                        label.TextColor3 = Color3.new(1,1,1)
                        reg.bill.Enabled = SETTINGS.ShowNames
                    end

                    -- Tracer 2D
                    if reg.tracer and SETTINGS.ShowTracers then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        reg.tracer.Visible = onScreen
                        if onScreen then
                            local origin = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * SETTINGS.TracerBaseY)
                            local target = Vector2.new(screenPos.X, screenPos.Y)

                            local dir = target - origin
                            local length = dir.Magnitude
                            local angle = math.deg(math.atan2(dir.Y, dir.X))

                            reg.tracer.Position = UDim2.fromOffset(origin.X, origin.Y)
                            reg.tracer.Size = UDim2.fromOffset(length, SETTINGS.TracerThickness)
                            reg.tracer.Rotation = angle
                            reg.tracer.BackgroundColor3 = color
                        end
                    end
                end
            end
        end
    end
end)

-- Micro panel flotante (esquina) con estado
do
    local panel = Instance.new("TextLabel")
    panel.Name = "ESP_Status"
    panel.Parent = ScreenGui
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -12, 0, 12)
    panel.Size = UDim2.fromOffset(210, 56)
    panel.BackgroundTransparency = 0.25
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    panel.TextColor3 = Color3.new(1,1,1)
    panel.Font = SETTINGS.Font
    panel.TextSize = 14
    panel.TextXAlignment = Enum.TextXAlignment.Right
    panel.TextYAlignment = Enum.TextYAlignment.Top
    panel.Text = ""

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.25
    stroke.Parent = panel

    task.spawn(function()
        while panel.Parent do
            panel.Text =
                ("ESP: %s\nNombres: %s  | Tracers: %s  | TeamCheck: %s\n[Shift der] [N] [T] [Y]"):format(
                    SETTINGS.Enabled and "ON" or "OFF",
                    SETTINGS.ShowNames and "ON" or "OFF",
                    SETTINGS.ShowTracers and "ON" or "OFF",
                    SETTINGS.TeamCheck and "ON" or "OFF"
                )
            task.wait(0.1)
        end
    end)
end
