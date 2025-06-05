--// Infinite Stamina Script for Blockspin
--// Bypass stamina drain by hooking function

-- Protege de detección básica
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar al character y humanoide
repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

-- Hook de método que reduce la stamina
-- Este ejemplo busca el RemoteEvent o Function que gestiona la stamina

for _, v in pairs(getgc(true)) do
    if typeof(v) == "function" and islclosure(v) then
        local info = debug.getinfo(v)
        if info.name == "TakeStamina" or tostring(info.name):lower():find("stamina") then
            hookfunction(v, function(...)
                -- Ignora la llamada, no se reduce stamina
                return
            end)
            print("[+] Hook aplicado a función de stamina:", info.name)
        end
    end
end
