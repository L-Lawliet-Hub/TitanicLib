-- TITANIC HUB Custom UI Library
-- Mobile + PC friendly, draggable, tabbed UI

local TitanicLib = {}
TitanicLib.__index = TitanicLib

-- ==================== COLORS ====================
local C = {
	BG       = Color3.fromRGB(15, 15, 20),
	Panel    = Color3.fromRGB(22, 22, 30),
	Group    = Color3.fromRGB(28, 28, 38),
	Accent   = Color3.fromRGB(88, 101, 242),   -- discord-like blue
	AccentHov= Color3.fromRGB(108, 121, 255),
	Toggle_On= Color3.fromRGB(88, 200, 120),
	Toggle_Of= Color3.fromRGB(60, 60, 75),
	Text     = Color3.fromRGB(225, 225, 235),
	TextDim  = Color3.fromRGB(140, 140, 160),
	Border   = Color3.fromRGB(50, 50, 70),
	SliderFG = Color3.fromRGB(88, 101, 242),
	SliderBG = Color3.fromRGB(40, 40, 55),
	Notif    = Color3.fromRGB(30, 30, 42),
	NotifBrd = Color3.fromRGB(88, 101, 242),
}

local FONT       = Enum.Font.GothamBold
local FONT_REG   = Enum.Font.Gotham
local CORNER_SM  = 6
local CORNER_MED = 10
local PAD        = 8

-- ==================== SERVICES ====================
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local lp            = Players.LocalPlayer
local gui           = lp:WaitForChild("PlayerGui")

-- ==================== HELPERS ====================
local function tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quad
	dir   = dir   or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(t or 0.15, style, dir), props):Play()
end

local function corner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or CORNER_SM); return c end
local function pad(x,y)  local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,x or PAD); p.PaddingRight = UDim.new(0,x or PAD); p.PaddingTop = UDim.new(0,y or PAD); p.PaddingBottom = UDim.new(0,y or PAD); return p end
local function stroke(c,t) local s = Instance.new("UIStroke"); s.Color = c or C.Border; s.Thickness = t or 1; return s end
local function listlayout(gap, dir, align)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, gap or 6)
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
	l.SortOrder = Enum.SortOrder.LayoutOrder
	return l
end

local function newLabel(text, size, color, font, parent)
	local l = Instance.new("TextLabel")
	l.Text = text
	l.TextSize = size or 14
	l.TextColor3 = color or C.Text
	l.Font = font or FONT_REG
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.Size = UDim2.new(1,0,0,0)
	if parent then l.Parent = parent end
	return l
end

local function newFrame(bg, size, pos, parent)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = bg or C.Panel
	f.Size = size or UDim2.new(1,0,0,30)
	f.Position = pos or UDim2.new(0,0,0,0)
	f.BorderSizePixel = 0
	if parent then f.Parent = parent end
	return f
end

-- Drag support (mobile + PC)
local function makeDraggable(handle, target)
	local dragging, start, startPos = false, nil, nil
	local function begin(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			start    = input.Position
			startPos = target.Position
		end
	end
	local function move(input)
		if not dragging then return end
		local delta = input.Position - start
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
	local function stop() dragging = false end
	handle.InputBegan:Connect(begin)
	handle.InputChanged:Connect(move)
	handle.InputEnded:Connect(stop)
	UserInput.InputChanged:Connect(function(i)
		if dragging then move(i) end
	end)
end

-- ==================== NOTIFICATION ====================
local notifHolder
local function ensureNotifHolder()
	if notifHolder and notifHolder.Parent then return end
	notifHolder = Instance.new("Frame")
	notifHolder.Name = "TH_Notifs"
	notifHolder.BackgroundTransparency = 1
	notifHolder.Size = UDim2.new(0, 280, 1, 0)
	notifHolder.Position = UDim2.new(1, -290, 0, 10)
	notifHolder.Parent = gui:FindFirstChild("TH_Screen") or gui
	local ll = listlayout(8)
	ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ll.FillDirection = Enum.FillDirection.Vertical
	ll.Parent = notifHolder
end

function TitanicLib:Notify(opts)
	ensureNotifHolder()
	local title = opts.Title or "TITANIC HUB"
	local desc  = opts.Description or ""
	local t     = opts.Time or 3

	local card = newFrame(C.Notif, UDim2.new(1,0,0,0), nil, notifHolder)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundTransparency = 0.1
	corner(CORNER_MED).Parent = card
	stroke(C.NotifBrd, 1.5).Parent = card
	pad(12, 10).Parent = card

	local layout = listlayout(4)
	layout.Parent = card

	local ttl = newLabel("🔔 " .. title, 14, C.Accent, FONT, card)
	local dsc = newLabel(desc, 13, C.TextDim, FONT_REG, card)
	dsc.TextWrapped = true

	-- progress bar
	local bar = newFrame(C.SliderBG, UDim2.new(1,0,0,3), nil, card)
	corner(2).Parent = bar
	local fill = newFrame(C.NotifBrd, UDim2.new(1,0,1,0), nil, bar)
	corner(2).Parent = fill

	card.Position = UDim2.new(1,10,0,0)
	tween(card, {Position = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back)
	tween(fill, {Size = UDim2.new(0,0,1,0)}, t, Enum.EasingStyle.Linear)

	task.delay(t, function()
		tween(card, {Position = UDim2.new(1,10,0,0), BackgroundTransparency = 1}, 0.25)
		task.wait(0.3)
		card:Destroy()
	end)
end

-- ==================== WINDOW ====================
local Lib = {}
Lib.Options  = {}
Lib.Toggles  = {}
Lib.Unloaded = false

function TitanicLib:CreateWindow(opts)
	local title  = opts.Title  or "TITANIC HUB"
	local footer = opts.Footer or "AOT:R"

	-- Screen
	local screen = Instance.new("ScreenGui")
	screen.Name = "TH_Screen"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = gui

	-- Main container
	local win = newFrame(C.BG, UDim2.new(0, 620, 0, 500))
	win.Position = UDim2.new(0.5, -310, 0.5, -250)
	win.AnchorPoint = Vector2.new(0, 0)
	win.Parent = screen
	corner(CORNER_MED + 2).Parent = win
	stroke(C.Border, 1.5).Parent = win

	-- Auto-size for mobile
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X < 500 then
		win.Size = UDim2.new(1, -16, 0, 480)
		win.Position = UDim2.new(0, 8, 0.5, -240)
	end

	-- Titlebar
	local titlebar = newFrame(C.Panel, UDim2.new(1,0,0,44), nil, win)
	titlebar.ZIndex = 5
	corner(CORNER_MED + 2).Parent = titlebar

	-- Fix bottom corners of titlebar
	local titleFix = newFrame(C.Panel, UDim2.new(1,0,0,12), UDim2.new(0,0,1,-12), titlebar)

	-- Icon + Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Text  = "⚡ " .. title
	titleLbl.Font  = FONT
	titleLbl.TextSize = 16
	titleLbl.TextColor3 = C.Text
	titleLbl.BackgroundTransparency = 1
	titleLbl.Size = UDim2.new(1,-80,1,0)
	titleLbl.Position = UDim2.new(0,14,0,0)
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = titlebar

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "✕"
	closeBtn.Font = FONT
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = C.TextDim
	closeBtn.BackgroundTransparency = 1
	closeBtn.Size = UDim2.new(0,36,1,0)
	closeBtn.Position = UDim2.new(1,-42,0,0)
	closeBtn.Parent = titlebar

	-- Minimize button
	local minBtn = Instance.new("TextButton")
	minBtn.Text = "–"
	minBtn.Font = FONT
	minBtn.TextSize = 18
	minBtn.TextColor3 = C.TextDim
	minBtn.BackgroundTransparency = 1
	minBtn.Size = UDim2.new(0,32,1,0)
	minBtn.Position = UDim2.new(1,-78,0,0)
	minBtn.Parent = titlebar

	makeDraggable(titlebar, win)

	local minimized = false
	local contentH  = win.Size.Y.Offset - 44

	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tween(win, {Size = minimized and UDim2.new(win.Size.X.Scale, win.Size.X.Offset, 0, 44) or UDim2.new(win.Size.X.Scale, win.Size.X.Offset, 0, contentH + 44)}, 0.2)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		tween(win, {BackgroundTransparency=1}, 0.2)
		task.wait(0.2)
		screen:Destroy()
		Lib.Unloaded = true
	end)

	-- Keybind toggle (RightControl)
	UserInput.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.RightControl then
			win.Visible = not win.Visible
		end
	end)

	-- Footer
	local foot = Instance.new("TextLabel")
	foot.Text = footer
	foot.Font = FONT_REG
	foot.TextSize = 11
	foot.TextColor3 = C.TextDim
	foot.BackgroundTransparency = 1
	foot.Size = UDim2.new(1,0,0,20)
	foot.Position = UDim2.new(0,0,1,-20)
	foot.TextXAlignment = Enum.TextXAlignment.Center
	foot.Parent = win

	-- Tab bar
	local tabBar = newFrame(C.Panel, UDim2.new(1,0,0,38), UDim2.new(0,0,0,44), win)
	tabBar.ZIndex = 4
	local tabLayout = listlayout(4, Enum.FillDirection.Horizontal, nil)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
	tabLayout.Parent = tabBar
	pad(8, 4).Parent = tabBar

	-- Content area
	local content = newFrame(C.BG, UDim2.new(1,0,1,-106), UDim2.new(0,0,0,82), win)
	content.ClipsDescendants = true
	content.Parent = win

	-- Tab system
	local tabs        = {}
	local activeTab   = nil
	local tabBtns     = {}

	local windowObj = {}
	windowObj._screen = screen
	windowObj._lib    = Lib

	function windowObj:AddTab(name)
		local btn = Instance.new("TextButton")
		btn.Text = name
		btn.Font = FONT_REG
		btn.TextSize = 13
		btn.TextColor3 = C.TextDim
		btn.BackgroundColor3 = C.Group
		btn.AutomaticSize = Enum.AutomaticSize.X
		btn.Size = UDim2.new(0,0,0,28)
		btn.BackgroundTransparency = 1
		btn.Parent = tabBar
		corner(6).Parent = btn
		local btnPad = Instance.new("UIPadding")
		btnPad.PaddingLeft = UDim.new(0,12)
		btnPad.PaddingRight = UDim.new(0,12)
		btnPad.Parent = btn

		-- Tab content frame
		local page = newFrame(C.BG, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), content)
		page.Visible = false
		page.ClipsDescendants = true

		-- Two-column scroll layout
		local leftScroll = Instance.new("ScrollingFrame")
		leftScroll.Size = UDim2.new(0.5,-4,1,0)
		leftScroll.Position = UDim2.new(0,4,0,4)
		leftScroll.BackgroundTransparency = 1
		leftScroll.ScrollBarThickness = 3
		leftScroll.ScrollBarImageColor3 = C.Accent
		leftScroll.CanvasSize = UDim2.new(0,0,0,0)
		leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		leftScroll.BorderSizePixel = 0
		leftScroll.Parent = page
		local ll = listlayout(6)
		ll.Parent = leftScroll

		local rightScroll = Instance.new("ScrollingFrame")
		rightScroll.Size = UDim2.new(0.5,-4,1,0)
		rightScroll.Position = UDim2.new(0.5,0,0,4)
		rightScroll.BackgroundTransparency = 1
		rightScroll.ScrollBarThickness = 3
		rightScroll.ScrollBarImageColor3 = C.Accent
		rightScroll.CanvasSize = UDim2.new(0,0,0,0)
		rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		rightScroll.BorderSizePixel = 0
		rightScroll.Parent = page
		local rl = listlayout(6)
		rl.Parent = rightScroll

		local tabObj = {}
		tabObj._page  = page
		tabObj._btn   = btn
		tabObj._left  = leftScroll
		tabObj._right = rightScroll

		function tabObj:AddLeftGroupbox(name)
			return windowObj:_makeGroup(name, leftScroll)
		end
		function tabObj:AddRightGroupbox(name)
			return windowObj:_makeGroup(name, rightScroll)
		end

		btn.MouseButton1Click:Connect(function()
			if activeTab == tabObj then return end
			-- deactivate old
			if activeTab then
				activeTab._page.Visible = false
				tween(activeTab._btn, {TextColor3 = C.TextDim}, 0.1)
				activeTab._btn.BackgroundTransparency = 1
			end
			activeTab = tabObj
			page.Visible = true
			tween(btn, {TextColor3 = C.Text}, 0.1)
			btn.BackgroundTransparency = 0
			btn.BackgroundColor3 = C.Accent
		end)

		table.insert(tabs, tabObj)
		if #tabs == 1 then
			-- auto-select first
			activeTab = tabObj
			page.Visible = true
			btn.TextColor3 = C.Text
			btn.BackgroundTransparency = 0
			btn.BackgroundColor3 = C.Accent
		end

		return tabObj
	end

	-- Group builder
	function windowObj:_makeGroup(name, parent)
		local grpFrame = newFrame(C.Group, UDim2.new(1,-8,0,0), nil, parent)
		grpFrame.AutomaticSize = Enum.AutomaticSize.Y
		corner(CORNER_SM).Parent = grpFrame
		stroke(C.Border).Parent = grpFrame

		-- Header
		local header = newFrame(C.Panel, UDim2.new(1,0,0,28), nil, grpFrame)
		corner(CORNER_SM).Parent = header
		local headerFix = newFrame(C.Panel, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-10), header)
		local hLbl = newLabel("  " .. name, 13, C.Accent, FONT, header)
		hLbl.Size = UDim2.new(1,0,1,0)
		hLbl.TextYAlignment = Enum.TextYAlignment.Center

		-- Items container
		local itemsFrame = newFrame(C.Group, UDim2.new(1,0,0,0), UDim2.new(0,0,0,28), grpFrame)
		itemsFrame.AutomaticSize = Enum.AutomaticSize.Y
		itemsFrame.BackgroundTransparency = 1
		local layout = listlayout(4)
		layout.Parent = itemsFrame
		pad(8, 6).Parent = itemsFrame

		local grp = {}

		-- ===== TOGGLE =====
		function grp:AddToggle(key, opts)
			local text    = opts.Text    or key
			local default = opts.Default or false

			local row = newFrame(C.Panel, UDim2.new(1,0,0,36), nil, itemsFrame)
			corner(CORNER_SM).Parent = row

			local lbl = newLabel(text, 13, C.Text, FONT_REG, row)
			lbl.Position = UDim2.new(0,10,0,0)
			lbl.Size = UDim2.new(1,-60,1,0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center

			local track = newFrame(C.Toggle_Of, UDim2.new(0,40,0,22), UDim2.new(1,-50,0.5,-11), row)
			corner(11).Parent = track
			local knob = newFrame(Color3.new(1,1,1), UDim2.new(0,18,0,18), UDim2.new(0,2,0.5,-9), track)
			corner(9).Parent = knob

			local val = default
			local togObj = {Value = val}
			Lib.Toggles[key] = togObj
			local _changed = nil

			local function setVal(v, silent)
				val = v
				togObj.Value = v
				tween(track, {BackgroundColor3 = v and C.Toggle_On or C.Toggle_Of}, 0.15)
				tween(knob, {Position = v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.15)
				if not silent and _changed then pcall(_changed) end
			end

			setVal(val, true)

			local btn = Instance.new("TextButton")
			btn.Text = ""
			btn.BackgroundTransparency = 1
			btn.Size = UDim2.new(1,0,1,0)
			btn.Parent = row
			btn.MouseButton1Click:Connect(function() setVal(not val) end)

			function togObj:SetValue(v) setVal(v) end
			function togObj:OnChanged(fn) _changed = fn end

			return togObj
		end

		-- ===== SLIDER =====
		function grp:AddSlider(key, opts)
			local text    = opts.Text     or key
			local min     = opts.Min      or 0
			local max     = opts.Max      or 100
			local default = opts.Default  or min
			local round   = opts.Rounding or 0

			local row = newFrame(C.Panel, UDim2.new(1,0,0,50), nil, itemsFrame)
			corner(CORNER_SM).Parent = row

			local topRow = newFrame(C.Panel, UDim2.new(1,0,0,22), nil, row)
			topRow.BackgroundTransparency = 1
			local lbl = newLabel(text, 13, C.Text, FONT_REG, topRow)
			lbl.Position = UDim2.new(0,10,0,0)
			lbl.Size = UDim2.new(0.7,0,1,0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center

			local valLbl = newLabel(tostring(default), 13, C.Accent, FONT, topRow)
			valLbl.Position = UDim2.new(0.7,0,0,0)
			valLbl.Size = UDim2.new(0.3,-10,1,0)
			valLbl.TextXAlignment = Enum.TextXAlignment.Right
			valLbl.TextYAlignment = Enum.TextYAlignment.Center

			-- Slider bar
			local bar = newFrame(C.SliderBG, UDim2.new(1,-20,0,8), UDim2.new(0,10,0,34), row)
			corner(4).Parent = bar
			local fill = newFrame(C.SliderFG, UDim2.new(0,0,1,0), nil, bar)
			corner(4).Parent = fill

			local val = default
			local slObj = {Value = val}
			Lib.Options[key] = slObj
			local _changed = nil

			local function setVal(v, silent)
				v = math.clamp(v, min, max)
				if round > 0 then
					v = math.round(v / round) * round
				else
					v = math.floor(v + 0.5)
				end
				val = v
				slObj.Value = v
				local pct = (v - min) / (max - min)
				tween(fill, {Size = UDim2.new(pct,0,1,0)}, 0.05)
				valLbl.Text = tostring(v)
				if not silent and _changed then pcall(_changed) end
			end

			setVal(val, true)

			local dragging = false
			local function updateFromInput(input)
				local relX = input.Position.X - bar.AbsolutePosition.X
				local pct  = math.clamp(relX / bar.AbsoluteSize.X, 0, 1)
				setVal(min + (max - min) * pct)
			end

			bar.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateFromInput(inp)
				end
			end)
			UserInput.InputChanged:Connect(function(inp)
				if dragging then updateFromInput(inp) end
			end)
			UserInput.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			function slObj:SetValue(v) setVal(v) end
			function slObj:OnChanged(fn) _changed = fn end

			return slObj
		end

		-- ===== DROPDOWN =====
		function grp:AddDropdown(key, opts)
			local text    = opts.Text    or key
			local values  = opts.Values  or {}
			local multi   = opts.Multi   or false
			local default = opts.Default

			local row = newFrame(C.Panel, UDim2.new(1,0,0,62), nil, itemsFrame)
			corner(CORNER_SM).Parent = row

			local lbl = newLabel(text, 13, C.Text, FONT_REG, row)
			lbl.Position = UDim2.new(0,10,0,4)
			lbl.Size = UDim2.new(1,-20,0,18)

			local selBtn = newFrame(C.SliderBG, UDim2.new(1,-20,0,30), UDim2.new(0,10,0,26), row)
			corner(CORNER_SM).Parent = selBtn
			stroke(C.Border).Parent = selBtn

			local selLbl = newLabel("", 13, C.TextDim, FONT_REG, selBtn)
			selLbl.Position = UDim2.new(0,8,0,0)
			selLbl.Size = UDim2.new(1,-30,1,0)
			selLbl.TextYAlignment = Enum.TextYAlignment.Center

			local arrow = newLabel("▾", 14, C.Accent, FONT, selBtn)
			arrow.Position = UDim2.new(1,-22,0,0)
			arrow.Size = UDim2.new(0,18,1,0)
			arrow.TextXAlignment = Enum.TextXAlignment.Center
			arrow.TextYAlignment = Enum.TextYAlignment.Center

			-- Dropdown values
			local val    = multi and {} or nil
			local ddObj  = {Value = val}
			Lib.Options[key] = ddObj
			local _changed = nil
			local _visible = true

			local function updateLabel()
				if multi then
					local parts = {}
					for k,v in pairs(val) do if v then table.insert(parts, k) end end
					selLbl.Text = #parts == 0 and "Select..." or table.concat(parts, ", ")
					selLbl.TextColor3 = #parts == 0 and C.TextDim or C.Text
				else
					selLbl.Text = val or "Select..."
					selLbl.TextColor3 = val and C.Text or C.TextDim
				end
			end

			local function setVal(v, silent)
				if multi then
					if type(v) == "table" then val = v else
						val[v] = not val[v]
					end
				else
					val = v
				end
				ddObj.Value = val
				updateLabel()
				if not silent and _changed then pcall(_changed) end
			end

			-- init default
			if multi then
				val = {}
				if type(default) == "table" then
					for k,v in pairs(default) do val[k] = v end
				end
			elseif default then
				if type(default) == "number" then val = values[default]
				else val = default end
			end
			ddObj.Value = val
			updateLabel()

			-- Dropdown popup
			local open = false
			local popup = nil

			local clickBtn = Instance.new("TextButton")
			clickBtn.Text = ""
			clickBtn.BackgroundTransparency = 1
			clickBtn.Size = UDim2.new(1,0,1,0)
			clickBtn.Parent = selBtn

			clickBtn.MouseButton1Click:Connect(function()
				if not _visible then return end
				open = not open
				if popup then popup:Destroy(); popup = nil end
				if not open then return end

				popup = newFrame(C.Group, UDim2.new(1,-20,0,0), UDim2.new(0,10,1,2), row)
				popup.AutomaticSize = Enum.AutomaticSize.Y
				popup.ZIndex = 10
				corner(CORNER_SM).Parent = popup
				stroke(C.Accent, 1).Parent = popup
				local pl = listlayout(2)
				pl.Parent = popup
				pad(4,4).Parent = popup

				for _, optVal in ipairs(values) do
					local optBtn = Instance.new("TextButton")
					optBtn.Text = "  " .. tostring(optVal)
					optBtn.Font = FONT_REG
					optBtn.TextSize = 13
					optBtn.TextColor3 = C.TextDim
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.BackgroundTransparency = 1
					optBtn.Size = UDim2.new(1,0,0,28)
					optBtn.ZIndex = 11
					optBtn.Parent = popup

					local function refreshOpt()
						local active = multi and val[optVal] or val == optVal
						optBtn.TextColor3 = active and C.Accent or C.TextDim
						optBtn.Text = (active and "✓ " or "  ") .. tostring(optVal)
					end
					refreshOpt()

					optBtn.MouseButton1Click:Connect(function()
						setVal(optVal)
						refreshOpt()
						if not multi then open = false; popup:Destroy(); popup = nil end
					end)
				end

				-- close on outside click
				local closeConn
				closeConn = UserInput.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						task.wait()
						if popup and popup.Parent then popup:Destroy(); popup = nil; open = false end
						closeConn:Disconnect()
					end
				end)
			end)

			function ddObj:SetValue(v, silent) setVal(v, silent) end
			function ddObj:SetValues(newVals)
				values = newVals
				if not multi then val = newVals[1] end
				ddObj.Value = val
				updateLabel()
				if popup then popup:Destroy(); popup = nil; open = false end
			end
			function ddObj:OnChanged(fn) _changed = fn end
			function ddObj:SetVisible(v)
				_visible = v
				row.Visible = v
			end

			return ddObj
		end

		-- ===== BUTTON =====
		function grp:AddButton(opts)
			local text = opts.Text or "Button"
			local func = opts.Func or function() end

			local btn = Instance.new("TextButton")
			btn.Text = text
			btn.Font = FONT
			btn.TextSize = 13
			btn.TextColor3 = C.Text
			btn.BackgroundColor3 = C.Accent
			btn.Size = UDim2.new(1,0,0,34)
			btn.BorderSizePixel = 0
			btn.Parent = itemsFrame
			corner(CORNER_SM).Parent = btn

			btn.MouseButton1Click:Connect(function()
				tween(btn, {BackgroundColor3 = C.AccentHov}, 0.1)
				pcall(func)
				task.delay(0.2, function() tween(btn, {BackgroundColor3 = C.Accent}, 0.1) end)
			end)

			btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = C.AccentHov}, 0.1) end)
			btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = C.Accent}, 0.1) end)

			return btn
		end

		-- ===== LABEL =====
		function grp:AddLabel(text, wrap)
			local lbl = newLabel(text, 12, C.TextDim, FONT_REG, itemsFrame)
			lbl.TextWrapped = wrap or false
			lbl.BackgroundColor3 = C.Group
			lbl.BackgroundTransparency = 1
			local lo = {
				SetText = function(_, t) lbl.Text = t end
			}
			return lo
		end

		-- ===== INPUT =====
		function grp:AddInput(key, opts)
			local text = opts.Text or key
			local ph   = opts.Placeholder or ""
			local def  = opts.Default or ""

			local row = newFrame(C.Panel, UDim2.new(1,0,0,58), nil, itemsFrame)
			corner(CORNER_SM).Parent = row

			local lbl = newLabel(text, 13, C.Text, FONT_REG, row)
			lbl.Position = UDim2.new(0,10,0,4)
			lbl.Size = UDim2.new(1,-20,0,18)

			local box = Instance.new("TextBox")
			box.PlaceholderText = ph
			box.Text = def
			box.Font = FONT_REG
			box.TextSize = 13
			box.TextColor3 = C.Text
			box.PlaceholderColor3 = C.TextDim
			box.BackgroundColor3 = C.SliderBG
			box.Size = UDim2.new(1,-20,0,28)
			box.Position = UDim2.new(0,10,0,26)
			box.BorderSizePixel = 0
			box.Parent = row
			corner(CORNER_SM).Parent = box
			stroke(C.Border).Parent = box
			pad(8,0).Parent = box

			local inpObj = {Value = def}
			Lib.Options[key] = inpObj
			local _changed = nil

			box:GetPropertyChangedSignal("Text"):Connect(function()
				inpObj.Value = box.Text
				if _changed then pcall(_changed) end
			end)

			function inpObj:OnChanged(fn) _changed = fn end

			return inpObj
		end

		-- ===== DIVIDER =====
		function grp:AddDivider()
			local div = newFrame(C.Border, UDim2.new(1,-16,0,1), nil, itemsFrame)
			div.BackgroundColor3 = C.Border
			return div
		end

		-- ===== KEYPICKER (just a label for mobile compat) =====
		function grp:AddKeyPicker(key, opts)
			local text = opts.Text or key
			local def  = opts.Default or "RightControl"
			local lbl = self:AddLabel("⌨ " .. text .. ": " .. def)
			local kpObj = {Value = Enum.KeyCode[def]}
			Lib.Options[key] = kpObj
			function kpObj:OnChanged(fn) end
			return lbl, kpObj
		end

		return grp
	end

	return windowObj
end

-- Expose Lib as the usable interface
function TitanicLib:GetLib()
	return Lib
end

return TitanicLib
