local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function getSafeParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return PlayerGui
end

local CONFIG = {
    Acc1=Color3.fromRGB(240,240,245), Acc2=Color3.fromRGB(190,190,200), Acc3=Color3.fromRGB(120,120,130),
    Bg1=Color3.fromRGB(12,12,14), Panel1=Color3.fromRGB(22,22,26), Panel2=Color3.fromRGB(15,15,18),
    PanelHi=Color3.fromRGB(30,30,36), Stroke=Color3.fromRGB(52,52,60), StrokeSoft=Color3.fromRGB(38,38,44),
    Text=Color3.fromRGB(230,230,235), TextDim=Color3.fromRGB(150,150,160), TextMute=Color3.fromRGB(90,90,100),
    Green=Color3.fromRGB(180,220,180), ToggleSize=40, MenuWidth=340, MenuHeight=360, RowHeight=30, DimOpacity=0.55,
}

local PULSE_PERIOD = 1.6
local GLOBAL_PULSE = 0
RunService.RenderStepped:Connect(function(dt) GLOBAL_PULSE = (GLOBAL_PULSE + dt) % PULSE_PERIOD end)
local function GetPulsePhase() return GLOBAL_PULSE / PULSE_PERIOD end

pcall(function()
    local old = PlayerGui:FindFirstChild("DecayMenu")
    if old then old:Destroy() end
end)
pcall(function()
    if gethui then
        local hui = gethui()
        local old = hui:FindFirstChild("DecayMenu")
        if old then old:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DecayMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = getSafeParent()

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function() if ScreenGui.Parent == nil then ScreenGui.Parent = getSafeParent() end end)
    end
end)

-- ===================== PING UTILS =====================
local function getPingRaw()
    local p1 = 0
    pcall(function() p1 = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    local p2 = 0
    pcall(function() p2 = LocalPlayer:GetNetworkPing() * 1000 end)
    return math.max(p1 or 0, p2 or 0)
end

local function getPingSeconds(cap)
    local p = getPingRaw() / 1000
    local c = cap or 0.4
    if p > c then p = c end
    if p < 0 then p = 0 end
    return p
end

-- ===================== UI HELPERS =====================
local function CreateDiamond(parent)
    local D = Instance.new("TextLabel")
    D.AnchorPoint = Vector2.new(0.5, 0.5)
    D.Size = UDim2.new(1, 0, 1, 0)
    D.Position = UDim2.new(0.5, 0, 0.5, 0)
    D.BackgroundTransparency = 1
    D.Text = "◆"
    D.TextColor3 = CONFIG.Acc1
    D.Font = Enum.Font.GothamBold
    D.TextSize = 11
    D.ZIndex = 10
    D.Parent = parent
    return D
end

local function ApplyPanelGradient(parent, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.PanelHi),
        ColorSequenceKeypoint.new(0.5, CONFIG.Panel1),
        ColorSequenceKeypoint.new(1, CONFIG.Panel2),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function ApplyStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.StrokeSoft
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.35
    s.Parent = parent
    return s
end

local function ApplyCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function CreateMarker(parent, size, position)
    local Marker = Instance.new("Frame")
    Marker.Size = UDim2.new(0, size or 20, 0, size or 20)
    Marker.Position = position
    Marker.BackgroundColor3 = CONFIG.PanelHi
    Marker.BorderSizePixel = 0
    Marker.ZIndex = 7
    Marker.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = Marker
    ApplyStroke(Marker, CONFIG.Stroke, 1, 0.4)
    CreateDiamond(Marker)
    return Marker
end

local function CreateRowLabel(parent, text, rightMargin)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -(32 + (rightMargin or 32)), 1, 0)
    Lbl.Position = UDim2.new(0, 32, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = CONFIG.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd
    Lbl.ZIndex = 7
    Lbl.Parent = parent
    return Lbl
end

local function CreateTopHighlight(parent)
    local Hi = Instance.new("Frame")
    Hi.Size = UDim2.new(1, -20, 0, 1)
    Hi.Position = UDim2.new(0, 10, 0, 0)
    Hi.BackgroundColor3 = CONFIG.Acc1
    Hi.BackgroundTransparency = 0.85
    Hi.BorderSizePixel = 0
    Hi.ZIndex = 7
    Hi.Parent = parent
    return Hi
end

local function CreateStatusDot(parent)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(0, 24, 0, 24)
    Holder.Position = UDim2.new(1, -30, 0.5, -12)
    Holder.BackgroundTransparency = 1
    Holder.ZIndex = 7
    Holder.Parent = parent

    local Aura = Instance.new("Frame")
    Aura.AnchorPoint = Vector2.new(0.5, 0.5)
    Aura.Size = UDim2.new(0, 24, 0, 24)
    Aura.Position = UDim2.new(0.5, 0, 0.5, 0)
    Aura.BackgroundColor3 = CONFIG.Green
    Aura.BackgroundTransparency = 1
    Aura.BorderSizePixel = 0
    Aura.ZIndex = 7
    Aura.Parent = Holder
    local ac = Instance.new("UICorner") ac.CornerRadius = UDim.new(1, 0) ac.Parent = Aura

    local Bg = Instance.new("Frame")
    Bg.AnchorPoint = Vector2.new(0.5, 0.5)
    Bg.Size = UDim2.new(0, 16, 0, 16)
    Bg.Position = UDim2.new(0.5, 0, 0.5, 0)
    Bg.BackgroundColor3 = CONFIG.PanelHi
    Bg.BorderSizePixel = 0
    Bg.ZIndex = 8
    Bg.Parent = Holder
    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(1, 0) bc.Parent = Bg

    local Dot = Instance.new("Frame")
    Dot.AnchorPoint = Vector2.new(0.5, 0.5)
    Dot.Size = UDim2.new(0, 7, 0, 7)
    Dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    Dot.BackgroundColor3 = CONFIG.TextMute
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 9
    Dot.Parent = Holder
    local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = Dot

    return Dot, Bg, Aura
end

-- ===================== MENU FRAME =====================
local MenuRoot = Instance.new("Frame")
MenuRoot.Size = UDim2.new(1, 0, 1, 0)
MenuRoot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MenuRoot.BackgroundTransparency = 1
MenuRoot.BorderSizePixel = 0
MenuRoot.Active = true
MenuRoot.Visible = false
MenuRoot.ZIndex = 1
MenuRoot.Parent = ScreenGui

local PanelGlow = Instance.new("Frame")
PanelGlow.AnchorPoint = Vector2.new(0.5, 0.5)
PanelGlow.Size = UDim2.new(0, CONFIG.MenuWidth + 20, 0, CONFIG.MenuHeight + 20)
PanelGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
PanelGlow.BackgroundColor3 = CONFIG.Acc3
PanelGlow.BackgroundTransparency = 0.92
PanelGlow.BorderSizePixel = 0
PanelGlow.ZIndex = 2
PanelGlow.Parent = MenuRoot
ApplyCorner(PanelGlow, 22)

local Panel = Instance.new("Frame")
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.Size = UDim2.new(0, CONFIG.MenuWidth, 0, CONFIG.MenuHeight)
Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
Panel.BackgroundColor3 = CONFIG.Bg1
Panel.BorderSizePixel = 0
Panel.ClipsDescendants = true
Panel.ZIndex = 3
Panel.Parent = MenuRoot
ApplyCorner(Panel, 14)
local PanelStroke = ApplyStroke(Panel, CONFIG.Stroke, 1, 0)

local PanelTopHighlight = Instance.new("Frame")
PanelTopHighlight.Size = UDim2.new(1, -28, 0, 1)
PanelTopHighlight.Position = UDim2.new(0, 14, 0, 0)
PanelTopHighlight.BackgroundColor3 = CONFIG.Acc2
PanelTopHighlight.BackgroundTransparency = 0.7
PanelTopHighlight.BorderSizePixel = 0
PanelTopHighlight.ZIndex = 4
PanelTopHighlight.Parent = Panel

local PanelGradient = Instance.new("UIGradient")
PanelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.Panel1),
    ColorSequenceKeypoint.new(0.5, CONFIG.Bg1),
    ColorSequenceKeypoint.new(1, CONFIG.Panel2),
})
PanelGradient.Rotation = 90
PanelGradient.Parent = Panel

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = CONFIG.PanelHi
Header.BackgroundTransparency = 0.6
Header.BorderSizePixel = 0
Header.ZIndex = 5
Header.Parent = Panel
ApplyCorner(Header, 14)

local HeaderMask = Instance.new("Frame")
HeaderMask.Size = UDim2.new(1, 0, 0, 12)
HeaderMask.Position = UDim2.new(0, 0, 1, -12)
HeaderMask.BackgroundColor3 = CONFIG.PanelHi
HeaderMask.BackgroundTransparency = 0.6
HeaderMask.BorderSizePixel = 0
HeaderMask.ZIndex = 5
HeaderMask.Parent = Header

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 24, 0, 24)
LogoBox.Position = UDim2.new(0, 10, 0.5, -12)
LogoBox.BackgroundColor3 = CONFIG.Panel1
LogoBox.BorderSizePixel = 0
LogoBox.ZIndex = 6
LogoBox.Parent = Header
ApplyCorner(LogoBox, 6)
ApplyStroke(LogoBox, CONFIG.Stroke, 1, 0.2)

local LogoGlyph = Instance.new("TextLabel")
LogoGlyph.Size = UDim2.new(1, 0, 1, 0)
LogoGlyph.BackgroundTransparency = 1
LogoGlyph.Text = "D"
LogoGlyph.TextColor3 = CONFIG.Acc1
LogoGlyph.Font = Enum.Font.GothamBold
LogoGlyph.TextSize = 13
LogoGlyph.ZIndex = 7
LogoGlyph.Parent = LogoBox

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DECAY"
Title.TextColor3 = CONFIG.Acc1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTruncate = Enum.TextTruncate.AtEnd
Title.ZIndex = 6
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
CloseBtn.BackgroundColor3 = CONFIG.Panel1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = CONFIG.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 6
CloseBtn.Parent = Header
ApplyCorner(CloseBtn, 999)
ApplyStroke(CloseBtn, CONFIG.Stroke, 1, 0.3)

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 1, 0)
HeaderDivider.BackgroundColor3 = CONFIG.StrokeSoft
HeaderDivider.BackgroundTransparency = 0.4
HeaderDivider.BorderSizePixel = 0
HeaderDivider.ZIndex = 6
HeaderDivider.Parent = Header

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -48)
Content.Position = UDim2.new(0, 8, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = CONFIG.Acc3
Content.ScrollBarImageTransparency = 0.5
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 5
Content.Parent = Panel

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 6)
ContentPadding.Parent = Content

-- ===================== TOGGLE =====================
local function CreateFeatureToggle(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, CONFIG.RowHeight)
    Btn.BackgroundColor3 = CONFIG.Panel1
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 6
    Btn.Parent = Content
    ApplyCorner(Btn, 8)
    ApplyStroke(Btn, CONFIG.StrokeSoft, 1, 0.35)
    ApplyPanelGradient(Btn, 90)
    CreateTopHighlight(Btn)
    CreateMarker(Btn, 20, UDim2.new(0, 8, 0.5, -10))
    CreateRowLabel(Btn, name, 32)

    local Dot, Bg, Aura = CreateStatusDot(Btn)
    local pulseConn = nil
    local function startPulse()
        if pulseConn then return end
        pulseConn = RunService.RenderStepped:Connect(function()
            local phase = GetPulsePhase()
            local size = 24 + phase * 5
            Aura.Size = UDim2.new(0, size, 0, size)
            Aura.BackgroundTransparency = 0.3 + phase * 0.7
        end)
    end
    local function stopPulse()
        if pulseConn then pulseConn:Disconnect() pulseConn = nil end
        Aura.Size = UDim2.new(0, 24, 0, 24)
        Aura.BackgroundTransparency = 1
    end

    local state = false
    local function setState(v)
        state = v
        local col = state and CONFIG.Acc1 or CONFIG.TextMute
        local bg = state and Color3.fromRGB(45, 45, 52) or CONFIG.PanelHi
        TweenService:Create(Dot, TweenInfo.new(0.25), { BackgroundColor3 = col }):Play()
        TweenService:Create(Bg, TweenInfo.new(0.25), { BackgroundColor3 = bg }):Play()
        if state then startPulse() else stopPulse() end
        pcall(callback, state)
    end

    Btn.MouseButton1Click:Connect(function() setState(not state) end)
    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { Size = UDim2.new(1, -2, 0, CONFIG.RowHeight - 2) }):Play()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, CONFIG.RowHeight),
        }):Play()
    end)
    return Btn, setState
end

local function CreateAimbotToggle(onCycle)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, CONFIG.RowHeight)
    Btn.BackgroundColor3 = CONFIG.Panel1
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 6
    Btn.Parent = Content
    ApplyCorner(Btn, 8)
    ApplyStroke(Btn, CONFIG.StrokeSoft, 1, 0.35)
    ApplyPanelGradient(Btn, 90)
    CreateTopHighlight(Btn)
    CreateMarker(Btn, 20, UDim2.new(0, 8, 0.5, -10))

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -120, 1, 0)
    Lbl.Position = UDim2.new(0, 32, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "Aimbot"
    Lbl.TextColor3 = CONFIG.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 7
    Lbl.Parent = Btn

    local ModeLbl = Instance.new("TextLabel")
    ModeLbl.Size = UDim2.new(0, 60, 1, 0)
    ModeLbl.Position = UDim2.new(1, -84, 0, 0)
    ModeLbl.BackgroundTransparency = 1
    ModeLbl.Text = ""
    ModeLbl.TextColor3 = CONFIG.Acc1
    ModeLbl.Font = Enum.Font.GothamBold
    ModeLbl.TextSize = 10
    ModeLbl.TextXAlignment = Enum.TextXAlignment.Right
    ModeLbl.ZIndex = 7
    ModeLbl.Parent = Btn

    local Dot, Bg, Aura = CreateStatusDot(Btn)
    local pulseConn = nil
    local function startPulse()
        if pulseConn then return end
        pulseConn = RunService.RenderStepped:Connect(function()
            local phase = GetPulsePhase()
            local size = 24 + phase * 5
            Aura.Size = UDim2.new(0, size, 0, size)
            Aura.BackgroundTransparency = 0.3 + phase * 0.7
        end)
    end
    local function stopPulse()
        if pulseConn then pulseConn:Disconnect() pulseConn = nil end
        Aura.Size = UDim2.new(0, 24, 0, 24)
        Aura.BackgroundTransparency = 1
    end

    local mode = 0
    local function applyMode()
        if mode == 0 then
            Btn.BackgroundColor3 = CONFIG.Panel1
            Btn.UIStroke.Color = CONFIG.StrokeSoft
            Lbl.TextColor3 = CONFIG.Text
            ModeLbl.Text = "OFF"
            ModeLbl.TextColor3 = CONFIG.TextMute
            Dot.BackgroundColor3 = CONFIG.TextMute
            Bg.BackgroundColor3 = CONFIG.PanelHi
            Aura.BackgroundColor3 = CONFIG.Acc1
            stopPulse()
        elseif mode == 1 then
            Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
            Btn.UIStroke.Color = CONFIG.Stroke
            Lbl.TextColor3 = CONFIG.Text
            ModeLbl.Text = "DRAG"
            ModeLbl.TextColor3 = CONFIG.Acc2
            Dot.BackgroundColor3 = CONFIG.Acc2
            Bg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            Aura.BackgroundColor3 = CONFIG.Acc2
            startPulse()
        else
            Btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
            Btn.UIStroke.Color = CONFIG.Acc1
            Lbl.TextColor3 = CONFIG.Acc1
            ModeLbl.Text = "LOCKED"
            ModeLbl.TextColor3 = CONFIG.Acc1
            Dot.BackgroundColor3 = CONFIG.Acc1
            Bg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            Aura.BackgroundColor3 = CONFIG.Acc1
            startPulse()
        end
        pcall(onCycle, mode)
    end

    Btn.MouseButton1Click:Connect(function() mode = (mode + 1) % 3 applyMode() end)
    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.08), { Size = UDim2.new(1, -2, 0, CONFIG.RowHeight - 2) }):Play()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, CONFIG.RowHeight),
        }):Play()
    end)
    return Btn, applyMode
end

local function CreateFOVSlider(callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundColor3 = CONFIG.Panel1
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 6
    Frame.Parent = Content
    ApplyCorner(Frame, 8)
    ApplyStroke(Frame, CONFIG.StrokeSoft, 1, 0.35)
    ApplyPanelGradient(Frame, 90)
    CreateTopHighlight(Frame)
    CreateMarker(Frame, 20, UDim2.new(0, 8, 0, 6))

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -100, 0, 14)
    Name.Position = UDim2.new(0, 32, 0, 8)
    Name.BackgroundTransparency = 1
    Name.Text = "Camera FOV"
    Name.TextColor3 = CONFIG.Text
    Name.Font = Enum.Font.GothamMedium
    Name.TextSize = 11
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.ZIndex = 7
    Name.Parent = Frame

    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.new(0, 60, 0, 14)
    Value.Position = UDim2.new(1, -66, 0, 8)
    Value.BackgroundTransparency = 1
    Value.Text = "70"
    Value.TextColor3 = CONFIG.Acc1
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 11
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.ZIndex = 7
    Value.Parent = Frame

    local TrackBg = Instance.new("Frame")
    TrackBg.Size = UDim2.new(1, -60, 0, 5)
    TrackBg.Position = UDim2.new(0, 42, 1, -13)
    TrackBg.BackgroundColor3 = CONFIG.PanelHi
    TrackBg.BorderSizePixel = 0
    TrackBg.ZIndex = 7
    TrackBg.Active = false
    TrackBg.Parent = Frame
    local tbc = Instance.new("UICorner") tbc.CornerRadius = UDim.new(1, 0) tbc.Parent = TrackBg

    local TrackFill = Instance.new("Frame")
    TrackFill.Size = UDim2.new(0, 0, 1, 0)
    TrackFill.BackgroundColor3 = CONFIG.Acc2
    TrackFill.BorderSizePixel = 0
    TrackFill.ZIndex = 8
    TrackFill.Parent = TrackBg
    local tfc = Instance.new("UICorner") tfc.CornerRadius = UDim.new(1, 0) tfc.Parent = TrackFill

    local Handle = Instance.new("Frame")
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Handle.Position = UDim2.new(0, 0, 0.5, 0)
    Handle.BackgroundColor3 = CONFIG.Acc1
    Handle.BorderSizePixel = 0
    Handle.ZIndex = 9
    Handle.Parent = TrackBg
    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(1, 0) hc.Parent = Handle

    local dragging = false
    local sliderCamConn = nil
    local savedCamCFrame

    local function startDrag()
        dragging = true
        pcall(function() UserInputService.ModalEnabled = true end)
        local cam = workspace.CurrentCamera
        if cam then savedCamCFrame = cam.CFrame end
        if sliderCamConn then sliderCamConn:Disconnect() end
        sliderCamConn = RunService.RenderStepped:Connect(function()
            if dragging and savedCamCFrame then
                local c = workspace.CurrentCamera
                if c then c.CFrame = savedCamCFrame end
            end
        end)
    end
    local function stopDrag()
        if not dragging then return end
        dragging = false
        pcall(function() UserInputService.ModalEnabled = false end)
        if sliderCamConn then sliderCamConn:Disconnect() sliderCamConn = nil end
        savedCamCFrame = nil
    end
    local function updateFromX(x)
        local relX = x - TrackBg.AbsolutePosition.X
        local pct = math.clamp(relX / TrackBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(40 + (120 - 40) * pct + 0.5)
        TrackFill.Size = UDim2.new(pct, 0, 1, 0)
        Handle.Position = UDim2.new(pct, 0, 0.5, 0)
        Value.Text = value
        pcall(callback, value)
    end

    TrackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(); updateFromX(input.Position.X)
        end
    end)
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            startDrag()
        end
    end)
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(); updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            stopDrag()
        end
    end)

    local startPct = (70 - 40) / (120 - 40)
    TrackFill.Size = UDim2.new(startPct, 0, 1, 0)
    Handle.Position = UDim2.new(startPct, 0, 0.5, 0)
    return Frame
end

local Values = { CameraFOV = 70 }
local function GetHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- ===================== SPEED =====================
local SPEED_PEAK, SPEED_NORMAL = 27, 16
local PULSE_TIME, REST_TIME, JITTER = 0.10, 0.45, 0.05
local speedOn = false
local pulseThread = nil
local function pulseLoop()
    while speedOn do
        local hum = GetHumanoid()
        if hum and hum.Parent then
            local pulse = PULSE_TIME * (1 - JITTER/2 + math.random() * JITTER)
            local rest  = REST_TIME  * (1 - JITTER/2 + math.random() * JITTER)
            hum.WalkSpeed = SPEED_PEAK
            task.wait(pulse)
            if hum and hum.Parent then hum.WalkSpeed = SPEED_NORMAL end
            task.wait(rest)
        else
            task.wait(0.2)
        end
    end
end
CreateFeatureToggle("Speed", function(state)
    speedOn = state
    if state then
        pulseThread = task.spawn(pulseLoop)
    else
        if pulseThread then pcall(task.cancel, pulseThread) pulseThread = nil end
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = SPEED_NORMAL end
    end
end)

-- ===================== JUMP =====================
local JUMP_POWER, JUMP_NORMAL = 60, 50
local jumpOn = false
local jumpConn = nil
local function installFallImmunity()
    if not (hookmetamethod and newcclosure and getnamecallmethod) then return nil end
    local oldNamecall
    pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "TakeDamage" and typeof(self) == "Instance" and self:IsA("Humanoid")
            and self:IsDescendantOf(LocalPlayer.Character or workspace) and jumpOn then
                local st = self:GetState()
                if st == Enum.HumanoidStateType.Freefall
                or st == Enum.HumanoidStateType.Landed
                or st == Enum.HumanoidStateType.FallingDown then
                    return
                end
            end
            return oldNamecall(self, ...)
        end))
    end)
end
CreateFeatureToggle("Jump", function(state)
    jumpOn = state
    if state then
        local hum = GetHumanoid()
        if hum then hum.UseJumpPower = true hum.JumpPower = JUMP_POWER end
        jumpConn = task.spawn(function()
            while jumpOn do
                local h = GetHumanoid()
                if h and h.Parent and h.JumpPower ~= JUMP_POWER then
                    h.UseJumpPower = true
                    h.JumpPower = JUMP_POWER
                end
                task.wait(0.2)
            end
        end)
        installFallImmunity()
    else
        if jumpConn then pcall(task.cancel, jumpConn) jumpConn = nil end
        local hum = GetHumanoid()
        if hum then hum.JumpPower = JUMP_NORMAL end
    end
end)

-- ===================== WALL CLIMB =====================
local CLIMB_SPEED    = 22
local CLIMB_WGAP     = 7
local CLIMB_PSZ      = 7
local CLIMB_MINP     = 6
local CLIMB_MAXH     = 80
local CLIMB_CLEAN    = 12
local CLIMB_FADE     = 8
local CLIMB_FTR      = 0.85
local CLIMB_INERT    = 2
local CLIMB_IDLE     = 5

local climbOn      = false
local climbConn    = nil
local climbPlats   = {}
local climbIdleT   = 0
local climbLastWall= 0

local function climbHasWall()
    local ch = LocalPlayer.Character
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local f = {ch}
    for _, p in ipairs(climbPlats) do table.insert(f, p) end
    rp.FilterDescendantsInstances = f
    local dirs = {hrp.CFrame.LookVector, -hrp.CFrame.LookVector, hrp.CFrame.RightVector, -hrp.CFrame.RightVector}
    for _, d in ipairs(dirs) do
        if workspace:Raycast(hrp.Position, d * 5, rp) then return true end
    end
    return false
end

local function climbClear()
    for _, p in ipairs(climbPlats) do pcall(function() p:Destroy() end) end
    climbPlats = {}
    climbIdleT = 0
    climbLastWall = 0
end

local function climbMk(pos)
    local p = Instance.new("Part")
    p.Name = "ClimbPlate"
    p.Size = Vector3.new(CLIMB_PSZ, 0.5, CLIMB_PSZ)
    p.Anchored = true
    p.CanCollide = true
    p.CanQuery = false
    p.CanTouch = false
    p.Material = Enum.Material.SmoothPlastic
    p.Color = Color3.fromRGB(130, 130, 130)
    p.Transparency = 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CFrame = CFrame.new(pos)
    p.Parent = workspace
    return p
end

local function climbStack(hrp)
    local by = hrp.Position.Y - 3
    for i = 0, CLIMB_MINP - 1 do
        table.insert(climbPlats, climbMk(Vector3.new(hrp.Position.X, by - i * CLIMB_WGAP, hrp.Position.Z)))
    end
end

local function climbUpdateStack(hrp)
    local lo = nil
    for _, p in ipairs(climbPlats) do
        if not lo or p.Position.Y < lo then lo = p.Position.Y end
    end
    if not lo then return end
    if hrp.Position.Y - lo < CLIMB_MAXH then
        table.insert(climbPlats, climbMk(Vector3.new(hrp.Position.X, lo - CLIMB_WGAP, hrp.Position.Z)))
    end
    for i = #climbPlats, 1, -1 do
        if climbPlats[i].Position.Y - hrp.Position.Y > CLIMB_CLEAN then
            climbPlats[i]:Destroy()
            table.remove(climbPlats, i)
        end
    end
    for _, p in ipairs(climbPlats) do
        local d = p.Position.Y - hrp.Position.Y
        if d > CLIMB_FADE then
            if p.Transparency ~= CLIMB_FTR then p.Transparency = CLIMB_FTR end
            if p.CanCollide then p.CanCollide = false end
        else
            if p.Transparency ~= 0 then p.Transparency = 0 end
            if not p.CanCollide then p.CanCollide = true end
        end
    end
end

CreateFeatureToggle("Wall Climb", function(state)
    climbOn = state
    if state then
        climbClear()
        climbLastWall = 0
        if climbConn then climbConn:Disconnect() end
        climbConn = RunService.Heartbeat:Connect(function(dt)
            if not climbOn then return end
            local ch = LocalPlayer.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            local hm = ch:FindFirstChildOfClass("Humanoid")
            if not hrp or not hm or hm.Health <= 0 then return end
            local w = climbHasWall()
            local n = tick()
            if w then climbLastWall = n end
            local active = w or (n - climbLastWall) < CLIMB_INERT
            if active and #climbPlats == 0 then
                climbStack(hrp)
                climbIdleT = 0
            end
            if #climbPlats > 0 then
                if active then
                    if w then climbIdleT = 0 end
                    for _, p in ipairs(climbPlats) do
                        p.CFrame = CFrame.new(p.Position + Vector3.new(0, CLIMB_SPEED * dt, 0))
                    end
                    climbUpdateStack(hrp)
                else
                    if climbIdleT == 0 then climbIdleT = n end
                    if n - climbIdleT > CLIMB_IDLE then climbClear() end
                end
            end
        end)
    else
        if climbConn then climbConn:Disconnect() climbConn = nil end
        climbClear()
    end
end)

-- ===================== ESP =====================
local ESP_FILL_COLOR = Color3.fromRGB(255, 255, 255)
local ESP_OUTLINE    = Color3.fromRGB(255, 255, 255)
local ESP_FILL_ALPHA = 0.55
local ESP_DEAD_COLOR = Color3.fromRGB(120, 120, 120)
local HP_BAR_BG      = Color3.fromRGB(14, 14, 17)
local HP_BAR_FILL    = Color3.fromRGB(235, 235, 240)
local HP_BAR_DEAD    = Color3.fromRGB(150, 80, 80)
local HP_W, HP_H     = 4, 34
local HP_OFFSET      = Vector3.new(-3.8, -1.0, 0)
local HP_HIDE_DIST   = 200
local HP_REF_DIST    = 40
local HP_SCALE_MIN, HP_SCALE_MAX = 0.6, 1.0
local DIST_W, DIST_H = 60, 16
local DIST_TEXT_SIZE = 12
local DIST_BASE_Y, DIST_REF_DIST, DIST_Y_GROWTH, DIST_Y_MAX = 6.8, 40, 0.06, 8
local ESP_RANGE      = 1000

local espOn = false
local espObjects = {}
local espConnections = {}
local createESP

local function bindCharacterLifecycle(player)
    local data = espObjects[player]
    if not data then return end
    if data.lifecycleConn then data.lifecycleConn:Disconnect() end
    data.lifecycleConn = player.CharacterAdded:Connect(function()
        task.wait(0.4)
        if espOn then createESP(player) end
    end)
end

function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if espObjects[player] then
        local d = espObjects[player]
        if d.highlight then pcall(function() d.highlight:Destroy() end) end
        if d.hpBillboard then pcall(function() d.hpBillboard:Destroy() end) end
        if d.distBillboard then pcall(function() d.distBillboard:Destroy() end) end
        if d.lifecycleConn then pcall(function() d.lifecycleConn:Disconnect() end) end
        espObjects[player] = nil
    end

    local hl = Instance.new("Highlight")
    hl.Name = "DecayESP_HL"
    hl.Adornee = char
    hl.FillColor = ESP_FILL_COLOR
    hl.FillTransparency = ESP_FILL_ALPHA
    hl.OutlineColor = ESP_OUTLINE
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char

    local hpBb = Instance.new("BillboardGui")
    hpBb.Size = UDim2.new(0, HP_W, 0, HP_H)
    hpBb.StudsOffset = HP_OFFSET
    hpBb.AlwaysOnTop = true
    hpBb.MaxDistance = ESP_RANGE
    hpBb.Parent = hrp

    local hpBg = Instance.new("Frame")
    hpBg.AnchorPoint = Vector2.new(0.5, 0.5)
    hpBg.Position = UDim2.new(0.5, 0, 0.5, 0)
    hpBg.Size = UDim2.new(1, 0, 1, 0)
    hpBg.BackgroundColor3 = HP_BAR_BG
    hpBg.BorderSizePixel = 0
    hpBg.Parent = hpBb
    local hpBgC = Instance.new("UICorner") hpBgC.CornerRadius = UDim.new(1, 0) hpBgC.Parent = hpBg
    local hpBgS = Instance.new("UIStroke")
    hpBgS.Color = Color3.fromRGB(0, 0, 0)
    hpBgS.Thickness = 1
    hpBgS.Transparency = 0.3
    hpBgS.Parent = hpBg

    local hpFill = Instance.new("Frame")
    hpFill.AnchorPoint = Vector2.new(0.5, 1)
    hpFill.Position = UDim2.new(0.5, 0, 1, -1)
    hpFill.Size = UDim2.new(1, 0, 1, -2)
    hpFill.BackgroundColor3 = HP_BAR_FILL
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    local hpFillC = Instance.new("UICorner") hpFillC.CornerRadius = UDim.new(1, 0) hpFillC.Parent = hpFill

    local distBb = Instance.new("BillboardGui")
    distBb.Size = UDim2.new(0, DIST_W, 0, DIST_H)
    distBb.StudsOffset = Vector3.new(0, DIST_BASE_Y, 0)
    distBb.AlwaysOnTop = true
    distBb.MaxDistance = ESP_RANGE
    distBb.Parent = hrp

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 1, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0]"
    distLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
    distLabel.TextSize = DIST_TEXT_SIZE
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextStrokeTransparency = 0.1
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = distBb

    espObjects[player] = {
        highlight = hl, hpBillboard = hpBb, hpFill = hpFill,
        distBillboard = distBb, distLabel = distLabel, hpVisible = true,
    }
    bindCharacterLifecycle(player)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local diedConn = hum.Died:Connect(function()
            local d = espObjects[player]
            if d then
                if d.highlight then
                    d.highlight.FillColor = ESP_DEAD_COLOR
                    d.highlight.OutlineColor = ESP_DEAD_COLOR
                end
                if d.hpFill then
                    d.hpFill.BackgroundColor3 = HP_BAR_DEAD
                    d.hpFill.Size = UDim2.new(1, 0, 0, 0)
                end
            end
        end)
        espConnections[player] = espConnections[player] or {}
        table.insert(espConnections[player], diedConn)
    end
end

local function removeESP(player)
    local data = espObjects[player]
    if data then
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.hpBillboard then pcall(function() data.hpBillboard:Destroy() end) end
        if data.distBillboard then pcall(function() data.distBillboard:Destroy() end) end
        if data.lifecycleConn then pcall(function() data.lifecycleConn:Disconnect() end) end
        espObjects[player] = nil
    end
    if espConnections[player] then
        for _, c in ipairs(espConnections[player]) do
            pcall(function() c:Disconnect() end)
        end
        espConnections[player] = nil
    end
end

local function refreshAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            removeESP(p)
            if espOn and p.Character then createESP(p) end
        end
    end
end

CreateFeatureToggle("ESP", function(state)
    espOn = state
    if state then
        refreshAllESP()
    else
        for player in pairs(espObjects) do removeESP(player) end
        espObjects = {}
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.4)
        if espOn then createESP(plr) end
    end)
    task.spawn(function()
        task.wait(0.5)
        if espOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            createESP(plr)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)

task.spawn(function()
    while true do
        task.wait(1)
        if espOn then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    local hasData = espObjects[p] ~= nil
                    local hasHRP = char and char:FindFirstChild("HumanoidRootPart") ~= nil
                    if hasHRP and not hasData then
                        createESP(p)
                    elseif hasData and hasHRP then
                        local d = espObjects[p]
                        if d.hpBillboard and d.hpBillboard.Parent ~= char:FindFirstChild("HumanoidRootPart") then
                            removeESP(p)
                            createESP(p)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if espOn then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = myRoot and myRoot.Position
            if myPos then
                for plr, data in pairs(espObjects) do
                    if plr.Parent then
                        local theirChar = plr.Character
                        local theirRoot = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
                        local theirHum = theirChar and theirChar:FindFirstChildOfClass("Humanoid")
                        if theirRoot then
                            local realDist = (theirRoot.Position - myPos).Magnitude
                            local inRange = realDist <= ESP_RANGE
                            if data.highlight then data.highlight.Enabled = inRange end
                            if data.hpBillboard then
                                if not inRange then
                                    data.hpBillboard.Enabled = false
                                else
                                    local shouldShow = realDist <= HP_HIDE_DIST
                                    if data.hpVisible ~= shouldShow then
                                        data.hpVisible = shouldShow
                                        data.hpBillboard.Enabled = shouldShow
                                    end
                                end
                            end
                            if data.distBillboard then data.distBillboard.Enabled = inRange end
                            if inRange then
                                if data.hpVisible and data.hpBillboard then
                                    local scale = math.clamp(HP_REF_DIST / realDist, HP_SCALE_MIN, HP_SCALE_MAX)
                                    data.hpBillboard.Size = UDim2.new(0, HP_W * scale, 0, HP_H * scale)
                                end
                                if data.hpVisible and theirHum and data.hpFill then
                                    local ratio = math.clamp(theirHum.Health / theirHum.MaxHealth, 0, 1)
                                    data.hpFill.Size = UDim2.new(1, 0, ratio, -2)
                                end
                                if data.distBillboard then
                                    local extra = math.max(0, realDist - DIST_REF_DIST) * DIST_Y_GROWTH
                                    data.distBillboard.StudsOffset = Vector3.new(0, math.min(DIST_BASE_Y + extra, DIST_Y_MAX), 0)
                                end
                                if data.distLabel then
                                    data.distLabel.Text = "[" .. math.floor(realDist) .. "]"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ===================== BRIGHT =====================
local brightOn = false
local brightBackup = nil
local BRIGHT_PRESET = {
    Ambient        = Color3.fromRGB(200, 200, 200),
    OutdoorAmbient = Color3.fromRGB(200, 200, 200),
    Brightness     = 4,
    FogEnd         = 100000,
    FogStart       = 100000,
}
CreateFeatureToggle("Bright", function(state)
    brightOn = state
    if state then
        brightBackup = {
            Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        }
        for k, v in pairs(BRIGHT_PRESET) do
            pcall(function() Lighting[k] = v end)
        end
    else
        if brightBackup then
            for k, v in pairs(brightBackup) do
                pcall(function() Lighting[k] = v end)
            end
            brightBackup = nil
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(2)
        if brightOn then
            pcall(function()
                Lighting.Ambient = BRIGHT_PRESET.Ambient
                Lighting.OutdoorAmbient = BRIGHT_PRESET.OutdoorAmbient
                Lighting.Brightness = BRIGHT_PRESET.Brightness
            end)
        end
    end
end)

-- ===================== STATS =====================
local StatsFrame = Instance.new("Frame")
StatsFrame.AnchorPoint = Vector2.new(0, 1)
StatsFrame.Position = UDim2.new(0, 12, 1, -12)
StatsFrame.Size = UDim2.new(0, 140, 0, 36)
StatsFrame.BackgroundTransparency = 1
StatsFrame.Visible = false
StatsFrame.ZIndex = 100
StatsFrame.Parent = ScreenGui

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, 0, 1, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "FPS: -- | PING: --"
StatsText.TextColor3 = Color3.fromRGB(235, 235, 245)
StatsText.TextSize = 12
StatsText.Font = Enum.Font.GothamMedium
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Bottom
StatsText.TextStrokeTransparency = 0.2
StatsText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
StatsText.Parent = StatsFrame

local statsOn = false
local statsLoopThread = nil
CreateFeatureToggle("Stats", function(state)
    statsOn = state
    if state then
        StatsFrame.Visible = true
        if statsLoopThread then pcall(task.cancel, statsLoopThread) end
        statsLoopThread = task.spawn(function()
            local frames = 0
            local lastTime = tick()
            local fps = 60
            local fpsConn = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
            while statsOn do
                local now = tick()
                if now - lastTime >= 1 then
                    fps = frames frames = 0 lastTime = now
                end
                StatsText.Text = "FPS: " .. fps .. "  |  PING: " .. math.floor(getPingRaw())
                task.wait(0.5)
            end
            if fpsConn then fpsConn:Disconnect() end
        end)
    else
        StatsFrame.Visible = false
        if statsLoopThread then pcall(task.cancel, statsLoopThread) statsLoopThread = nil end
    end
end)

-- ===================== ANTI-KB =====================
local ANTI_KB_RANGE = 15
local antiKnockbackOn = false
local antiKnockbackConn = nil
local function hasEnemyNearby()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local myPos = myRoot.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local theirHum = player.Character:FindFirstChildOfClass("Humanoid")
            local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if theirHum and theirHum.Health > 0 and theirRoot then
                if (theirRoot.Position - myPos).Magnitude <= ANTI_KB_RANGE then return true end
            end
        end
    end
    return false
end
CreateFeatureToggle("Anti-KB", function(state)
    antiKnockbackOn = state
    if state then
        if antiKnockbackConn then antiKnockbackConn:Disconnect() end
        antiKnockbackConn = RunService.Heartbeat:Connect(function()
            if not antiKnockbackOn then return end
            if not hasEnemyNearby() then return end
            local myChar = LocalPlayer.Character
            if not myChar then return end
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            local root = myChar:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            local vel = root.AssemblyLinearVelocity
            if hum:GetState() == Enum.HumanoidStateType.Freefall
            and hum.Jump == false and math.abs(vel.Y) > 12 then
                root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
            end
        end)
    else
        if antiKnockbackConn then antiKnockbackConn:Disconnect() antiKnockbackConn = nil end
    end
end)

-- ===================== ATTACH (PING-COMPENSATED) =====================
local ATTACH_CONFIG = {
    Range          = 10,       -- увеличено с 8
    HoldRange      = 30,
    OffsetBACK     = 2.5,      -- увеличено с 1.5
    OffsetFRONT    = 3.0,      -- увеличено с 2.0
    OffsetSIDE     = 2.0,      -- увеличено с 1.2
    PredictMul     = 2.0,      -- увеличено с 1.5
    StopSpeed      = 2.0,
    EMA_ALPHA      = 0.75,     -- ускорено с 0.6
    DotThresh      = 0.5,
    ReversalThresh = 0.3,
    ReversalHold   = 0.35,
    PingCap        = 0.40,     -- увеличено с 0.25
    LerpSpeed      = 0.6,      -- плавность вместо телепорта
}

local attachOn = false
local attachConn = nil
local attachTarget = nil
local emaVelocity = Vector3.zero
local lastHorizVel = Vector3.zero
local reversalTime = 0

local function findNearestForAttach()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local best, bestDist = nil, ATTACH_CONFIG.Range
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local theirHum = player.Character:FindFirstChildOfClass("Humanoid")
            local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if theirHum and theirHum.Health > 0 and theirRoot then
                local dist = (theirRoot.Position - myPos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = player
                end
            end
        end
    end
    return best
end

local function pickSide(theirLook, horizVel, speed)
    if speed <= ATTACH_CONFIG.StopSpeed then return "BACK" end
    local unit = horizVel.Unit
    local dot = unit:Dot(theirLook)
    if dot > ATTACH_CONFIG.DotThresh then return "BACK"
    elseif dot < -ATTACH_CONFIG.DotThresh then return "FRONT"
    else
        local left = theirLook:Cross(Vector3.new(0,1,0)).Unit
        if unit:Dot(left) > 0 then return "LEFT" else return "RIGHT" end
    end
end

local function dirFromSide(side, theirLook)
    if side == "BACK" then return -theirLook
    elseif side == "FRONT" then return theirLook
    elseif side == "LEFT" then return theirLook:Cross(Vector3.new(0,1,0)).Unit
    elseif side == "RIGHT" then return -theirLook:Cross(Vector3.new(0,1,0)).Unit
    end
    return -theirLook
end

local function offsetFromSide(side)
    if side == "BACK" then return ATTACH_CONFIG.OffsetBACK
    elseif side == "FRONT" then return ATTACH_CONFIG.OffsetFRONT
    else return ATTACH_CONFIG.OffsetSIDE end
end

CreateFeatureToggle("Attach", function(state)
    attachOn = state
    if state then
        if attachConn then attachConn:Disconnect() end
        emaVelocity = Vector3.zero
        lastHorizVel = Vector3.zero
        reversalTime = 0
        attachTarget = nil
        attachConn = RunService.RenderStepped:Connect(function()
            if not attachOn then return end
            local myChar = LocalPlayer.Character
            if not myChar then return end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if not myRoot or not hum or hum.Health <= 0 then return end

            if not attachTarget or not attachTarget.Parent or not attachTarget.Character then
                attachTarget = findNearestForAttach()
            else
                local chk = attachTarget.Character:FindFirstChild("HumanoidRootPart")
                local chkHum = attachTarget.Character:FindFirstChildOfClass("Humanoid")
                if not chk or not chkHum or chkHum.Health <= 0 then
                    attachTarget = findNearestForAttach()
                elseif (chk.Position - myRoot.Position).Magnitude > ATTACH_CONFIG.HoldRange then
                    attachTarget = findNearestForAttach()
                end
            end
            if not attachTarget or not attachTarget.Character then return end
            local theirRoot = attachTarget.Character:FindFirstChild("HumanoidRootPart")
            if not theirRoot then return end

            local rawVel = theirRoot.AssemblyLinearVelocity
            local horizVel = Vector3.new(rawVel.X, 0, rawVel.Z)
            local speed = horizVel.Magnitude
            local moving = speed > ATTACH_CONFIG.StopSpeed

            local reversal = false
            if moving and lastHorizVel.Magnitude > ATTACH_CONFIG.StopSpeed then
                local dot = horizVel.Unit:Dot(lastHorizVel.Unit)
                if dot < -ATTACH_CONFIG.ReversalThresh then
                    reversal = true
                end
            end
            lastHorizVel = horizVel

            if reversal then
                reversalTime = tick()
            end

            if moving then
                emaVelocity = emaVelocity:Lerp(horizVel, ATTACH_CONFIG.EMA_ALPHA)
            else
                emaVelocity = emaVelocity:Lerp(Vector3.zero, 0.5)
            end

            local theirPos = theirRoot.Position
            local theirLook = theirRoot.CFrame.LookVector
            local fullPing = getPingSeconds(ATTACH_CONFIG.PingCap)

            local inReversalWindow = (tick() - reversalTime) < ATTACH_CONFIG.ReversalHold

            local targetPos
            if inReversalWindow then
                targetPos = theirPos - theirLook * ATTACH_CONFIG.OffsetBACK
            else
                local basePos = theirPos
                if moving then
                    -- ПОЛНАЯ ping-компенсация: ставим туда, где цель БУДЕТ через наш пинг
                    basePos = theirPos + emaVelocity * fullPing * ATTACH_CONFIG.PredictMul
                end
                local side = pickSide(theirLook, horizVel, speed)
                local dir = dirFromSide(side, theirLook)
                local offset = offsetFromSide(side)
                targetPos = basePos + dir * offset
            end

            -- ПЛАВНОЕ следование вместо жёсткого телепорта (убирает откат при пинге)
            local newPos = myRoot.Position:Lerp(targetPos, ATTACH_CONFIG.LerpSpeed)
            myRoot.CFrame = CFrame.new(newPos, theirPos)
            myRoot.AssemblyLinearVelocity = Vector3.zero
        end)
    else
        if attachConn then attachConn:Disconnect() attachConn = nil end
        attachTarget = nil
        emaVelocity = Vector3.zero
        lastHorizVel = Vector3.zero
        reversalTime = 0
    end
end)

-- ===================== AIMBOT (PING-PREDICTIVE) =====================
local AIM_CONFIG = {
    Mode         = 0,
    TargetPart   = "Head",
    Keybind      = Enum.UserInputType.MouseButton2,
    MaxDist      = 500,
    SwitchBuffer = 5,
    PingCap      = 0.40,
}

local aimActive = false
local lockedTarget = nil

local function isTargetValid(target)
    if not target or not target.Parent then return false end
    local char = target.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not char:FindFirstChild(AIM_CONFIG.TargetPart) then return false end
    return true
end

local function findBestTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local best, bestDist = nil, AIM_CONFIG.MaxDist
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isTargetValid(player) then
            local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if theirRoot then
                local dist = (theirRoot.Position - myPos).Magnitude
                if dist < bestDist then bestDist = dist best = player end
            end
        end
    end
    return best
end

local function getDistanceToTarget(target)
    if not target or not target.Character then return math.huge end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local theirRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not theirRoot then return math.huge end
    return (theirRoot.Position - myRoot.Position).Magnitude
end

local function activateAim()
    if aimActive then return end
    aimActive = true
    lockedTarget = findBestTarget()
end
local function deactivateAim()
    if not aimActive then return end
    aimActive = false
    lockedTarget = nil
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AIM_CONFIG.Keybind and AIM_CONFIG.Mode ~= 0 and not aimActive then
        activateAim()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIM_CONFIG.Keybind and aimActive then deactivateAim() end
end)

RunService.RenderStepped:Connect(function()
    if AIM_CONFIG.Mode == 0 or not aimActive then return end
    if not isTargetValid(lockedTarget) then
        lockedTarget = findBestTarget()
    else
        local best = findBestTarget()
        if best and best ~= lockedTarget then
            local distCur = getDistanceToTarget(lockedTarget)
            local distNew = getDistanceToTarget(best)
            if distNew < distCur - AIM_CONFIG.SwitchBuffer then lockedTarget = best end
        end
    end
    if lockedTarget then
        local camera = workspace.CurrentCamera
        local part = lockedTarget.Character and lockedTarget.Character:FindFirstChild(AIM_CONFIG.TargetPart)
        if camera and part then
            local eyePos = camera.CFrame.Position
            local targetPos = part.Position

            -- ПРЕДИКЦИЯ: наводимся туда, где цель БУДЕТ через наш пинг
            local theirRoot = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
            local vel = theirRoot and theirRoot.AssemblyLinearVelocity or Vector3.zero
            local ping = getPingSeconds(AIM_CONFIG.PingCap)
            local predicted = targetPos + vel * ping

            if (predicted - eyePos).Magnitude > 0.1 then
                camera.CFrame = CFrame.new(eyePos, predicted)
            end
        end
    end
end)

-- ===================== AIM BUTTON =====================
local AimBtn = Instance.new("TextButton")
AimBtn.AnchorPoint = Vector2.new(0.5, 0.5)
AimBtn.Position = UDim2.new(1, -50, 1, -50)
AimBtn.Size = UDim2.new(0, 60, 0, 60)
AimBtn.BackgroundColor3 = CONFIG.Panel1
AimBtn.BackgroundTransparency = 0.15
AimBtn.Text = ""
AimBtn.AutoButtonColor = false
AimBtn.BorderSizePixel = 0
AimBtn.Active = true
AimBtn.Visible = false
AimBtn.ZIndex = 50
AimBtn.Parent = ScreenGui

local AimBtnC = Instance.new("UICorner") AimBtnC.CornerRadius = UDim.new(1, 0) AimBtnC.Parent = AimBtn
local AimBtnS = Instance.new("UIStroke")
AimBtnS.Color = CONFIG.Stroke
AimBtnS.Thickness = 1.5
AimBtnS.Parent = AimBtn

local AimRing = Instance.new("Frame")
AimRing.AnchorPoint = Vector2.new(0.5, 0.5)
AimRing.Position = UDim2.new(0.5, 0, 0.5, 0)
AimRing.Size = UDim2.new(0, 34, 0, 34)
AimRing.BackgroundTransparency = 1
AimRing.BorderSizePixel = 0
AimRing.ZIndex = 51
AimRing.Parent = AimBtn
local AimRingC = Instance.new("UICorner") AimRingC.CornerRadius = UDim.new(1, 0) AimRingC.Parent = AimRing
local AimRingS = Instance.new("UIStroke")
AimRingS.Color = CONFIG.Acc1
AimRingS.Thickness = 1.5
AimRingS.Transparency = 0.3
AimRingS.Parent = AimRing

local AimDot = Instance.new("Frame")
AimDot.AnchorPoint = Vector2.new(0.5, 0.5)
AimDot.Position = UDim2.new(0.5, 0, 0.5, 0)
AimDot.Size = UDim2.new(0, 5, 0, 5)
AimDot.BackgroundColor3 = CONFIG.Acc1
AimDot.BorderSizePixel = 0
AimDot.ZIndex = 52
AimDot.Parent = AimBtn
local AimDotC = Instance.new("UICorner") AimDotC.CornerRadius = UDim.new(1, 0) AimDotC.Parent = AimDot

local AimLabel = Instance.new("TextLabel")
AimLabel.AnchorPoint = Vector2.new(0.5, 1)
AimLabel.Position = UDim2.new(0.5, 0, 1, -4)
AimLabel.Size = UDim2.new(1, -10, 0, 11)
AimLabel.BackgroundTransparency = 1
AimLabel.Text = "AIM"
AimLabel.TextColor3 = CONFIG.TextDim
AimLabel.TextSize = 8
AimLabel.Font = Enum.Font.GothamBold
AimLabel.ZIndex = 52
AimLabel.Parent = AimBtn

local function updateAimBtnVisual(mode)
    if mode == 0 then
        AimBtn.Visible = false
    elseif mode == 1 then
        AimBtn.Visible = true
        AimRingS.Color = CONFIG.Acc2
        AimRingS.Transparency = 0.2
        AimRingS.Thickness = 1.5
        AimDot.BackgroundColor3 = CONFIG.Acc2
        AimLabel.TextColor3 = CONFIG.Acc2
        AimLabel.Text = "DRAG"
    else
        AimBtn.Visible = true
        AimRingS.Color = CONFIG.Acc1
        AimRingS.Transparency = 0
        AimRingS.Thickness = 2.5
        AimDot.BackgroundColor3 = CONFIG.Acc1
        AimLabel.TextColor3 = CONFIG.Acc1
        AimLabel.Text = "AIM"
    end
end

CreateAimbotToggle(function(mode)
    AIM_CONFIG.Mode = mode
    if mode == 0 and aimActive then deactivateAim() end
    updateAimBtnVisual(mode)
end)

do
    local pressed = false
    local hasMoved = false
    local dragStart, startPos

    AimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            pressed = true
            hasMoved = false
            dragStart = input.Position
            startPos = AimBtn.Position
        end
    end)
    AimBtn.InputChanged:Connect(function(input)
        if not pressed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude > 12 then
                hasMoved = true
                if AIM_CONFIG.Mode == 1 then
                    AimBtn.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end
    end)
    AimBtn.InputEnded:Connect(function(input)
        if not pressed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local wasMoved = hasMoved
            pressed = false
            hasMoved = false
            if not wasMoved and AIM_CONFIG.Mode == 2 then
                if aimActive then
                    deactivateAim()
                    AimBtn.BackgroundColor3 = CONFIG.Panel1
                else
                    activateAim()
                    AimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                end
            end
        end
    end)
end

-- ===================== FOV CHANGER =====================
local fovOn = false
local fovConn = nil
local fovSaved = 70
CreateFeatureToggle("FOV Changer", function(state)
    fovOn = state
    if state then
        local cam = workspace.CurrentCamera
        if cam then fovSaved = cam.FieldOfView end
        if fovConn then fovConn:Disconnect() end
        fovConn = RunService.RenderStepped:Connect(function()
            local c = workspace.CurrentCamera
            if c then c.FieldOfView = Values.CameraFOV end
        end)
    else
        if fovConn then fovConn:Disconnect() fovConn = nil end
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = fovSaved end
    end
end)
CreateFOVSlider(function(val)
    Values.CameraFOV = val
    if fovOn then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = val end
    end
end)

-- ===================== TOGGLE BUTTON =====================
local ToggleGlow = Instance.new("Frame")
ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleGlow.Size = UDim2.new(0, CONFIG.ToggleSize + 10, 0, CONFIG.ToggleSize + 10)
ToggleGlow.Position = UDim2.new(0, 16 + CONFIG.ToggleSize / 2, 0.5, 0)
ToggleGlow.BackgroundColor3 = CONFIG.Acc3
ToggleGlow.BackgroundTransparency = 0.9
ToggleGlow.BorderSizePixel = 0
ToggleGlow.ZIndex = 19
ToggleGlow.Parent = ScreenGui
ApplyCorner(ToggleGlow, 999)

local Toggle = Instance.new("TextButton")
Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
Toggle.Size = UDim2.new(0, CONFIG.ToggleSize, 0, CONFIG.ToggleSize)
Toggle.Position = UDim2.new(0, 16 + CONFIG.ToggleSize / 2, 0.5, 0)
Toggle.BackgroundColor3 = CONFIG.Panel1
Toggle.Text = "◆"
Toggle.TextColor3 = CONFIG.Acc1
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 18
Toggle.AutoButtonColor = false
Toggle.BorderSizePixel = 0
Toggle.Active = true
Toggle.ZIndex = 20
Toggle.Parent = ScreenGui
ApplyCorner(Toggle, 999)
local ToggleStroke = ApplyStroke(Toggle, CONFIG.Stroke, 1.5, 0.3)

local function TweenObject(obj, time, goal, style, dir)
    local info = TweenInfo.new(time or 0.35, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

local isOpen = false
local OPEN_TIME  = 0.32
local CLOSE_TIME = 0.24
local savedPosition = UDim2.new(0.5, 0, 0.5, 0)
local savedSize     = UDim2.new(0, CONFIG.MenuWidth, 0, CONFIG.MenuHeight)

local function OpenMenu()
    if isOpen then return end
    isOpen = true
    MenuRoot.Visible = true
    MenuRoot.BackgroundTransparency = 1
    TweenObject(MenuRoot, OPEN_TIME, { BackgroundTransparency = 1 - CONFIG.DimOpacity })
    PanelGlow.Position = savedPosition
    PanelGlow.Size = UDim2.new(0, savedSize.X.Offset * 0.9 + 20, 0, savedSize.Y.Offset * 0.9 + 20)
    PanelGlow.BackgroundTransparency = 0.98
    Panel.Position = savedPosition
    Panel.Size = UDim2.new(0, savedSize.X.Offset * 0.88, 0, savedSize.Y.Offset * 0.88)
    Panel.BackgroundTransparency = 0.35
    PanelStroke.Transparency = 1
    TweenObject(Panel, OPEN_TIME, { Size = savedSize, BackgroundTransparency = 0 })
    TweenObject(PanelGlow, OPEN_TIME, {
        Size = UDim2.new(0, savedSize.X.Offset + 20, 0, savedSize.Y.Offset + 20),
        BackgroundTransparency = 0.92,
    })
    TweenObject(PanelStroke, OPEN_TIME, { Transparency = 0 })
    TweenObject(Toggle, 0.3, { BackgroundColor3 = CONFIG.PanelHi, TextColor3 = CONFIG.TextDim })
    TweenObject(ToggleStroke, 0.3, { Transparency = 0.8 })
    TweenObject(ToggleGlow, 0.3, { BackgroundTransparency = 1 })
    Toggle.Text = "X"
end
local function CloseMenu()
    if not isOpen then return end
    isOpen = false
    savedPosition = Panel.Position
    savedSize = Panel.Size
    TweenObject(MenuRoot, CLOSE_TIME, { BackgroundTransparency = 1 })
    local t1 = TweenObject(Panel, CLOSE_TIME, {
        Size = UDim2.new(0, savedSize.X.Offset * 0.88, 0, savedSize.Y.Offset * 0.88),
        BackgroundTransparency = 0.35,
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenObject(PanelGlow, CLOSE_TIME, {
        Size = UDim2.new(0, savedSize.X.Offset * 0.9 + 20, 0, savedSize.Y.Offset * 0.9 + 20),
        BackgroundTransparency = 0.98,
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenObject(PanelStroke, CLOSE_TIME, { Transparency = 1 })
    t1.Completed:Connect(function()
        if not isOpen then
            MenuRoot.Visible = false
            Panel.Size = savedSize
            Panel.BackgroundTransparency = 0
        end
    end)
    TweenObject(Toggle, 0.3, { BackgroundColor3 = CONFIG.Panel1, TextColor3 = CONFIG.Acc1 })
    TweenObject(ToggleStroke, 0.3, { Transparency = 0.3 })
    TweenObject(ToggleGlow, 0.3, { BackgroundTransparency = 0.9 })
    Toggle.Text = "◆"
end

Toggle.MouseButton1Click:Connect(function() if not isOpen then OpenMenu() end end)
CloseBtn.MouseButton1Click:Connect(function() CloseMenu() end)

do
    local pressed = false
    local dragStart, startPos, glowStartPos
    local hasMoved = false
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            pressed = true
            hasMoved = false
            dragStart = input.Position
            startPos = Panel.Position
            glowStartPos = PanelGlow.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if not pressed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude > 12 or hasMoved then
                hasMoved = true
                local newPos = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
                Panel.Position = newPos
                PanelGlow.Position = UDim2.new(
                    glowStartPos.X.Scale, glowStartPos.X.Offset + delta.X,
                    glowStartPos.Y.Scale, glowStartPos.Y.Offset + delta.Y
                )
                savedPosition = newPos
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            pressed = false
            hasMoved = false
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if speedOn and pulseThread then
        pcall(task.cancel, pulseThread)
        pulseThread = task.spawn(pulseLoop)
    end
    if jumpOn and not jumpConn then
        local hum = GetHumanoid()
        if hum then hum.UseJumpPower = true hum.JumpPower = JUMP_POWER end
    end
    if espOn then
        task.wait(0.5)
        refreshAllESP()
    end
    if climbOn then
        climbClear()
        climbLastWall = 0
    end
end)

print("[DECAY] ping-compensated v2 loaded.")
