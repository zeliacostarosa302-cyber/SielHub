
-- SIEL OPTIMIZATION V4
-- Roblox / Delta Executor
-- Mantém texturas e materiais do mapa.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remover versão anterior
local old = playerGui:FindFirstChild("SielOptimization")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SielOptimization"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local original = {
    GlobalShadows = Lighting.GlobalShadows,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    Effects = {}
}

for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("PostEffect") then
        original.Effects[obj] = obj.Enabled
    end
end

local settings = {
    particles = false,
    shadows = false,
    lowGraphics = false,
    cleanEffects = false,
    antiFog = false
}

-- Cores
local purple = Color3.fromRGB(130, 65, 220)
local dark = Color3.fromRGB(18, 15, 27)
local white = Color3.fromRGB(245, 240, 255)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(270, 390)
panel.Position = UDim2.new(0.5, -135, 0.5, -195)
panel.BackgroundColor3 = dark
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = purple
stroke.Thickness = 2
stroke.Parent = panel

-- Cabeçalho
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -90, 0, 45)
header.Position = UDim2.fromOffset(12, 0)
header.BackgroundTransparency = 1
header.Text = "SIEL OPTIMIZATION"
header.TextColor3 = white
header.TextSize = 17
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

-- Arrastar painel
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Botão minimizar
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -78, 0, 8)
minimize.Text = "—"
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = white
minimize.BackgroundColor3 = purple
minimize.Parent = panel
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

-- Botão fechar
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -38, 0, 8)
close.Text = "X"
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.TextColor3 = white
close.BackgroundColor3 = Color3.fromRGB(170, 45, 65)
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

-- Botão flutuante S
local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(48, 48)
reopen.Position = UDim2.new(0, 20, 0.5, -24)
reopen.Text = "S"
reopen.TextSize = 23
reopen.Font = Enum.Font.GothamBold
reopen.TextColor3 = white
reopen.BackgroundColor3 = purple
reopen.Visible = false
reopen.Parent = gui
Instance.new("UICorner", reopen).CornerRadius = UDim.new(1, 0)

minimize.MouseButton1Click:Connect(function()
    panel.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    panel.Visible = true
    reopen.Visible = false
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 25)
fpsLabel.Position = UDim2.fromOffset(10, 45)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(190, 160, 255)
fpsLabel.Text = "FPS: --"
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = panel

local frames = 0
local elapsed = 0

local fpsConnection = RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
    if elapsed >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        elapsed = 0
    end
end)

-- Criar botões
local function createButton(name, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 36)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(43, 34, 59)
    button.TextColor3 = white
    button.Text = name .. " [OFF]"
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.Parent = panel

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    local enabled = false

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = name .. (enabled and " [ON]" or " [OFF]")
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(105, 55, 165)
            or Color3.fromRGB(43, 34, 59)

        callback(enabled)
    end)

    return button
end

-- No Particles
createButton("No Particles", 80, function(on)
    settings.particles = on
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Beam") then
            if on then
                obj.Enabled = false
            end
        end
    end
end)

-- No Shadows
createButton("No Shadows", 124, function(on)
    settings.shadows = on
    Lighting.GlobalShadows = on and false or original.GlobalShadows
end)

-- Low Graphics (preserva texturas e materiais)
createButton("Low Graphics", 168, function(on)
    settings.lowGraphics = on
    if on then
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    else
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    end
end)

-- Clean Effects
createButton("Clean Effects", 212, function(on)
    settings.cleanEffects = on
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") then
            if on then
                obj.Enabled = false
            elseif original.Effects[obj] ~= nil then
                obj.Enabled = original.Effects[obj]
            end
        end
    end
end)

-- Anti Fog
createButton("Anti Fog", 256, function(on)
    settings.antiFog = on
    if on then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    else
        Lighting.FogStart = original.FogStart
        Lighting.FogEnd = original.FogEnd
    end
end)

-- Restaurar
local restore = Instance.new("TextButton")
restore.Size = UDim2.new(1, -24, 0, 36)
restore.Position = UDim2.fromOffset(12, 300)
restore.BackgroundColor3 = Color3.fromRGB(70, 110, 80)
restore.TextColor3 = white
restore.Text = "Restore Graphics"
restore.Font = Enum.Font.GothamBold
restore.TextSize = 13
restore.Parent = panel
Instance.new("UICorner", restore).CornerRadius = UDim.new(0, 8)

restore.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.FogStart = original.FogStart
    Lighting.FogEnd = original.FogEnd

    for obj, enabled in pairs(original.Effects) do
        if obj and obj.Parent then
            obj.Enabled = enabled
        end
    end

    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Beam") then
            obj.Enabled = true
        end
    end

    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("%[") then
            child.Text = child.Text:gsub("%[ON%]", "[OFF]")
            child.BackgroundColor3 = Color3.fromRGB(43, 34, 59)
        end
    end

    for key in pairs(settings) do
        settings[key] = false
    end
end)

-- Encerrar conexões ao fechar
close.MouseButton1Click:Connect(function()
    fpsConnection:Disconnect()
end)
