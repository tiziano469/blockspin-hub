-- Auto ATM Farmer para BlockSpin con GUI
-- Autor: ChatGPT

-- Variables
local autoFarm = false
local waitTime = 2 -- tiempo entre acciones
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ATMGui"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = "AutoFarm ATM: OFF"
button.Parent = gui
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.1

-- Función para buscar y farmear ATMs
function farmATM()
    while wait(waitTime) do
        if not autoFarm then break end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("ATM") then
                local atmPart = obj:FindFirstChild("ATM")
                if atmPart and atmPart:IsA("BasePart") then
                    hrp.CFrame = atmPart.CFrame + Vector3.new(0, 2, 0)
                    wait(0.5)
                    local prompt = atmPart:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                    wait(1.5)
                end
            end
        end
    end
end

-- Alternar AutoFarm
button.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    button.Text = autoFarm and "AutoFarm ATM: ON" or "AutoFarm ATM: OFF"
    button.BackgroundColor3 = autoFarm and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
    if autoFarm then
        task.spawn(farmATM)
    end
end)

-- Seguridad
if not fireproximityprompt then
    warn("Tu ejecutor no soporta 'fireproximityprompt'.")
    button.Text = "Ejecutor no soportado"
    button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
end
