-- LocalScript
-- Mobile PC Emulator: Syu_hub Cyber Deck Edition
-- Features: Fake ADB Logs, Smart Snapping, Heatmap Traces, Input Monitoring

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- PCデバッグ用 (Touchがない環境でも強制起動させるならコメントアウト解除)
-- if not UIS.TouchEnabled and not RunService:IsStudio() then return end

--------------------------------------------------------------------------------
-- [Config] デザイン & 設定
--------------------------------------------------------------------------------
local THEME = {
	Background = Color3.fromRGB(5, 5, 8),      -- Void Black
	CyberCyan  = Color3.fromRGB(0, 255, 200),  -- Main Accent
	NeonPurple = Color3.fromRGB(180, 0, 255),  -- Secondary
	AlertRed   = Color3.fromRGB(255, 50, 80),  -- Error/System
	Terminal   = Color3.fromRGB(0, 255, 100),  -- Matrix Green
	TextDim    = Color3.fromRGB(150, 150, 160),
}

local WASD_SCALE = 1.0
local SNAP_THRESHOLD = 25 -- スナップする距離(px)
local isWasdVisible = false
local currentInputMode = "TOUCH" -- TOUCH or USB

-- キー入力管理
local keysDown = {}

--------------------------------------------------------------------------------
-- [FX System] エフェクトエンジン
--------------------------------------------------------------------------------

-- 1. ネオン残光 (Heatmap)
local function spawnHeatmap(btn)
	local clone = btn:Clone()
	clone:ClearAllChildren() -- 子要素(Textなど)は消す
	clone.Name = "HeatmapFX"
	clone.BackgroundTransparency = 0.4
	clone.BackgroundColor3 = THEME.CyberCyan
	clone.BorderSizePixel = 0
	clone.ZIndex = btn.ZIndex - 1
	clone.Parent = btn.Parent -- 同じ親に置く
	
	-- 位置合わせ（AbsoluteではなくScaleコピー済み）
	-- 装飾追加
	local glow = Instance.new("UIStroke")
	glow.Color = THEME.CyberCyan
	glow.Thickness = 3
	glow.Transparency = 0.2
	glow.Parent = clone
	
	Instance.new("UICorner", clone).CornerRadius = btn:FindFirstChildOfClass("UICorner").CornerRadius
	
	-- アニメーション: 拡大しながらフェードアウト
	local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(clone, tInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 10, btn.Size.Y.Scale, btn.Size.Y.Offset + 10)
	}):Play()
	TweenService:Create(glow, tInfo, {Transparency = 1, Thickness = 0}):Play()
	
	task.delay(0.4, function() clone:Destroy() end)
end

-- 2. スナップ時のフラッシュ
local function playSnapFlash(frame)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1,0,1,0)
	flash.BackgroundColor3 = Color3.new(1,1,1)
	flash.BackgroundTransparency = 0.5
	flash.ZIndex = 100
	flash.Parent = frame
	Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 10)
	
	local t = TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1})
	t:Play()
	t.Completed:Connect(function() flash:Destroy() end)
end

-- 3. 回転グラデーション
local function applyCyberStroke(stroke, color1, color2)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(0.5, color2),
		ColorSequenceKeypoint.new(1, color1),
	})
	g.Parent = stroke
	
	RunService.Heartbeat:Connect(function(dt)
		if stroke.Parent and stroke.Parent.Visible then
			g.Rotation = (g.Rotation + dt * 100) % 360
		end
	end)
end

--------------------------------------------------------------------------------
-- [Core] 入力送信
--------------------------------------------------------------------------------
local function simulateKey(keyCodeName, down)
	if currentInputMode == "USB" then return end -- USB接続時はエミュレートしない

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
-- [UI] GUI構築
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyuHub_CyberDeck"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
mainFrame.BackgroundColor3 = THEME.Background
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
applyCyberStroke(mainStroke, THEME.CyberCyan, THEME.NeonPurple)

--------------------------------------------------------------------------------
-- [Feature: Fake ADB Terminal]
--------------------------------------------------------------------------------
local terminalFrame = Instance.new("Frame")
terminalFrame.Size = UDim2.new(1, -20, 0, 80)
terminalFrame.Position = UDim2.new(0, 10, 1, -90)
terminalFrame.BackgroundColor3 = Color3.fromRGB(0, 10, 5)
terminalFrame.BackgroundTransparency = 0.5
terminalFrame.ClipsDescendants = true
terminalFrame.Parent = mainFrame
Instance.new("UICorner", terminalFrame).CornerRadius = UDim.new(0, 6)

local logContainer = Instance.new("ScrollingFrame")
logContainer.Size = UDim2.new(1, -10, 1, -10)
logContainer.Position = UDim2.new(0, 5, 0, 5)
logContainer.BackgroundTransparency = 1
logContainer.ScrollBarThickness = 2
logContainer.Parent = terminalFrame
local listLayout = Instance.new("UIListLayout", logContainer)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local logCounter = 0
local function addLog(text, color)
	local label = Instance.new("TextLabel")
	label.Text = string.format("> %s", text)
	label.TextColor3 = color or THEME.Terminal
	label.Font = Enum.Font.Code
	label.TextSize = 12
	label.Size = UDim2.new(1, 0, 0, 14)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = logCounter
	label.Parent = logContainer
	
	logCounter += 1
	logContainer.CanvasPosition = Vector2.new(0, 9999) -- Auto scroll
	
	if logCounter > 20 then -- 古いログ消去
		logContainer:GetChildren()[1]:Destroy()
	end
end

-- ダミーログ生成ルーチン
task.spawn(function()
	local fakeLogs = {
		"[ADB] Bridge_v2.4 connected", "Mem_Alloc: 0x4F2A OK", "Syncing HID...",
		"Packet Loss: 0.0%", "Virtual_Input: READY", "Polling rate: 1000Hz",
		"KeepAlive sent...", "Bypass_Check: PASS", "Optimization: High"
	}
	while true do
		if mainFrame.Visible then
			if math.random() > 0.7 then
				addLog(fakeLogs[math.random(#fakeLogs)])
			end
		end
		task.wait(math.random(0.5, 3.0))
	end
end)

--------------------------------------------------------------------------------
-- [Feature: Input Mode Indicator]
--------------------------------------------------------------------------------
local indicatorBox = Instance.new("Frame")
indicatorBox.Size = UDim2.new(0, 120, 0, 24)
indicatorBox.Position = UDim2.new(1, -130, 0, 15)
indicatorBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
indicatorBox.Parent = mainFrame
Instance.new("UICorner", indicatorBox).CornerRadius = UDim.new(0, 4)
local indStroke = Instance.new("UIStroke", indicatorBox)
indStroke.Color = THEME.TextDim
indStroke.Thickness = 1

local indText = Instance.new("TextLabel")
indText.Size = UDim2.new(1,0,1,0)
indText.BackgroundTransparency = 1
indText.Font = Enum.Font.GothamBold
indText.TextSize = 11
indText.Text = "INPUT: TOUCH"
indText.TextColor3 = THEME.TextDim
indText.Parent = indicatorBox

local function updateInputMode(mode)
	if currentInputMode == mode then return end
	currentInputMode = mode
	
	if mode == "USB" then
		indText.Text = "INPUT: USB (HID)"
		indText.TextColor3 = THEME.CyberCyan
		indStroke.Color = THEME.CyberCyan
		addLog("[SYS] Keyboard Detected", THEME.CyberCyan)
		addLog("[SYS] Overlay Dimmed", THEME.CyberCyan)
	else
		indText.Text = "INPUT: TOUCH"
		indText.TextColor3 = THEME.TextDim
		indStroke.Color = THEME.TextDim
		addLog("[SYS] Touch Mode Active", THEME.NeonPurple)
	end
end

--------------------------------------------------------------------------------
-- [WASD & Expansion Keys]
--------------------------------------------------------------------------------
local controlsGroup = Instance.new("CanvasGroup") -- CanvasGroupで一括透明度管理
controlsGroup.Name = "ControlsOverlay"
controlsGroup.Size = UDim2.new(0, 250, 0, 150) -- 少し広げる
controlsGroup.Position = UDim2.new(0.1, 0, 0.6, 0)
controlsGroup.BackgroundTransparency = 1
controlsGroup.Visible = false
controlsGroup.Parent = screenGui

-- [Feature: Smart Snap]
local dragging, dragStart, startPos
controlsGroup.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = controlsGroup.Position
	end
end)

controlsGroup.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		local newX = startPos.X.Offset + delta.X
		local newY = startPos.Y.Offset + delta.Y
		
		-- スナップ計算 (絶対座標変換)
		local absPos = controlsGroup.AbsolutePosition
		local screenSize = screenGui.AbsoluteSize
		local mySize = controlsGroup.AbsoluteSize
		
		local didSnap = false
		
		-- 左端
		if math.abs(absPos.X) < SNAP_THRESHOLD then
			newX = 0 - (startPos.X.Scale * screenSize.X) -- Scale分を相殺して0に
			if not didSnap then playSnapFlash(controlsGroup) didSnap = true end
		end
		-- 下端
		if math.abs((absPos.Y + mySize.Y) - screenSize.Y) < SNAP_THRESHOLD then
			newY = screenSize.Y - mySize.Y - (startPos.Y.Scale * screenSize.Y)
			if not didSnap then playSnapFlash(controlsGroup) didSnap = true end
		end
		
		controlsGroup.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
	end
end)
controlsGroup.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)


local function createButtons()
	controlsGroup:ClearAllChildren()
	local base = 50 * WASD_SCALE
	local pad = 6 * WASD_SCALE
	
	-- WASD配置
	local function make(text, key, x, y, w, h)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, w or base, 0, h or base)
		btn.Position = UDim2.new(0, x, 0, y)
		btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
		btn.BackgroundTransparency = 0.3
		btn.Text = text
		btn.TextColor3 = THEME.CyberCyan
		btn.Font = Enum.Font.GothamBlack
		btn.TextSize = 20 * WASD_SCALE
		btn.Parent = controlsGroup
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		local s = Instance.new("UIStroke", btn)
		s.Color = THEME.CyberCyan
		s.Thickness = 2
		s.Transparency = 0.5
		
		-- イベント
		local function press()
			if currentInputMode == "USB" then return end
			simulateKey(key, true)
			spawnHeatmap(btn) -- Heatmap発動
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.CyberCyan, TextColor3 = Color3.new(0,0,0)}):Play()
		end
		local function release()
			simulateKey(key, false)
			TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.new(0,0,0), TextColor3 = THEME.CyberCyan}):Play()
		end
		
		btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then press() end end)
		btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then release() end end)
		btn.MouseLeave:Connect(release)
	end

	-- Layout: 
	--      [W]       [JUMP]
	-- [A]  [S]  [D]
	-- [SHIFT]
	
	local midX = base + pad
	
	make("W", "W", midX, 0)
	make("A", "A", 0, base + pad)
	make("S", "S", midX, base + pad)
	make("D", "D", (base + pad)*2, base + pad)
	
	-- Shift (Dash) - Aの下 or 横
	make("SHFT", "LeftShift", 0, (base + pad)*2, base*1.5, base*0.8)
	
	-- Jump (Space) - Dの右、少し離す
	make("JUMP", "Space", (base + pad)*3.5, base, base*1.5, base)
	
	controlsGroup.Size = UDim2.new(0, (base*5), 0, (base*3))
end
createButtons()

--------------------------------------------------------------------------------
-- [System] 入力監視 (Auto-Dim & Mode Switch)
--------------------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		updateInputMode("USB")
		if isWasdVisible then
			TweenService:Create(controlsGroup, TweenInfo.new(0.3), {GroupTransparency = 0.9}):Play()
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		updateInputMode("TOUCH")
		if isWasdVisible then
			TweenService:Create(controlsGroup, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
		end
	end
end)

--------------------------------------------------------------------------------
-- [Main UI] Controls (Toggle / Settings)
--------------------------------------------------------------------------------
local title = Instance.new("TextLabel")
title.Text = "SYU_HUB // DECK"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = THEME.CyberCyan
title.Size = UDim2.new(0, 200, 0, 40)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -40, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.Text = "ENABLE VIRTUAL KEYS"
toggleBtn.TextColor3 = THEME.TextDim
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
	isWasdVisible = not isWasdVisible
	controlsGroup.Visible = isWasdVisible
	
	if isWasdVisible then
		toggleBtn.Text = "VIRTUAL KEYS: ACTIVE"
		toggleBtn.TextColor3 = THEME.CyberCyan
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 40, 40)
		addLog("[UI] Overlay Enabled", THEME.CyberCyan)
		
		controlsGroup.GroupTransparency = (currentInputMode=="USB") and 0.9 or 0
	else
		toggleBtn.Text = "ENABLE VIRTUAL KEYS"
		toggleBtn.TextColor3 = THEME.TextDim
		toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		addLog("[UI] Overlay Disabled", THEME.AlertRed)
	end
end)

-- 最小化ボタン
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 50, 0, 50)
minBtn.Position = UDim2.new(0, 20, 0.5, -25)
minBtn.BackgroundColor3 = THEME.Background
minBtn.Text = "⚙"
minBtn.TextColor3 = THEME.CyberCyan
minBtn.TextSize = 24
minBtn.Visible = false
minBtn.Parent = screenGui
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", minBtn).Color = THEME.CyberCyan

minBtn.MouseButton1Click:Connect(function()
	if not mainFrame.Visible then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0,0,0,0)
		mainFrame.Position = minBtn.Position
		TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 360, 0, 260), Position = UDim2.new(0.5, -180, 0.5, -130)
		}):Play()
	else
		local t = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0,0,0,0), Position = minBtn.Position
		})
		t:Play()
		t.Completed:Connect(function() mainFrame.Visible = false end)
	end
end)

--------------------------------------------------------------------------------
-- [Boot Sequence]
--------------------------------------------------------------------------------
task.wait(1)
addLog("System Boot...", THEME.CyberCyan)
minBtn.Visible = true
mainFrame.Visible = true
