--[[
    SpinachUI — Roblox Executor UI Library
    Components: Toggle, Button, Paragraph, Slider, Dropdown, Multiselect, SaveConfig
]]

local SpinachUI = {}
SpinachUI.__index = SpinachUI

-- Services
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- Theme
local THEME = {
    Background      = Color3.fromRGB(13, 13, 18),
    Surface         = Color3.fromRGB(20, 20, 28),
    SurfaceHover    = Color3.fromRGB(26, 26, 36),
    SurfaceAlt      = Color3.fromRGB(16, 16, 22),
    Border          = Color3.fromRGB(38, 38, 52),
    BorderHover     = Color3.fromRGB(90, 90, 120),
    Accent          = Color3.fromRGB(120, 80, 255),
    AccentDim       = Color3.fromRGB(70, 45, 160),
    AccentGlow      = Color3.fromRGB(140, 100, 255),
    TextPrimary     = Color3.fromRGB(230, 230, 240),
    TextSecondary   = Color3.fromRGB(130, 130, 155),
    TextDisabled    = Color3.fromRGB(70, 70, 90),
    Success         = Color3.fromRGB(80, 220, 140),
    Danger          = Color3.fromRGB(255, 80, 100),
    SliderFill      = Color3.fromRGB(120, 80, 255),
    ToggleOff       = Color3.fromRGB(50, 50, 65),
    ToggleOn        = Color3.fromRGB(120, 80, 255),
    TitleBar        = Color3.fromRGB(16, 16, 23),
    Shadow          = Color3.fromRGB(0, 0, 0),
}

local FONT        = Enum.Font.GothamBold
local FONT_SEMI   = Enum.Font.Gotham
local FONT_LIGHT  = Enum.Font.GothamSemibold
local TWEEN_FAST  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED   = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Utility
local function tween(obj, props, info)
    TweenService:Create(obj, info or TWEEN_FAST, props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color       = color or THEME.Border
    s.Thickness   = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function makePadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.Parent = parent
    return p
end

local function newLabel(text, size, color, font, parent)
    local l = Instance.new("TextLabel")
    l.Text              = text
    l.TextSize          = size or 13
    l.TextColor3        = color or THEME.TextPrimary
    l.Font              = font or FONT_SEMI
    l.BackgroundTransparency = 1
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.TextYAlignment    = Enum.TextYAlignment.Center
    l.Size              = UDim2.new(1, 0, 1, 0)
    l.Parent            = parent
    return l
end

-- Config persistence (writefile/readfile executor API)
local CONFIG_PATH = "SpinachUI_Config.json"
local configData  = {}

local function loadConfig()
    local ok, raw = pcall(readfile, CONFIG_PATH)
    if ok and raw and raw ~= "" then
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok2 then configData = data end
    end
end

local function saveConfig()
    local ok, str = pcall(HttpService.JSONEncode, HttpService, configData)
    if ok then pcall(writefile, CONFIG_PATH, str) end
end

pcall(loadConfig)

-- ============================================================
-- WINDOW
-- ============================================================

function SpinachUI.new(options)
    options = options or {}
    local self = setmetatable({}, SpinachUI)
    self._tabs      = {}
    self._activeTab = nil
    self._open      = true

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name             = options.Name or "SpinachUI"
    sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn     = false
    sg.DisplayOrder     = 999
    sg.IgnoreGuiInset   = true

    -- Try getsenv exploit method, fallback to CoreGui or PlayerGui
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Shadow frame
    local shadow = Instance.new("Frame")
    shadow.Name             = "Shadow"
    shadow.Size             = UDim2.new(0, 556, 0, 406)
    shadow.Position         = UDim2.new(0.5, -280, 0.5, -200)
    shadow.BackgroundColor3 = THEME.Shadow
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel  = 0
    shadow.ZIndex           = 0
    shadow.Parent           = sg
    makeCorner(shadow, 14)

    -- Main frame
    local main = Instance.new("Frame")
    main.Name             = "Main"
    main.Size             = UDim2.new(0, 550, 0, 400)
    main.Position         = UDim2.new(0.5, -275, 0.5, -200)
    main.BackgroundColor3 = THEME.Background
    main.BorderSizePixel  = 0
    main.ClipsDescendants = true
    main.ZIndex           = 1
    main.Parent           = sg
    makeCorner(main, 12)
    makeStroke(main, THEME.Border, 1)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = THEME.TitleBar
    titleBar.BorderSizePixel  = 0
    titleBar.ZIndex           = 2
    titleBar.Parent           = main

    local titleAccent = Instance.new("Frame")
    titleAccent.Size             = UDim2.new(0, 3, 0, 22)
    titleAccent.Position         = UDim2.new(0, 14, 0.5, -11)
    titleAccent.BackgroundColor3 = THEME.Accent
    titleAccent.BorderSizePixel  = 0
    titleAccent.Parent           = titleBar
    makeCorner(titleAccent, 4)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text              = options.Title or "SpinachUI"
    titleLabel.TextSize          = 15
    titleLabel.Font              = FONT
    titleLabel.TextColor3        = THEME.TextPrimary
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position          = UDim2.new(0, 26, 0, 0)
    titleLabel.Size              = UDim2.new(0.6, 0, 1, 0)
    titleLabel.TextXAlignment    = Enum.TextXAlignment.Left
    titleLabel.ZIndex            = 3
    titleLabel.Parent            = titleBar

    local subLabel = Instance.new("TextLabel")
    subLabel.Text              = options.Subtitle or "executor ui"
    subLabel.TextSize          = 11
    subLabel.Font              = FONT_SEMI
    subLabel.TextColor3        = THEME.TextSecondary
    subLabel.BackgroundTransparency = 1
    subLabel.Position          = UDim2.new(0, 28, 0.52, 0)
    subLabel.Size              = UDim2.new(0.5, 0, 0.4, 0)
    subLabel.TextXAlignment    = Enum.TextXAlignment.Left
    subLabel.ZIndex            = 3
    subLabel.Parent            = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size              = UDim2.new(0, 28, 0, 28)
    closeBtn.Position          = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundColor3  = Color3.fromRGB(255, 70, 90)
    closeBtn.Text              = ""
    closeBtn.ZIndex            = 3
    closeBtn.Parent            = titleBar
    makeCorner(closeBtn, 6)

    local closeX = Instance.new("TextLabel")
    closeX.Text           = "×"
    closeX.TextSize       = 16
    closeX.Font           = FONT
    closeX.TextColor3     = Color3.fromRGB(255, 255, 255)
    closeX.BackgroundTransparency = 1
    closeX.Size           = UDim2.new(1, 0, 1, 0)
    closeX.TextXAlignment = Enum.TextXAlignment.Center
    closeX.TextYAlignment = Enum.TextYAlignment.Center
    closeX.ZIndex         = 4
    closeX.Parent         = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        self._open = not self._open
        tween(main, { Size = self._open and UDim2.new(0, 550, 0, 400) or UDim2.new(0, 550, 0, 44) }, TWEEN_MED)
    end)

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size             = UDim2.new(0, 28, 0, 28)
    minBtn.Position         = UDim2.new(1, -72, 0.5, -14)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
    minBtn.Text             = ""
    minBtn.ZIndex           = 3
    minBtn.Parent           = titleBar
    makeCorner(minBtn, 6)

    local minIcon = Instance.new("TextLabel")
    minIcon.Text           = "–"
    minIcon.TextSize       = 16
    minIcon.Font           = FONT
    minIcon.TextColor3     = Color3.fromRGB(255, 255, 255)
    minIcon.BackgroundTransparency = 1
    minIcon.Size           = UDim2.new(1, 0, 1, 0)
    minIcon.TextXAlignment = Enum.TextXAlignment.Center
    minIcon.TextYAlignment = Enum.TextYAlignment.Center
    minIcon.ZIndex         = 4
    minIcon.Parent         = minBtn

    minBtn.MouseButton1Click:Connect(function()
        sg.Enabled = false
        local conn
        conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.RightControl then
                sg.Enabled = true
                conn:Disconnect()
            end
        end)
    end)

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            shadow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X + 3,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y + 3
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Name             = "TabBar"
    tabBar.Size             = UDim2.new(0, 140, 1, -44)
    tabBar.Position         = UDim2.new(0, 0, 0, 44)
    tabBar.BackgroundColor3 = THEME.SurfaceAlt
    tabBar.BorderSizePixel  = 0
    tabBar.ZIndex           = 2
    tabBar.Parent           = main

    local tabDivider = Instance.new("Frame")
    tabDivider.Size             = UDim2.new(0, 1, 1, 0)
    tabDivider.Position         = UDim2.new(1, 0, 0, 0)
    tabDivider.BackgroundColor3 = THEME.Border
    tabDivider.BorderSizePixel  = 0
    tabDivider.Parent           = tabBar

    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder       = Enum.SortOrder.LayoutOrder
    tabList.Padding         = UDim.new(0, 4)
    tabList.Parent          = tabBar
    makePadding(tabBar, 10, 10, 8, 8)

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name             = "ContentArea"
    contentArea.Size             = UDim2.new(1, -140, 1, -44)
    contentArea.Position         = UDim2.new(0, 140, 0, 44)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel  = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent           = main

    self._sg          = sg
    self._main        = main
    self._tabBar      = tabBar
    self._contentArea = contentArea

    return self
end

-- ============================================================
-- TAB
-- ============================================================

function SpinachUI:addTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size             = UDim2.new(1, 0, 0, 34)
    tabButton.BackgroundColor3 = THEME.Surface
    tabButton.BackgroundTransparency = 1
    tabButton.Text             = ""
    tabButton.ZIndex           = 3
    tabButton.LayoutOrder      = #self._tabs + 1
    tabButton.Parent           = self._tabBar
    makeCorner(tabButton, 7)

    local tabLabel = Instance.new("TextLabel")
    tabLabel.Text              = name
    tabLabel.TextSize          = 12
    tabLabel.Font              = FONT_SEMI
    tabLabel.TextColor3        = THEME.TextSecondary
    tabLabel.BackgroundTransparency = 1
    tabLabel.Size              = UDim2.new(1, -8, 1, 0)
    tabLabel.Position          = UDim2.new(0, 8, 0, 0)
    tabLabel.TextXAlignment    = Enum.TextXAlignment.Left
    tabLabel.ZIndex            = 4
    tabLabel.Parent            = tabButton

    local tabIndicator = Instance.new("Frame")
    tabIndicator.Size             = UDim2.new(0, 3, 0, 16)
    tabIndicator.Position         = UDim2.new(0, 0, 0.5, -8)
    tabIndicator.BackgroundColor3 = THEME.Accent
    tabIndicator.BackgroundTransparency = 1
    tabIndicator.BorderSizePixel  = 0
    tabIndicator.ZIndex           = 5
    tabIndicator.Parent           = tabButton
    makeCorner(tabIndicator, 3)

    -- Scroll frame for content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size             = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel  = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = THEME.Accent
    scrollFrame.CanvasSize       = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Visible          = false
    scrollFrame.ZIndex           = 2
    scrollFrame.Parent           = self._contentArea

    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder  = Enum.SortOrder.LayoutOrder
    contentList.Padding    = UDim.new(0, 6)
    contentList.Parent     = scrollFrame
    makePadding(scrollFrame, 12, 12, 14, 14)

    local tabData = {
        name     = name,
        button   = tabButton,
        label    = tabLabel,
        indicator = tabIndicator,
        scroll   = scrollFrame,
        order    = 0,
    }

    table.insert(self._tabs, tabData)

    tabButton.MouseButton1Click:Connect(function()
        self:_selectTab(tabData)
    end)

    tabButton.MouseEnter:Connect(function()
        if self._activeTab ~= tabData then
            tween(tabButton, { BackgroundTransparency = 0.7 })
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if self._activeTab ~= tabData then
            tween(tabButton, { BackgroundTransparency = 1 })
        end
    end)

    if #self._tabs == 1 then
        self:_selectTab(tabData)
    end

    -- Return section builder
    local Tab = {}

    local function nextOrder()
        tabData.order = tabData.order + 1
        return tabData.order
    end

    -- ──────────────── SECTION ────────────────
    function Tab:addSection(sectionName)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size             = UDim2.new(1, 0, 0, 28)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.BorderSizePixel  = 0
        sectionFrame.LayoutOrder      = nextOrder()
        sectionFrame.Parent           = scrollFrame

        local sLine = Instance.new("Frame")
        sLine.Size             = UDim2.new(1, 0, 0, 1)
        sLine.Position         = UDim2.new(0, 0, 0.5, 0)
        sLine.BackgroundColor3 = THEME.Border
        sLine.BorderSizePixel  = 0
        sLine.Parent           = sectionFrame

        local sBg = Instance.new("Frame")
        sBg.Size             = UDim2.new(0, 0, 1, 0)
        sBg.Position         = UDim2.new(0, 0, 0, 0)
        sBg.BackgroundColor3 = THEME.Background
        sBg.BorderSizePixel  = 0
        sBg.AutomaticSize    = Enum.AutomaticSize.X
        sBg.Parent           = sectionFrame
        makePadding(sBg, 0, 0, 0, 8)

        local sLabel = Instance.new("TextLabel")
        sLabel.Text              = sectionName:upper()
        sLabel.TextSize          = 10
        sLabel.Font              = FONT
        sLabel.TextColor3        = THEME.Accent
        sLabel.BackgroundTransparency = 1
        sLabel.Size              = UDim2.new(0, 0, 1, 0)
        sLabel.AutomaticSize     = Enum.AutomaticSize.X
        sLabel.TextXAlignment    = Enum.TextXAlignment.Left
        sLabel.Parent            = sBg
    end

    -- ──────────────── PARAGRAPH ────────────────
    function Tab:addParagraph(title, body)
        local frame = Instance.new("Frame")
        frame.Size             = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize   = Enum.AutomaticSize.Y
        frame.BackgroundColor3 = THEME.Surface
        frame.BorderSizePixel  = 0
        frame.LayoutOrder      = nextOrder()
        frame.Parent           = scrollFrame
        makeCorner(frame, 8)
        makeStroke(frame, THEME.Border)
        makePadding(frame, 10, 10, 12, 12)

        local innerList = Instance.new("UIListLayout")
        innerList.SortOrder = Enum.SortOrder.LayoutOrder
        innerList.Padding   = UDim.new(0, 4)
        innerList.Parent    = frame

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Text              = title
        titleLbl.TextSize          = 13
        titleLbl.Font              = FONT
        titleLbl.TextColor3        = THEME.TextPrimary
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size              = UDim2.new(1, 0, 0, 18)
        titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
        titleLbl.LayoutOrder       = 1
        titleLbl.Parent            = frame

        local bodyLbl = Instance.new("TextLabel")
        bodyLbl.Text              = body or ""
        bodyLbl.TextSize          = 12
        bodyLbl.Font              = FONT_SEMI
        bodyLbl.TextColor3        = THEME.TextSecondary
        bodyLbl.BackgroundTransparency = 1
        bodyLbl.Size              = UDim2.new(1, 0, 0, 0)
        bodyLbl.AutomaticSize    = Enum.AutomaticSize.Y
        bodyLbl.TextXAlignment   = Enum.TextXAlignment.Left
        bodyLbl.TextWrapped      = true
        bodyLbl.LayoutOrder      = 2
        bodyLbl.Parent           = frame

        local ParagraphObj = {}
        function ParagraphObj:set(newTitle, newBody)
            titleLbl.Text = newTitle or title
            bodyLbl.Text  = newBody  or body
        end
        return ParagraphObj
    end

    -- ──────────────── BUTTON ────────────────
    function Tab:addButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = THEME.Surface
        btn.Text             = ""
        btn.BorderSizePixel  = 0
        btn.LayoutOrder      = nextOrder()
        btn.Parent           = scrollFrame
        makeCorner(btn, 8)
        makeStroke(btn, THEME.Border)

        local label = Instance.new("TextLabel")
        label.Text              = text
        label.TextSize          = 13
        label.Font              = FONT_SEMI
        label.TextColor3        = THEME.TextPrimary
        label.BackgroundTransparency = 1
        label.Size              = UDim2.new(1, -36, 1, 0)
        label.Position          = UDim2.new(0, 14, 0, 0)
        label.TextXAlignment    = Enum.TextXAlignment.Left
        label.Parent            = btn

        local arrow = Instance.new("TextLabel")
        arrow.Text              = "›"
        arrow.TextSize          = 18
        arrow.Font              = FONT
        arrow.TextColor3        = THEME.Accent
        arrow.BackgroundTransparency = 1
        arrow.Size              = UDim2.new(0, 24, 1, 0)
        arrow.Position          = UDim2.new(1, -30, 0, 0)
        arrow.TextXAlignment    = Enum.TextXAlignment.Center
        arrow.Parent            = btn

        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = THEME.SurfaceHover })
            tween(arrow, { TextColor3 = THEME.AccentGlow })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = THEME.Surface })
            tween(arrow, { TextColor3 = THEME.Accent })
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, { BackgroundColor3 = THEME.AccentDim })
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, { BackgroundColor3 = THEME.SurfaceHover })
        end)
        btn.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[SpinachUI] Button callback error:", err) end
            end
        end)

        local BtnObj = {}
        function BtnObj:setText(t) label.Text = t end
        function BtnObj:setCallback(fn) callback = fn end
        return BtnObj
    end

    -- ──────────────── TOGGLE ────────────────
    function Tab:addToggle(id, text, default, callback)
        local state = configData[id] ~= nil and configData[id] or (default or false)

        local frame = Instance.new("TextButton")
        frame.Size             = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = THEME.Surface
        frame.Text             = ""
        frame.BorderSizePixel  = 0
        frame.LayoutOrder      = nextOrder()
        frame.Parent           = scrollFrame
        makeCorner(frame, 8)
        makeStroke(frame, THEME.Border)

        local label = Instance.new("TextLabel")
        label.Text              = text
        label.TextSize          = 13
        label.Font              = FONT_SEMI
        label.TextColor3        = THEME.TextPrimary
        label.BackgroundTransparency = 1
        label.Size              = UDim2.new(1, -60, 1, 0)
        label.Position          = UDim2.new(0, 14, 0, 0)
        label.TextXAlignment    = Enum.TextXAlignment.Left
        label.Parent            = frame

        -- Track background
        local trackBg = Instance.new("Frame")
        trackBg.Size             = UDim2.new(0, 36, 0, 20)
        trackBg.Position         = UDim2.new(1, -48, 0.5, -10)
        trackBg.BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff
        trackBg.BorderSizePixel  = 0
        trackBg.Parent           = frame
        makeCorner(trackBg, 12)

        -- Knob
        local knob = Instance.new("Frame")
        knob.Size             = UDim2.new(0, 14, 0, 14)
        knob.Position         = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel  = 0
        knob.Parent           = trackBg
        makeCorner(knob, 10)

        local function applyState(s, fire)
            state = s
            tween(trackBg, { BackgroundColor3 = s and THEME.ToggleOn or THEME.ToggleOff })
            tween(knob, { Position = s and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
            configData[id] = s
            if fire and callback then
                local ok, err = pcall(callback, s)
                if not ok then warn("[SpinachUI] Toggle callback error:", err) end
            end
        end

        applyState(state, false)

        frame.MouseButton1Click:Connect(function()
            applyState(not state, true)
        end)

        frame.MouseEnter:Connect(function()
            tween(frame, { BackgroundColor3 = THEME.SurfaceHover })
        end)
        frame.MouseLeave:Connect(function()
            tween(frame, { BackgroundColor3 = THEME.Surface })
        end)

        local ToggleObj = {}
        function ToggleObj:set(val, fire)
            applyState(val, fire ~= false)
        end
        function ToggleObj:get() return state end
        return ToggleObj
    end

    -- ──────────────── SLIDER ────────────────
    function Tab:addSlider(id, text, options, callback)
        options = options or {}
        local min     = options.min or 0
        local max     = options.max or 100
        local step    = options.step or 1
        local suffix  = options.suffix or ""
        local default = configData[id] ~= nil and configData[id] or (options.default or min)
        local value   = math.clamp(default, min, max)

        local frame = Instance.new("Frame")
        frame.Size             = UDim2.new(1, 0, 0, 52)
        frame.BackgroundColor3 = THEME.Surface
        frame.BorderSizePixel  = 0
        frame.LayoutOrder      = nextOrder()
        frame.Parent           = scrollFrame
        makeCorner(frame, 8)
        makeStroke(frame, THEME.Border)
        makePadding(frame, 10, 10, 14, 14)

        local innerList = Instance.new("UIListLayout")
        innerList.SortOrder = Enum.SortOrder.LayoutOrder
        innerList.Padding   = UDim.new(0, 6)
        innerList.Parent    = frame

        -- Header row
        local headerRow = Instance.new("Frame")
        headerRow.Size             = UDim2.new(1, 0, 0, 16)
        headerRow.BackgroundTransparency = 1
        headerRow.BorderSizePixel  = 0
        headerRow.LayoutOrder      = 1
        headerRow.Parent           = frame

        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Text              = text
        sliderLabel.TextSize          = 13
        sliderLabel.Font              = FONT_SEMI
        sliderLabel.TextColor3        = THEME.TextPrimary
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Size              = UDim2.new(0.7, 0, 1, 0)
        sliderLabel.TextXAlignment    = Enum.TextXAlignment.Left
        sliderLabel.Parent            = headerRow

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text              = tostring(value) .. suffix
        valueLabel.TextSize          = 12
        valueLabel.Font              = FONT
        valueLabel.TextColor3        = THEME.Accent
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size              = UDim2.new(0.3, 0, 1, 0)
        valueLabel.Position          = UDim2.new(0.7, 0, 0, 0)
        valueLabel.TextXAlignment    = Enum.TextXAlignment.Right
        valueLabel.Parent            = headerRow

        -- Track
        local trackFrame = Instance.new("Frame")
        trackFrame.Size             = UDim2.new(1, 0, 0, 16)
        trackFrame.BackgroundColor3 = THEME.Border
        trackFrame.BorderSizePixel  = 0
        trackFrame.LayoutOrder      = 2
        trackFrame.Parent           = frame
        makeCorner(trackFrame, 8)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = THEME.SliderFill
        fill.BorderSizePixel  = 0
        fill.Parent           = trackFrame
        makeCorner(fill, 8)

        local thumb = Instance.new("Frame")
        thumb.Size             = UDim2.new(0, 16, 0, 16)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel  = 0
        thumb.ZIndex           = 3
        thumb.Parent           = trackFrame
        makeCorner(thumb, 10)
        makeStroke(thumb, THEME.Accent, 2)

        local function updateSlider(v)
            value = math.clamp(math.round((v - min) / step) * step + min, min, max)
            local pct = (value - min) / (max - min)
            fill.Size     = UDim2.new(pct, 0, 1, 0)
            thumb.Position = UDim2.new(pct, -8, 0, 0)
            valueLabel.Text = tostring(value) .. suffix
            configData[id] = value
            if callback then
                local ok, err = pcall(callback, value)
                if not ok then warn("[SpinachUI] Slider callback error:", err) end
            end
        end

        updateSlider(value)

        local draggingSlider = false

        trackFrame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)

        UserInputService.InputChanged:Connect(function(inp)
            if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local tf_abs = trackFrame.AbsolutePosition
                local tf_sz  = trackFrame.AbsoluteSize
                local pct    = math.clamp((inp.Position.X - tf_abs.X) / tf_sz.X, 0, 1)
                local newVal = min + pct * (max - min)
                updateSlider(newVal)
            end
        end)

        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)

        local SliderObj = {}
        function SliderObj:set(v) updateSlider(v) end
        function SliderObj:get() return value end
        return SliderObj
    end

    -- ──────────────── DROPDOWN ────────────────
    function Tab:addDropdown(id, text, items, callback)
        local selected = configData[id] or items[1] or ""
        local open     = false

        local wrapper = Instance.new("Frame")
        wrapper.Size             = UDim2.new(1, 0, 0, 36)
        wrapper.BackgroundTransparency = 1
        wrapper.BorderSizePixel  = 0
        wrapper.LayoutOrder      = nextOrder()
        wrapper.ClipsDescendants = false
        wrapper.ZIndex           = 5
        wrapper.Parent           = scrollFrame

        local mainFrame = Instance.new("Frame")
        mainFrame.Size             = UDim2.new(1, 0, 0, 36)
        mainFrame.BackgroundColor3 = THEME.Surface
        mainFrame.BorderSizePixel  = 0
        mainFrame.ZIndex           = 5
        mainFrame.Parent           = wrapper
        makeCorner(mainFrame, 8)
        makeStroke(mainFrame, THEME.Border)

        local ddLabel = Instance.new("TextLabel")
        ddLabel.Text              = text
        ddLabel.TextSize          = 13
        ddLabel.Font              = FONT_SEMI
        ddLabel.TextColor3        = THEME.TextPrimary
        ddLabel.BackgroundTransparency = 1
        ddLabel.Size              = UDim2.new(0.45, 0, 1, 0)
        ddLabel.Position          = UDim2.new(0, 14, 0, 0)
        ddLabel.TextXAlignment    = Enum.TextXAlignment.Left
        ddLabel.ZIndex            = 6
        ddLabel.Parent            = mainFrame

        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.Text              = selected
        selectedLabel.TextSize          = 12
        selectedLabel.Font              = FONT_SEMI
        selectedLabel.TextColor3        = THEME.Accent
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Size              = UDim2.new(0.45, 0, 1, 0)
        selectedLabel.Position          = UDim2.new(0.45, 0, 0, 0)
        selectedLabel.TextXAlignment    = Enum.TextXAlignment.Right
        selectedLabel.ZIndex            = 6
        selectedLabel.Parent            = mainFrame

        local chevron = Instance.new("TextLabel")
        chevron.Text              = "⌄"
        chevron.TextSize          = 14
        chevron.Font              = FONT
        chevron.TextColor3        = THEME.TextSecondary
        chevron.BackgroundTransparency = 1
        chevron.Size              = UDim2.new(0, 24, 1, 0)
        chevron.Position          = UDim2.new(1, -28, 0, 0)
        chevron.TextXAlignment    = Enum.TextXAlignment.Center
        chevron.ZIndex            = 6
        chevron.Parent            = mainFrame

        -- Dropdown panel
        local panel = Instance.new("Frame")
        panel.Size             = UDim2.new(1, 0, 0, 0)
        panel.Position         = UDim2.new(0, 0, 1, 4)
        panel.BackgroundColor3 = THEME.SurfaceAlt
        panel.BorderSizePixel  = 0
        panel.ClipsDescendants = true
        panel.ZIndex           = 10
        panel.Visible          = false
        panel.Parent           = wrapper
        makeCorner(panel, 8)
        makeStroke(panel, THEME.Border)

        local panelList = Instance.new("UIListLayout")
        panelList.SortOrder = Enum.SortOrder.LayoutOrder
        panelList.Padding   = UDim.new(0, 2)
        panelList.Parent    = panel
        makePadding(panel, 4, 4, 4, 4)

        local itemHeight = 30
        local maxVisible = 5

        local function buildItems()
            for _, c in ipairs(panel:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i, item in ipairs(items) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size             = UDim2.new(1, 0, 0, itemHeight)
                itemBtn.BackgroundColor3 = item == selected and THEME.AccentDim or THEME.SurfaceAlt
                itemBtn.BackgroundTransparency = item == selected and 0 or 1
                itemBtn.Text             = ""
                itemBtn.BorderSizePixel  = 0
                itemBtn.LayoutOrder      = i
                itemBtn.ZIndex           = 11
                itemBtn.Parent           = panel
                makeCorner(itemBtn, 6)

                local itemLabel = Instance.new("TextLabel")
                itemLabel.Text              = item
                itemLabel.TextSize          = 12
                itemLabel.Font              = FONT_SEMI
                itemLabel.TextColor3        = item == selected and THEME.TextPrimary or THEME.TextSecondary
                itemLabel.BackgroundTransparency = 1
                itemLabel.Size              = UDim2.new(1, -16, 1, 0)
                itemLabel.Position          = UDim2.new(0, 10, 0, 0)
                itemLabel.TextXAlignment    = Enum.TextXAlignment.Left
                itemLabel.ZIndex            = 12
                itemLabel.Parent            = itemBtn

                itemBtn.MouseEnter:Connect(function()
                    if item ~= selected then
                        tween(itemBtn, { BackgroundTransparency = 0.7, BackgroundColor3 = THEME.SurfaceHover })
                    end
                end)
                itemBtn.MouseLeave:Connect(function()
                    if item ~= selected then
                        tween(itemBtn, { BackgroundTransparency = 1 })
                    end
                end)

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    selectedLabel.Text = selected
                    configData[id] = selected
                    open = false
                    tween(panel, { Size = UDim2.new(1, 0, 0, 0) })
                    tween(chevron, { Rotation = 0 })
                    task.delay(0.2, function() panel.Visible = false end)
                    buildItems()
                    if callback then pcall(callback, selected) end
                end)
            end

            local totalH = #items * (itemHeight + 2) + 8
            local clampH = math.min(totalH, maxVisible * (itemHeight + 2) + 8)
            return clampH
        end

        local function toggleOpen()
            open = not open
            local targetH = buildItems()
            panel.Visible = true
            if open then
                tween(panel, { Size = UDim2.new(1, 0, 0, targetH) })
                tween(chevron, { Rotation = 180 })
                wrapper.Size = UDim2.new(1, 0, 0, 36 + targetH + 8)
            else
                tween(panel, { Size = UDim2.new(1, 0, 0, 0) })
                tween(chevron, { Rotation = 0 })
                task.delay(0.2, function()
                    panel.Visible = false
                    wrapper.Size = UDim2.new(1, 0, 0, 36)
                end)
            end
        end

        mainFrame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleOpen()
            end
        end)

        buildItems()

        local DDObj = {}
        function DDObj:set(item)
            selected = item
            selectedLabel.Text = selected
            configData[id] = selected
            buildItems()
        end
        function DDObj:get() return selected end
        function DDObj:setItems(newItems)
            items = newItems
            buildItems()
        end
        return DDObj
    end

    -- ──────────────── DROPDOWN MULTISELECT ────────────────
    function Tab:addMultiDropdown(id, text, items, callback)
        local selected = configData[id] or {}
        local open = false

        local wrapper = Instance.new("Frame")
        wrapper.Size             = UDim2.new(1, 0, 0, 36)
        wrapper.BackgroundTransparency = 1
        wrapper.BorderSizePixel  = 0
        wrapper.LayoutOrder      = nextOrder()
        wrapper.ClipsDescendants = false
        wrapper.ZIndex           = 4
        wrapper.Parent           = scrollFrame

        local mainFrame = Instance.new("Frame")
        mainFrame.Size             = UDim2.new(1, 0, 0, 36)
        mainFrame.BackgroundColor3 = THEME.Surface
        mainFrame.BorderSizePixel  = 0
        mainFrame.ZIndex           = 4
        mainFrame.Parent           = wrapper
        makeCorner(mainFrame, 8)
        makeStroke(mainFrame, THEME.Border)

        local ddLabel = Instance.new("TextLabel")
        ddLabel.Text              = text
        ddLabel.TextSize          = 13
        ddLabel.Font              = FONT_SEMI
        ddLabel.TextColor3        = THEME.TextPrimary
        ddLabel.BackgroundTransparency = 1
        ddLabel.Size              = UDim2.new(0.45, 0, 1, 0)
        ddLabel.Position          = UDim2.new(0, 14, 0, 0)
        ddLabel.TextXAlignment    = Enum.TextXAlignment.Left
        ddLabel.ZIndex            = 5
        ddLabel.Parent            = mainFrame

        local countLabel = Instance.new("TextLabel")
        countLabel.TextSize          = 12
        countLabel.Font              = FONT_SEMI
        countLabel.TextColor3        = THEME.Accent
        countLabel.BackgroundTransparency = 1
        countLabel.Size              = UDim2.new(0.45, 0, 1, 0)
        countLabel.Position          = UDim2.new(0.45, 0, 0, 0)
        countLabel.TextXAlignment    = Enum.TextXAlignment.Right
        countLabel.ZIndex            = 5
        countLabel.Parent            = mainFrame

        local chevron = Instance.new("TextLabel")
        chevron.Text              = "⌄"
        chevron.TextSize          = 14
        chevron.Font              = FONT
        chevron.TextColor3        = THEME.TextSecondary
        chevron.BackgroundTransparency = 1
        chevron.Size              = UDim2.new(0, 24, 1, 0)
        chevron.Position          = UDim2.new(1, -28, 0, 0)
        chevron.TextXAlignment    = Enum.TextXAlignment.Center
        chevron.ZIndex            = 5
        chevron.Parent            = mainFrame

        local panel = Instance.new("Frame")
        panel.Size             = UDim2.new(1, 0, 0, 0)
        panel.Position         = UDim2.new(0, 0, 1, 4)
        panel.BackgroundColor3 = THEME.SurfaceAlt
        panel.BorderSizePixel  = 0
        panel.ClipsDescendants = true
        panel.ZIndex           = 9
        panel.Visible          = false
        panel.Parent           = wrapper
        makeCorner(panel, 8)
        makeStroke(panel, THEME.Border)

        local panelList = Instance.new("UIListLayout")
        panelList.SortOrder = Enum.SortOrder.LayoutOrder
        panelList.Padding   = UDim.new(0, 2)
        panelList.Parent    = panel
        makePadding(panel, 4, 4, 4, 4)

        local itemHeight = 30
        local maxVisible = 5

        local function isSelected(item)
            for _, v in ipairs(selected) do
                if v == item then return true end
            end
            return false
        end

        local function toggleItem(item)
            if isSelected(item) then
                for i, v in ipairs(selected) do
                    if v == item then table.remove(selected, i) break end
                end
            else
                table.insert(selected, item)
            end
        end

        local function updateCountLabel()
            if #selected == 0 then
                countLabel.Text = "None"
                countLabel.TextColor3 = THEME.TextSecondary
            else
                countLabel.Text = #selected .. " selected"
                countLabel.TextColor3 = THEME.Accent
            end
        end

        local function buildItems()
            for _, c in ipairs(panel:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            for i, item in ipairs(items) do
                local sel = isSelected(item)

                local itemRow = Instance.new("Frame")
                itemRow.Size             = UDim2.new(1, 0, 0, itemHeight)
                itemRow.BackgroundColor3 = sel and THEME.AccentDim or THEME.SurfaceAlt
                itemRow.BackgroundTransparency = sel and 0 or 1
                itemRow.BorderSizePixel  = 0
                itemRow.LayoutOrder      = i
                itemRow.ZIndex           = 10
                itemRow.Parent           = panel
                makeCorner(itemRow, 6)

                local checkbox = Instance.new("Frame")
                checkbox.Size             = UDim2.new(0, 14, 0, 14)
                checkbox.Position         = UDim2.new(0, 8, 0.5, -7)
                checkbox.BackgroundColor3 = sel and THEME.Accent or THEME.ToggleOff
                checkbox.BorderSizePixel  = 0
                checkbox.ZIndex           = 11
                checkbox.Parent           = itemRow
                makeCorner(checkbox, 4)

                if sel then
                    local check = Instance.new("TextLabel")
                    check.Text              = "✓"
                    check.TextSize          = 10
                    check.Font              = FONT
                    check.TextColor3        = Color3.fromRGB(255, 255, 255)
                    check.BackgroundTransparency = 1
                    check.Size              = UDim2.new(1, 0, 1, 0)
                    check.TextXAlignment    = Enum.TextXAlignment.Center
                    check.TextYAlignment    = Enum.TextYAlignment.Center
                    check.ZIndex            = 12
                    check.Parent            = checkbox
                end

                local itemLabel = Instance.new("TextLabel")
                itemLabel.Text              = item
                itemLabel.TextSize          = 12
                itemLabel.Font              = FONT_SEMI
                itemLabel.TextColor3        = sel and THEME.TextPrimary or THEME.TextSecondary
                itemLabel.BackgroundTransparency = 1
                itemLabel.Size              = UDim2.new(1, -36, 1, 0)
                itemLabel.Position          = UDim2.new(0, 28, 0, 0)
                itemLabel.TextXAlignment    = Enum.TextXAlignment.Left
                itemLabel.ZIndex            = 11
                itemLabel.Parent            = itemRow

                local clickBtn = Instance.new("TextButton")
                clickBtn.Size             = UDim2.new(1, 0, 1, 0)
                clickBtn.BackgroundTransparency = 1
                clickBtn.Text             = ""
                clickBtn.ZIndex           = 13
                clickBtn.Parent           = itemRow

                clickBtn.MouseEnter:Connect(function()
                    if not isSelected(item) then
                        tween(itemRow, { BackgroundTransparency = 0.7, BackgroundColor3 = THEME.SurfaceHover })
                    end
                end)
                clickBtn.MouseLeave:Connect(function()
                    if not isSelected(item) then
                        tween(itemRow, { BackgroundTransparency = 1 })
                    end
                end)

                clickBtn.MouseButton1Click:Connect(function()
                    toggleItem(item)
                    configData[id] = selected
                    updateCountLabel()
                    buildItems()
                    if callback then pcall(callback, selected) end
                end)
            end

            local totalH = #items * (itemHeight + 2) + 8
            return math.min(totalH, maxVisible * (itemHeight + 2) + 8)
        end

        updateCountLabel()

        local function toggleOpen()
            open = not open
            local targetH = buildItems()
            panel.Visible = true
            if open then
                tween(panel, { Size = UDim2.new(1, 0, 0, targetH) })
                tween(chevron, { Rotation = 180 })
                wrapper.Size = UDim2.new(1, 0, 0, 36 + targetH + 8)
            else
                tween(panel, { Size = UDim2.new(1, 0, 0, 0) })
                tween(chevron, { Rotation = 0 })
                task.delay(0.2, function()
                    panel.Visible = false
                    wrapper.Size = UDim2.new(1, 0, 0, 36)
                end)
            end
        end

        mainFrame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleOpen()
            end
        end)

        local MultiObj = {}
        function MultiObj:get() return selected end
        function MultiObj:set(tbl)
            selected = tbl
            configData[id] = selected
            updateCountLabel()
            buildItems()
        end
        function MultiObj:setItems(newItems)
            items = newItems
            buildItems()
        end
        return MultiObj
    end

    -- ──────────────── SAVE CONFIG BUTTON ────────────────
    function Tab:addSaveConfig(filename)
        filename = filename or CONFIG_PATH
        local frame = Instance.new("Frame")
        frame.Size             = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = THEME.Surface
        frame.BorderSizePixel  = 0
        frame.LayoutOrder      = nextOrder()
        frame.Parent           = scrollFrame
        makeCorner(frame, 8)
        makeStroke(frame, THEME.Border)

        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, 0, 1, 0)
        row.BackgroundTransparency = 1
        row.Parent           = frame

        -- Save button
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size             = UDim2.new(0.5, -2, 1, 0)
        saveBtn.Position         = UDim2.new(0, 0, 0, 0)
        saveBtn.BackgroundColor3 = THEME.AccentDim
        saveBtn.Text             = ""
        saveBtn.BorderSizePixel  = 0
        saveBtn.ZIndex           = 3
        saveBtn.Parent           = row
        makeCorner(saveBtn, 8)

        local saveLabel = Instance.new("TextLabel")
        saveLabel.Text              = "💾  Save Config"
        saveLabel.TextSize          = 12
        saveLabel.Font              = FONT_SEMI
        saveLabel.TextColor3        = THEME.TextPrimary
        saveLabel.BackgroundTransparency = 1
        saveLabel.Size              = UDim2.new(1, 0, 1, 0)
        saveLabel.TextXAlignment    = Enum.TextXAlignment.Center
        saveLabel.ZIndex            = 4
        saveLabel.Parent            = saveBtn

        -- Load button
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size             = UDim2.new(0.5, -2, 1, 0)
        loadBtn.Position         = UDim2.new(0.5, 2, 0, 0)
        loadBtn.BackgroundColor3 = THEME.SurfaceHover
        loadBtn.Text             = ""
        loadBtn.BorderSizePixel  = 0
        loadBtn.ZIndex           = 3
        loadBtn.Parent           = row
        makeCorner(loadBtn, 8)
        makeStroke(loadBtn, THEME.Border)

        local loadLabel = Instance.new("TextLabel")
        loadLabel.Text              = "📂  Load Config"
        loadLabel.TextSize          = 12
        loadLabel.Font              = FONT_SEMI
        loadLabel.TextColor3        = THEME.TextPrimary
        loadLabel.BackgroundTransparency = 1
        loadLabel.Size              = UDim2.new(1, 0, 1, 0)
        loadLabel.TextXAlignment    = Enum.TextXAlignment.Center
        loadLabel.ZIndex            = 4
        loadLabel.Parent            = loadBtn

        -- Status label
        local statusLbl = Instance.new("TextLabel")
        statusLbl.Text              = ""
        statusLbl.TextSize          = 11
        statusLbl.Font              = FONT_SEMI
        statusLbl.TextColor3        = THEME.Success
        statusLbl.BackgroundTransparency = 1
        statusLbl.Size              = UDim2.new(1, 0, 0, 14)
        statusLbl.Position          = UDim2.new(0, 0, 1, 2)
        statusLbl.TextXAlignment    = Enum.TextXAlignment.Center
        statusLbl.ZIndex            = 3
        statusLbl.Parent            = frame

        local function flashStatus(msg, color)
            statusLbl.Text       = msg
            statusLbl.TextColor3 = color or THEME.Success
            task.delay(2, function()
                statusLbl.Text = ""
            end)
        end

        saveBtn.MouseButton1Click:Connect(function()
            local ok, err = pcall(function()
                local str = HttpService:JSONEncode(configData)
                writefile(filename, str)
            end)
            flashStatus(ok and "✓ Config saved!" or "✗ Save failed: " .. tostring(err), ok and THEME.Success or THEME.Danger)
        end)

        saveBtn.MouseEnter:Connect(function()
            tween(saveBtn, { BackgroundColor3 = THEME.Accent })
        end)
        saveBtn.MouseLeave:Connect(function()
            tween(saveBtn, { BackgroundColor3 = THEME.AccentDim })
        end)

        loadBtn.MouseButton1Click:Connect(function()
            local ok, err = pcall(loadConfig)
            flashStatus(ok and "✓ Config loaded!" or "✗ Load failed", ok and THEME.Success or THEME.Danger)
        end)

        loadBtn.MouseEnter:Connect(function()
            tween(loadBtn, { BackgroundColor3 = THEME.SurfaceAlt })
        end)
        loadBtn.MouseLeave:Connect(function()
            tween(loadBtn, { BackgroundColor3 = THEME.SurfaceHover })
        end)
    end

    return Tab
end

-- ============================================================
-- TAB SELECTION
-- ============================================================

function SpinachUI:_selectTab(tabData)
    for _, t in ipairs(self._tabs) do
        t.scroll.Visible = false
        tween(t.button,    { BackgroundTransparency = 1 })
        tween(t.label,     { TextColor3 = THEME.TextSecondary })
        tween(t.indicator, { BackgroundTransparency = 1 })
    end

    tabData.scroll.Visible = true
    tween(tabData.button,    { BackgroundTransparency = 0.75, BackgroundColor3 = THEME.Surface })
    tween(tabData.label,     { TextColor3 = THEME.TextPrimary })
    tween(tabData.indicator, { BackgroundTransparency = 0 })
    self._activeTab = tabData
end

function SpinachUI:destroy()
    self._sg:Destroy()
end

return SpinachUI
