-- LocalScript
-- 設置場所: StarterGui または StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ---------------------------------------------------------
-- UI 生成 (GUI Creation)
-- ---------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PC_Control_GUI"
screenGui.ResetOnSpawn = false -- リスポーンしてもUIを消さない
screenGui.Parent = player:WaitForChild("PlayerGui")

-- === 最小化/展開ボタン (左下固定) ===
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 1, -70) -- 左下
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0) -- 完全な円
toggleCorner.Parent = toggleBtn

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.new(1,0,1,0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "≡" -- ハンバーガーメニューアイコン的表現
toggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleIcon.TextSize = 30
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleBtn

-- === メインパネル (ドラッグ可能) ===
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125) -- 画面中央
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- タイトルバー (ドラッグ用ハンドル)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- タイトルバーの下部を四角くしてフレームと馴染ませる
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Text = "PC Playing"
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

-- === タブボタンエリア ===
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTabBtn(text, positionX)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -10, 1, 0)
	btn.Position = UDim2.new(positionX, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.AutoButtonColor = true
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
	btn.Parent = tabContainer
	return btn
end

local mainTabBtn = createTabBtn("main", 0)
local settingTabBtn = createTabBtn("setting", 0.5)

-- === コンテンツエリア ===
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -80)
contentFrame.Position = UDim2.new(0, 10, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- PAGE 1: MAIN (Controls)
local pageMain = Instance.new("Frame")
pageMain.Size = UDim2.new(1, 0, 1, 0)
pageMain.BackgroundTransparency = 1
pageMain.Visible = true
pageMain.Parent = contentFrame

-- WASD Buttons Layout
local function createKeyBtn(text, pos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.WHITE
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.Parent = pageMain
	
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
	return btn
end

-- 配置調整 (WASD)
local btnW = createKeyBtn("W", UDim2.new(0, 60, 0, 10))
local btnA = createKeyBtn("A", UDim2.new(0, 10, 0, 60))
local btnS = createKeyBtn("S", UDim2.new(0, 60, 0, 60))
local btnD = createKeyBtn("D", UDim2.new(0, 110, 0, 60))

-- Jump Button (Space)
local btnJump = createKeyBtn("Jump", UDim2.new(1, -80, 0, 40))
btnJump.Size = UDim2.new(0, 70, 0, 40) -- 横長にする

-- PAGE 2: SETTING
local pageSetting = Instance.new("Frame")
pageSetting.Size = UDim2.new(1, 0, 1, 0)
pageSetting.BackgroundTransparency = 1
pageSetting.Visible = false
pageSetting.Parent = contentFrame

-- WalkSpeed Slider Placeholder
local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "WalkSpeed (16)"
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 10)
speedLabel.TextColor3 = Color3.WHITE
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = pageSetting

local speedInput = Instance.new("TextBox")
speedInput.PlaceholderText = "Input Speed..."
speedInput.Text = ""
speedInput.Size = UDim2.new(0.8, 0, 0, 30)
speedInput.Position = UDim2.new(0.1, 0, 0, 35)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.WHITE
speedInput.Parent = pageSetting
local ic = Instance.new("UICorner"); ic.Parent = speedInput

-- ---------------------------------------------------------
-- ロジック (Logic)
-- ---------------------------------------------------------

-- 1. ドラッグ機能 (Dragging)
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- 2. 最小化機能 (Minimize Toggle)
local isOpen = true
toggleBtn.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	mainFrame.Visible = isOpen
	if isOpen then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- 閉じているときは少し明るく
	end
end)

-- 3. タブ切り替え (Tabs)
mainTabBtn.MouseButton1Click:Connect(function()
	pageMain.Visible = true
	pageSetting.Visible = false
	mainTabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Active
	settingTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

settingTabBtn.MouseButton1Click:Connect(function()
	pageMain.Visible = false
	pageSetting.Visible = true
	settingTabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Active
	mainTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- 初期タブ状態
mainTabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

-- 4. 設定ロジック (Settings)
speedInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(speedInput.Text)
		if num and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = num
			speedLabel.Text = "WalkSpeed ("..num..")"
		end
		speedInput.Text = ""
	end
end)

-- 5. 移動コントロールロジック (Movement Control)
-- モバイル画面からの入力でキャラクターを動かす
local moveVector = Vector3.new(0, 0, 0)
local keysPressed = {W=false, A=false, S=false, D=false}

local function updateMovement()
	local currentCamera = workspace.CurrentCamera
	if not player.Character then return end
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local lookVector = currentCamera.CFrame.LookVector
	local rightVector = currentCamera.CFrame.RightVector
	
	-- Y軸の影響を消して水平移動のみにする
	local forward = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
	local right = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
	
	local finalDir = Vector3.new(0,0,0)
	
	if keysPressed.W then finalDir = finalDir + forward end
	if keysPressed.S then finalDir = finalDir - forward end
	if keysPressed.D then finalDir = finalDir + right end
	if keysPressed.A then finalDir = finalDir - right end
	
	if finalDir.Magnitude > 0 then
		humanoid:Move(finalDir, true) -- trueはカメラ相対移動
	else
		humanoid:Move(Vector3.new(0,0,0), true)
	end
end

-- ボタンイベントの紐付け
local function bindButton(btn, key)
	btn.MouseButton1Down:Connect(function() keysPressed[key] = true end)
	btn.MouseButton1Up:Connect(function() keysPressed[key] = false end)
	btn.MouseLeave:Connect(function() keysPressed[key] = false end) -- 指が離れた時も停止
end

bindButton(btnW, "W")
bindButton(btnA, "A")
bindButton(btnS, "S")
bindButton(btnD, "D")

-- ジャンプ
btnJump.MouseButton1Down:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.Jump = true
	end
end)

-- ループで移動処理を継続実行
RunService.RenderStepped:Connect(function()
	updateMovement()
end)

print("PC Playing Script Loaded")
