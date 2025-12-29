-- PC Playing - Mobile to PC Controller
-- モバイルでPC操作を可能にするスクリプト

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- 設定
local settings = {
    joystickSize = 120,
    buttonSize = 60,
    transparency = 0.3,
    moveSpeed = 1,
    jumpPower = 50,
    showJoystick = true,
    showJump = true,
    vibration = true
}

-- UI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PCPlayingController"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- ドラッグ機能
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if input.Position.Y - mainFrame.AbsolutePosition.Y < 40 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- タイトルバー
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 20)
titleCover.Position = UDim2.new(0, 0, 1, -20)
titleCover.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PC Playing"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- 最小化ボタン(タイトルバー内)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(1, 0)
minBtnCorner.Parent = minimizeBtn

-- タブボタン
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local mainTab = Instance.new("TextButton")
mainTab.Name = "MainTab"
mainTab.Size = UDim2.new(0.5, -5, 1, 0)
mainTab.Position = UDim2.new(0, 5, 0, 0)
mainTab.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
mainTab.Text = "Main"
mainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTab.TextSize = 16
mainTab.Font = Enum.Font.GothamBold
mainTab.Parent = tabContainer

local mainTabCorner = Instance.new("UICorner")
mainTabCorner.CornerRadius = UDim.new(0, 8)
mainTabCorner.Parent = mainTab

local settingTab = Instance.new("TextButton")
settingTab.Name = "SettingTab"
settingTab.Size = UDim2.new(0.5, -5, 1, 0)
settingTab.Position = UDim2.new(0.5, 0, 0, 0)
settingTab.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
settingTab.Text = "Setting"
settingTab.TextColor3 = Color3.fromRGB(200, 200, 200)
settingTab.TextSize = 16
settingTab.Font = Enum.Font.Gotham
settingTab.Parent = tabContainer

local settingTabCorner = Instance.new("UICorner")
settingTabCorner.CornerRadius = UDim.new(0, 8)
settingTabCorner.Parent = settingTab

-- コンテンツエリア
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -95)
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Main タブコンテンツ
local mainContent = Instance.new("ScrollingFrame")
mainContent.Name = "MainContent"
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.ScrollBarThickness = 4
mainContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
mainContent.CanvasSize = UDim2.new(0, 0, 0, 0)
mainContent.Parent = contentFrame

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 10)
mainLayout.Parent = mainContent

local function createToggle(name, defaultValue, parent)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleFrame.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(80, 80, 85)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    
    local toggleCrn = Instance.new("UICorner")
    toggleCrn.CornerRadius = UDim.new(0, 12)
    toggleCrn.Parent = toggle
    
    local value = defaultValue
    toggle.MouseButton1Click:Connect(function()
        value = not value
        toggle.BackgroundColor3 = value and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(80, 80, 85)
        toggle.Text = value and "ON" or "OFF"
    end)
    
    return toggleFrame, function() return value end
end

local joystickToggle, getJoystickEnabled = createToggle("Show Joystick", true, mainContent)
local jumpToggle, getJumpEnabled = createToggle("Show Jump Button", true, mainContent)

-- Setting タブコンテンツ
local settingContent = Instance.new("ScrollingFrame")
settingContent.Name = "SettingContent"
settingContent.Size = UDim2.new(1, 0, 1, 0)
settingContent.BackgroundTransparency = 1
settingContent.ScrollBarThickness = 4
settingContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
settingContent.Visible = false
settingContent.CanvasSize = UDim2.new(0, 0, 0, 0)
settingContent.Parent = contentFrame

local settingLayout = Instance.new("UIListLayout")
settingLayout.Padding = UDim.new(0, 10)
settingLayout.Parent = settingContent

local function createSlider(name, min, max, default, parent)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderFrame.Parent = parent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 1, -15)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    sliderBg.Parent = sliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local value = default
    local draggingSlider = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * relativeX
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            label.Text = name .. ": " .. math.floor(value * 10) / 10
        end
    end)
    
    return sliderFrame, function() return value end
end

local transparencySlider, getTransparency = createSlider("Transparency", 0, 1, 0.3, settingContent)
local sizeSlider, getSize = createSlider("Control Size", 80, 150, 120, settingContent)

-- タブ切り替え
local currentTab = "main"

mainTab.MouseButton1Click:Connect(function()
    if currentTab ~= "main" then
        currentTab = "main"
        mainContent.Visible = true
        settingContent.Visible = false
        mainTab.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        mainTab.Font = Enum.Font.GothamBold
        settingTab.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        settingTab.Font = Enum.Font.Gotham
    end
end)

settingTab.MouseButton1Click:Connect(function()
    if currentTab ~= "setting" then
        currentTab = "setting"
        mainContent.Visible = false
        settingContent.Visible = true
        settingTab.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        settingTab.Font = Enum.Font.GothamBold
        mainTab.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        mainTab.Font = Enum.Font.Gotham
    end
end)

-- 固定最小化ボタン(左下)
local fixedMinBtn = Instance.new("TextButton")
fixedMinBtn.Name = "FixedMinimizeButton"
fixedMinBtn.Size = UDim2.new(0, 50, 0, 50)
fixedMinBtn.Position = UDim2.new(0, 15, 1, -65)
fixedMinBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
fixedMinBtn.Text = "📱"
fixedMinBtn.TextSize = 24
fixedMinBtn.Visible = false
fixedMinBtn.Parent = screenGui

local fixedMinCorner = Instance.new("UICorner")
fixedMinCorner.CornerRadius = UDim.new(1, 0)
fixedMinCorner.Parent = fixedMinBtn

-- 最小化機能
local minimized = false

local function toggleMinimize()
    minimized = not minimized
    mainFrame.Visible = not minimized
    fixedMinBtn.Visible = minimized
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
fixedMinBtn.MouseButton1Click:Connect(toggleMinimize)

-- ゲームコントロール(ジョイスティックとジャンプボタン)
local controlGui = Instance.new("ScreenGui")
controlGui.Name = "GameControls"
controlGui.ResetOnSpawn = false
controlGui.Parent = player:WaitForChild("PlayerGui")

-- ジョイスティック
local joystickBase = Instance.new("Frame")
joystickBase.Name = "JoystickBase"
joystickBase.Size = UDim2.new(0, settings.joystickSize, 0, settings.joystickSize)
joystickBase.Position = UDim2.new(0, 30, 1, -settings.joystickSize - 30)
joystickBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
joystickBase.BackgroundTransparency = settings.transparency
joystickBase.Parent = controlGui

local joystickCorner = Instance.new("UICorner")
joystickCorner.CornerRadius = UDim.new(1, 0)
joystickCorner.Parent = joystickBase

local joystickStick = Instance.new("Frame")
joystickStick.Name = "JoystickStick"
joystickStick.Size = UDim2.new(0, settings.joystickSize * 0.5, 0, settings.joystickSize * 0.5)
joystickStick.Position = UDim2.new(0.5, -settings.joystickSize * 0.25, 0.5, -settings.joystickSize * 0.25)
joystickStick.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
joystickStick.BackgroundTransparency = settings.transparency
joystickStick.Parent = joystickBase

local joystickStickCorner = Instance.new("UICorner")
joystickStickCorner.CornerRadius = UDim.new(1, 0)
joystickStickCorner.Parent = joystickStick

-- ジャンプボタン
local jumpButton = Instance.new("TextButton")
jumpButton.Name = "JumpButton"
jumpButton.Size = UDim2.new(0, settings.buttonSize, 0, settings.buttonSize)
jumpButton.Position = UDim2.new(1, -settings.buttonSize - 30, 1, -settings.buttonSize - 30)
jumpButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
jumpButton.BackgroundTransparency = settings.transparency
jumpButton.Text = "🦘"
jumpButton.TextSize = 28
jumpButton.Parent = controlGui

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(1, 0)
jumpCorner.Parent = jumpButton

-- ジョイスティック制御
local joystickActive = false
local joystickInput = Vector2.new(0, 0)

joystickBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        joystickActive = true
    end
end)

joystickBase.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        joystickActive = false
        joystickInput = Vector2.new(0, 0)
        joystickStick.Position = UDim2.new(0.5, -settings.joystickSize * 0.25, 0.5, -settings.joystickSize * 0.25)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if joystickActive and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local center = joystickBase.AbsolutePosition + joystickBase.AbsoluteSize / 2
        local delta = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
        local distance = math.min(delta.Magnitude, settings.joystickSize / 2)
        local direction = delta.Unit
        
        joystickInput = direction * (distance / (settings.joystickSize / 2))
        
        local stickPos = direction * distance
        joystickStick.Position = UDim2.new(0.5, stickPos.X - settings.joystickSize * 0.25, 0.5, stickPos.Y - settings.joystickSize * 0.25)
    end
end)

-- ジャンプ機能
jumpButton.MouseButton1Click:Connect(function()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- キャラクター移動
RunService.RenderStepped:Connect(function()
    if character and humanoid and joystickInput.Magnitude > 0.1 and getJoystickEnabled() then
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local moveDirection = (cameraCFrame.RightVector * joystickInput.X + cameraCFrame.LookVector * -joystickInput.Y).Unit
        humanoid:Move(moveDirection)
    end
end)

-- 設定の適用
RunService.Heartbeat:Connect(function()
    local trans = getTransparency()
    local size = getSize()
    
    joystickBase.BackgroundTransparency = trans
    joystickStick.BackgroundTransparency = trans
    jumpButton.BackgroundTransparency = trans
    
    joystickBase.Visible = getJoystickEnabled()
    jumpButton.Visible = getJumpEnabled()
    
    joystickBase.Size = UDim2.new(0, size, 0, size)
    joystickStick.Size = UDim2.new(0, size * 0.5, 0, size * 0.5)
    jumpButton.Size = UDim2.new(0, size * 0.5, 0, size * 0.5)
end)

-- Canvas Size自動調整
mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainContent.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 10)
end)

settingLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    settingContent.CanvasSize = UDim2.new(0, 0, 0, settingLayout.AbsoluteContentSize.Y + 10)
end)