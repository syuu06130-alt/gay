-- // 限定Script UI - クールな黒デザイン //
-- 使い方：LocalScriptとしてScreenGui内に配置

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ScreenGui作成（既にあれば使い回し）
local ScreenGui = script.Parent
if not ScreenGui:IsA("ScreenGui") then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = PlayerGui
    script.Parent = ScreenGui
end
ScreenGui.ResetOnSpawn = false

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Name = "CheaterUI"
MainFrame.Size = UDim2.new(0, 360, 0, 500)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 12, 1, 12)
Shadow.Position = UDim2.new(0, -6, 0, -6)
Shadow.BackgroundTransparency = 0.5
Shadow.BackgroundColor3 = Color3.new(0, 0, 0)
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 14)
ShadowCorner.Parent = Shadow

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "限定チェイター"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 8)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- コンテンツエリア（スクロール対応）
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800) -- 後で調整
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ContentFrame

-- ここから機能ボタンを追加（例）--
-- 例: 無限マネー
local function createButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 16
    Btn.BorderSizePixel = 0
    Btn.Parent = ContentFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)

    -- ホバーエフェクト
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 75)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)

    return Btn
end

-- 例の機能（元のゲームのClickMoneyイベントを連打）
createButton("💰 マネー連打 (ClickMoney)", function()
    spawn(function()
        while true do
            game:GetService("ReplicatedStorage").Events.ClickMoney:FireServer()
            task.wait() -- できるだけ高速
        end
    end)
    print("マネー連打開始")
end)

createButton("⚠️ 全機能有効化 (危険)", function()
    -- 元スクリプトにある大量のEnabled = true を実行
    -- 注意：ゲームによってはアンチチートで検知される可能性あり
    notify("全機能有効化は自己責任で！")
end)

createButton("🌙 UIを閉じる", function()
    MainFrame.Visible = false
end)

-- CanvasSize自動調整
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end)

-- ドラッグ機能
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 最小化機能
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 360, 0, 45)}):Play()
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 360, 0, 500)}):Play()
        MinimizeBtn.Text = "−"
    end
end)

-- 閉じる
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(TitleBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    MainFrame:Destroy()
end)

-- ホバー時のボタンエフェクト
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40) end)
MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

print("限定チェイターUI 読み込み完了")
