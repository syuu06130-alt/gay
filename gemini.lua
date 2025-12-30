-- LocalScript
-- Mobile PC Emulator: Syu_hub WebADB Concept Edition
-- Features: Physical Keyboard Detection (USB/BT), Draggable WASD, Cyberpunk UI

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- モバイル判定 (PCデバッグ用コメントアウト)
-- if not UIS.TouchEnabled and not RunService:IsStudio() then return end

--------------------------------------------------------------------------------
-- [Setting] テーマ設定 (Cyberpunk Neon)
--------------------------------------------------------------------------------
local THEME = {
	MainColor = Color3.fromRGB(8, 8, 12),       -- Deep Void
	AccentColor = Color3.fromRGB(0, 255, 180),  -- Cyber Mint
	AccentColor2 = Color3.fromRGB(180, 0, 255), -- Neon Purple
	TextColor = Color3.fromRGB(240, 240, 255),
	RippleColor = Color3.fromRGB(255, 255, 255),
	HideTransparency = 0.9, -- 物理キー操作時の透明度
}

local WASD_SCALE = 1.0
local isWasdVisible = false
local usingPhysicalKeyboard = false -- 物理キーボード使用フラグ

-- 入力管理
local keysDown = { W = false, A = false, S = false, D = false }

--------------------------------------------------------------------------------
-- [Utility] アニメーションエンジン
--------------------------------------------------------------------------------

-- 1. リップルエフェクト (波紋)
local function spawnRipple(button, inputPosition)
	if not button:FindFirstChild("RippleContainer") then
		local c = Instance.new("Frame")
		c.Name = "RippleContainer"
		c.Size = UDim2.new(1,0,1,0)
		c.BackgroundTransparency = 1
		c.ClipsDescendants = true
		c.ZIndex = 10
		c.Parent = button
	end
	
	local ripple = Instance.new("Frame")
	ripple.BackgroundColor3 = THEME.RippleColor
	ripple.BackgroundTransparency = 0.7
	ripple.BorderSizePixel = 0
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	
	local x = inputPosition.X - button.AbsolutePosition.X
	local y = inputPosition.Y - button.AbsolutePosition.Y
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0,0,0,0)
	Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
	ripple.Parent = button.RippleContainer
	
	local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3
	local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	TweenService:Create(ripple, tInfo, {Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1}):Play()
	task.delay(0.5, function() ripple:Destroy() end)
end

-- 2. 生きたネオンボーダー (回転)
local function applyLivingNeon(stroke)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, THEME.AccentColor),
		ColorSequenceKeypoint.new(0.5, THEME.AccentColor2),
		ColorSequenceKeypoint.new(1, THEME.AccentColor),
	})
	gradient.Parent = stroke
	
	local rotation = 0
	RunService.Heartbeat:Connect(function(dt)
		if stroke.Parent and stroke.Parent.Visible then
			rotation = (rotation + (dt * 90)) % 360
			gradient.Rotation = rotation
		end
	end)
end

--------------------------------------------------------------------------------
-- [System] 入力シミュレーション & USBキーボード検知
--------------------------------------------------------------------------------
local function simulateKey(keyCodeName, down)
	-- 物理キーボードを使っている場合はシミュレートしない（競合回避）
	if usingPhysicalKeyboard then return end

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
-- [UI Construction] メイン構築
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyuHub_WebADB_Concept"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local wasdContainer = Instance.new("Frame") -- 先に宣言

--------------------------------------------------------------------------------
-- [System] Auto-Hide Logic (USB/Keyboard Detection)
--------------------------------------------------------------------------------
-- 物理キーボードの入力を検知してUIを薄くする
UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		usingPhysicalKeyboard = true
		-- キーボード操作中はWASD UIを邪魔にならないように薄くする
		if isWasdVisible and wasdContainer.Visible then
			TweenService:Create(wasdContainer, TweenInfo.new(0.3), {GroupTransparency = THEME.HideTransparency}):Play()
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		usingPhysicalKeyboard = false
		-- タッチ操作に戻ったら濃くする
		if isWasdVisible and wasdContainer.Visible then
			TweenService:Create(wasdContainer, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
		end
	end
end)

--------------------------------------------------------------------------------
-- [Intro] Glitch Boot Sequence
--------------------------------------------------------------------------------
local function playIntro(onComplete)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.new(0,0,0)
	frame.ZIndex = 100
	frame.Parent = screenGui
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,0,100)
	text.Position = UDim2.new(0,0,0.45,0)
	text.BackgroundTransparency = 1
	text.Text = "USB LINKING..." -- 演出用テキスト
	text.TextColor3 = THEME.AccentColor
	text.Font = Enum.Font.Code
	text.TextSize = 40
	text.Parent = frame
	
	-- 演出: テキスト変化
	task.wait(0.5)
	text.Text = "DEVICE_CONNECTED"
	text.TextColor3 = THEME.AccentColor2
	
	-- グリッチ演出
	for i = 1, 8 do
		text.Position = UDim2.new(0, math.random(-4,4), 0.45, math.random(-4,4))
		text.TextTransparency = math.random(0, 5)/10
		task.wait(0.05)
	end
	text.Position = UDim2.new(0,0,0.45,0)
	text.Text = "Syu_hub // ACTIVE"
	text.TextTransparency = 0
	text.TextColor3 = THEME.AccentColor
	
	-- スリットアニメーションで開く
	local top = Instance.new("Frame", frame)
	top.Size = UDim2.new(1,0,0.5,0)
	top.BackgroundColor3 = Color3.new(0,0,0)
	top.BorderSizePixel = 0
	
	local bottom = Instance.new("Frame", frame)
	bottom.Size = UDim2.new(1,0,0.5,0)
	bottom.Position = UDim2.new(0,0,0.5,0)
	bottom.BackgroundColor3 = Color3.new(0,0,0)
	bottom.BorderSizePixel = 0
	
	text:Destroy()
	
	local tInfo = TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(top, tInfo, {Position = UDim2.new(0,0,-0.5,0)}):Play()
	TweenService:Create(bottom, tInfo, {Position = UDim2.new(0,0,1,0)}):Play()
	
	task.wait(0.6)
	frame:Destroy()
	if onComplete then onComplete() end
end

--------------------------------------------------------------------------------
-- [WASD] ドラッグ & リサイズ & スマート表示
--------------------------------------------------------------------------------
wasdContainer.Name = "WASD_Overlay"
wasdContainer.Size = UDim2.new(0, 150, 0, 150)
wasdContainer.Position = UDim2.new(0.1, 0, 0.6, 0)
wasdContainer.BackgroundTransparency = 1
wasdContainer.Visible = false
wasdContainer.Parent = screenGui

-- 全体の透明度制御用（GroupTransparency用にはCanvasGroupが必要だが、軽量化のためFrameで代用し、子要素をループで制御する関数を作るか、単にCanvasGroupにする）
-- ここでは簡易的にCanvasGroupに変更して一括透明度操作を可能にする
local newContainer = Instance.new("CanvasGroup")
newContainer.Name = wasdContainer.Name
newContainer.Size = wasdContainer.Size
newContainer.Position = wasdContainer.Position
newContainer.BackgroundTransparency = 1
newContainer.Visible = false
newContainer.Parent = screenGui
wasdContainer:Destroy()
wasdContainer = newContainer

-- ドラッグ機能
local dragging, dragInput, dragStart, startPos
wasdContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = wasdContainer.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
wasdContainer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		wasdContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function createWasdButtons()
	wasdContainer:ClearAllChildren()
	local baseSize = 55 * WASD_SCALE
	local padding = 8 * WASD_SCALE
	wasdContainer.Size = UDim2.new(0, (baseSize*3) + (padding*2), 0, (baseSize*2) + padding)

	local function makeBtn(text, key, xPos, yPos)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, baseSize, 0, baseSize)
		btn.Position = UDim2.new(0, xPos, 0, yPos)
		btn.Text = text
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = 0.3
		btn.TextColor3 = THEME.AccentColor
		btn.TextSize = 24 * WASD_SCALE
		btn.Font = Enum.Font.GothamBlack
		btn.Parent = wasdContainer
		
		-- ネオン枠
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = THEME.AccentColor
		stroke.Transparency = 0.4
		stroke.Parent = btn
		
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
		
		-- タッチ処理
		local function press(input)
			if usingPhysicalKeyboard then return end -- 物理キー優先
			simulateKey(key, true)
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentColor, TextColor3 = Color3.new(0,0,0)}):Play()
			spawnRipple(btn, input.Position)
		end
		
		local function release()
			simulateKey(key, false)
			TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = THEME.AccentColor}):Play()
		end

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				press(input)
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				release()
			end
		end)
		btn.MouseLeave:Connect(release)
	end

	local midX = baseSize + padding
	makeBtn("W", "W", midX, 0)
	makeBtn("A", "A", 0, baseSize + padding)
	makeBtn("S", "S", midX, baseSize + padding)
	makeBtn("D", "D", (baseSize + padding)*2, baseSize + padding)
end
createWasdButtons()

--------------------------------------------------------------------------------
-- [Control Panel] メインUI
--------------------------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 250)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -125)
mainFrame.BackgroundColor3 = THEME.MainColor
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
applyLivingNeon(mainStroke)

-- タイトル
local title = Instance.new("TextLabel")
title.Text = "SYU_HUB // USB MODE"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = THEME.AccentColor
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- 設定UI: WASD トグル
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -40, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.Text = "WASD Overlay: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
toggleBtn.Parent = mainFrame

toggleBtn.MouseButton1Click:Connect(function()
	isWasdVisible = not isWasdVisible
	wasdContainer.Visible = isWasdVisible
	
	if isWasdVisible then
		toggleBtn.Text = "WASD Overlay: ON"
		toggleBtn.TextColor3 = THEME.AccentColor
		TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
		
		-- Pop animation
		wasdContainer.Size = UDim2.new(0,0,0,0)
		TweenService:Create(wasdContainer, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
			Size = UDim2.new(0, (55*WASD_SCALE*3)+(8*WASD_SCALE*2), 0, (55*WASD_SCALE*2)+(8*WASD_SCALE))
		}):Play()
	else
		toggleBtn.Text = "WASD Overlay: OFF"
		toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
	end
end)

-- 情報テキスト
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0, 120)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Connect USB Keyboard to Auto-Hide"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = mainFrame

-- 最小化ボタン
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 50, 0, 50)
minBtn.Position = UDim2.new(0, 20, 0.5, -25)
minBtn.BackgroundColor3 = THEME.MainColor
minBtn.Text = "≡"
minBtn.TextColor3 = THEME.AccentColor
minBtn.TextSize = 30
minBtn.Font = Enum.Font.GothamBold
minBtn.Visible = false
minBtn.Parent = screenGui
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
local minStroke = Instance.new("UIStroke", minBtn)
minStroke.Color = THEME.AccentColor
minStroke.Thickness = 2

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
	if not mainFrame.Visible then
		-- OPEN
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0,0,0,0)
		mainFrame.Position = minBtn.Position
		
		TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 340, 0, 250),
			Position = UDim2.new(0.5, -170, 0.5, -125)
		}):Play()
	else
		-- CLOSE
		local t = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0,0,0,0),
			Position = minBtn.Position
		})
		t:Play()
		t.Completed:Connect(function() mainFrame.Visible = false end)
	end
end)

--------------------------------------------------------------------------------
-- Start
--------------------------------------------------------------------------------
playIntro(function()
	minBtn.Visible = true
	mainFrame.Visible = true
	-- 初期オープンアニメーション
	mainFrame.Size = UDim2.new(0,0,0,0)
	TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(0, 340, 0, 250)
	}):Play()
end)
