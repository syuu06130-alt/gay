-- LocalScript
-- Syu_hub Ultimate Edition v2.0
-- Cyberpunk Neon Mobile/PC Emulator Hub

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--------------------------------------------------------------------------------
-- [Setting] テーマ
--------------------------------------------------------------------------------
local THEME = {
    MainColor = Color3.fromRGB(10, 10, 15),
    AccentColor = Color3.fromRGB(0, 255, 255),     -- Cyan
    AccentColor2 = Color3.fromRGB(255, 0, 150),    -- Magenta
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonColor = Color3.fromRGB(30, 30, 40),
    RippleColor = Color3.fromRGB(255, 255, 255),
}

local WASD_SCALE = 1.0
local isWasdVisible = false
local keysDown = { W = false, A = false, S = false, D = false, Space = false, E = false }

--------------------------------------------------------------------------------
-- [Utility] アニメーション関数
--------------------------------------------------------------------------------
local function spawnRipple(button, inputPosition)
    if not button:FindFirstChild("RippleContainer") then
        local c = Instance.new("Frame")
        c.Name = "RippleContainer"
        c.Size = UDim2.new(1,0,1,0)
        c.BackgroundTransparency = 1
        c.ClipsDescendants = true
        c.ZIndex = 9
        c.Parent = button
    end
    local container = button.RippleContainer
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = THEME.RippleColor
    ripple.BackgroundTransparency = 0.6
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local absPos = button.AbsolutePosition
    local relX = (inputPosition.X - absPos.X) / button.AbsoluteSize.X
    local relY = (inputPosition.Y - absPos.Y) / button.AbsoluteSize.Y
    ripple.Position = UDim2.new(relX, 0, relY, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    ripple.Parent = container
    
    local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3
    local tween = TweenService:Create(ripple, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

local function animateButtonPress(btn, isDown, inputObj)
    local uiScale = btn:FindFirstChild("UIScale") or Instance.new("UIScale", btn)
    local target = isDown and 0.9 or 1.0
    TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = target}):Play()
    if isDown and inputObj then
        spawnRipple(btn, inputObj.Position)
    end
end

local function applyRotatingRainbow(stroke)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME.AccentColor),
        ColorSequenceKeypoint.new(0.5, THEME.AccentColor2),
        ColorSequenceKeypoint.new(1, THEME.AccentColor),
    }
    gradient.Rotation = 0
    gradient.Parent = stroke
    RunService.Heartbeat:Connect(function(dt)
        if stroke.Parent and stroke.Parent.Visible then
            gradient.Rotation = (gradient.Rotation + dt * 50) % 360
        end
    end)
end

--------------------------------------------------------------------------------
-- [オープニングアニメーション] 3種類をランダム再生
--------------------------------------------------------------------------------
local function playIntro(onComplete)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.ZIndex = 100
    frame.Parent = screenGui

    local introType = math.random(1, 3)

    if introType == 1 then
        -- Type 1: Matrix Digital Rain + Glitch Title
        local title = Instance.new("TextLabel")
        title.Text = "SYU_HUB"
        title.Font = Enum.Font.Code
        title.TextSize = 80
        title.TextColor3 = THEME.AccentColor
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1,0,0.3,0)
        title.Position = UDim2.new(0,0,0.35,0)
        title.TextTransparency = 1
        title.Parent = frame

        -- Digital rain effect
        for i = 1, 40 do
            local rain = Instance.new("TextLabel")
            rain.Text = string.rep("1\n0\n", 20)
            rain.Font = Enum.Font.Code
            rain.TextSize = 20
            rain.TextColor3 = THEME.AccentColor
            rain.TextTransparency = 0.7
            rain.Size = UDim2.new(0,30,1,0)
            rain.Position = UDim2.new(0, math.random(0, workspace.CurrentCamera.ViewportSize.X-30), 0, -1000)
            rain.Parent = frame
            TweenService:Create(rain, TweenInfo.new(math.random(30,50)/10, Enum.EasingStyle.Linear), {Position = UDim2.new(rain.Position.X.Scale, rain.Position.X.Offset, 1, 1000)}):Play()
        end

        task.wait(1)
        TweenService:Create(title, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
        task.wait(1.2)
        for i = 1, 8 do
            title.TextColor3 = i%2==0 and THEME.AccentColor2 or THEME.AccentColor
            title.Position = title.Position + UDim2.new(0, math.random(-10,10), 0, math.random(-10,10))
            task.wait(0.08)
        end
        task.wait(1)

    elseif introType == 2 then
        -- Type 2: Neon Scan Line + Pulse Reveal
        local scan = Instance.new("Frame")
        scan.Size = UDim2.new(1,0,0,6)
        scan.Position = UDim2.new(0,0,0.5,0)
        scan.BackgroundColor3 = THEME.AccentColor
        scan.Parent = frame
        Instance.new("UIGradient", scan).Color = ColorSequence.new(THEME.AccentColor, Color3.new(1,1,1), THEME.AccentColor)

        local title = Instance.new("TextLabel")
        title.Text = "SYU_HUB ULTIMATE"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 70
        title.TextColor3 = THEME.AccentColor
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1,0,0.3,0)
        title.Position = UDim2.new(0,0,0.4,0)
        title.TextTransparency = 1
        title.Parent = frame

        for i = 1, 5 do
            TweenService:Create(scan, TweenInfo.new(0.6), {Position = UDim2.new(0,0,-0.1,0)}):Play()
            task.wait(0.3)
            TweenService:Create(scan, TweenInfo.new(0.6), {Position = UDim2.new(0,0,1.1,0)}):Play()
            task.wait(0.6)
        end
        TweenService:Create(title, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(1.5)

    else
        -- Type 3: Particle Burst + Hologram
        local title = Instance.new("TextLabel")
        title.Text = "SYU_HUB"
        title.Font = Enum.Font.Arcade
        title.TextSize = 90
        title.TextColor3 = THEME.AccentColor
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1,0,0.3,0)
        title.Position = UDim2.new(0,0,0.4,0)
        title.TextTransparency = 1
        title.Rotation = -20
        title.Parent = frame

        -- Particle effect
        for i = 1, 60 do
            local p = Instance.new("Frame")
            p.Size = UDim2.new(0,6,0,6)
            p.BackgroundColor3 = math.random(1,2)==1 and THEME.AccentColor or THEME.AccentColor2
            p.Position = UDim2.new(0.5,0,0.5,0)
            p.AnchorPoint = Vector2.new(0.5,0.5)
            p.Parent = frame
            local angle = math.rad(i * 6)
            local dist = 800
            TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, math.cos(angle)*dist, 0.5, math.sin(angle)*dist),
                BackgroundTransparency = 1
            }):Play()
        end

        TweenService:Create(title, TweenInfo.new(1.5, Enum.EasingStyle.Elastic), {
            TextTransparency = 0,
            Rotation = 0
        }):Play()
        task.wait(2)
    end

    -- Fade out
    TweenService:Create(frame, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    task.wait(0.8)
    frame:Destroy()
    if onComplete then onComplete() end
end

--------------------------------------------------------------------------------
-- [キーシミュレーション]
--------------------------------------------------------------------------------
local function simulateKey(keyCodeName, down)
    local keyCode = Enum.KeyCode[keyCodeName]
    if down then
        if not keysDown[keyCodeName] then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            keysDown[keyCodeName] = true
        end
    else
        if keysDown[keyCodeName] then
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            keysDown[keyCodeName] = false
        end
    end
end

--------------------------------------------------------------------------------
-- [GUI構築]
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyuHub_Ultimate"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- WASD Overlay
local wasdContainer = Instance.new("Frame")
wasdContainer.Name = "WASD_Overlay"
wasdContainer.Size = UDim2.new(0, 200, 0, 150)
wasdContainer.Position = UDim2.new(0.05, 0, 0.65, 0)
wasdContainer.BackgroundTransparency = 1
wasdContainer.Visible = false
wasdContainer.Parent = screenGui

local dragging, dragInput, dragStart, startPos
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(wasdContainer)

local function createWasdButtons()
    wasdContainer:ClearAllChildren()
    local baseSize = 55 * WASD_SCALE
    local padding = 10 * WASD_SCALE
    local totalW = baseSize*3 + padding*2
    local totalH = baseSize*2 + padding

    local function makeBtn(text, key, xPos, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, baseSize, 0, baseSize)
        btn.Position = UDim2.new(0, xPos, 0, yPos)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = THEME.AccentColor
        btn.TextSize = 28 * WASD_SCALE
        btn.Font = Enum.Font.GothamBlack
        btn.Parent = wasdContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = THEME.AccentColor
        stroke.Transparency = 0.4
        stroke.Parent = btn

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                simulateKey(key, true)
                animateButtonPress(btn, true, input)
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.AccentColor, TextColor3 = Color3.new(0,0,0)}):Play()
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                simulateKey(key, false)
                animateButtonPress(btn, false)
                TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = THEME.AccentColor}):Play()
            end
        end)
    end

    local midX = baseSize + padding
    makeBtn("W", "W", midX, 0)
    makeBtn("A", "A", 0, baseSize + padding)
    makeBtn("S", "S", midX, baseSize + padding)
    makeBtn("D", "D", (baseSize + padding)*2, baseSize + padding)
end
createWasdButtons()

-- Main Hub Panel
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainHub"
mainFrame.Size = UDim2.new(0, 340, 0, 480)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
mainFrame.BackgroundColor3 = THEME.MainColor
mainFrame.BackgroundTransparency = 0.15
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 4
mainStroke.Parent = mainFrame
applyRotatingRainbow(mainStroke)

local title = Instance.new("TextLabel")
title.Text = "SYU_HUB // ULTIMATE"
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = THEME.AccentColor
title.Size = UDim2.new(1, -30, 0, 50)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- トグル作成関数
local function createToggle(text, posY, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, 50)
    container.Position = UDim2.new(0, 20, 0, posY)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 17
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local switchBg = Instance.new("TextButton")
    switchBg.Text = ""
    switchBg.Size = UDim2.new(0, 66, 0, 34)
    switchBg.Position = UDim2.new(1, -66, 0.5, -17)
    switchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    switchBg.AutoButtonColor = false
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    switchBg.Parent = container

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 28, 0, 28)
    knob.Position = default and UDim2.new(1, -31, 0.5, -14) or UDim2.new(0, 3, 0.5, -14)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Parent = switchBg

    local isOn = default
    switchBg.BackgroundColor3 = isOn and THEME.AccentColor or Color3.fromRGB(50, 50, 50)

    switchBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        local targetPos = isOn and UDim2.new(1, -31, 0.5, -14) or UDim2.new(0, 3, 0.5, -14)
        local targetBg = isOn and THEME.AccentColor or Color3.fromRGB(50, 50, 50)
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.3), {BackgroundColor3 = targetBg}):Play()
        spawnRipple(switchBg, switchBg.AbsolutePosition + Vector2.new(33,17))
        callback(isOn)
    end)
    return isOn
end

-- 新機能トグル一覧
local yPos = 70
createToggle("WASD Overlay", yPos, false, function(state) 
    isWasdVisible = state
    wasdContainer.Visible = state
    if state then
        wasdContainer.Size = UDim2.new(0,0,0,0)
        TweenService:Create(wasdContainer, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 200, 0, 150)}):Play()
    end
end); yPos += 60

createToggle("Jump Button (Space)", yPos, false, function(state)
    -- 別途ジャンプボタンを作成する場合はここに追加可能（今回はシンプルにキーシミュレートのみ）
end); yPos += 60

createToggle("Auto Sprint", yPos, false, function(state)
    -- 実装例（ゲーム依存）
end); yPos += 60

createToggle("FPS Counter", yPos, false, function(state)
    -- 簡単なFPSカウンター表示（例）
end); yPos += 60

createToggle("Touch Joystick", yPos, false, function(state)
    -- 仮想ジョイスティック表示（別途実装可能）
end); yPos += 60

createToggle("Night Mode", yPos, false, function(state)
    -- 画面全体の明るさ調整（Lighting.Brightnessなど）
end); yPos += 60

createToggle("Hide HUD", yPos, false, function(state)
    -- game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not state)
end); yPos += 60

-- サイズ調整
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Text = "WASD Size Scale"
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.TextSize = 16
sizeLabel.TextColor3 = Color3.fromRGB(180,180,180)
sizeLabel.Size = UDim2.new(1, -40, 0, 30)
sizeLabel.Position = UDim2.new(0, 20, 0, yPos)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Parent = mainFrame
yPos += 40

local function createCircleBtn(text, posX, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, posX, 0, yPos)
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 30
    btn.TextColor3 = THEME.TextColor
    btn.BackgroundColor3 = THEME.ButtonColor
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = THEME.AccentColor
    stroke.Parent = btn
    btn.Parent = mainFrame

    btn.InputBegan:Connect(function(input) animateButtonPress(btn, true, input) end)
    btn.InputEnded:Connect(function() animateButtonPress(btn, false) callback() end)
end

createCircleBtn("-", 40, function()
    WASD_SCALE = math.clamp(WASD_SCALE - 0.15, 0.6, 2.0)
    createWasdButtons()
end)
createCircleBtn("+", 110, function()
    WASD_SCALE = math.clamp(WASD_SCALE + 0.15, 0.6, 2.0)
    createWasdButtons()
end)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 60, 0, 60)
minimizeBtn.Position = UDim2.new(0, 20, 0.85, 0)
minimizeBtn.Text = ""
minimizeBtn.BackgroundColor3 = THEME.MainColor
minimizeBtn.BackgroundTransparency = 0.3
minimizeBtn.Visible = false
minimizeBtn.Parent = screenGui

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
local minStroke = Instance.new("UIStroke")
minStroke.Thickness = 3
minStroke.Color = THEME.AccentColor
minStroke.Parent = minimizeBtn

local iconImg = Instance.new("ImageLabel")
iconImg.Size = UDim2.new(0.6, 0, 0.6, 0)
iconImg.Position = UDim2.new(0.2, 0, 0.2, 0)
iconImg.BackgroundTransparency = 1
iconImg.Image = "rbxassetid://6034818379" -- Menu
iconImg.ImageColor3 = THEME.AccentColor
iconImg.Parent = minimizeBtn

minimizeBtn.MouseButton1Click:Connect(function()
    spawnRipple(minimizeBtn, minimizeBtn.AbsolutePosition + Vector2.new(30,30))
    if not mainFrame.Visible then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0,0,0,0)
        mainFrame.Position = minimizeBtn.Position + UDim2.new(0,0,0,-300)
        mainFrame.Rotation = -30
        TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {
            Size = UDim2.new(0, 340, 0, 480),
            Position = UDim2.new(0.5, -170, 0.5, -240),
            Rotation = 0
        }):Play()
        iconImg.Image = "rbxassetid://6031094678" -- X
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0),
            Position = minimizeBtn.Position + UDim2.new(0,0,0,-300),
            Rotation = 45
        })
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
            iconImg.Image = "rbxassetid://6034818379"
        end)
    end
end)

-- Startup
playIntro(function()
    minimizeBtn.Visible = true
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {
        Size = UDim2.new(0, 340, 0, 480)
    }):Play()
end)
