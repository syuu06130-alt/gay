-- LocalScript
-- Mobile PC Emulator: Syu_hub Ultimate Edition
-- Aesthetics: Cyberpunk, Neon, Material Ripples, Elastic Motions

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- PCでのテスト用 (タッチがないデバイスでも動作させる場合はここを調整)
if not UIS.TouchEnabled and not RunService:IsStudio() then
	-- return -- 実機でPCを除外したい場合はコメントアウトを外す
end

--------------------------------------------------------------------------------
-- [Setting] デザイン・設定定数
--------------------------------------------------------------------------------
local THEME = {
	MainColor = Color3.fromRGB(10, 10, 15),       -- 深いダークブルー背景
	AccentColor = Color3.fromRGB(0, 255, 255),    -- シアン（ネオン）
	AccentColor2 = Color3.fromRGB(255, 0, 150),   -- マゼンタ（グラデーション用）
	TextColor = Color3.fromRGB(255, 255, 255),
	ButtonColor = Color3.fromRGB(30, 30, 40),
	RippleColor = Color3.fromRGB(255, 255, 255),
}

local WASD_SCALE = 1.0
local isWasdVisible = false

-- キー入力状態管理
local keysDown = { W = false, A = false, S = false, D = false, Space = false }

--------------------------------------------------------------------------------
-- [Utility] アニメーション関数群 (Core of Coolness)
--------------------------------------------------------------------------------

-- 1. リップルエフェクト (波紋)
local function spawnRipple(button, inputPosition)
	if not button:FindFirstChild("RippleContainer") then
		local c = Instance.new("Frame")
		c.Name = "RippleContainer"
		c.Size = UDim2.new(1,0,1,0)
		c.BackgroundTransparency = 1
		c.ClipsDescendants = true
		c.ZIndex = 10 -- 文字より下、背景より上
		c.Parent = button
	end
	
	local container = button.RippleContainer
	
	local ripple = Instance.new("Frame")
	ripple.BackgroundColor3 = THEME.RippleColor
	ripple.BackgroundTransparency = 0.6
	ripple.BorderSizePixel = 0
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	
	-- マウス位置の計算 (絶対座標 -> 相対座標)
	local x = inputPosition.X - button.AbsolutePosition.X
	local y = inputPosition.Y - button.AbsolutePosition.Y
	ripple.Position = UDim2.new(0, x, 0, y)
	ripple.Size = UDim2.new(0, 0, 0, 0)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple
	ripple.Parent = container
	
	-- 広がって消える
	local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
	
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(ripple, tweenInfo, {
		Size = UDim2.new(0, targetSize, 0, targetSize),
		BackgroundTransparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- 2. ボタンの押下アニメーション (スケール & 明度)
local function animateButtonPress(btn, isDown, inputObj)
	local scale = isDown and 0.92 or 1.0
	local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(btn, tInfo, {Size = btn:GetAttribute("OriginalSize") or btn.Size}):Play() -- 簡易実装のためscaleはUIScale推奨だが今回はシンプルに
	
	-- Scaleの代わりにUIScaleを使うとレイアウトが崩れにくい
	local uiScale = btn:FindFirstChild("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = btn
	end
	
	TweenService:Create(uiScale, tInfo, {Scale = scale}):Play()
	
	if isDown and inputObj then
		spawnRipple(btn, inputObj.Position)
	end
end

-- 3. グラデーション回転アニメーション (ネオン枠用)
local function applyRotatingRainbow(stroke)
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
			rotation = (rotation + (dt * 60)) % 360 -- 毎秒60度回転
			gradient.Rotation = rotation
		end
	end)
end

--------------------------------------------------------------------------------
-- [System] キー入力処理
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
-- [UI Construction] GUI全体
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyuHub_Ultimate"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- [Animation] Intro Sequence (Glitch & Typewriter)
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
	text.Text = ""
	text.TextColor3 = THEME.AccentColor
	text.Font = Enum.Font.FredokaOne -- 少しポップかつ太いフォント
	text.TextSize = 60
	text.Parent = frame
	
	-- 1. Typewriter Effect
	local content = "Syu_hub"
	for i = 1, #content do
		text.Text = string.sub(content, 1, i)
		-- タイピングごとのランダムピッチ音などを入れるとさらに良し
		task.wait(0.05)
	end
	
	-- 2. Glitch Shake
	local originalPos = text.Position
	for i = 1, 10 do
		local offsetX = math.random(-5, 5)
		local offsetY = math.random(-5, 5)
		text.Position = originalPos + UDim2.new(0, offsetX, 0, offsetY)
		text.TextColor3 = (i % 2 == 0) and THEME.AccentColor or THEME.AccentColor2
		task.wait(0.03)
	end
	text.Position = originalPos
	text.TextColor3 = THEME.AccentColor
	
	-- 3. Line Expand & Fade Out
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 0, 0, 4)
	line.Position = UDim2.new(0.5, 0, 0.5, 40)
	line.BackgroundColor3 = THEME.AccentColor2
	line.BorderSizePixel = 0
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Parent = frame
	
	TweenService:Create(line, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(0.8, 0, 0, 4)}):Play()
	task.wait(0.4)
	
	TweenService:Create(text, TweenInfo.new(0.5), {TextTransparency = 1, Position = originalPos - UDim2.new(0,0,0.1,0)}):Play()
	TweenService:Create(line, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,2), BackgroundTransparency = 1}):Play()
	TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	
	task.wait(0.5)
	frame:Destroy()
	if onComplete then onComplete() end
end

--------------------------------------------------------------------------------
-- [WASD Overlay] ドラッグ＆リサイズ＆ネオン
--------------------------------------------------------------------------------
local wasdContainer = Instance.new("Frame")
wasdContainer.Name = "WASD_Overlay"
wasdContainer.Size = UDim2.new(0, 150, 0, 150)
wasdContainer.Position = UDim2.new(0.1, 0, 0.6, 0)
wasdContainer.BackgroundTransparency = 1
wasdContainer.Visible = false
wasdContainer.Parent = screenGui

-- ドラッグロジック
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
	local padding = 8 * WASD_SCALE
	wasdContainer.Size = UDim2.new(0, (baseSize*3) + (padding*2), 0, (baseSize*2) + padding)

	local function makeBtn(text, key, xPos, yPos)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, baseSize, 0, baseSize)
		btn.Position = UDim2.new(0, xPos, 0, yPos)
		btn.Text = text
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = 0.4
		btn.TextColor3 = THEME.AccentColor
		btn.TextSize = 24 * WASD_SCALE
		btn.Font = Enum.Font.GothamBold
		btn.Parent = wasdContainer
		
		-- 装飾: ネオンストローク
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = THEME.AccentColor
		stroke.Transparency = 0.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = btn
		
		-- 入力イベント
		btn.MouseButton1Down:Connect(function(x, y) 
			simulateKey(key, true)
			animateButtonPress(btn, true) -- スケールダウン
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentColor, TextColor3 = Color3.new(0,0,0)}):Play()
		end)
		
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				simulateKey(key, true)
				animateButtonPress(btn, true, input)
				TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentColor, TextColor3 = Color3.new(0,0,0)}):Play()
			end
		end)

		local function release()
			simulateKey(key, false)
			animateButtonPress(btn, false) -- 元に戻る
			TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = THEME.AccentColor}):Play()
		end
		
		btn.MouseButton1Up:Connect(release)
		btn.MouseLeave:Connect(release)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then release() end
		end)
	end

	local midX = baseSize + padding
	makeBtn("W", "W", midX, 0)
	makeBtn("A", "A", 0, baseSize + padding)
	makeBtn("S", "S", midX, baseSize + padding)
	makeBtn("D", "D", (baseSize + padding)*2, baseSize + padding)
end
createWasdButtons()

--------------------------------------------------------------------------------
-- [Main UI] Hub Control Panel
--------------------------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainHub"
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = THEME.MainColor
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- 回転ネオンボーダー
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.Color = Color3.new(1,1,1) -- Gradientで上書きされる
mainStroke.Parent = mainFrame
applyRotatingRainbow(mainStroke)

-- タイトル
local title = Instance.new("TextLabel")
title.Text = "SYU_HUB // CONTROLS"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = THEME.AccentColor
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- スムーズトグルスイッチ作成関数
local function createToggle(text, parentFrame, position, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 50)
	container.Position = position
	container.BackgroundTransparency = 1
	container.Parent = parentFrame
	
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local switchBg = Instance.new("TextButton") -- クリック判定用
	switchBg.Text = ""
	switchBg.Size = UDim2.new(0, 60, 0, 30)
	switchBg.Position = UDim2.new(1, -60, 0.5, -15)
	switchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	switchBg.AutoButtonColor = false
	Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
	switchBg.Parent = container
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 24, 0, 24)
	knob.Position = UDim2.new(0, 3, 0.5, -12)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	knob.Parent = switchBg
	
	local isOn = false
	
	switchBg.MouseButton1Click:Connect(function()
		isOn = not isOn
		
		-- アニメーション
		local targetPos = isOn and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
		local targetColor = isOn and THEME.AccentColor or Color3.fromRGB(50, 50, 50)
		local knobColor = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
		
		TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos, BackgroundColor3 = knobColor}):Play()
		TweenService:Create(switchBg, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
		
		-- リップル
		spawnRipple(switchBg, switchBg.AbsolutePosition + Vector2.new(30, 15))
		
		callback(isOn)
	end)
end

-- トグル配置
createToggle("WASD Overlay", mainFrame, UDim2.new(0, 20, 0, 60), function(state)
	isWasdVisible = state
	wasdContainer.Visible = state
	
	if state then
		-- 出現アニメーション (ポップアップ)
		wasdContainer.Size = UDim2.new(0,0,0,0)
		TweenService:Create(wasdContainer, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
			Size = UDim2.new(0, (55*WASD_SCALE*3)+(8*WASD_SCALE*2), 0, (55*WASD_SCALE*2)+(8*WASD_SCALE))
		}):Play()
	end
end)

-- サイズ調整セクション
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Text = "Size Scale"
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.TextSize = 14
sizeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
sizeLabel.Size = UDim2.new(1, -40, 0, 20)
sizeLabel.Position = UDim2.new(0, 20, 0, 130)
sizeLabel.BackgroundTransparency = 1
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = mainFrame

local function createCircleBtn(text, pos, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.Position = pos
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 20
	btn.TextColor3 = THEME.TextColor
	btn.BackgroundColor3 = THEME.ButtonColor
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(60,60,60)
	btn.Parent = mainFrame
	
	btn.MouseButton1Down:Connect(function() animateButtonPress(btn, true) end)
	btn.MouseButton1Up:Connect(function() animateButtonPress(btn, false) callback() end)
	btn.MouseLeave:Connect(function() animateButtonPress(btn, false) end)
end

createCircleBtn("-", UDim2.new(0, 20, 0, 160), function()
	WASD_SCALE = math.clamp(WASD_SCALE - 0.1, 0.5, 2.0)
	createWasdButtons()
end)

createCircleBtn("+", UDim2.new(0, 70, 0, 160), function()
	WASD_SCALE = math.clamp(WASD_SCALE + 0.1, 0.5, 2.0)
	createWasdButtons()
end)

--------------------------------------------------------------------------------
-- [Minimize Button] かっこいい開閉
--------------------------------------------------------------------------------
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 50, 0, 50)
minimizeBtn.Position = UDim2.new(0, 20, 0.5, -25)
minimizeBtn.Text = ""
minimizeBtn.BackgroundColor3 = THEME.MainColor
minimizeBtn.Visible = false
minimizeBtn.Parent = screenGui

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0)
minCorner.Parent = minimizeBtn

local minStroke = Instance.new("UIStroke")
minStroke.Color = THEME.AccentColor
minStroke.Thickness = 2
minStroke.Parent = minimizeBtn

-- アイコン (ハンバーガーメニュー風)
local iconImg = Instance.new("ImageLabel")
iconImg.Size = UDim2.new(0.6, 0, 0.6, 0)
iconImg.Position = UDim2.new(0.2, 0, 0.2, 0)
iconImg.BackgroundTransparency = 1
iconImg.Image = "rbxassetid://6034818379" -- Menu icon
iconImg.ImageColor3 = THEME.AccentColor
iconImg.Parent = minimizeBtn

local isMinimized = false

local function toggleUI()
	isMinimized = not isMinimized
	
	if not isMinimized then
		-- OPEN: スピンしながら拡大して登場
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0,0,0,0)
		mainFrame.Position = minimizeBtn.Position
		mainFrame.Rotation = -90
		
		local tInfo = TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		TweenService:Create(mainFrame, tInfo, {
			Size = UDim2.new(0, 320, 0, 240),
			Position = UDim2.new(0.5, -160, 0.5, -120),
			Rotation = 0
		}):Play()
		
		-- ボタンは消すか目立たなくする
		TweenService:Create(minimizeBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
		TweenService:Create(minStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(iconImg, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
	else
		-- CLOSE: 閉じるボタンが押された時の挙動 (今回は外部ボタンがないので、メインフレーム外クリック等で実装も可だが、ここでは単純化のためトグルボタン自体を常に表示させておく設計に変更も可能。
		-- 今回は「最小化ボタン」をクリックして開閉するスタイルにするため、
		-- 開いたときも最小化ボタンは薄く残し、押せるようにします。
	end
end

-- ボタン状態のリセット用修正: 開いているときもボタンを押せるようにする
minimizeBtn.MouseButton1Click:Connect(function()
	if not mainFrame.Visible then
		-- OPEN
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0,0,0,0)
		mainFrame.Position = minimizeBtn.Position
		mainFrame.Rotation = -45
		
		-- Material Ripple
		spawnRipple(minimizeBtn, minimizeBtn.AbsolutePosition + Vector2.new(25,25))
		
		TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 320, 0, 240),
			Position = UDim2.new(0.5, -160, 0.5, -120),
			Rotation = 0
		}):Play()
		
		-- アイコンを×に変えるなど
		iconImg.Image = "rbxassetid://6031094678" -- X mark
	else
		-- CLOSE
		spawnRipple(minimizeBtn, minimizeBtn.AbsolutePosition + Vector2.new(25,25))
		
		local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0,0,0,0),
			Position = minimizeBtn.Position,
			Rotation = 45
		})
		tween:Play()
		tween.Completed:Connect(function()
			mainFrame.Visible = false
		end)
		
		iconImg.Image = "rbxassetid://6034818379" -- Menu icon
	end
end)

--------------------------------------------------------------------------------
-- Start Up
--------------------------------------------------------------------------------
playIntro(function()
	minimizeBtn.Visible = true
	-- 初期展開
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0,0,0,0)
	TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(0, 320, 0, 240)
	}):Play()
end)
