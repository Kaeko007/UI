--[[
    SpinachUI v2 — Premium Roblox Executor UI
    Redesigned from scratch. No more flat garbage.
]]

local SpinachUI = {}
SpinachUI.__index = SpinachUI

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ╔══════════════════════════════════════╗
-- ║              THEME                   ║
-- ╚══════════════════════════════════════╝
local T = {
    -- Backgrounds
    BG          = Color3.fromRGB(8,   8,  14),
    BG2         = Color3.fromRGB(12,  12,  20),
    Panel       = Color3.fromRGB(15,  15,  24),
    Card        = Color3.fromRGB(18,  18,  28),
    CardHover   = Color3.fromRGB(22,  22,  34),
    CardActive  = Color3.fromRGB(26,  22,  40),

    -- Borders
    Border      = Color3.fromRGB(30,  30,  48),
    BorderHover = Color3.fromRGB(80,  60, 140),
    BorderGlow  = Color3.fromRGB(110, 70, 210),

    -- Accent (electric purple → pink)
    Accent      = Color3.fromRGB(130,  70, 255),
    AccentSoft  = Color3.fromRGB( 90,  45, 180),
    AccentGlow  = Color3.fromRGB(160, 100, 255),
    AccentPink  = Color3.fromRGB(200,  80, 200),

    -- Text
    TextW       = Color3.fromRGB(240, 240, 250),
    TextM       = Color3.fromRGB(160, 155, 185),
    TextD       = Color3.fromRGB( 80,  75, 105),

    -- Status
    Green       = Color3.fromRGB( 60, 220, 130),
    Red         = Color3.fromRGB(255,  70,  90),
    Yellow      = Color3.fromRGB(255, 190,  50),

    -- Toggle
    TOn         = Color3.fromRGB(110,  55, 230),
    TOff        = Color3.fromRGB( 28,  28,  42),
    TKnob       = Color3.fromRGB(230, 225, 255),

    -- Sidebar
    Sidebar     = Color3.fromRGB(10,  10,  17),
    SideActive  = Color3.fromRGB(18,  14,  30),

    White       = Color3.new(1,1,1),
    Black       = Color3.new(0,0,0),
}

local FG   = Enum.Font.GothamBold
local FM   = Enum.Font.GothamSemibold
local FL   = Enum.Font.Gotham
local TF   = function(t,s,e) return TweenInfo.new(t or .2, s or Enum.EasingStyle.Quart, e or Enum.EasingDirection.Out) end
local TW   = function(o,p,t) TweenService:Create(o, TF(t), p):Play() end

-- ╔══════════════════════════════════════╗
-- ║              HELPERS                 ║
-- ╚══════════════════════════════════════╝
local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function Stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border; s.Thickness = thick or 1
    s.Transparency = trans or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end
local function Pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop = UDim.new(0,t or 8); u.PaddingBottom = UDim.new(0,b or 8)
    u.PaddingLeft = UDim.new(0,l or 10); u.PaddingRight = UDim.new(0,r or 10)
    u.Parent = p; return u
end
local function List(p, dir, pad, align)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, pad or 6)
    if align then l.HorizontalAlignment = align end
    l.Parent = p; return l
end
local function Gradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1); g.Rotation = rot or 90; g.Parent = p; return g
end
local function Img(p, id, size, pos, zi, trans)
    local i = Instance.new("ImageLabel")
    i.Image = id; i.Size = size or UDim2.new(1,0,1,0); i.Position = pos or UDim2.new(0,0,0,0)
    i.BackgroundTransparency = 1; i.ZIndex = zi or 1; i.ImageTransparency = trans or 0
    i.Parent = p; return i
end
local function Frame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do
        if k ~= "Parent" then f[k] = v end
    end
    if props.Corner  then Corner(f, props.Corner) end
    if props.Stroke  then Stroke(f, props.Stroke[1], props.Stroke[2], props.Stroke[3]) end
    if props.Padding then Pad(f, table.unpack(props.Padding)) end
    f.Parent = props.Parent; return f
end
local function Lbl(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    for k,v in pairs(props) do
        if k ~= "Parent" then l[k] = v end
    end
    l.Parent = props.Parent; return l
end
local function Btn(props)
    local b = Instance.new("TextButton")
    b.Text = ""; b.BorderSizePixel = 0
    for k,v in pairs(props) do
        if k ~= "Parent" then b[k] = v end
    end
    if props.Corner  then Corner(b, props.Corner) end
    if props.Stroke  then Stroke(b, props.Stroke[1], props.Stroke[2], props.Stroke[3]) end
    if props.Padding then Pad(b, table.unpack(props.Padding)) end
    b.Parent = props.Parent; return b
end

-- ╔══════════════════════════════════════╗
-- ║           CONFIG SYSTEM              ║
-- ╚══════════════════════════════════════╝
local CONFIG_FILE = "SpinachUI_v2.json"
local CFG = {}
pcall(function()
    local raw = readfile(CONFIG_FILE)
    CFG = HttpService:JSONDecode(raw) or {}
end)
local function cfgSave() pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CFG)) end) end
local function cfgLoad()
    pcall(function()
        local raw = readfile(CONFIG_FILE)
        CFG = HttpService:JSONDecode(raw) or {}
    end)
end

-- ╔══════════════════════════════════════╗
-- ║              WINDOW                  ║
-- ╚══════════════════════════════════════╝
local W_W, W_H = 620, 420
local SB_W     = 150

function SpinachUI.new(opts)
    opts = opts or {}
    local self = setmetatable({}, SpinachUI)
    self._tabs      = {}
    self._activeTab = nil

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = opts.Name or "SpinachUI"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn   = false
    sg.DisplayOrder   = 1000
    sg.IgnoreGuiInset = true
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent or sg.Parent == nil then sg.Parent = LP:WaitForChild("PlayerGui") end

    -- ── Outer glow shadow ──
    local glow = Instance.new("Frame")
    glow.Name                   = "Glow"
    glow.Size                   = UDim2.new(0, W_W + 40, 0, W_H + 40)
    glow.Position               = UDim2.new(0.5, -(W_W/2)-20, 0.5, -(W_H/2)-20)
    glow.BackgroundColor3       = T.Accent
    glow.BackgroundTransparency = 0.88
    glow.BorderSizePixel        = 0
    glow.ZIndex                 = 0
    glow.Parent                 = sg
    Corner(glow, 20)

    -- ── Main container ──
    local main = Instance.new("Frame")
    main.Name             = "Main"
    main.Size             = UDim2.new(0, W_W, 0, W_H)
    main.Position         = UDim2.new(0.5, -W_W/2, 0.5, -W_H/2)
    main.BackgroundColor3 = T.BG
    main.BorderSizePixel  = 0
    main.ClipsDescendants = true
    main.ZIndex           = 1
    main.Parent           = sg
    Corner(main, 14)
    -- Outer border
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color       = T.Accent
    mainStroke.Thickness   = 1.5
    mainStroke.Transparency = 0.6
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent      = main

    -- Subtle grid/noise texture overlay
    local noiseBg = Instance.new("Frame")
    noiseBg.Size             = UDim2.new(1,0,1,0)
    noiseBg.BackgroundColor3 = T.Accent
    noiseBg.BackgroundTransparency = 0.97
    noiseBg.BorderSizePixel  = 0
    noiseBg.ZIndex           = 0
    noiseBg.Parent           = main

    -- ── Top accent bar (gradient) ──
    local topBar = Instance.new("Frame")
    topBar.Size             = UDim2.new(1,0,0,3)
    topBar.BackgroundColor3 = T.Accent
    topBar.BorderSizePixel  = 0
    topBar.ZIndex           = 10
    topBar.Parent           = main
    Gradient(topBar,
        Color3.fromRGB(180, 80, 255),
        Color3.fromRGB(80, 120, 255),
        0
    )

    -- ── Title bar ──
    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 48)
    titleBar.Position         = UDim2.new(0, 0, 0, 3)
    titleBar.BackgroundColor3 = T.BG
    titleBar.BorderSizePixel  = 0
    titleBar.ZIndex           = 5
    titleBar.Parent           = main

    -- subtle bottom line on titlebar
    local tbLine = Instance.new("Frame")
    tbLine.Size             = UDim2.new(1,0,0,1)
    tbLine.Position         = UDim2.new(0,0,1,0)
    tbLine.BackgroundColor3 = T.Border
    tbLine.BorderSizePixel  = 0
    tbLine.ZIndex           = 6
    tbLine.Parent           = titleBar
    Gradient(tbLine, T.AccentSoft, Color3.fromRGB(20,20,35), 0)

    -- Logo dot
    local logoDot = Instance.new("Frame")
    logoDot.Size             = UDim2.new(0, 8, 0, 8)
    logoDot.Position         = UDim2.new(0, 16, 0.5, -4)
    logoDot.BackgroundColor3 = T.Accent
    logoDot.BorderSizePixel  = 0
    logoDot.ZIndex           = 7
    logoDot.Parent           = titleBar
    Corner(logoDot, 4)

    local logoDotGlow = Instance.new("Frame")
    logoDotGlow.Size             = UDim2.new(0, 18, 0, 18)
    logoDotGlow.Position         = UDim2.new(0, 11, 0.5, -9)
    logoDotGlow.BackgroundColor3 = T.Accent
    logoDotGlow.BackgroundTransparency = 0.75
    logoDotGlow.BorderSizePixel  = 0
    logoDotGlow.ZIndex           = 6
    logoDotGlow.Parent           = titleBar
    Corner(logoDotGlow, 9)

    -- Title text
    local titleLbl = Lbl({
        Text = opts.Title or "SpinachUI",
        TextSize = 15, Font = FG,
        TextColor3 = T.TextW,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7, Parent = titleBar,
    })
    local subLbl = Lbl({
        Text = opts.Subtitle or "executor ui",
        TextSize = 10, Font = FL,
        TextColor3 = T.TextD,
        Size = UDim2.new(0, 200, 0, 14),
        Position = UDim2.new(0, 34, 0.5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7, Parent = titleBar,
    })

    -- Window buttons
    local function winBtn(xOff, col, icon)
        local b = Btn({
            Size = UDim2.new(0,26,0,26),
            Position = UDim2.new(1, xOff, 0.5, -13),
            BackgroundColor3 = col,
            BackgroundTransparency = 0.3,
            ZIndex = 8, Corner = 6, Parent = titleBar,
        })
        Stroke(b, col, 1, 0.5)
        Lbl({ Text=icon, TextSize=13, Font=FG, TextColor3=T.White,
              BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
              TextXAlignment=Enum.TextXAlignment.Center,
              TextYAlignment=Enum.TextYAlignment.Center,
              ZIndex=9, Parent=b })
        b.MouseEnter:Connect(function() TW(b,{BackgroundTransparency=0}) end)
        b.MouseLeave:Connect(function() TW(b,{BackgroundTransparency=0.3}) end)
        return b
    end

    local closeBtn = winBtn(-38, T.Red,    "✕")
    local miniBtn  = winBtn(-70, T.Yellow, "–")

    closeBtn.MouseButton1Click:Connect(function()
        TW(main, {Size = UDim2.new(0,W_W,0,51)}, 0.25)
    end)
    -- reopen on click of minimized bar
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if main.Size.Y.Offset == 51 then
                TW(main, {Size = UDim2.new(0,W_W,0,W_H)}, 0.3)
            end
        end
    end)
    miniBtn.MouseButton1Click:Connect(function()
        sg.Enabled = false
        local c; c = UserInputService.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.RightControl then
                sg.Enabled = true; c:Disconnect()
            end
        end)
    end)

    -- Drag
    local drag, ds, dp = false, nil, nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; dp=main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            local nx = dp.X.Scale*workspace.CurrentCamera.ViewportSize.X + dp.X.Offset + d.X
            local ny = dp.Y.Scale*workspace.CurrentCamera.ViewportSize.Y + dp.Y.Offset + d.Y
            main.Position = UDim2.new(0, nx, 0, ny)
            glow.Position = UDim2.new(0, nx-20, 0, ny-20)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
    end)

    -- ── Sidebar ──
    local sidebar = Instance.new("Frame")
    sidebar.Name             = "Sidebar"
    sidebar.Size             = UDim2.new(0, SB_W, 1, -52)
    sidebar.Position         = UDim2.new(0, 0, 0, 51)
    sidebar.BackgroundColor3 = T.Sidebar
    sidebar.BorderSizePixel  = 0
    sidebar.ZIndex           = 4
    sidebar.Parent           = main

    local sbRight = Instance.new("Frame")
    sbRight.Size             = UDim2.new(0,1,1,0)
    sbRight.Position         = UDim2.new(1,0,0,0)
    sbRight.BackgroundColor3 = T.Border
    sbRight.BorderSizePixel  = 0
    sbRight.ZIndex           = 5
    sbRight.Parent           = sidebar

    local sbList = Instance.new("UIListLayout")
    sbList.SortOrder  = Enum.SortOrder.LayoutOrder
    sbList.Padding    = UDim.new(0,3)
    sbList.Parent     = sidebar
    Pad(sidebar, 12, 12, 8, 8)

    -- Sidebar footer glow line
    local sbGlow = Instance.new("Frame")
    sbGlow.Size             = UDim2.new(1,0,0,1)
    sbGlow.Position         = UDim2.new(0,0,1,-1)
    sbGlow.BackgroundColor3 = T.Accent
    sbGlow.BackgroundTransparency = 0.6
    sbGlow.BorderSizePixel  = 0
    sbGlow.ZIndex           = 5
    sbGlow.Parent           = sidebar

    -- ── Content area ──
    local content = Instance.new("Frame")
    content.Name             = "Content"
    content.Size             = UDim2.new(1,-SB_W,1,-51)
    content.Position         = UDim2.new(0,SB_W,0,51)
    content.BackgroundTransparency = 1
    content.BorderSizePixel  = 0
    content.ClipsDescendants = true
    content.ZIndex           = 3
    content.Parent           = main

    self._sg      = sg
    self._main    = main
    self._sidebar = sidebar
    self._content = content
    self._glow    = glow

    return self
end

-- ╔══════════════════════════════════════╗
-- ║               TAB                   ║
-- ╚══════════════════════════════════════╝
function SpinachUI:addTab(name, icon)
    icon = icon or "◈"

    -- Sidebar button
    local tabBtn = Btn({
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = T.SideActive,
        BackgroundTransparency = 1,
        ZIndex = 6, Corner = 8, LayoutOrder = #self._tabs+1,
        Parent = self._sidebar,
    })

    -- Active indicator stripe
    local stripe = Instance.new("Frame")
    stripe.Size             = UDim2.new(0,3,0,18)
    stripe.Position         = UDim2.new(0,0,0.5,-9)
    stripe.BackgroundColor3 = T.Accent
    stripe.BackgroundTransparency = 1
    stripe.BorderSizePixel  = 0
    stripe.ZIndex           = 8
    stripe.Parent           = tabBtn
    Corner(stripe, 2)

    -- Icon
    local tabIcon = Lbl({
        Text = icon, TextSize = 12, Font = FG,
        TextColor3 = T.TextD,
        Size = UDim2.new(0,24,1,0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 7, Parent = tabBtn,
    })

    -- Name
    local tabLbl = Lbl({
        Text = name, TextSize = 12, Font = FM,
        TextColor3 = T.TextD,
        Size = UDim2.new(1,-36,1,0),
        Position = UDim2.new(0,34,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7, Parent = tabBtn,
    })

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size              = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel   = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = T.Accent
    scroll.CanvasSize        = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible           = false
    scroll.ZIndex            = 4
    scroll.Parent            = self._content
    Pad(scroll, 14, 14, 16, 16)
    List(scroll, nil, 7)

    local tabData = { btn=tabBtn, stripe=stripe, icon=tabIcon, lbl=tabLbl, scroll=scroll, order=0 }
    table.insert(self._tabs, tabData)

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tabData then
            TW(tabBtn, {BackgroundTransparency=0.85, BackgroundColor3=T.SideActive})
            TW(tabLbl, {TextColor3=T.TextM})
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tabData then
            TW(tabBtn, {BackgroundTransparency=1})
            TW(tabLbl, {TextColor3=T.TextD})
        end
    end)
    tabBtn.MouseButton1Click:Connect(function() self:_selectTab(tabData) end)

    if #self._tabs == 1 then self:_selectTab(tabData) end

    -- ── Component builder ──
    local Tab = {}
    local function ord() tabData.order += 1; return tabData.order end

    -- ─────────────── SECTION ───────────────
    function Tab:addSection(name)
        local f = Instance.new("Frame")
        f.Size             = UDim2.new(1,0,0,24)
        f.BackgroundTransparency = 1
        f.BorderSizePixel  = 0
        f.LayoutOrder      = ord()
        f.Parent           = scroll

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0.5,0)
        line.BackgroundColor3 = T.Border; line.BorderSizePixel = 0; line.Parent = f
        Gradient(line, T.AccentSoft, Color3.fromRGB(15,15,25), 0)

        local bg = Instance.new("Frame")
        bg.BackgroundColor3 = T.BG; bg.BorderSizePixel=0
        bg.AutomaticSize = Enum.AutomaticSize.XY; bg.Parent = f
        Pad(bg,0,0,0,8)

        Lbl({ Text=name:upper(), TextSize=9, Font=FG, TextColor3=T.Accent,
              BackgroundTransparency=1, Size=UDim2.new(0,0,1,0),
              AutomaticSize=Enum.AutomaticSize.X,
              TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2, Parent=bg })
    end

    -- ─────────────── PARAGRAPH ───────────────
    function Tab:addParagraph(title, body)
        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1,0,0,0)
        card.AutomaticSize    = Enum.AutomaticSize.Y
        card.BackgroundColor3 = T.Card
        card.BorderSizePixel  = 0
        card.LayoutOrder      = ord()
        card.Parent           = scroll
        Corner(card, 10)
        Stroke(card, T.Border, 1)
        Pad(card, 12, 12, 14, 14)

        -- Left accent bar
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0,3,1,-24); bar.Position=UDim2.new(0,-14,0,12)
        bar.BackgroundColor3 = T.Accent; bar.BorderSizePixel=0; bar.Parent=card
        Corner(bar,2)

        local inner = Instance.new("Frame")
        inner.BackgroundTransparency=1; inner.BorderSizePixel=0
        inner.Size=UDim2.new(1,0,0,0); inner.AutomaticSize=Enum.AutomaticSize.Y
        inner.Parent=card
        List(inner,nil,5)

        local tl = Lbl({ Text=title, TextSize=13, Font=FG, TextColor3=T.TextW,
              BackgroundTransparency=1, Size=UDim2.new(1,0,0,17),
              TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=1, Parent=inner })
        local bl = Lbl({ Text=body or "", TextSize=12, Font=FL, TextColor3=T.TextM,
              BackgroundTransparency=1, Size=UDim2.new(1,0,0,0),
              AutomaticSize=Enum.AutomaticSize.Y, TextXAlignment=Enum.TextXAlignment.Left,
              TextWrapped=true, LayoutOrder=2, Parent=inner })

        local obj = {}
        function obj:set(t,b) tl.Text=t or title; bl.Text=b or body end
        return obj
    end

    -- ─────────────── BUTTON ───────────────
    function Tab:addButton(text, callback)
        local card = Btn({
            Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Card,
            ZIndex=2, Corner=10, LayoutOrder=ord(), Parent=scroll,
        })
        Stroke(card, T.Border, 1)

        -- gradient sheen on card
        local sheen = Instance.new("Frame")
        sheen.Size=UDim2.new(1,0,0,1); sheen.Position=UDim2.new(0,0,0,0)
        sheen.BackgroundColor3=T.White; sheen.BackgroundTransparency=0.92
        sheen.BorderSizePixel=0; sheen.ZIndex=3; sheen.Parent=card
        Corner(sheen,10)

        Lbl({ Text=text, TextSize=13, Font=FM, TextColor3=T.TextW,
              BackgroundTransparency=1, Size=UDim2.new(1,-50,1,0),
              Position=UDim2.new(0,16,0,0), TextXAlignment=Enum.TextXAlignment.Left,
              ZIndex=3, Parent=card })

        -- Arrow badge
        local badge = Instance.new("Frame")
        badge.Size=UDim2.new(0,26,0,26); badge.Position=UDim2.new(1,-38,0.5,-13)
        badge.BackgroundColor3=T.AccentSoft; badge.BackgroundTransparency=0.3
        badge.BorderSizePixel=0; badge.ZIndex=3; badge.Parent=card
        Corner(badge,8)
        Lbl({ Text="→", TextSize=13, Font=FG, TextColor3=T.Accent,
              BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
              TextXAlignment=Enum.TextXAlignment.Center,
              TextYAlignment=Enum.TextYAlignment.Center,
              ZIndex=4, Parent=badge })

        card.MouseEnter:Connect(function()
            TW(card, {BackgroundColor3=T.CardHover})
            TW(badge, {BackgroundTransparency=0, BackgroundColor3=T.AccentSoft})
        end)
        card.MouseLeave:Connect(function()
            TW(card, {BackgroundColor3=T.Card})
            TW(badge, {BackgroundTransparency=0.3})
        end)
        card.MouseButton1Down:Connect(function()
            TW(card, {BackgroundColor3=T.CardActive})
        end)
        card.MouseButton1Up:Connect(function()
            TW(card, {BackgroundColor3=T.CardHover})
        end)
        card.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)

        local obj = {}
        function obj:setText(t)
            for _, c in ipairs(card:GetChildren()) do
                if c:IsA("TextLabel") then c.Text = t; break end
            end
        end
        return obj
    end

    -- ─────────────── TOGGLE ───────────────
    function Tab:addToggle(id, text, default, callback)
        local state = CFG[id] ~= nil and CFG[id] or (default or false)

        local card = Btn({
            Size=UDim2.new(1,0,0,44), BackgroundColor3=T.Card,
            ZIndex=2, Corner=10, LayoutOrder=ord(), Parent=scroll,
        })
        Stroke(card, T.Border, 1)

        Lbl({ Text=text, TextSize=13, Font=FM, TextColor3=T.TextW,
              BackgroundTransparency=1, Size=UDim2.new(1,-72,1,0),
              Position=UDim2.new(0,16,0,0), TextXAlignment=Enum.TextXAlignment.Left,
              ZIndex=3, Parent=card })

        -- Toggle track
        local track = Instance.new("Frame")
        track.Size             = UDim2.new(0,44,0,24)
        track.Position         = UDim2.new(1,-56,0.5,-12)
        track.BackgroundColor3 = T.TOff
        track.BorderSizePixel  = 0
        track.ZIndex           = 3
        track.Parent           = card
        Corner(track, 12)
        Stroke(track, T.Border, 1)

        -- Track gradient when ON
        local tGrad = Gradient(track, T.Accent, T.AccentPink, 0)
        tGrad.Transparency = NumberSequence.new(1)

        -- Glow under track
        local trackGlow = Instance.new("Frame")
        trackGlow.Size             = UDim2.new(1,8,1,8)
        trackGlow.Position         = UDim2.new(0,-4,0,-4)
        trackGlow.BackgroundColor3 = T.Accent
        trackGlow.BackgroundTransparency = 1
        trackGlow.BorderSizePixel  = 0
        trackGlow.ZIndex           = 2
        trackGlow.Parent           = track
        Corner(trackGlow, 14)

        -- Knob
        local knob = Instance.new("Frame")
        knob.Size             = UDim2.new(0,18,0,18)
        knob.Position         = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        knob.BackgroundColor3 = T.TKnob
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 5
        knob.Parent           = track
        Corner(knob, 9)

        -- Knob inner glow
        local ki = Instance.new("Frame")
        ki.Size=UDim2.new(0,10,0,10); ki.Position=UDim2.new(0.5,-5,0.5,-5)
        ki.BackgroundColor3=T.Accent; ki.BackgroundTransparency=1
        ki.BorderSizePixel=0; ki.ZIndex=6; ki.Parent=knob
        Corner(ki,5)

        local function applyState(s, fire)
            state = s
            CFG[id] = s
            if s then
                TW(track, {BackgroundColor3=T.TOn})
                TW(knob,  {Position=UDim2.new(1,-21,0.5,-9), BackgroundColor3=T.White})
                TW(trackGlow, {BackgroundTransparency=0.78})
                TW(ki, {BackgroundTransparency=0.3})
                tGrad.Transparency = NumberSequence.new(0)
            else
                TW(track, {BackgroundColor3=T.TOff})
                TW(knob,  {Position=UDim2.new(0,3,0.5,-9), BackgroundColor3=T.TKnob})
                TW(trackGlow, {BackgroundTransparency=1})
                TW(ki, {BackgroundTransparency=1})
                tGrad.Transparency = NumberSequence.new(1)
            end
            if fire and callback then pcall(callback, s) end
        end

        applyState(state, false)

        card.MouseButton1Click:Connect(function() applyState(not state, true) end)
        card.MouseEnter:Connect(function()
            TW(card, {BackgroundColor3=T.CardHover})
        end)
        card.MouseLeave:Connect(function()
            TW(card, {BackgroundColor3=T.Card})
        end)

        local obj = {}
        function obj:set(v, fire) applyState(v, fire~=false) end
        function obj:get() return state end
        return obj
    end

    -- ─────────────── SLIDER ───────────────
    function Tab:addSlider(id, text, opts2, callback)
        opts2 = opts2 or {}
        local mn   = opts2.min or 0
        local mx   = opts2.max or 100
        local step = opts2.step or 1
        local sfx  = opts2.suffix or ""
        local val  = CFG[id] ~= nil and CFG[id] or (opts2.default or mn)
        val = math.clamp(val, mn, mx)

        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1,0,0,58)
        card.BackgroundColor3 = T.Card
        card.BorderSizePixel  = 0
        card.LayoutOrder      = ord()
        card.Parent           = scroll
        Corner(card, 10)
        Stroke(card, T.Border, 1)
        Pad(card, 11, 11, 16, 16)
        List(card, nil, 8)

        -- Header
        local header = Instance.new("Frame")
        header.Size=UDim2.new(1,0,0,16); header.BackgroundTransparency=1
        header.BorderSizePixel=0; header.LayoutOrder=1; header.Parent=card

        Lbl({ Text=text, TextSize=13, Font=FM, TextColor3=T.TextW,
              BackgroundTransparency=1, Size=UDim2.new(0.6,0,1,0),
              TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=header })

        -- Value pill
        local valPill = Instance.new("Frame")
        valPill.Size=UDim2.new(0,0,1,0); valPill.AutomaticSize=Enum.AutomaticSize.X
        valPill.Position=UDim2.new(1,0,0,0); valPill.AnchorPoint=Vector2.new(1,0)
        valPill.BackgroundColor3=T.AccentSoft; valPill.BackgroundTransparency=0.4
        valPill.BorderSizePixel=0; valPill.ZIndex=3; valPill.Parent=header
        Corner(valPill, 6)
        Pad(valPill, 1, 1, 6, 6)

        local valLbl = Lbl({ Text=tostring(val)..sfx, TextSize=11, Font=FG,
              TextColor3=T.AccentGlow, BackgroundTransparency=1,
              Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
              TextXAlignment=Enum.TextXAlignment.Right, ZIndex=4, Parent=valPill })

        -- Track
        local trackWrap = Instance.new("Frame")
        trackWrap.Size=UDim2.new(1,0,0,8); trackWrap.BackgroundColor3=T.Border
        trackWrap.BorderSizePixel=0; trackWrap.LayoutOrder=2; trackWrap.Parent=card
        Corner(trackWrap, 4)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0; fill.ZIndex=2; fill.Parent=trackWrap
        Corner(fill, 4)
        Gradient(fill, T.AccentGlow, T.AccentPink, 0)

        -- Fill glow
        local fillGlow = Instance.new("Frame")
        fillGlow.Size=UDim2.new(1,0,1,6); fillGlow.Position=UDim2.new(0,0,0,-3)
        fillGlow.BackgroundColor3=T.Accent; fillGlow.BackgroundTransparency=0.75
        fillGlow.BorderSizePixel=0; fillGlow.ZIndex=1; fillGlow.Parent=fill
        Corner(fillGlow,4)

        -- Thumb
        local thumb = Instance.new("Frame")
        thumb.Size=UDim2.new(0,20,0,20); thumb.AnchorPoint=Vector2.new(0.5,0.5)
        thumb.Position=UDim2.new(0,0,0.5,0)
        thumb.BackgroundColor3=T.White; thumb.BorderSizePixel=0; thumb.ZIndex=5; thumb.Parent=trackWrap
        Corner(thumb,10)
        Stroke(thumb, T.Accent, 2)

        local thumbInner = Instance.new("Frame")
        thumbInner.Size=UDim2.new(0,8,0,8); thumbInner.AnchorPoint=Vector2.new(0.5,0.5)
        thumbInner.Position=UDim2.new(0.5,0,0.5,0)
        thumbInner.BackgroundColor3=T.Accent; thumbInner.BorderSizePixel=0; thumbInner.ZIndex=6; thumbInner.Parent=thumb
        Corner(thumbInner,4)

        local function upd(v)
            val = math.clamp(math.round((v-mn)/step)*step+mn, mn, mx)
            local pct = (val-mn)/(mx-mn)
            fill.Size = UDim2.new(pct,0,1,0)
            thumb.Position = UDim2.new(pct,0,0.5,0)
            valLbl.Text = tostring(val)..sfx
            CFG[id] = val
            if callback then pcall(callback, val) end
        end
        upd(val)

        local drag2 = false
        trackWrap.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag2=true
                TW(thumb, {Size=UDim2.new(0,22,0,22)})
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag2 and i.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = trackWrap.AbsolutePosition; local sz = trackWrap.AbsoluteSize
                upd(mn + math.clamp((i.Position.X-abs.X)/sz.X,0,1)*(mx-mn))
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag2=false
                TW(thumb, {Size=UDim2.new(0,20,0,20)})
            end
        end)

        local obj = {}
        function obj:set(v) upd(v) end
        function obj:get() return val end
        return obj
    end

    -- ─────────────── DROPDOWN (single) ───────────────
    local function buildDropdown(id, text, items, callback, multi)
        local selected  = multi and (CFG[id] or {}) or (CFG[id] or items[1] or "")
        local open      = false
        local ITEM_H    = 32

        local wrapper = Instance.new("Frame")
        wrapper.Size=UDim2.new(1,0,0,44); wrapper.BackgroundTransparency=1
        wrapper.BorderSizePixel=0; wrapper.LayoutOrder=ord()
        wrapper.ClipsDescendants=false; wrapper.ZIndex=5; wrapper.Parent=scroll

        local header = Instance.new("Frame")
        header.Size=UDim2.new(1,0,0,44); header.BackgroundColor3=T.Card
        header.BorderSizePixel=0; header.ZIndex=5; header.Parent=wrapper
        Corner(header,10); Stroke(header,T.Border,1)

        Lbl({ Text=text, TextSize=13, Font=FM, TextColor3=T.TextW,
              BackgroundTransparency=1, Size=UDim2.new(0.45,0,1,0),
              Position=UDim2.new(0,16,0,0), TextXAlignment=Enum.TextXAlignment.Left,
              ZIndex=6, Parent=header })

        local selLbl = Lbl({ Text="", TextSize=11, Font=FM, TextColor3=T.AccentGlow,
              BackgroundTransparency=1, Size=UDim2.new(0.45,0,1,0),
              Position=UDim2.new(0.45,0,0,0), TextXAlignment=Enum.TextXAlignment.Right,
              ZIndex=6, Parent=header })

        -- Chevron
        local chevFrame = Instance.new("Frame")
        chevFrame.Size=UDim2.new(0,22,0,22); chevFrame.Position=UDim2.new(1,-34,0.5,-11)
        chevFrame.BackgroundColor3=T.AccentSoft; chevFrame.BackgroundTransparency=0.5
        chevFrame.BorderSizePixel=0; chevFrame.ZIndex=6; chevFrame.Parent=header
        Corner(chevFrame,6)
        local chev = Lbl({ Text="⌄", TextSize=11, Font=FG, TextColor3=T.Accent,
              BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
              TextXAlignment=Enum.TextXAlignment.Center,
              TextYAlignment=Enum.TextYAlignment.Center,
              ZIndex=7, Parent=chevFrame })

        -- Panel
        local panel = Instance.new("Frame")
        panel.Size=UDim2.new(1,0,0,0); panel.Position=UDim2.new(0,0,1,6)
        panel.BackgroundColor3=T.BG2; panel.BorderSizePixel=0
        panel.ClipsDescendants=true; panel.ZIndex=20; panel.Visible=false; panel.Parent=wrapper
        Corner(panel,10); Stroke(panel,T.BorderHover,1)
        List(panel,nil,2); Pad(panel,4,4,4,4)

        local function getSelText()
            if multi then
                return #selected==0 and "None" or (#selected.." selected")
            else return selected end
        end
        selLbl.Text = getSelText()

        local function isIn(item)
            if not multi then return false end
            for _,v in ipairs(selected) do if v==item then return true end end
            return false
        end

        local function rebuildPanel()
            for _,c in ipairs(panel:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
            end

            for i, item in ipairs(items) do
                local sel = multi and isIn(item) or (item==selected)
                local row = Btn({
                    Size=UDim2.new(1,0,0,ITEM_H), BackgroundColor3=sel and T.CardActive or T.BG2,
                    BackgroundTransparency=sel and 0 or 1,
                    ZIndex=21, Corner=7, LayoutOrder=i, Parent=panel,
                })

                if multi then
                    -- Checkbox
                    local cb = Instance.new("Frame")
                    cb.Size=UDim2.new(0,14,0,14); cb.Position=UDim2.new(0,8,0.5,-7)
                    cb.BackgroundColor3=sel and T.Accent or T.TOff
                    cb.BorderSizePixel=0; cb.ZIndex=23; cb.Parent=row
                    Corner(cb,4)
                    if sel then
                        Stroke(cb,T.AccentGlow,1)
                        Lbl({ Text="✓", TextSize=9, Font=FG, TextColor3=T.White,
                              BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                              TextXAlignment=Enum.TextXAlignment.Center,
                              TextYAlignment=Enum.TextYAlignment.Center,
                              ZIndex=24, Parent=cb })
                    end
                    Lbl({ Text=item, TextSize=12, Font=FM,
                          TextColor3=sel and T.TextW or T.TextM,
                          BackgroundTransparency=1, Size=UDim2.new(1,-32,1,0),
                          Position=UDim2.new(0,28,0,0), TextXAlignment=Enum.TextXAlignment.Left,
                          ZIndex=22, Parent=row })
                else
                    -- Dot
                    if sel then
                        local dot = Instance.new("Frame")
                        dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,9,0.5,-3)
                        dot.BackgroundColor3=T.Accent; dot.BorderSizePixel=0; dot.ZIndex=23; dot.Parent=row
                        Corner(dot,3)
                    end
                    Lbl({ Text=item, TextSize=12, Font=FM,
                          TextColor3=sel and T.TextW or T.TextM,
                          BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0),
                          Position=UDim2.new(0,20,0,0), TextXAlignment=Enum.TextXAlignment.Left,
                          ZIndex=22, Parent=row })
                end

                row.MouseEnter:Connect(function()
                    if not sel then TW(row,{BackgroundTransparency=0.75,BackgroundColor3=T.CardHover}) end
                end)
                row.MouseLeave:Connect(function()
                    if not sel then TW(row,{BackgroundTransparency=1}) end
                end)
                row.MouseButton1Click:Connect(function()
                    if multi then
                        if isIn(item) then
                            for j,v in ipairs(selected) do if v==item then table.remove(selected,j) break end end
                        else table.insert(selected,item) end
                        CFG[id]=selected
                        selLbl.Text=getSelText()
                        if callback then pcall(callback,selected) end
                        rebuildPanel()
                    else
                        selected=item; CFG[id]=selected
                        selLbl.Text=selected
                        open=false
                        TW(panel,{Size=UDim2.new(1,0,0,0)})
                        TW(chev,{Rotation=0}); TW(chevFrame,{BackgroundTransparency=0.5})
                        task.delay(0.22, function() panel.Visible=false; wrapper.Size=UDim2.new(1,0,0,44) end)
                        rebuildPanel()
                        if callback then pcall(callback,selected) end
                    end
                end)
            end

            local total = #items*(ITEM_H+2)+8
            return math.min(total, 5*(ITEM_H+2)+8)
        end

        local function togglePanel()
            open=not open
            local h=rebuildPanel()
            panel.Visible=true
            if open then
                TW(panel,{Size=UDim2.new(1,0,0,h)})
                TW(chev,{Rotation=180}); TW(chevFrame,{BackgroundTransparency=0.2})
                wrapper.Size=UDim2.new(1,0,0,44+h+8)
            else
                TW(panel,{Size=UDim2.new(1,0,0,0)})
                TW(chev,{Rotation=0}); TW(chevFrame,{BackgroundTransparency=0.5})
                task.delay(0.22,function() panel.Visible=false; wrapper.Size=UDim2.new(1,0,0,44) end)
            end
        end

        header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then togglePanel() end
        end)
        header.MouseEnter:Connect(function() TW(header,{BackgroundColor3=T.CardHover}) end)
        header.MouseLeave:Connect(function() TW(header,{BackgroundColor3=T.Card}) end)

        rebuildPanel()

        local obj = {}
        function obj:get() return selected end
        function obj:set(v)
            if multi then selected=v else selected=v; selLbl.Text=v end
            CFG[id]=selected; selLbl.Text=getSelText(); rebuildPanel()
        end
        function obj:setItems(ni) items=ni; rebuildPanel() end
        return obj
    end

    function Tab:addDropdown(id, text, items, callback)
        return buildDropdown(id, text, items, callback, false)
    end
    function Tab:addMultiDropdown(id, text, items, callback)
        return buildDropdown(id, text, items, callback, true)
    end

    -- ─────────────── SAVE CONFIG ───────────────
    function Tab:addSaveConfig(filename)
        filename = filename or CONFIG_FILE

        local card = Instance.new("Frame")
        card.Size=UDim2.new(1,0,0,50); card.BackgroundColor3=T.Card
        card.BorderSizePixel=0; card.LayoutOrder=ord(); card.Parent=scroll
        Corner(card,10); Stroke(card,T.Border,1)
        Pad(card,7,7,12,12)
        List(card,nil,6)

        local row = Instance.new("Frame")
        row.Size=UDim2.new(1,0,0,30); row.BackgroundTransparency=1
        row.BorderSizePixel=0; row.LayoutOrder=1; row.Parent=card

        local function mkBtn(lbl, xscale, xoff, bgcol, strokecol)
            local b = Btn({
                Size=UDim2.new(xscale,-4,1,0), Position=UDim2.new(xoff and 0.5 or 0, xoff or 0,0,0),
                BackgroundColor3=bgcol, ZIndex=3, Corner=8,
                Stroke={strokecol,1,0.3},
                Parent=row,
            })
            Lbl({ Text=lbl, TextSize=12, Font=FM, TextColor3=T.TextW,
                  BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                  TextXAlignment=Enum.TextXAlignment.Center,
                  ZIndex=4, Parent=b })
            b.MouseEnter:Connect(function() TW(b,{BackgroundTransparency=0.2}) end)
            b.MouseLeave:Connect(function() TW(b,{BackgroundTransparency=0}) end)
            return b
        end

        local saveB = mkBtn("💾  Save", 0.5, nil, T.AccentSoft, T.Accent)
        local loadB = mkBtn("📂  Load", 0.5, 2, T.Card, T.Border)
        loadB.Position = UDim2.new(0.5,4,0,0)

        local statusLbl = Lbl({ Text="", TextSize=10, Font=FM, TextColor3=T.Green,
              BackgroundTransparency=1, Size=UDim2.new(1,0,0,12),
              TextXAlignment=Enum.TextXAlignment.Center,
              LayoutOrder=2, Parent=card })

        local function flash(msg, col)
            statusLbl.Text=msg; statusLbl.TextColor3=col or T.Green
            task.delay(2.5, function() statusLbl.Text="" end)
        end

        saveB.MouseButton1Click:Connect(function()
            local ok,err=pcall(function()
                writefile(filename, HttpService:JSONEncode(CFG))
            end)
            flash(ok and "✓ Config saved to "..filename or "✗ "..tostring(err), ok and T.Green or T.Red)
        end)
        loadB.MouseButton1Click:Connect(function()
            local ok,err=pcall(cfgLoad)
            flash(ok and "✓ Config loaded" or "✗ "..tostring(err), ok and T.Green or T.Red)
        end)
    end

    return Tab
end

-- ╔══════════════════════════════════════╗
-- ║          TAB SELECTION               ║
-- ╚══════════════════════════════════════╝
function SpinachUI:_selectTab(tabData)
    for _, t in ipairs(self._tabs) do
        t.scroll.Visible = false
        TW(t.btn,    {BackgroundTransparency=1})
        TW(t.lbl,    {TextColor3=T.TextD})
        TW(t.icon,   {TextColor3=T.TextD})
        TW(t.stripe, {BackgroundTransparency=1})
    end
    tabData.scroll.Visible = true
    TW(tabData.btn,    {BackgroundTransparency=0.75, BackgroundColor3=T.SideActive})
    TW(tabData.lbl,    {TextColor3=T.TextW})
    TW(tabData.icon,   {TextColor3=T.Accent})
    TW(tabData.stripe, {BackgroundTransparency=0})
    self._activeTab = tabData
end

function SpinachUI:destroy()
    self._sg:Destroy()
end

return SpinachUI
