-- サービスとプレイヤーの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PCPlayingUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- メインコンテナ（開閉可能な部分）
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 300, 0, 350)
mainContainer.Position = UDim2.new(0, 20, 0.5, -175)
mainContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainContainer.BackgroundTransparency = 0.3
mainContainer.BorderSizePixel = 0
mainContainer.ClipsDescendants = true
mainContainer.Parent = screenGui

-- 丸角の追加
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainContainer

-- タブ選択用ボタン
local tabFrame = Instance.new("Frame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainContainer

local mainTabButton = Instance.new("TextButton")
mainTabButton.Name = "MainTab"
mainTabButton.Size = UDim2.new(0.5, 0, 1, 0)
mainTabButton.Position = UDim2.new(0, 0, 0, 0)
mainTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mainTabButton.Text = "MAIN"
mainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabButton.Font = Enum.Font.SourceSansBold
mainTabButton.Parent = tabFrame

local settingTabButton = Instance.new("TextButton")
settingTabButton.Name = "SettingTab"
settingTabButton.Size = UDim2.new(0.5, 0, 1, 0)
settingTabButton.Position = UDim2.new(0.5, 0, 0, 0)
settingTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingTabButton.Text = "SETTING"
settingTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
settingTabButton.Font = Enum.Font.SourceSansBold
settingTabButton.Parent = tabFrame

-- タブコンテンツ
local tabContent = Instance.new("Frame")
tabContent.Name = "TabContent"
tabContent.Size = UDim2.new(1, 0, 1, -40)
tabContent.Position = UDim2.new(0, 0, 0, 40)
tabContent.BackgroundTransparency = 1
tabContent.Parent = mainContainer

-- メインタブコンテンツ
local mainTab = Instance.new("ScrollingFrame")
mainTab.Name = "MainTab"
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.ScrollBarThickness = 4
mainTab.Visible = true
mainTab.Parent = tabContent

-- WASDコントロール用フレーム
local wasdFrame = Instance.new("Frame")
wasdFrame.Name = "WASDFrame"
wasdFrame.Size = UDim2.new(0, 180, 0, 180)
wasdFrame.Position = UDim2.new(0.5, -90, 0.1, 0)
wasdFrame.BackgroundTransparency = 1
wasdFrame.Parent = mainTab

-- Wキー（上）
local wButton = Instance.new("TextButton")
wButton.Name = "WButton"
wButton.Size = UDim2.new(0, 50, 0, 50)
wButton.Position = UDim2.new(0.5, -25, 0, 0)
wButton.Text = "W"
wButton.Font = Enum.Font.SourceSansBold
wButton.TextSize = 24
wButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
wButton.BackgroundTransparency = 0.5
wButton.Parent = wasdFrame

-- Aキー（左）
local aButton = Instance.new("TextButton")
aButton.Name = "AButton"
aButton.Size = UDim2.new(0, 50, 0, 50)
aButton.Position = UDim2.new(0, 0, 0.5, -25)
aButton.Text = "A"
aButton.Font = Enum.Font.SourceSansBold
aButton.TextSize = 24
aButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
aButton.BackgroundTransparency = 0.5
aButton.Parent = wasdFrame

-- Sキー（下）
local sButton = Instance.new("TextButton")
sButton.Name = "SButton"
sButton.Size = UDim2.new(0, 50, 0, 50)
sButton.Position = UDim2.new(0.5, -25, 0.5, -25)
sButton.Text = "S"
sButton.Font = Enum.Font.SourceSansBold
sButton.TextSize = 24
sButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sButton.BackgroundTransparency = 0.5
sButton.Parent = wasdFrame

-- Dキー（右）
local dButton = Instance.new("TextButton")
dButton.Name = "DButton"
dButton.Size = UDim2.new(0, 50, 0, 50)
dButton.Position = UDim2.new(1, -50, 0.5, -25)
dButton.Text = "D"
dButton.Font = Enum.Font.SourceSansBold
dButton.TextSize = 24
dButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
dButton.BackgroundTransparency = 0.5
dButton.Parent = wasdFrame

-- スペースキー（ジャンプ）
local spaceButton = Instance.new("TextButton")
spaceButton.Name = "SpaceButton"
spaceButton.Size = UDim2.new(0, 200, 0, 60)
spaceButton.Position = UDim2.new(0.5, -100, 0.8, 0)
spaceButton.Text = "SPACE (JUMP)"
spaceButton.Font = Enum.Font.SourceSansBold
spaceButton.TextSize = 20
spaceButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
spaceButton.BackgroundTransparency = 0.3
spaceButton.Parent = mainTab

-- ボタンに丸角を追加
for _, btn in ipairs({wButton, aButton, sButton, dButton, spaceButton}) do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
end

-- 設定タブコンテンツ
local settingTab = Instance.new("ScrollingFrame")
settingTab.Name = "SettingTab"
settingTab.Size = UDim2.new(1, 0, 1, 0)
settingTab.BackgroundTransparency = 1
settingTab.ScrollBarThickness = 4
settingTab.Visible = false
settingTab.Parent = tabContent

-- 設定項目の例
local transparencyLabel = Instance.new("TextLabel")
transparencyLabel.Name = "TransparencyLabel"
transparencyLabel.Size = UDim2.new(1, -20, 0, 30)
transparencyLabel.Position = UDim2.new(0, 10, 0, 10)
transparencyLabel.Text = "UI透明度"
transparencyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
transparencyLabel.BackgroundTransparency = 1
transparencyLabel.Font = Enum.Font.SourceSans
transparencyLabel.Parent = settingTab

local transparencySlider = Instance.new("Frame")
transparencySlider.Name = "TransparencySlider"
transparencySlider.Size = UDim2.new(1, -20, 0, 30)
transparencySlider.Position = UDim2.new(0, 10, 0, 50)
transparencySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
transparencySlider.Parent = settingTab

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
sliderFill.Parent = transparencySlider

local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 20, 1, 4)
sliderButton.Position = UDim2.new(0.5, -10, 0, -2)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = ""
sliderButton.Parent = transparencySlider

-- 最小化ボタン（左下固定）
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 60, 0, 60)
minimizeButton.Position = UDim2.new(0, 20, 1, -80)
minimizeButton.AnchorPoint = Vector2.new(0, 1)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
minimizeButton.Text = "◀"
minimizeButton.TextSize = 24
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Parent = screenGui

-- 最小化ボタンの丸角
local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeButton

-- 入力状態管理
local inputStates = {
	W = false,
	A = false,
	S = false,
	D = false
}

-- 移動方向計算
local function calculateMoveDirection()
	local direction = Vector3.new(0, 0, 0)
	
	if inputStates.W then
		direction = direction + Vector3.new(0, 0, -1)
	end
	if inputStates.A then
		direction = direction + Vector3.new(-1, 0, 0)
	end
	if inputStates.S then
		direction = direction + Vector3.new(0, 0, 1)
	end
	if inputStates.D then
		direction = direction + Vector3.new(1, 0, 0)
	end
	
	return direction.Unit
end

-- モバイル入力処理
local function setupMobileControls()
	-- Wボタン
	wButton.MouseButton1Down:Connect(function()
		inputStates.W = true
		wButton.BackgroundTransparency = 0.2
	end)
	
	wButton.MouseButton1Up:Connect(function()
		inputStates.W = false
		wButton.BackgroundTransparency = 0.5
	end)
	
	-- Aボタン
	aButton.MouseButton1Down:Connect(function()
		inputStates.A = true
		aButton.BackgroundTransparency = 0.2
	end)
	
	aButton.MouseButton1Up:Connect(function()
		inputStates.A = false
		aButton.BackgroundTransparency = 0.5
	end)
	
	-- Sボタン
	sButton.MouseButton1Down:Connect(function()
		inputStates.S = true
		sButton.BackgroundTransparency = 0.2
	end)
	
	sButton.MouseButton1Up:Connect(function()
		inputStates.S = false
		sButton.BackgroundTransparency = 0.5
	end)
	
	-- Dボタン
	dButton.MouseButton1Down:Connect(function()
		inputStates.D = true
		dButton.BackgroundTransparency = 0.2
	end)
	
	dButton.MouseButton1Up:Connect(function()
		inputStates.D = false
		dButton.BackgroundTransparency = 0.5
	end)
	
	-- スペースボタン（ジャンプ）
	spaceButton.MouseButton1Down:Connect(function()
		if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid.Jump = true
			spaceButton.BackgroundTransparency = 0.1
		end
	end)
	
	spaceButton.MouseButton1Up:Connect(function()
		spaceButton.BackgroundTransparency = 0.3
	end)
	
	-- タッチ対応
	local function handleTouch(button, key)
		button.TouchLongPress:Connect(function()
			inputStates[key] = true
			button.BackgroundTransparency = 0.2
		end)
		
		button.TouchEnded:Connect(function()
			inputStates[key] = false
			button.BackgroundTransparency = 0.5
		end)
	end
	
	handleTouch(wButton, "W")
	handleTouch(aButton, "A")
	handleTouch(sButton, "S")
	handleTouch(dButton, "D")
end

-- タブ切り替え
local function setupTabs()
	mainTabButton.MouseButton1Click:Connect(function()
		mainTab.Visible = true
		settingTab.Visible = false
		mainTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		settingTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)
	
	settingTabButton.MouseButton1Click:Connect(function()
		mainTab.Visible = false
		settingTab.Visible = true
		mainTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		settingTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
end

-- UI最小化/最大化
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	
	if isMinimized then
		-- 最小化
		mainContainer.Visible = false
		minimizeButton.Text = "▶"
		minimizeButton.Position = UDim2.new(0, 20, 1, -80)
	else
		-- 最大化
		mainContainer.Visible = true
		minimizeButton.Text = "◀"
		minimizeButton.Position = UDim2.new(0, 20, 1, -80)
	end
end)

-- スライダー設定
local function setupSlider()
	local sliding = false
	
	sliderButton.MouseButton1Down:Connect(function()
		sliding = true
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	
	sliderButton.MouseMoved:Connect(function()
		if sliding then
			local mousePos = UserInputService:GetMouseLocation()
			local sliderAbsolutePos = transparencySlider.AbsolutePosition
			local sliderSize = transparencySlider.AbsoluteSize
			
			local relativeX = math.clamp((mousePos.X - sliderAbsolutePos.X) / sliderSize.X, 0, 1)
			
			sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
			sliderButton.Position = UDim2.new(relativeX, -10, 0, -2)
			
			local transparency = 0.3 + (0.7 * (1 - relativeX))
			mainContainer.BackgroundTransparency = transparency
		end
	end)
end

-- 移動処理
local movementConnection
local function startMovement()
	if movementConnection then
		movementConnection:Disconnect()
	end
	
	movementConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not character or not humanoid then
			character = player.Character
			if character then
				humanoid = character:WaitForChild("Humanoid")
			end
			return
		end
		
		local direction = calculateMoveDirection()
		if direction.Magnitude > 0 then
			-- カメラの向きを考慮した移動
			local camera = workspace.CurrentCamera
			if camera then
				local cameraCFrame = camera.CFrame
				local moveVector = (cameraCFrame.LookVector * direction.Z) + (cameraCFrame.RightVector * direction.X)
				moveVector = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
				
				-- キャラクターを移動
				humanoid:Move(moveVector * humanoid.WalkSpeed)
			end
		end
	end)
end

-- 初期化
setupMobileControls()
setupTabs()
setupSlider()
startMovement()

-- キャラクター変更時の対応
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
end)

-- 画面サイズ変更時の対応
local function updateUIPosition()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	-- 必要に応じてUI位置を調整
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIPosition)
updateUIPosition()

print("PC Playing UI loaded successfully!")