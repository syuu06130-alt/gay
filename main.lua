-- Auto Clicker GUI for Roblox
-- 黒いクールなデザイン with ドラッグ & 最小化機能

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ScreenGui作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoClickerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- メインフレーム（クールな黒デザイン）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- 影効果
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎮 Auto Clicker Pro"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- 最小化ボタン
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- スクロールフレーム
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

-- UIListLayout
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Parent = ScrollFrame

-- パディング
local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = ScrollFrame

-- ボタン作成関数
local function CreateToggleButton(name, defaultState)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 280, 0, 45)
    Button.BackgroundColor3 = defaultState and Color3.fromRGB(30, 150, 100) or Color3.fromRGB(40, 40, 40)
    Button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    return Button
end

-- 状態変数
local autoClickEnabled = false
local autoFarmEnabled = false
local clickSpeed = 0.1

-- Auto Click ボタン
local AutoClickBtn = CreateToggleButton("Auto Click Money", false)

-- Auto Farm ボタン
local AutoFarmBtn = CreateToggleButton("Auto Farm All", false)

-- Speed設定
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 280, 0, 30)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedLabel.Text = "Click Speed: " .. clickSpeed .. "s"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 13
SpeedLabel.Parent = ScrollFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedLabel

-- 速度調整ボタン
local SpeedUpBtn = CreateToggleButton("Speed +", false)
local SpeedDownBtn = CreateToggleButton("Speed -", false)

-- 統計情報
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0, 280, 0, 60)
StatsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatsLabel.Text = "Clicks: 0\nStatus: Idle"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.Parent = ScrollFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsLabel

-- ドラッグ機能
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- 最小化機能
local minimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "−"
    end
end)

-- 閉じる機能
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Auto Click機能
local clickCount = 0

AutoClickBtn.MouseButton1Click:Connect(function()
    autoClickEnabled = not autoClickEnabled
    AutoClickBtn.BackgroundColor3 = autoClickEnabled and Color3.fromRGB(30, 150, 100) or Color3.fromRGB(40, 40, 40)
    AutoClickBtn.Text = "Auto Click Money: " .. (autoClickEnabled and "ON" or "OFF")
end)

-- Auto Farm機能
AutoFarmBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    AutoFarmBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(30, 150, 100) or Color3.fromRGB(40, 40, 40)
    AutoFarmBtn.Text = "Auto Farm All: " .. (autoFarmEnabled and "ON" or "OFF")
end)

-- 速度調整
SpeedUpBtn.MouseButton1Click:Connect(function()
    clickSpeed = math.max(0.01, clickSpeed - 0.05)
    SpeedLabel.Text = "Click Speed: " .. string.format("%.2f", clickSpeed) .. "s"
end)

SpeedDownBtn.MouseButton1Click:Connect(function()
    clickSpeed = math.min(1, clickSpeed + 0.05)
    SpeedLabel.Text = "Click Speed: " .. string.format("%.2f", clickSpeed) .. "s"
end)

-- メインループ
spawn(function()
    while wait(clickSpeed) do
        if autoClickEnabled and ReplicatedStorage:FindFirstChild("Events") then
            local success = pcall(function()
                ReplicatedStorage.Events.ClickMoney:FireServer()
                clickCount = clickCount + 1
            end)
            if success then
                StatsLabel.Text = "Clicks: " .. clickCount .. "\nStatus: Active"
            end
        elseif not autoClickEnabled then
            StatsLabel.Text = "Clicks: " .. clickCount .. "\nStatus: Idle"
        end
    end
end)

-- ホバーエフェクト
local buttons = {AutoClickBtn, AutoFarmBtn, SpeedUpBtn, SpeedDownBtn}
for _, btn in pairs(buttons) do
    btn.MouseEnter:Connect(function()
        btn:TweenSize(UDim2.new(0, 285, 0, 48), "Out", "Quad", 0.2, true)
    end)
    btn.MouseLeave:Connect(function()
        btn:TweenSize(UDim2.new(0, 280, 0, 45), "Out", "Quad", 0.2, true)
    end)
end

print("Auto Clicker GUI loaded successfully!")
