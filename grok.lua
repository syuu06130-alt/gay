-- LocalScript (PlayerGuiまたはStarterPlayerScriptsに置いてください)
-- Mobile専用: PC操作をモバイルからエミュレートする仮想コントロールGUI
-- WASD移動 + Spaceジャンプ + 視点ドラッグ
-- UI: 最初は開いた状態、タブ切り替え (Main / Setting)
-- 最小化: 左下の丸いボタンで開閉 (最小化時はボタンだけ固定表示)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Mobileのみ実行
if not UIS.TouchEnabled then
	return
end

-- VirtualInputManagerを使ってキー入力をシミュレート
local VirtualInputManager = game:GetService("VirtualInputManager")

-- キー状態管理
local keysDown = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
}

-- キー押下/離上シミュレート関数
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

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PCPlayingControls"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- メインFrame (背景)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- タイトル
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "PC Playing"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- タブボタン
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
mainTabBtn.Position = UDim2.new(0, 0, 0, 0)
mainTabBtn.Text = "Main"
mainTabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainTabBtn.TextColor3 = Color3.new(1,1,1)
mainTabBtn.TextScaled = true
mainTabBtn.Parent = tabFrame

local settingTabBtn = Instance.new("TextButton")
settingTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
settingTabBtn.Position = UDim2.new(0.5, 5, 0, 0)
settingTabBtn.Text = "Setting"
settingTabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
settingTabBtn.TextColor3 = Color3.new(1,1,1)
settingTabBtn.TextScaled = true
settingTabBtn.Parent = tabFrame

-- コンテンツFrame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Mainタブコンテンツ (WASD + Jump)
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1,0,1,0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- WASDボタン配置 (左下寄り)
local wasdFrame = Instance.new("Frame")
wasdFrame.Size = UDim2.new(0, 150, 0, 150)
wasdFrame.Position = UDim2.new(0, 20, 1, -170)
wasdFrame.BackgroundTransparency = 1
wasdFrame.Parent = mainContent

local buttonSize = UDim2.new(0, 50, 0, 50)

local wBtn = Instance.new("TextButton")
wBtn.Size = buttonSize
wBtn.Position = UDim2.new(0.5, -25, 0, 0)
wBtn.Text = "W"
wBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
wBtn.TextColor3 = Color3.new(1,1,1)
wBtn.TextScaled = true
Instance.new("UICorner", wBtn).CornerRadius = UDim.new(0,8)
wBtn.Parent = wasdFrame

local aBtn = Instance.new("TextButton")
aBtn.Size = buttonSize
aBtn.Position = UDim2.new(0, 0, 1, -50)
aBtn.Text = "A"
aBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
aBtn.TextColor3 = Color3.new(1,1,1)
aBtn.TextScaled = true
Instance.new("UICorner", aBtn).CornerRadius = UDim.new(0,8)
aBtn.Parent = wasdFrame

local sBtn = Instance.new("TextButton")
sBtn.Size = buttonSize
sBtn.Position = UDim2.new(0.5, -25, 1, -50)
sBtn.Text = "S"
sBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
sBtn.TextColor3 = Color3.new(1,1,1)
sBtn.TextScaled = true
Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0,8)
sBtn.Parent = wasdFrame

local dBtn = Instance.new("TextButton")
dBtn.Size = buttonSize
dBtn.Position = UDim2.new(1, -50, 1, -50)
dBtn.Text = "D"
dBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
dBtn.TextColor3 = Color3.new(1,1,1)
dBtn.TextScaled = true
Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0,8)
dBtn.Parent = wasdFrame

-- Jumpボタン (右下)
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, 80, 0, 80)
jumpBtn.Position = UDim2.new(1, -100, 1, -100)
jumpBtn.Text = "Jump\n(Space)"
jumpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
jumpBtn.TextColor3 = Color3.new(1,1,1)
jumpBtn.TextScaled = true
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(1, 0) -- 丸く
jumpBtn.Parent = mainContent

-- 視点ドラッグエリア (画面右半分を透明Frameで覆う)
local viewDragArea = Instance.new("Frame")
viewDragArea.Size = UDim2.new(0.5, 0, 1, 0)
viewDragArea.Position = UDim2.new(0.5, 0, 0, 0)
viewDragArea.BackgroundTransparency = 1
viewDragArea.Parent = mainContent

-- Settingタブコンテンツ (例: 透明度スライダーなど。今は仮のテキスト)
local settingContent = Instance.new("Frame")
settingContent.Size = UDim2.new(1,0,1,0)
settingContent.BackgroundTransparency = 1
settingContent.Visible = false
settingContent.Parent = contentFrame

local settingLabel = Instance.new("TextLabel")
settingLabel.Size = UDim2.new(1,0,1,0)
settingLabel.Text = "Settingタブ\n(ここに透明度や感度などの設定を追加できます)"
settingLabel.TextColor3 = Color3.new(1,1,1)
settingLabel.TextScaled = true
settingLabel.BackgroundTransparency = 1
settingLabel.Parent = settingContent

-- タブ切り替え
local function switchTab(toMain)
	mainContent.Visible = toMain
	settingContent.Visible = not toMain
	mainTabBtn.BackgroundColor3 = toMain and Color3.fromRGB(50,50,50) or Color3.fromRGB(40,40,40)
	settingTabBtn.BackgroundColor3 = toMain and Color3.fromRGB(40,40,40) or Color3.fromRGB(50,50,50)
end

mainTabBtn.MouseButton1Click:Connect(function() switchTab(true) end)
settingTabBtn.MouseButton1Click:Connect(function() switchTab(false) end)

-- ボタン入力処理
local function connectButton(btn, key)
	btn.MouseButton1Down:Connect(function() simulateKey(key, true) end)
	btn.MouseButton1Up:Connect(function() simulateKey(key, false) end)
	btn.MouseLeave:Connect(function() simulateKey(key, false) end) -- 指が離れた場合も対応
end

connectButton(wBtn, "W")
connectButton(aBtn, "A")
connectButton(sBtn, "S")
connectButton(dBtn, "D")
connectButton(jumpBtn, "Space")

-- 視点ドラッグ (右半分)
local dragging = false
local lastPos

viewDragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		lastPos = input.Position
	end
end)

viewDragArea.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - lastPos
		VirtualInputManager:SendMouseMoveEvent(delta.X, delta.Y, game)
		lastPos = input.Position
	end
end)

viewDragArea.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- 最小化ボタン (左下固定の丸いボタン)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 60, 0, 60)
minimizeBtn.Position = UDim2.new(0, 20, 1, -80)
minimizeBtn.Text = "▶"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
minimizeBtn.Parent = screenGui

local minimized = false

local function toggleMinimize()
	minimized = not minimized
	local goal = minimized and UDim2.new(-1, 0, 0.2, 0) or UDim2.new(0.1, 0, 0.2, 0)
	TweenService:Create(mainFrame, TweenInfo.new(0.3), {Position = goal}):Play()
	minimizeBtn.Text = minimized and "◀" or "▶"
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

-- 初期状態: 開いたまま
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)