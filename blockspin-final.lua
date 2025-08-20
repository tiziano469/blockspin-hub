-- Nametags compactos para Roblox (LocalScript)
-- Muestra solo un pequeño nametag sobre la cabeza de cada jugador (excluye al local player)
-- Instalación: StarterPlayerScripts (o ejecutar en cliente)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local showSelf = false -- cambiar a true si quieres ver tu propio nametag

-- Ajustes visuales (pequeños / poco intrusivos)
local TAG_SIZE = UDim2.new(0, 110, 0, 18) -- ancho x alto fijo (compacto)
local STROKE_TRANSPARENCY = 0.75
local BG_TRANSPARENCY = 0.5
local TEXT_SIZE = 14
local OFFSET = Vector3.new(0, 1.25, 0) -- offset sobre la cabeza

-- Crea el nametag para un personaje
local function createNametagFor(character, player)
    if not character then return end
    local head = character:WaitForChild("Head", 2)
    if not head then return end

    -- Evitar duplicados
    if head:FindFirstChild("CompactNameTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CompactNameTag"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Size = TAG_SIZE
    billboard.StudsOffset = OFFSET
    billboard.MaxDistance = 500 -- distancia máxima para mostrarse (mejora rendimiento)
    billboard.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0
    frame.LayoutOrder = 1
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = player.DisplayName or player.Name
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = TEXT_SIZE
    label.TextStrokeTransparency = STROKE_TRANSPARENCY
    label.RichText = false
    label.TextWrapped = false
    label.ClipsDescendants = true
    label.Parent = frame

    -- Color según equipo si existe, si no blanco/gris
    local function updateColor()
        if player.Team and player.Team.TeamColor then
            label.TextColor3 = player.Team.TeamColor.Color
        else
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
        end
    end
    updateColor()

    -- Actualizar nombre si cambian DisplayName/Name
    player:GetPropertyChangedSignal("DisplayName"):Connect(function() label.Text = player.DisplayName or player.Name end)
    player:GetPropertyChangedSignal("Name"):Connect(function() label.Text = player.DisplayName or player.Name end)

    -- Limpiar cuando personaje muera/desaparezca
    local function cleanup()
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() end
    end)
end

-- Manejo cuando aparece un personaje
local function onCharacterAdded(character, player)
    -- esperar Head existente y crear tag
    spawn(function()
        createNametagFor(character, player)
    end)
end

-- Registrar jugador: crear nametag si ya tiene personaje y conectar CharacterAdded
local function registerPlayer(player)
    if player == localPlayer and not showSelf then return end

    if player.Character then
        onCharacterAdded(player.Character, player)
    end
    player.CharacterAdded:Connect(function(char) onCharacterAdded(char, player) end)
end

-- Inicial: todos los jugadores existentes
for _, p in pairs(Players:GetPlayers()) do
    registerPlayer(p)
end

-- Nuevos jugadores
Players.PlayerAdded:Connect(function(player)
    registerPlayer(player)
end)

-- Opcional: limpiar nametags si el cliente pierde personaje (por ejemplo al reaparecer)
local function onLocalCharacterAdded(char)
    -- pequeñas pausas para evitar duplicados; no es obligatorio
    wait(0.1)
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= localPlayer or showSelf then
            if other.Character then
                createNametagFor(other.Character, other)
            end
        end
    end
end
if localPlayer then
    localPlayer.CharacterAdded:Connect(onLocalCharacterAdded)
end
