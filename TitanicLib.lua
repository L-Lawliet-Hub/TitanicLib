local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local lp2          = Players.LocalPlayer
local gui2         = lp2:WaitForChild("PlayerGui")

-- ===================== SHARED TABLES =====================
local TH_UI = {
	Options  = {},
	Toggles  = {},
	Unloaded = false,
}

-- ===================== COLORS =====================
local C = {
	BG       = Color3.fromRGB(13, 13, 18),
	Panel    = Color3.fromRGB(20, 20, 28),
	Group    = Color3.fromRGB(25, 25, 36),
	Accent   = Color3.fromRGB(88, 101, 242),
	AccentHv = Color3.fromRGB(110, 124, 255),
	TogOn    = Color3.fromRGB(80, 200, 120),
	TogOff   = Color3.fromRGB(50, 50, 68),
	Text     = Color3.fromRGB(220, 220, 232),
	Dim      = Color3.fromRGB(120, 120, 148),
	Border   = Color3.fromRGB(42, 42, 62),
	SlBG     = Color3.fromRGB(32, 32, 48),
	SlFG     = Color3.fromRGB(88, 101, 242),
}
local FB = Enum.Font.GothamBold
local FR = Enum.Font.Gotham

-- ===================== HELPERS =====================
local function tw(o,p,t,s,d)
	TweenService:Create(o, TweenInfo.new(t or .15, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p):Play()
end
local function crn(r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 6);return c end
local function stk(c,t) local s=Instance.new("UIStroke");s.Color=c or C.Border;s.Thickness=t or 1;return s end
local function pdg(x,y) local p=Instance.new("UIPadding");p.PaddingLeft=UDim.new(0,x);p.PaddingRight=UDim.new(0,x);p.PaddingTop=UDim.new(0,y);p.PaddingBottom=UDim.new(0,y);return p end
local function ll(g,fd) local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,g or 4);l.FillDirection=fd or Enum.FillDirection.Vertical;l.HorizontalAlignment=Enum.HorizontalAlignment.Left;l.SortOrder=Enum.SortOrder.LayoutOrder;return l end

local function frm(bg,sz,pos)
	local f=Instance.new("Frame");f.BackgroundColor3=bg or C.Panel
	f.Size=sz or UDim2.new(1,0,0,30);if pos then f.Position=pos end
	f.BorderSizePixel=0;return f
end
local function lbl(txt,sz,col,fnt)
	local l=Instance.new("TextLabel");l.Text=txt or""
	l.TextSize=sz or 13;l.TextColor3=col or C.Text;l.Font=fnt or FR
	l.BackgroundTransparency=1;l.TextXAlignment=Enum.TextXAlignment.Left
	l.Size=UDim2.new(1,0,0,(sz or 13)+3);return l
end

-- Drag
local function makeDrag(handle, target)
	local dr,st,sp=false
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
			dr=true;st=i.Position;sp=target.Position
		end
	end)
	UserInput.InputChanged:Connect(function(i)
		if not dr then return end
		local d=i.Position-st
		target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end)
	UserInput.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
	end)
end

-- ===================== NOTIFICATIONS =====================
local nHolder
local function ensureNH(sc)
	if nHolder and nHolder.Parent then return end
	nHolder=frm(Color3.new(),UDim2.new(0,270,1,-20),UDim2.new(1,-280,0,10))
	nHolder.BackgroundTransparency=1;nHolder.Parent=sc
	local l2=ll(6);l2.VerticalAlignment=Enum.VerticalAlignment.Bottom;l2.Parent=nHolder
end

function TH_UI:Notify(o)
	if not nHolder then return end
	local card=frm(C.Panel,UDim2.new(1,0,0,0));card.AutomaticSize=Enum.AutomaticSize.Y
	card.BackgroundTransparency=0.08;crn(10).Parent=card;stk(C.Accent,1.5).Parent=card
	pdg(12,10).Parent=card;ll(4).Parent=card;card.Parent=nHolder
	local t=lbl("🔔 "..(o.Title or"TITANIC HUB"),14,C.Accent,FB);t.Parent=card
	local d=lbl(o.Description or"",13,C.Dim,FR)
	d.TextWrapped=true;d.AutomaticSize=Enum.AutomaticSize.Y;d.Parent=card
	local bar=frm(C.SlBG,UDim2.new(1,0,0,3));crn(2).Parent=bar;bar.Parent=card
	local fill=frm(C.SlFG,UDim2.new(1,0,1,0));crn(2).Parent=fill;fill.Parent=bar
	card.Position=UDim2.new(1,10,0,0)
	tw(card,{Position=UDim2.new(0,0,0,0)},.25,Enum.EasingStyle.Back)
	tw(fill,{Size=UDim2.new(0,0,1,0)},o.Time or 3,Enum.EasingStyle.Linear)
	task.delay(o.Time or 3,function()
		tw(card,{Position=UDim2.new(1,10,0,0),BackgroundTransparency=1},.2)
		task.wait(.25);card:Destroy()
	end)
end

function TH_UI:Toggle(v)
	-- handled by window visibility
end

-- ===================== WINDOW =====================
function TH_UI:CreateWindow(opts)
	local title = opts.Title or "TITANIC HUB"
	local footer= opts.Footer or "AOT:R"

	local sc=Instance.new("ScreenGui")
	sc.Name="TH_Screen";sc.ResetOnSpawn=false
	sc.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sc.Parent=gui2

	ensureNH(sc)

	local vp=workspace.CurrentCamera.ViewportSize
	local mob=vp.X<600

	-- Main window
	local W=frm(C.BG,mob and UDim2.new(1,-14,0,530) or UDim2.new(0,660,0,530))
	W.Position=mob and UDim2.new(0,7,.5,-265) or UDim2.new(.5,-330,.5,-265)
	W.Parent=sc;crn(14).Parent=W;stk(C.Border,1.5).Parent=W
	local wsz=W.Size

	-- Floating icon (shown when minimized)
	local icon=Instance.new("ImageButton")
	icon.Size=UDim2.new(0,48,0,48)
	icon.Position=UDim2.new(0,10,0,10)
	icon.BackgroundColor3=C.Accent
	icon.Image=""
	icon.BorderSizePixel=0
	icon.Visible=false
	icon.ZIndex=100
	icon.Parent=sc
	crn(12).Parent=icon
	stk(C.Border,1.5).Parent=icon
	local iconLbl=Instance.new("TextLabel")
	iconLbl.Text="⚡";iconLbl.TextSize=22;iconLbl.Font=FB
	iconLbl.TextColor3=Color3.new(1,1,1);iconLbl.BackgroundTransparency=1
	iconLbl.Size=UDim2.new(1,0,1,0);iconLbl.Parent=icon
	makeDrag(icon,icon)
	icon.MouseButton1Click:Connect(function()
		icon.Visible=false;W.Visible=true
	end)

	-- Titlebar
	local TB=frm(C.Panel,UDim2.new(1,0,0,46))
	TB.Parent=W;crn(14).Parent=TB
	-- fix bottom corners
	frm(C.Panel,UDim2.new(1,0,0,14),UDim2.new(0,0,1,-14)).Parent=TB

	local tl=lbl("⚡ "..title,17,C.Text,FB)
	tl.Size=UDim2.new(1,-90,1,0);tl.Position=UDim2.new(0,14,0,0)
	tl.TextYAlignment=Enum.TextYAlignment.Center;tl.Parent=TB

	-- Minimize → icon
	local minB=Instance.new("TextButton");minB.Text="–";minB.Font=FB;minB.TextSize=20
	minB.TextColor3=C.Dim;minB.BackgroundTransparency=1
	minB.Size=UDim2.new(0,32,1,0);minB.Position=UDim2.new(1,-78,0,0);minB.Parent=TB
	minB.MouseButton1Click:Connect(function()
		W.Visible=false;icon.Visible=true
	end)

	-- Close
	local clB=Instance.new("TextButton");clB.Text="✕";clB.Font=FB;clB.TextSize=16
	clB.TextColor3=C.Dim;clB.BackgroundTransparency=1
	clB.Size=UDim2.new(0,32,1,0);clB.Position=UDim2.new(1,-42,0,0);clB.Parent=TB
	clB.MouseButton1Click:Connect(function()
		tw(W,{BackgroundTransparency=1},.2);task.wait(.2);sc:Destroy();TH_UI.Unloaded=true
	end)

	makeDrag(TB,W)

	-- RightControl to toggle
	UserInput.InputBegan:Connect(function(i,gp)
		if gp then return end
		if i.KeyCode==Enum.KeyCode.RightControl then
			if W.Visible then W.Visible=false;icon.Visible=true
			else icon.Visible=false;W.Visible=true end
		end
	end)

	-- Footer
	local fl=lbl(footer,11,C.Dim,FR)
	fl.Size=UDim2.new(1,0,0,18);fl.Position=UDim2.new(0,0,1,-18)
	fl.TextXAlignment=Enum.TextXAlignment.Center;fl.Parent=W

	-- Tabbar
	local tabBar=frm(C.Panel,UDim2.new(1,0,0,38),UDim2.new(0,0,0,46))
	tabBar.Parent=W
	local tbl=Instance.new("UIListLayout");tbl.FillDirection=Enum.FillDirection.Horizontal
	tbl.Padding=UDim.new(0,3);tbl.VerticalAlignment=Enum.VerticalAlignment.Center
	tbl.SortOrder=Enum.SortOrder.LayoutOrder;tbl.Parent=tabBar
	pdg(6,4).Parent=tabBar

	-- Content
	local content=frm(C.BG,UDim2.new(1,0,1,-108),UDim2.new(0,0,0,84))
	content.ClipsDescendants=true;content.Parent=W

	local activeTab=nil

	local winObj={}

	function winObj:AddTab(name)
		local btn=Instance.new("TextButton");btn.Text=name;btn.Font=FR;btn.TextSize=13
		btn.TextColor3=C.Dim;btn.BackgroundTransparency=1;btn.AutomaticSize=Enum.AutomaticSize.X
		btn.Size=UDim2.new(0,0,0,30);btn.Parent=tabBar;crn(6).Parent=btn
		local bp=Instance.new("UIPadding");bp.PaddingLeft=UDim.new(0,12);bp.PaddingRight=UDim.new(0,12);bp.Parent=btn

		local page=frm(C.BG,UDim2.new(1,0,1,0));page.Visible=false;page.ClipsDescendants=true;page.Parent=content

		local function mkScroll(xpos,xsz)
			local s=Instance.new("ScrollingFrame")
			s.Size=UDim2.new(xsz,-6,1,-8);s.Position=UDim2.new(xpos,3,0,4)
			s.BackgroundTransparency=1;s.ScrollBarThickness=3
			s.ScrollBarImageColor3=C.Accent;s.BorderSizePixel=0
			s.CanvasSize=UDim2.new(0,0,0,0);s.AutomaticCanvasSize=Enum.AutomaticSize.Y
			s.Parent=page;ll(5).Parent=s;return s
		end
		local LS=mkScroll(0,.5)
		local RS=mkScroll(.5,.5)

		local tabObj={}

		local function mkGroup(gname,scroll)
			local gf=frm(C.Group,UDim2.new(1,-6,0,0));gf.AutomaticSize=Enum.AutomaticSize.Y
			crn(8).Parent=gf;stk(C.Border).Parent=gf;gf.Parent=scroll

			local hdr=frm(C.Panel,UDim2.new(1,0,0,28));crn(8).Parent=hdr
			frm(C.Panel,UDim2.new(1,0,0,10),UDim2.new(0,0,1,-10)).Parent=hdr;hdr.Parent=gf
			local hl=lbl("  "..gname,13,C.Accent,FB)
			hl.Size=UDim2.new(1,0,1,0);hl.TextYAlignment=Enum.TextYAlignment.Center;hl.Parent=hdr

			local items=frm(C.Group,UDim2.new(1,0,0,0),UDim2.new(0,0,0,28))
			items.AutomaticSize=Enum.AutomaticSize.Y;items.BackgroundTransparency=1
			ll(4).Parent=items;pdg(8,6).Parent=items;items.Parent=gf

			local grp={}

			-- TOGGLE
			function grp:AddToggle(key,o)
				local row=frm(C.Panel,UDim2.new(1,0,0,40));crn(7).Parent=row;row.Parent=items
				local l2=lbl(o.Text or key,13,C.Text,FR)
				l2.Position=UDim2.new(0,10,0,0);l2.Size=UDim2.new(1,-60,1,0)
				l2.TextYAlignment=Enum.TextYAlignment.Center;l2.Parent=row
				local tr=frm(C.TogOff,UDim2.new(0,44,0,26),UDim2.new(1,-54,.5,-13));crn(13).Parent=tr;tr.Parent=row
				local kn=frm(Color3.new(1,1,1),UDim2.new(0,22,0,22),UDim2.new(0,2,.5,-11));crn(11).Parent=kn;kn.Parent=tr
				local v=o.Default or false
				local to={Value=v};TH_UI.Toggles[key]=to;local ch=nil
				local function sv(nv,si)
					v=nv;to.Value=nv
					tw(tr,{BackgroundColor3=nv and C.TogOn or C.TogOff},.15)
					tw(kn,{Position=nv and UDim2.new(1,-24,.5,-11) or UDim2.new(0,2,.5,-11)},.15)
					if not si and ch then task.spawn(pcall,ch) end
				end
				sv(v,true)
				local bb=Instance.new("TextButton");bb.Text="";bb.BackgroundTransparency=1
				bb.Size=UDim2.new(1,0,1,0);bb.Parent=row
				bb.MouseButton1Click:Connect(function() sv(not v) end)
				function to:SetValue(nv) sv(nv) end
				function to:OnChanged(fn) ch=fn end
				return to
			end

			-- SLIDER
			function grp:AddSlider(key,o)
				local mn,mx,df=o.Min or 0,o.Max or 100,o.Default or 0
				local row=frm(C.Panel,UDim2.new(1,0,0,54));crn(7).Parent=row;row.Parent=items
				local tl2=lbl(o.Text or key,13,C.Text,FR)
				tl2.Position=UDim2.new(0,10,0,6);tl2.Size=UDim2.new(.72,-10,0,16);tl2.Parent=row
				local vl=lbl(tostring(df),13,C.Accent,FB)
				vl.Position=UDim2.new(.72,0,0,6);vl.Size=UDim2.new(.28,-10,0,16)
				vl.TextXAlignment=Enum.TextXAlignment.Right;vl.Parent=row
				local bar2=frm(C.SlBG,UDim2.new(1,-20,0,8),UDim2.new(0,10,0,38));crn(4).Parent=bar2;bar2.Parent=row
				local fill2=frm(C.SlFG,UDim2.new(0,0,1,0));crn(4).Parent=fill2;fill2.Parent=bar2
				local v2=df;local so={Value=v2};TH_UI.Options[key]=so;local ch2=nil
				local function sv2(nv,si)
					nv=math.clamp(math.floor(nv+.5),mn,mx);v2=nv;so.Value=nv
					tw(fill2,{Size=UDim2.new((nv-mn)/(mx-mn),0,1,0)},.05);vl.Text=tostring(nv)
					if not si and ch2 then task.spawn(pcall,ch2) end
				end
				sv2(v2,true)
				local dr=false
				local function upd(i2)
					local rx=i2.Position.X-bar2.AbsolutePosition.X
					sv2(mn+(mx-mn)*math.clamp(rx/bar2.AbsoluteSize.X,0,1))
				end
				bar2.InputBegan:Connect(function(i2)
					if i2.UserInputType==Enum.UserInputType.Touch or i2.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;upd(i2) end
				end)
				UserInput.InputChanged:Connect(function(i2) if dr then upd(i2) end end)
				UserInput.InputEnded:Connect(function(i2)
					if i2.UserInputType==Enum.UserInputType.Touch or i2.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
				end)
				function so:SetValue(nv) sv2(nv) end
				function so:OnChanged(fn) ch2=fn end
				return so
			end

			-- DROPDOWN
			function grp:AddDropdown(key,o)
				local vals=o.Values or{};local multi=o.Multi or false
				local row=frm(C.Panel,UDim2.new(1,0,0,66));crn(7).Parent=row;row.Parent=items
				local tl3=lbl(o.Text or key,13,C.Text,FR)
				tl3.Position=UDim2.new(0,10,0,6);tl3.Size=UDim2.new(1,-20,0,16);tl3.Parent=row
				local sf=frm(C.SlBG,UDim2.new(1,-20,0,32),UDim2.new(0,10,0,28));crn(7).Parent=sf;stk(C.Border).Parent=sf;sf.Parent=row
				local sl=lbl("Select...",13,C.Dim,FR)
				sl.Position=UDim2.new(0,8,0,0);sl.Size=UDim2.new(1,-28,1,0)
				sl.TextYAlignment=Enum.TextYAlignment.Center;sl.Parent=sf
				local ar=lbl("▾",14,C.Accent,FB)
				ar.Position=UDim2.new(1,-22,0,0);ar.Size=UDim2.new(0,18,1,0)
				ar.TextXAlignment=Enum.TextXAlignment.Center;ar.TextYAlignment=Enum.TextYAlignment.Center;ar.Parent=sf
				local v3=multi and {} or nil;local ddo={Value=v3};TH_UI.Options[key]=ddo;local ch3=nil;local vis=true
				local function ul()
					if multi then
						local p={};for k,vv in pairs(v3) do if vv then p[#p+1]=k end end
						sl.Text=#p==0 and"Select..." or table.concat(p,", ");sl.TextColor3=#p==0 and C.Dim or C.Text
					else sl.Text=v3 or"Select...";sl.TextColor3=v3 and C.Text or C.Dim end
				end
				local function sv3(nv,si)
					if multi then if type(nv)=="table" then v3=nv else v3[nv]=not v3[nv] end else v3=nv end
					ddo.Value=v3;ul()
					if not si and ch3 then task.spawn(pcall,ch3) end
				end
				local df3=o.Default
				if multi then v3={};if type(df3)=="table" then for k,vv in pairs(df3) do v3[k]=vv end end
				elseif df3 then v3=type(df3)=="number" and vals[df3] or df3 end
				ddo.Value=v3;ul()
				local open=false;local pop=nil
				local cb2=Instance.new("TextButton");cb2.Text="";cb2.BackgroundTransparency=1
				cb2.Size=UDim2.new(1,0,1,0);cb2.Parent=sf
				cb2.MouseButton1Click:Connect(function()
					if not vis then return end;open=not open
					if pop then pop:Destroy();pop=nil end
					if not open then return end
					pop=frm(C.Group,UDim2.new(1,-20,0,0),UDim2.new(0,10,1,2))
					pop.AutomaticSize=Enum.AutomaticSize.Y;pop.ZIndex=20
					crn(7).Parent=pop;stk(C.Accent,1).Parent=pop;ll(2).Parent=pop;pdg(4,4).Parent=pop;pop.Parent=row
					for _,ov in ipairs(vals) do
						local ob=Instance.new("TextButton");ob.Text="  "..tostring(ov);ob.Font=FR;ob.TextSize=13
						ob.TextColor3=C.Dim;ob.TextXAlignment=Enum.TextXAlignment.Left
						ob.BackgroundTransparency=1;ob.Size=UDim2.new(1,0,0,28);ob.ZIndex=21;ob.Parent=pop
						local function ro() local act=multi and v3[ov] or v3==ov;ob.TextColor3=act and C.Accent or C.Dim;ob.Text=(act and"✓ " or"  ")..tostring(ov) end
						ro()
						ob.MouseButton1Click:Connect(function() sv3(ov);ro();if not multi then open=false;pop:Destroy();pop=nil end end)
					end
					local cc;cc=UserInput.InputBegan:Connect(function(i3)
						if i3.UserInputType==Enum.UserInputType.MouseButton1 or i3.UserInputType==Enum.UserInputType.Touch then
							task.wait();if pop and pop.Parent then pop:Destroy();pop=nil;open=false end;cc:Disconnect()
						end
					end)
				end)
				function ddo:SetValue(nv,si) sv3(nv,si) end
				function ddo:SetValues(nv) vals=nv;if not multi then v3=nv[1] end;ddo.Value=v3;ul();if pop then pop:Destroy();pop=nil;open=false end end
				function ddo:OnChanged(fn) ch3=fn end
				function ddo:SetVisible(v5) vis=v5;row.Visible=v5 end
				return ddo
			end

			-- BUTTON
			function grp:AddButton(o)
				local b=Instance.new("TextButton");b.Text=o.Text or"Button";b.Font=FB;b.TextSize=13
				b.TextColor3=C.Text;b.BackgroundColor3=C.Accent;b.Size=UDim2.new(1,0,0,36)
				b.BorderSizePixel=0;b.Parent=items;crn(7).Parent=b
				b.MouseButton1Click:Connect(function() tw(b,{BackgroundColor3=C.AccentHv},.1);pcall(o.Func or function()end);task.delay(.2,function() tw(b,{BackgroundColor3=C.Accent},.1) end) end)
				b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=C.AccentHv},.1) end)
				b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=C.Accent},.1) end)
				return b
			end

			-- LABEL
			function grp:AddLabel(txt,wrap)
				local l3=lbl(txt,12,C.Dim,FR);l3.TextWrapped=wrap or false
				l3.AutomaticSize=Enum.AutomaticSize.Y;l3.Parent=items
				return {SetText=function(_,t) l3.Text=t end}
			end

			-- INPUT
			function grp:AddInput(key,o)
				local row=frm(C.Panel,UDim2.new(1,0,0,60));crn(7).Parent=row;row.Parent=items
				local tl4=lbl(o.Text or key,13,C.Text,FR)
				tl4.Position=UDim2.new(0,10,0,6);tl4.Size=UDim2.new(1,-20,0,16);tl4.Parent=row
				local bx=Instance.new("TextBox");bx.PlaceholderText=o.Placeholder or""
				bx.Text=o.Default or"";bx.Font=FR;bx.TextSize=13;bx.TextColor3=C.Text
				bx.PlaceholderColor3=C.Dim;bx.BackgroundColor3=C.SlBG;bx.Size=UDim2.new(1,-20,0,30)
				bx.Position=UDim2.new(0,10,0,26);bx.BorderSizePixel=0;bx.Parent=row
				crn(7).Parent=bx;stk(C.Border).Parent=bx;pdg(8,0).Parent=bx
				local io={Value=o.Default or""};TH_UI.Options[key]=io;local ch4=nil
				bx:GetPropertyChangedSignal("Text"):Connect(function() io.Value=bx.Text;if ch4 then pcall(ch4) end end)
				function io:OnChanged(fn) ch4=fn end
				return io
			end

			-- DIVIDER
			function grp:AddDivider()
				local d=frm(C.Border,UDim2.new(1,-16,0,1));d.Parent=items;return d
			end

			-- KEYPICKER
			function grp:AddKeyPicker(key,o)
				local l4=self:AddLabel("⌨ "..(o.Text or key)..": "..(o.Default or"RightControl"))
				local kp={Value=Enum.KeyCode[o.Default or"RightControl"]};TH_UI.Options[key]=kp
				function kp:OnChanged() end
				return l4,kp
			end

			return grp
		end

		function tabObj:AddLeftGroupbox(n) return mkGroup(n,LS) end
		function tabObj:AddRightGroupbox(n) return mkGroup(n,RS) end

		btn.MouseButton1Click:Connect(function()
			if activeTab==tabObj then return end
			if activeTab then activeTab._page.Visible=false;tw(activeTab._btn,{TextColor3=C.Dim},.1);activeTab._btn.BackgroundTransparency=1 end
			activeTab=tabObj;page.Visible=true;tw(btn,{TextColor3=C.Text},.1)
			btn.BackgroundTransparency=0;btn.BackgroundColor3=C.Accent
		end)

		if not activeTab then
			activeTab=tabObj;page.Visible=true
			btn.TextColor3=C.Text;btn.BackgroundTransparency=0;btn.BackgroundColor3=C.Accent
		end

		return tabObj
	end

	return winObj
end

return TH_UI
