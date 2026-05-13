--[[
    ╔══════════════════════════════════════════╗
    ║          OceanUI — Roblox Library        ║
    ║       Ocean Theme · Wave Edition         ║
    ╚══════════════════════════════════════════╝

    COMPONENTS:
      • Toggle
      • Button
      • Slider
      • Dropdown
      • MultiDropdown
      • InputBox
      • Paragraph
      • Notify

    USAGE EXAMPLE:
        local OceanUI = loadstring(game:HttpGet("..."))()
        local Window  = OceanUI:CreateWindow({ Title = "My Script" })
        local Tab     = Window:AddTab("Main")
        Tab:AddButton({ Text = "Click Me", Callback = function() print("Hi!") end })
--]]

local OceanUI = {}
OceanUI.__index = OceanUI

---------------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------------
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------------
-- OCEAN THEME PALETTE
---------------------------------------------------------------------------
local Theme = {
    -- Backgrounds
    BG          = Color3.fromRGB(8,  22,  40),   -- deep ocean
    BGSecondary = Color3.fromRGB(12, 32,  58),   -- slightly lighter
    BGTertiary  = Color3.fromRGB(16, 44,  76),   -- panel
    BGHover     = Color3.fromRGB(20, 55,  92),   -- hover state

    -- Accents
    Accent      = Color3.fromRGB(0,  188, 212),  -- cyan wave
    AccentDark  = Color3.fromRGB(0,  137, 167),  -- darker cyan
    AccentGlow  = Color3.fromRGB(64, 224, 255),  -- bright foam

    -- Text
    TextPrimary   = Color3.fromRGB(220, 245, 255),
    TextSecondary = Color3.fromRGB(130, 185, 210),
    TextMuted     = Color3.fromRGB(70,  120, 150),

    -- Status
    Success  = Color3.fromRGB(0,  210, 140),
    Warning  = Color3.fromRGB(255, 185, 0),
    Error    = Color3.fromRGB(255, 75,  75),
    Info     = Color3.fromRGB(0,  188, 212),

    -- Misc
    Separator   = Color3.fromRGB(0,  80,  120),
    Shadow      = Color3.fromRGB(0,  5,   15),
    ToggleOff   = Color3.fromRGB(30, 55,  80),
    ToggleOn    = Color3.fromRGB(0,  188, 212),
    SliderTrack = Color3.fromRGB(15, 45,  70),
    SliderFill  = Color3.fromRGB(0,  188, 212),
    SliderThumb = Color3.fromRGB(220, 245, 255),
}

---------------------------------------------------------------------------
-- TWEEN HELPER
---------------------------------------------------------------------------
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration    or 0.25,
        style       or Enum.EasingStyle.Quart,
        direction   or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

---------------------------------------------------------------------------
-- CREATE INSTANCE HELPER
---------------------------------------------------------------------------
local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

---------------------------------------------------------------------------
-- DRAGGING HELPER
---------------------------------------------------------------------------
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

---------------------------------------------------------------------------
-- RIPPLE EFFECT
---------------------------------------------------------------------------
local function AddRipple(btn)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local rip = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 0.7,
            Size  = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(
                0, input.Position.X - btn.AbsolutePosition.X,
                0, input.Position.Y - btn.AbsolutePosition.Y
            ),
            ZIndex = btn.ZIndex + 1,
            ClipsDescendants = false,
        }, btn)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, rip)
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
        Tween(rip, { Size = UDim2.new(0, sz, 0, sz), BackgroundTransparency = 1 }, 0.5)
        task.delay(0.5, function() rip:Destroy() end)
    end)
end

---------------------------------------------------------------------------
-- SHIMMER WAVE (decorative)
---------------------------------------------------------------------------
local function AddShimmer(frame)
    local shimmer = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.92,
        Size  = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(-0.3, 0, 0, 0),
        ZIndex = frame.ZIndex + 1,
        ClipsDescendants = false,
    }, frame)
    New("UIGradient", {
        Rotation = 30,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, shimmer)

    local function anim()
        shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
        Tween(shimmer, { Position = UDim2.new(1.3, 0, 0, 0) }, 2.5,
              Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(5, anim)
    end
    task.delay(math.random(0, 3), anim)
end

---------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
---------------------------------------------------------------------------
local NotifyHolder = New("ScreenGui", {
    Name = "OceanUI_Notify",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local NotifyStack = New("Frame", {
    BackgroundTransparency = 1,
    Size     = UDim2.new(0, 320, 1, 0),
    Position = UDim2.new(1, -340, 0, 20),
    AnchorPoint = Vector2.new(0, 0),
}, NotifyHolder)

New("UIListLayout", {
    SortOrder       = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding         = UDim.new(0, 8),
}, NotifyStack)

local function Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "OceanUI"
    local text     = opts.Text     or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info" -- Info | Success | Warning | Error

    local colorMap = {
        Info    = Theme.Info,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error   = Theme.Error,
    }
    local accentColor = colorMap[ntype] or Theme.Info

    local card = New("Frame", {
        BackgroundColor3 = Theme.BGTertiary,
        Size    = UDim2.new(1, 0, 0, 72),
        ClipsDescendants = true,
        BackgroundTransparency = 0,
    }, NotifyStack)
    New("UICorner",  { CornerRadius = UDim.new(0, 10) }, card)
    New("UIStroke",  { Color = accentColor, Thickness = 1.2, Transparency = 0.4 }, card)

    -- Left accent bar
    New("Frame", {
        BackgroundColor3 = accentColor,
        Size    = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    }, card)

    -- Icon circle
    local iconBg = New("Frame", {
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.75,
        Size    = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    }, card)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, iconBg)

    local iconSymbols = { Info = "ℹ", Success = "✓", Warning = "⚠", Error = "✕" }
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = iconSymbols[ntype] or "ℹ",
        TextColor3 = accentColor,
        TextSize = 16,
    }, iconBg)

    -- Title
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 62, 0, 12),
        Font     = Enum.Font.GothamBold,
        Text     = title,
        TextColor3  = Theme.TextPrimary,
        TextSize    = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    -- Message
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -72, 0, 28),
        Position = UDim2.new(0, 62, 0, 34),
        Font     = Enum.Font.Gotham,
        Text     = text,
        TextColor3  = Theme.TextSecondary,
        TextSize    = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, card)

    -- Progress bar
    local progBG = New("Frame", {
        BackgroundColor3 = Theme.SliderTrack,
        Size     = UDim2.new(1, -8, 0, 2),
        Position = UDim2.new(0, 4, 1, -4),
        AnchorPoint = Vector2.new(0, 1),
    }, card)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, progBG)

    local progFill = New("Frame", {
        BackgroundColor3 = accentColor,
        Size = UDim2.new(1, 0, 1, 0),
    }, progBG)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, progFill)

    -- Slide in
    card.Position = UDim2.new(1, 20, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35)

    -- Progress shrink
    Tween(progFill, { Size = UDim2.new(0, 0, 1, 0) }, duration,
          Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    task.delay(duration, function()
        Tween(card, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, 0.3)
        task.delay(0.3, function() card:Destroy() end)
    end)

    return card
end

OceanUI.Notify = Notify

---------------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------------
function OceanUI:CreateWindow(config)
    config = config or {}
    local title  = config.Title  or "OceanUI"
    local width  = config.Width  or 560
    local height = config.Height or 400

    local ScreenGui = New("ScreenGui", {
        Name = "OceanUI_" .. title,
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    -- Shadow
    local Shadow = New("Frame", {
        BackgroundColor3 = Theme.Shadow,
        BackgroundTransparency = 0.4,
        Size    = UDim2.new(0, width + 20, 0, height + 20),
        Position = UDim2.new(0.5, -(width / 2) - 10, 0.5, -(height / 2) - 10),
        AnchorPoint = Vector2.new(0, 0),
        ZIndex = 0,
    }, ScreenGui)
    New("UICorner", { CornerRadius = UDim.new(0, 18) }, Shadow)

    -- Main frame
    local Main = New("Frame", {
        Name = "Main",
        BackgroundColor3 = Theme.BG,
        Size    = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        ClipsDescendants = true,
        ZIndex = 1,
    }, ScreenGui)
    New("UICorner", { CornerRadius = UDim.new(0, 14) }, Main)
    New("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.4,
        Transparency = 0.5,
    }, Main)

    -- Ocean BG gradient
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 22, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 30, 55)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(6, 18, 35)),
        }),
        Rotation = 135,
    }, Main)

    -- Animated wave lines (decorative)
    for i = 1, 3 do
        local wave = New("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.88 + i * 0.03,
            Size    = UDim2.new(1.5, 0, 0, 1),
            Position = UDim2.new(-0.5, 0, 0.3 + i * 0.18, 0),
            ZIndex = 1,
        }, Main)
        local function animWave()
            wave.Position = UDim2.new(-0.5, 0, 0.3 + i * 0.18, 0)
            Tween(wave, { Position = UDim2.new(0.1, 0, 0.32 + i * 0.18, 0) },
                  3 + i, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(3 + i, function()
                Tween(wave, { Position = UDim2.new(-0.5, 0, 0.3 + i * 0.18, 0) },
                      3 + i, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.delay(3 + i, animWave)
            end)
        end
        task.delay(i * 0.8, animWave)
    end

    -- ── Title Bar ──────────────────────────────────────────────────────
    local TitleBar = New("Frame", {
        BackgroundColor3 = Theme.BGSecondary,
        Size     = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex   = 3,
    }, Main)
    New("UICorner", { CornerRadius = UDim.new(0, 14) }, TitleBar)
    -- fix bottom corners
    New("Frame", {
        BackgroundColor3 = Theme.BGSecondary,
        Size    = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        ZIndex = 3,
    }, TitleBar)

    -- Wave icon
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Font     = Enum.Font.GothamBold,
        Text     = "〜",
        TextColor3  = Theme.AccentGlow,
        TextSize    = 20,
        ZIndex   = 4,
    }, TitleBar)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        Font     = Enum.Font.GothamBold,
        Text     = title,
        TextColor3  = Theme.TextPrimary,
        TextSize    = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex   = 4,
    }, TitleBar)

    -- Close button
    local CloseBtn = New("TextButton", {
        BackgroundColor3 = Color3.fromRGB(255, 75, 75),
        Size    = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -28, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text    = "",
        ZIndex  = 4,
    }, TitleBar)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { Size = UDim2.new(0, width, 0, 0), Position = UDim2.new(0.5, -width/2, 0.5, 0) }, 0.3)
        task.delay(0.31, function() ScreenGui:Destroy() end)
    end)

    -- Minimize
    local MinBtn = New("TextButton", {
        BackgroundColor3 = Theme.Warning,
        Size    = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text    = "",
        ZIndex  = 4,
    }, TitleBar)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, MinBtn)
    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Tween(Main, {
            Size = minimised
                and UDim2.new(0, width, 0, 44)
                or  UDim2.new(0, width, 0, height)
        }, 0.3)
    end)

    MakeDraggable(Main, TitleBar)

    -- ── Tab Bar ────────────────────────────────────────────────────────
    local TabBar = New("Frame", {
        BackgroundColor3 = Theme.BGSecondary,
        Size     = UDim2.new(0, 130, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        ClipsDescendants = true,
        ZIndex   = 2,
    }, Main)

    New("UIListLayout", {
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Padding     = UDim.new(0, 4),
    }, TabBar)
    New("UIPadding", {
        PaddingTop   = UDim.new(0, 10),
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, TabBar)

    -- Separator line
    New("Frame", {
        BackgroundColor3 = Theme.Separator,
        Size    = UDim2.new(0, 1, 1, -44),
        Position = UDim2.new(0, 130, 0, 44),
        ZIndex  = 2,
    }, Main)

    -- Content area
    local ContentArea = New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -138, 1, -52),
        Position = UDim2.new(0, 138, 0, 52),
        ClipsDescendants = true,
        ZIndex   = 2,
    }, Main)

    -- Entry animation
    Main.Size = UDim2.new(0, width, 0, 0)
    Main.Position = UDim2.new(0.5, -width/2, 0.5, 0)
    Tween(Main, {
        Size     = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
    }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -----------------------------------------------------------------
    -- Window object
    -----------------------------------------------------------------
    local Window = {}
    local tabs   = {}
    local activeTab = nil

    local function switchTab(tabObj)
        if activeTab == tabObj then return end
        if activeTab then
            Tween(activeTab.Btn, { BackgroundColor3 = Theme.BGTertiary }, 0.2)
            activeTab.Btn.TitleLabel.TextColor3 = Theme.TextSecondary
            activeTab.Panel.Visible = false
        end
        activeTab = tabObj
        Tween(tabObj.Btn, { BackgroundColor3 = Theme.AccentDark }, 0.2)
        tabObj.Btn.TitleLabel.TextColor3 = Theme.TextPrimary
        tabObj.Panel.Visible = true
    end

    function Window:AddTab(name)
        local btn = New("TextButton", {
            BackgroundColor3 = Theme.BGTertiary,
            Size    = UDim2.new(1, 0, 0, 34),
            Text    = "",
            AutoButtonColor = false,
            ZIndex  = 3,
        }, TabBar)
        New("UICorner", { CornerRadius = UDim.new(0, 8) }, btn)

        local label = New("TextLabel", {
            Name = "TitleLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3  = Theme.TextSecondary,
            TextSize    = 12,
            ZIndex      = 4,
        }, btn)

        -- Tab content panel
        local panel = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible  = false,
            ZIndex   = 2,
        }, ContentArea)
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
        }, panel)
        New("UIPadding", {
            PaddingTop    = UDim.new(0, 8),
            PaddingLeft   = UDim.new(0, 8),
            PaddingRight  = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }, panel)

        local tabObj = { Btn = btn, Panel = panel }

        btn.MouseButton1Click:Connect(function()
            switchTab(tabObj)
        end)
        btn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Tween(btn, { BackgroundColor3 = Theme.BGHover }, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                Tween(btn, { BackgroundColor3 = Theme.BGTertiary }, 0.15)
            end
        end)

        table.insert(tabs, tabObj)
        if #tabs == 1 then switchTab(tabObj) end

        ------------------------------------------------------------------
        -- Tab API
        ------------------------------------------------------------------
        local Tab = {}

        -- Shared card builder
        local function MakeCard(h)
            local card = New("Frame", {
                BackgroundColor3 = Theme.BGTertiary,
                Size    = UDim2.new(1, 0, 0, h or 40),
                ZIndex  = 3,
            }, panel)
            New("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            return card
        end

        -- ── BUTTON ────────────────────────────────────────────────
        function Tab:AddButton(opts)
            opts = opts or {}
            local card = MakeCard(38)

            local btn = New("TextButton", {
                BackgroundColor3 = Theme.AccentDark,
                Size    = UDim2.new(1, -16, 0, 26),
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Text    = opts.Text or "Button",
                Font    = Enum.Font.GothamBold,
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                AutoButtonColor = false,
                ClipsDescendants = true,
                ZIndex  = 4,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentDark),
                }),
                Rotation = 90,
            }, btn)
            AddRipple(btn)
            AddShimmer(btn)

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.AccentGlow }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.AccentDark }, 0.15)
            end)
            btn.MouseButton1Click:Connect(function()
                if opts.Callback then opts.Callback() end
            end)

            return btn
        end

        -- ── TOGGLE ────────────────────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local state = opts.Default or false
            local card  = MakeCard(40)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font     = Enum.Font.GothamSemibold,
                Text     = opts.Text or "Toggle",
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
            }, card)

            local track = New("Frame", {
                BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                Size    = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -54, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex  = 4,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

            local thumb = New("Frame", {
                BackgroundColor3 = Theme.SliderThumb,
                Size    = UDim2.new(0, 16, 0, 16),
                Position = state
                    and UDim2.new(1, -19, 0.5, 0)
                    or  UDim2.new(0, 3,   0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex  = 5,
            }, track)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)

            local clickRegion = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
            }, card)

            clickRegion.MouseButton1Click:Connect(function()
                state = not state
                Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Tween(thumb, {
                    Position = state
                        and UDim2.new(1, -19, 0.5, 0)
                        or  UDim2.new(0, 3,   0.5, 0)
                }, 0.2, Enum.EasingStyle.Back)
                if opts.Callback then opts.Callback(state) end
            end)

            local api = {}
            function api:Set(val)
                state = val
                Tween(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Tween(thumb, {
                    Position = state
                        and UDim2.new(1, -19, 0.5, 0)
                        or  UDim2.new(0, 3,   0.5, 0)
                }, 0.2, Enum.EasingStyle.Back)
            end
            function api:Get() return state end
            return api
        end

        -- ── SLIDER ────────────────────────────────────────────────
        function Tab:AddSlider(opts)
            opts = opts or {}
            local min  = opts.Min     or 0
            local max  = opts.Max     or 100
            local val  = opts.Default or min
            local card = MakeCard(54)

            local header = New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -12, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                Font     = Enum.Font.GothamSemibold,
                Text     = opts.Text or "Slider",
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
            }, card)

            local valLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 50, 0, 18),
                Position = UDim2.new(1, -62, 0, 6),
                Font     = Enum.Font.GothamBold,
                Text     = tostring(val),
                TextColor3  = Theme.AccentGlow,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex   = 4,
            }, card)

            local track = New("Frame", {
                BackgroundColor3 = Theme.SliderTrack,
                Size    = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 36),
                ZIndex  = 4,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

            local pct = (val - min) / (max - min)
            local fill = New("Frame", {
                BackgroundColor3 = Theme.SliderFill,
                Size    = UDim2.new(pct, 0, 1, 0),
                ZIndex  = 5,
            }, track)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentDark),
                    ColorSequenceKeypoint.new(1, Theme.AccentGlow),
                }),
            }, fill)

            local thumb = New("Frame", {
                BackgroundColor3 = Theme.SliderThumb,
                Size    = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(pct, -7, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex  = 6,
            }, track)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)
            New("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Transparency = 0.3 }, thumb)

            local dragging = false
            local function update(input)
                local relX = math.clamp(
                    (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                    0, 1
                )
                val = math.floor(min + relX * (max - min))
                valLabel.Text = tostring(val)
                Tween(fill,  { Size     = UDim2.new(relX, 0, 1, 0) },       0.05)
                Tween(thumb, { Position = UDim2.new(relX, -7, 0.5, 0) }, 0.05)
                if opts.Callback then opts.Callback(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local api = {}
            function api:Set(v)
                val = math.clamp(v, min, max)
                local r = (val - min) / (max - min)
                valLabel.Text = tostring(val)
                Tween(fill,  { Size     = UDim2.new(r, 0, 1, 0) },       0.2)
                Tween(thumb, { Position = UDim2.new(r, -7, 0.5, 0) }, 0.2)
            end
            function api:Get() return val end
            return api
        end

        -- ── DROPDOWN ──────────────────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local options  = opts.Options  or {}
            local selected = opts.Default  or nil
            local open     = false
            local card     = MakeCard(38)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font     = Enum.Font.GothamSemibold,
                Text     = opts.Text or "Dropdown",
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
            }, card)

            local selBtn = New("TextButton", {
                BackgroundColor3 = Theme.BGSecondary,
                Size    = UDim2.new(0.48, 0, 0, 26),
                Position = UDim2.new(0.52, -8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Text    = selected or "Select...",
                Font    = Enum.Font.Gotham,
                TextColor3  = selected and Theme.TextPrimary or Theme.TextMuted,
                TextSize    = 11,
                AutoButtonColor = false,
                ClipsDescendants = true,
                ZIndex  = 4,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 6) }, selBtn)
            New("UIStroke", { Color = Theme.Separator, Thickness = 1 }, selBtn)

            -- Arrow
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                Text     = "▾",
                Font     = Enum.Font.GothamBold,
                TextColor3  = Theme.AccentGlow,
                TextSize    = 12,
                ZIndex   = 5,
            }, selBtn)

            -- Dropdown list (rendered in panel, above card)
            local list = New("Frame", {
                BackgroundColor3 = Theme.BGSecondary,
                Size    = UDim2.new(0.48, 0, 0, #options * 28 + 6),
                Position = UDim2.new(0.52, -8, 1, 2),
                ZIndex  = 10,
                Visible = false,
                ClipsDescendants = true,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 8) }, list)
            New("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.5 }, list)
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, list)
            New("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3) }, list)

            for _, opt in ipairs(options) do
                local item = New("TextButton", {
                    BackgroundColor3 = Theme.BGTertiary,
                    Size    = UDim2.new(1, 0, 0, 26),
                    Text    = opt,
                    Font    = Enum.Font.Gotham,
                    TextColor3  = Theme.TextPrimary,
                    TextSize    = 11,
                    AutoButtonColor = false,
                    ZIndex  = 11,
                }, list)
                New("UICorner", { CornerRadius = UDim.new(0, 5) }, item)
                item.MouseEnter:Connect(function()
                    Tween(item, { BackgroundColor3 = Theme.BGHover }, 0.1)
                end)
                item.MouseLeave:Connect(function()
                    Tween(item, { BackgroundColor3 = Theme.BGTertiary }, 0.1)
                end)
                item.MouseButton1Click:Connect(function()
                    selected = opt
                    selBtn.Text = opt
                    selBtn.TextColor3 = Theme.TextPrimary
                    open = false
                    list.Visible = false
                    if opts.Callback then opts.Callback(opt) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                list.Visible = open
                card.ZIndex = open and 20 or 3
            end)

            local api = {}
            function api:Set(v) selected = v; selBtn.Text = v end
            function api:Get() return selected end
            return api
        end

        -- ── MULTI-DROPDOWN ────────────────────────────────────────
        function Tab:AddMultiDropdown(opts)
            opts = opts or {}
            local options   = opts.Options  or {}
            local selected  = {}
            local open      = false
            local card      = MakeCard(38)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font     = Enum.Font.GothamSemibold,
                Text     = opts.Text or "MultiDropdown",
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
            }, card)

            local selBtn = New("TextButton", {
                BackgroundColor3 = Theme.BGSecondary,
                Size    = UDim2.new(0.48, 0, 0, 26),
                Position = UDim2.new(0.52, -8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Text    = "Select...",
                Font    = Enum.Font.Gotham,
                TextColor3  = Theme.TextMuted,
                TextSize    = 10,
                AutoButtonColor = false,
                ClipsDescendants = true,
                ZIndex  = 4,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 6) }, selBtn)
            New("UIStroke", { Color = Theme.Separator, Thickness = 1 }, selBtn)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                Text     = "▾",
                Font     = Enum.Font.GothamBold,
                TextColor3  = Theme.AccentGlow,
                TextSize    = 12,
                ZIndex   = 5,
            }, selBtn)

            local list = New("Frame", {
                BackgroundColor3 = Theme.BGSecondary,
                Size    = UDim2.new(0.48, 0, 0, #options * 28 + 6),
                Position = UDim2.new(0.52, -8, 1, 2),
                ZIndex  = 10,
                Visible = false,
                ClipsDescendants = true,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 8) }, list)
            New("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 0.5 }, list)
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, list)
            New("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3) }, list)

            local checkboxes = {}
            local function refreshLabel()
                local t = {}
                for _, v in ipairs(options) do
                    if selected[v] then table.insert(t, v) end
                end
                if #t == 0 then
                    selBtn.Text = "Select..."
                    selBtn.TextColor3 = Theme.TextMuted
                else
                    selBtn.Text = table.concat(t, ", ")
                    selBtn.TextColor3 = Theme.TextPrimary
                end
            end

            for _, opt in ipairs(options) do
                local row = New("TextButton", {
                    BackgroundColor3 = Theme.BGTertiary,
                    Size    = UDim2.new(1, 0, 0, 26),
                    Text    = "",
                    AutoButtonColor = false,
                    ZIndex  = 11,
                }, list)
                New("UICorner", { CornerRadius = UDim.new(0, 5) }, row)

                local chk = New("Frame", {
                    BackgroundColor3 = selected[opt] and Theme.Accent or Theme.SliderTrack,
                    Size    = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 8, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    ZIndex  = 12,
                }, row)
                New("UICorner", { CornerRadius = UDim.new(0, 3) }, chk)

                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 28, 0, 0),
                    Text     = opt,
                    Font     = Enum.Font.Gotham,
                    TextColor3  = Theme.TextPrimary,
                    TextSize    = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 12,
                }, row)

                checkboxes[opt] = chk
                row.MouseEnter:Connect(function()
                    Tween(row, { BackgroundColor3 = Theme.BGHover }, 0.1)
                end)
                row.MouseLeave:Connect(function()
                    Tween(row, { BackgroundColor3 = Theme.BGTertiary }, 0.1)
                end)
                row.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    Tween(chk, {
                        BackgroundColor3 = selected[opt] and Theme.Accent or Theme.SliderTrack
                    }, 0.15)
                    refreshLabel()
                    if opts.Callback then opts.Callback(selected) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                list.Visible = open
                card.ZIndex = open and 20 or 3
            end)

            local api = {}
            function api:Get()
                local t = {}
                for k, v in pairs(selected) do if v then table.insert(t, k) end end
                return t
            end
            return api
        end

        -- ── INPUT BOX ─────────────────────────────────────────────
        function Tab:AddInputBox(opts)
            opts = opts or {}
            local card = MakeCard(54)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -12, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                Font     = Enum.Font.GothamSemibold,
                Text     = opts.Text or "Input",
                TextColor3  = Theme.TextPrimary,
                TextSize    = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
            }, card)

            local box = New("TextBox", {
                BackgroundColor3 = Theme.BGSecondary,
                Size    = UDim2.new(1, -24, 0, 24),
                Position = UDim2.new(0, 12, 0, 26),
                Font    = Enum.Font.Gotham,
                Text    = opts.Default or "",
                PlaceholderText = opts.Placeholder or "Enter text...",
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3  = Theme.TextPrimary,
                TextSize    = 11,
                ClearTextOnFocus = opts.ClearOnFocus ~= false,
                ZIndex  = 4,
                ClipsDescendants = true,
            }, card)
            New("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
            New("UIStroke", { Color = Theme.Separator, Thickness = 1 }, box)
            New("UIPadding", { PaddingLeft = UDim.new(0, 8) }, box)

            box.Focused:Connect(function()
                Tween(box, { BackgroundColor3 = Theme.BGTertiary }, 0.15)
                New("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Transparency = 0.2 }, box)
            end)
            box.FocusLost:Connect(function(enter)
                Tween(box, { BackgroundColor3 = Theme.BGSecondary }, 0.15)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            local api = {}
            function api:Get() return box.Text end
            function api:Set(v) box.Text = v end
            return api
        end

        -- ── PARAGRAPH ─────────────────────────────────────────────
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local text = opts.Text or ""
            local lines = math.max(1, math.ceil(#text / 55))
            local h = 28 + lines * 14
            local card = MakeCard(h)

            if opts.Title then
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -16, 0, 16),
                    Position = UDim2.new(0, 12, 0, 6),
                    Font     = Enum.Font.GothamBold,
                    Text     = opts.Title,
                    TextColor3  = Theme.AccentGlow,
                    TextSize    = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 4,
                }, card)
            end

            local off = opts.Title and 22 or 8
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -16, 1, -(off + 6)),
                Position = UDim2.new(0, 12, 0, off),
                Font     = Enum.Font.Gotham,
                Text     = text,
                TextColor3  = Theme.TextSecondary,
                TextSize    = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex   = 4,
            }, card)

            -- decorative left border
            New("Frame", {
                BackgroundColor3 = Theme.Accent,
                Size    = UDim2.new(0, 3, 0.7, 0),
                Position = UDim2.new(0, 0, 0.15, 0),
                ZIndex  = 4,
            }, card)

            local api = {}
            function api:SetText(t) end -- extend if needed
            return api
        end

        return Tab
    end

    -- ── Window-level Notify shortcut ──────────────────────────────────
    function Window:Notify(opts)
        Notify(opts)
    end

    return Window
end

---------------------------------------------------------------------------
-- RETURN LIBRARY
---------------------------------------------------------------------------
return OceanUI
