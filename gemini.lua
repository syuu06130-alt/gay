-- LocalScript
-- Mobile PC Emulator: Syu_hub Edition
-- Features: Intro Animation, Draggable/Resizable WASD Overlay, Cool UI Animations

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- モバイル判定 (PCでのテスト用にコメントアウトして確認可能)
if not UIS.TouchEnabled then
	-- PCでもテストしたい場合はこの行を削除またはコメントアウトしてください
	-- return 
end

--------------------------------------------------------------------------------
-- 1. 設定 & 変数
--------------------------------------------------------------------------------
local WASD_SCALE = 1.0 -- 初期の大きさ倍率
local isWasdVisible = false

-- キー入力状態管理
local keysDown = { W = false, A = false, S = false, D = false, Space = false }

-- キー送信関数
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

-- GUI全体コンテナ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyuHubInterface"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 2. オープニングアニメーション (Syu_hub)
--------------------------------------------------------------------------------
local function playIntro(onComplete)
	local introFrame = Instance.new("Frame")
	introFrame.Size = UDim2.new(1, 0, 1, 0)
	introFrame.BackgroundColor3 = Color3.new(0,0,0)
	introFrame.ZIndex = 100
	introFrame.Parent = screenGui
	
	local introText = Instance.new("TextLabel")
	introText.Size = UDim2.new(1, 0, 0, 100)
	introText.Position = UDim2.new(0, 0, 0.45, 0)
	introText.BackgroundTransparency = 1
	introText.Text = "Syu_hub"
	introText.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
	introText.Font = Enum.Font.GothamBlack
	introText.TextSize = 50
	introText.TextTransparency = 1
	introText.Parent = introFrame
	
	-- アニメーション: テキストフェードイン -> 拡大 -> フェードアウト
	local tInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(introText, tInfo, {TextTransparency = 0, TextSize = 70}):Play()
	
	task.wait(2.0)
	
	local tInfoOut = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(introText, tInfoOut, {TextTransparency = 1, TextSize = 100}):Play()
	TweenService:Create(introFrame, tInfoOut, {BackgroundTransparency = 1}):Play()
	
	task.wait(1.0)
	introFrame:Destroy()
	
	if onComplete then onComplete() end
end

--------------------------------------------------------------------------------
-- 3. WASD オーバーレイ (独立・ドラッグ可能・リサイズ可能)
--------------------------------------------------------------------------------
local wasdContainer = Instance.new("Frame")
wasdContainer.Name = "WASD_Overlay"
wasdContainer.Size = UDim2.new(0, 150, 0, 150)
wasdContainer.Position = UDim2.new(0.1, 0, 0.6, 0) -- 初期位置
wasdContainer.BackgroundTransparency = 1
wasdContainer.Visible = false -- 最初は非表示
wasdContainer.Parent = screenGui

-- ドラッグ機能の実装
local dragging, dragInput, dragStart, startPos
local function makeDraggable(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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

-- WASDボタン生成ヘルパー
local function createWasdButtons()
	wasdContainer:ClearAllChildren()
	
	-- ベースサイズに対するスケール適用
	local baseSize = 50 * WASD_SCALE
	local padding = 5 * WASD_SCALE
	
	-- コンテナ自体のサイズも更新
	wasdContainer.Size = UDim2.new(0, (baseSize*3) + (padding*2), 0, (baseSize*2) + padding)

	local function makeBtn(text, key, xPos, yPos)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, baseSize, 0, baseSize)
		btn.Position = UDim2.new(0, xPos, 0, yPos)
		btn.Text = text
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = 0.5
		btn.TextColor3 = Color3.new(1,1,1)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn
		
		btn.MouseButton1Down:Connect(function() simulateKey(key, true) btn.BackgroundColor3 = Color3.fromRGB(0, 200, 255) end)
		btn.MouseButton1Up:Connect(function() simulateKey(key, false) btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) end)
		btn.MouseLeave:Connect(function() simulateKey(key, false) btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) end)
		
		btn.Parent = wasdContainer
	end

	-- 配置計算
	-- 	 [W]
	-- [A][S][D]
	local midX = baseSize + padding
	makeBtn("W", "W", midX, 0)
	makeBtn("A", "A", 0, baseSize + padding)
	makeBtn("S", "S", midX, baseSize + padding)
	makeBtn("D", "D", (baseSize + padding)*2, baseSize + padding)
	
	-- ドラッグ用ハンドル（見た目だけ）
	local dragHandle = Instance.new("Frame")
	dragHandle.Size = UDim2.new(1, 0, 1, 0)
	dragHandle.BackgroundTransparency = 1
	dragHandle.ZIndex = 0
	dragHandle.Parent = wasdContainer
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(0, 255, 255)
	stroke.Transparency = 0.8
	stroke.Parent = dragHandle
end

-- 初期生成
createWasdButtons()

--------------------------------------------------------------------------------
-- 4. メインメニュー UI構築
--------------------------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110) -- 画面中央
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false -- Intro後に表示
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- UIStroke (ネオン風枠線)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 170, 255)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- ヘッダー
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Syu_hub Control"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- タブコンテナ
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTabBtn(text, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, 0, 1, 0)
	btn.Position = UDim2.new((order-1)*0.5, 0, 0, 0)
	btn.Text = text
	btn.BackgroundColor3 = order == 1 and Color3.fromRGB(50,50,50) or Color3.fromRGB(30,30,30)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.Parent = tabContainer
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local btnMain = createTabBtn("Main", 1)
local btnSetting = createTabBtn("Setting", 2)

-- コンテンツエリア
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -80)
contentArea.Position = UDim2.new(0, 10, 0, 80)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- [Main Page]
local pageMain = Instance.new("Frame")
pageMain.Size = UDim2.new(1, 0, 1, 0)
pageMain.BackgroundTransparency = 1
pageMain.Visible = true
pageMain.Parent = contentArea

-- WASD Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 50)
toggleBtn.Position = UDim2.new(0, 0, 0.2, 0)
toggleBtn.Text = "Enable WASD Overlay: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
toggleBtn.Parent = pageMain

toggleBtn.MouseButton1Click:Connect(function()
	isWasdVisible = not isWasdVisible
	wasdContainer.Visible = isWasdVisible
	if isWasdVisible then
		toggleBtn.Text = "Enable WASD Overlay: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
	else
		toggleBtn.Text = "Enable WASD Overlay: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
	end
end)

-- [Setting Page]
local pageSetting = Instance.new("Frame")
pageSetting.Size = UDim2.new(1, 0, 1, 0)
pageSetting.BackgroundTransparency = 1
pageSetting.Visible = false
pageSetting.Parent = contentArea

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, 0, 0, 30)
sizeLabel.Text = "WASD Size Adjustment"
sizeLabel.TextColor3 = Color3.new(1,1,1)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Parent = pageSetting

-- Size Buttons (- / +)
local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Size = UDim2.new(0.4, 0, 0, 40)
decreaseBtn.Position = UDim2.new(0, 0, 0, 35)
decreaseBtn.Text = "-"
decreaseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
decreaseBtn.TextColor3 = Color3.new(1,1,1)
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.TextSize = 24
Instance.new("UICorner", decreaseBtn).Parent = decreaseBtn
decreaseBtn.Parent = pageSetting

local increaseBtn = Instance.new("TextButton")
increaseBtn.Size = UDim2.new(0.4, 0, 0, 40)
increaseBtn.Position = UDim2.new(0.6, 0, 0, 35)
increaseBtn.Text = "+"
increaseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
increaseBtn.TextColor3 = Color3.new(1,1,1)
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.TextSize = 24
Instance.new("UICorner", increaseBtn).Parent = increaseBtn
increaseBtn.Parent = pageSetting

local currentSizeDisplay = Instance.new("TextLabel")
currentSizeDisplay.Size = UDim2.new(0.2, 0, 0, 40)
currentSizeDisplay.Position = UDim2.new(0.4, 0, 0, 35)
currentSizeDisplay.Text = "1.0x"
currentSizeDisplay.TextColor3 = Color3.new(0.8,0.8,0.8)
currentSizeDisplay.BackgroundTransparency = 1
currentSizeDisplay.Parent = pageSetting

-- サイズ変更処理
local function updateSize(delta)
	WASD_SCALE = math.clamp(WASD_SCALE + delta, 0.5, 3.0)
	currentSizeDisplay.Text = string.format("%.1fx", WASD_SCALE)
	createWasdButtons() -- ボタン再生成
end

decreaseBtn.MouseButton1Click:Connect(function() updateSize(-0.1) end)
increaseBtn.MouseButton1Click:Connect(function() updateSize(0.1) end)

-- タブ切り替え処理
local function switchTab(toMain)
	pageMain.Visible = toMain
	pageSetting.Visible = not toMain
	btnMain.BackgroundColor3 = toMain and Color3.fromRGB(50,50,50) or Color3.fromRGB(30,30,30)
	btnSetting.BackgroundColor3 = toMain and Color3.fromRGB(30,30,30) or Color3.fromRGB(50,50,50)
end

btnMain.MouseButton1Click:Connect(function() switchTab(true) end)
btnSetting.MouseButton1Click:Connect(function() switchTab(false) end)


--------------------------------------------------------------------------------
-- 5. 最小化ボタン & かっこいいアニメーション
--------------------------------------------------------------------------------
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "ToggleUI"
minimizeBtn.Size = UDim2.new(0, 50, 0, 50)
minimizeBtn.Position = UDim2.new(0, 20, 0.5, -25) -- 左端中央
minimizeBtn.Text = "≡"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 24
minimizeBtn.Visible = false -- Intro後に表示
minimizeBtn.Parent = screenGui

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0) -- 丸
minCorner.Parent = minimizeBtn

local isMinimized = false

local function toggleMenu()
	if isMinimized then
		-- OPEN (カッコよく登場)
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0) -- 小さい状態から
		mainFrame.Position = minimizeBtn.Position -- ボタンの位置から
		mainFrame.Rotation = -45
		
		-- 目標: 中央へ
		local goal = {
			Size = UDim2.new(0, 300, 0, 220),
			Position = UDim2.new(0.5, -150, 0.5, -110),
			Rotation = 0
		}
		-- ElasticやBackを使って弾むような動き
		local tInfo = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		TweenService:Create(mainFrame, tInfo, goal):Play()
		
		isMinimized = false
	else
		-- CLOSE (ボタンに吸い込まれるように)
		local goal = {
			Size = UDim2.new(0, 0, 0, 0),
			Position = minimizeBtn.Position,
			Rotation = 45
		}
		local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local tween = TweenService:Create(mainFrame, tInfo, goal)
		tween:Play()
		tween.Completed:Connect(function()
			mainFrame.Visible = false
		end)
		
		isMinimized = true
	end
end

minimizeBtn.MouseButton1Click:Connect(toggleMenu)

--------------------------------------------------------------------------------
-- 6. 実行開始
--------------------------------------------------------------------------------
-- イントロ再生 -> UI表示
playIntro(function()
	mainFrame.Visible = true
	minimizeBtn.Visible = true
	
	-- 初期登場アニメーション
	mainFrame.Size = UDim2.new(0,0,0,0)
	mainFrame.Rotation = 180
	local tInfo = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	TweenService:Create(mainFrame, tInfo, {
		Size = UDim2.new(0, 300, 0, 220),
		Rotation = 0
	}):Play()
end)

-- 補足: ジャンプボタンや視点移動は前のコード同様に追加可能ですが、
-- 今回は「WASD UIの改善」にフォーカスしています。
-- 必要なら別途追加してください。
