--[[
    ╔══════════════════════════════════════════╗
    ║          OceanUI — Roblox Library        ║
    ║       Ocean Theme · v2                   ║
    ╚══════════════════════════════════════════╝

--]]

local OceanUI   = {}
OceanUI.__index = OceanUI

----------------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------------
-- OCEAN THEME
----------------------------------------------------------------------
local T = {
    -- Backgrounds (all explicit, no gradients on main frame)
    BG        = Color3.fromRGB(11, 26, 48),
    BGPanel   = Color3.fromRGB(15, 34, 60),
    BGCard    = Color3.fromRGB(19, 42, 72),
    BGHover   = Color3.fromRGB(24, 52, 86),
    BGInput   = Color3.fromRGB(13, 30, 54),

    -- Accent cyan
    Accent    = Color3.fromRGB(0,  188, 212),
    AccentDk  = Color3.fromRGB(0,  140, 165),
    AccentGlow= Color3.fromRGB(90, 235, 255),
    AccentLine= Color3.fromRGB(0,  80,  120),

    -- Text
    TextPri   = Color3.fromRGB(215, 242, 255),
    TextSec   = Color3.fromRGB(115, 172, 205),
    TextMuted = Color3.fromRGB(62,  108, 142),

    -- Status
    Success   = Color3.fromRGB(0,  210, 130),
    Warning   = Color3.fromRGB(255, 185, 30),
    Error     = Color3.fromRGB(255, 70,  70),
    Info      = Color3.fromRGB(0,  188, 212),

    TrackBG   = Color3.fromRGB(12, 32, 56),
    ToggleOff = Color3.fromRGB(24, 50, 78),
}

----------------------------------------------------------------------
-- UTILITY HELPERS
----------------------------------------------------------------------
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Tw(obj, goal, dur, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or .22,
            sty or Enum.EasingStyle.Quart,
            dir or Enum.EasingDirection.Out),
        goal):Play()
end

local function Rnd(cls, radius, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Pad(t, b, l, r, parent)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
        PaddingRight  = UDim.new(0, r),
    }, parent)
end

----------------------------------------------------------------------
-- DRAGGABLE
----------------------------------------------------------------------
local function MakeDraggable(frame, handle)
    local drag, mStart, fStart
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        drag = true; mStart = i.Position; fStart = frame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - mStart
            frame.Position = UDim2.new(
                fStart.X.Scale, fStart.X.Offset + d.X,
                fStart.Y.Scale, fStart.Y.Offset + d.Y)
        end
    end)
end

----------------------------------------------------------------------
-- RIPPLE EFFECT
----------------------------------------------------------------------
local function Ripple(btn)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local r = New("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = .72,
            Size = UDim2.new(0,0,0,0),
            AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(0, i.Position.X - btn.AbsolutePosition.X,
                                  0, i.Position.Y - btn.AbsolutePosition.Y),
            ZIndex = btn.ZIndex + 3,
        }, btn)
        Rnd(999, r)
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.6
        Tw(r, { Size = UDim2.new(0,sz,0,sz), BackgroundTransparency = 1 }, .44)
        task.delay(.46, function() r:Destroy() end)
    end)
end

----------------------------------------------------------------------
-- GLOBAL NOTIFY
----------------------------------------------------------------------
local _NGui = New("ScreenGui", {
    Name="OceanNotify", IgnoreGuiInset=true,
    ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local _NStack = New("Frame", {
    BackgroundTransparency=1,
    Size=UDim2.new(0,300,1,0),
    Position=UDim2.new(1,-316,0,16),
}, _NGui)
New("UIListLayout", {
    SortOrder=Enum.SortOrder.LayoutOrder,
    VerticalAlignment=Enum.VerticalAlignment.Top,
    Padding=UDim.new(0,8),
}, _NStack)

local function Notify(opts)
    opts = opts or {}
    local ntype    = opts.Type     or "Info"
    local accC     = ({Info=T.Info,Success=T.Success,Warning=T.Warning,Error=T.Error})[ntype] or T.Info
    local icons    = {Info="ℹ",Success="✓",Warning="⚠",Error="✕"}
    local duration = opts.Duration or 4

    local card = New("Frame", {
        BackgroundColor3=T.BGPanel,
        Size=UDim2.new(1,0,0,70),
        ClipsDescendants=true,
    }, _NStack)
    Rnd(10, card)
    New("UIStroke",{Color=accC,Thickness=1.2,Transparency=.4},card)

    -- left bar
    New("Frame",{BackgroundColor3=accC,Size=UDim2.new(0,4,1,0),ZIndex=2},card)

    -- icon bg
    local ibg = New("Frame",{
        BackgroundColor3=accC,BackgroundTransparency=.75,
        Size=UDim2.new(0,32,0,32),
        Position=UDim2.new(0,14,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=2,
    },card)
    Rnd(99,ibg)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text=icons[ntype] or "ℹ",
        TextColor3=accC,TextSize=14,ZIndex=3},ibg)

    New("TextLabel",{BackgroundTransparency=1,
        Size=UDim2.new(1,-62,0,18),Position=UDim2.new(0,54,0,10),
        Font=Enum.Font.GothamBold,Text=opts.Title or "OceanUI",
        TextColor3=T.TextPri,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},card)

    New("TextLabel",{BackgroundTransparency=1,
        Size=UDim2.new(1,-62,0,26),Position=UDim2.new(0,54,0,28),
        Font=Enum.Font.Gotham,Text=opts.Text or "",
        TextColor3=T.TextSec,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,ZIndex=2},card)

    -- progress bar
    local pb=New("Frame",{BackgroundColor3=T.TrackBG,Size=UDim2.new(1,-8,0,2),
        Position=UDim2.new(0,4,1,-4),AnchorPoint=Vector2.new(0,1),ZIndex=2},card)
    Rnd(99,pb)
    local pf=New("Frame",{BackgroundColor3=accC,Size=UDim2.new(1,0,1,0),ZIndex=3},pb)
    Rnd(99,pf)

    -- animate in
    card.Position = UDim2.new(1,10,0,0)
    Tw(card,{Position=UDim2.new(0,0,0,0)},.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    Tw(pf,{Size=UDim2.new(0,0,1,0)},duration,Enum.EasingStyle.Linear)

    task.delay(duration,function()
        Tw(card,{Position=UDim2.new(1,10,0,0)},.28)
        task.delay(.3,function() card:Destroy() end)
    end)
end

OceanUI.Notify = Notify

----------------------------------------------------------------------
-- CREATE WINDOW
----------------------------------------------------------------------
function OceanUI:CreateWindow(cfg)
    cfg = cfg or {}
    local TITLE = cfg.Title  or "Ocean Hub"
    local W     = cfg.Width  or 540
    local H     = cfg.Height or 380
    local TAB_W = 112

    local SG = New("ScreenGui",{
        Name="OceanUI_"..TITLE, IgnoreGuiInset=true,
        ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    ------------------------------------------------------------------
    -- ROOT FRAME (explicit solid color — no gradient on root)
    ------------------------------------------------------------------
    local Root = New("Frame",{
        Name="Root",
        BackgroundColor3 = T.BG,
        Size    = UDim2.new(0,W,0,H),
        Position= UDim2.new(.5,-W/2,.5,-H/2),
        ClipsDescendants = true,
        ZIndex  = 1,
    }, SG)
    Rnd(14, Root)
    New("UIStroke",{Color=T.AccentLine,Thickness=1.5,Transparency=.25},Root)

    ------------------------------------------------------------------
    -- ANIMATED WAVE LINES inside root (pure frames, not gradient)
    ------------------------------------------------------------------
    for i = 1,4 do
        local wl = New("Frame",{
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = .88 + i*.02,
            Size = UDim2.new(1.8,0,0,1.5),
            Position = UDim2.new(-.8,0, .28+i*.15,0),
            ZIndex=1,
        },Root)
        Rnd(99,wl)
        local function animWave()
            Tw(wl,{Position=UDim2.new(.1,0,.28+i*.15+(i%2==0 and .04 or -.04),0)},2.8+i*.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.delay(2.8+i*.5,function()
                Tw(wl,{Position=UDim2.new(-.8,0,.28+i*.15,0)},2.8+i*.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
                task.delay(2.8+i*.5,animWave)
            end)
        end
        task.delay(i*.7, animWave)
    end

    -- Floating bubble dots
    for i=1,5 do
        local sz = math.random(3,8)
        local bub = New("Frame",{
            BackgroundColor3=T.AccentGlow,
            BackgroundTransparency=.78,
            Size=UDim2.new(0,sz,0,sz),
            Position=UDim2.new(0,math.random(10,W-10),1.05,0),
            ZIndex=1,
        },Root)
        Rnd(99,bub)
        local function rise()
            local x=math.random(10,W-10)
            bub.Position=UDim2.new(0,x,1.05,0)
            bub.BackgroundTransparency=.78
            Tw(bub,{Position=UDim2.new(0,x+math.random(-20,20),-0.08,0),BackgroundTransparency=1},math.random(4,8)+0.0,Enum.EasingStyle.Sine)
            task.delay(math.random(5,10),rise)
        end
        task.delay(math.random(0,6),rise)
    end

    ------------------------------------------------------------------
    -- TITLE BAR
    ------------------------------------------------------------------
    local TBar = New("Frame",{
        BackgroundColor3=T.BGPanel,
        Size=UDim2.new(1,0,0,42),
        ZIndex=5,
    },Root)
    Rnd(14,TBar)
    -- cover bottom rounded corners of title bar
    New("Frame",{BackgroundColor3=T.BGPanel,Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),ZIndex=5},TBar)
    -- bottom separator
    New("Frame",{BackgroundColor3=T.AccentLine,BackgroundTransparency=.5,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),ZIndex=6},TBar)

    -- Wave icon
    New("TextLabel",{BackgroundTransparency=1,
        Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,.5,0),AnchorPoint=Vector2.new(0,.5),
        Font=Enum.Font.GothamBold,Text="〜",TextColor3=T.AccentGlow,TextSize=17,ZIndex=6},TBar)

    New("TextLabel",{BackgroundTransparency=1,
        Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,40,0,0),
        Font=Enum.Font.GothamBold,Text=TITLE,
        TextColor3=T.TextPri,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},TBar)

    -- ── Minimize button
    local MinBtn = New("TextButton",{
        BackgroundColor3=Color3.fromRGB(230,170,0),
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(1,-38,.5,0),AnchorPoint=Vector2.new(1,.5),
        Text="",AutoButtonColor=false,ZIndex=7,
    },TBar)
    Rnd(99,MinBtn)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text="–",TextColor3=Color3.new(1,1,1),TextSize=12,ZIndex=8},MinBtn)

    -- ── Close button
    local CloseBtn = New("TextButton",{
        BackgroundColor3=Color3.fromRGB(218,58,58),
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(1,-16,.5,0),AnchorPoint=Vector2.new(1,.5),
        Text="",AutoButtonColor=false,ZIndex=7,
    },TBar)
    Rnd(99,CloseBtn)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text="×",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=8},CloseBtn)

    CloseBtn.MouseEnter:Connect(function()
        Tw(CloseBtn,{BackgroundColor3=Color3.fromRGB(255,80,80),Size=UDim2.new(0,16,0,16)},.14)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tw(CloseBtn,{BackgroundColor3=Color3.fromRGB(218,58,58),Size=UDim2.new(0,14,0,14)},.14)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tw(Root,{Size=UDim2.new(0,W,0,0),Position=UDim2.new(.5,-W/2,.5,0)},.28,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.delay(.3,function() SG:Destroy() end)
    end)

    local minimised = false
    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Tw(Root,{Size=minimised and UDim2.new(0,W,0,42) or UDim2.new(0,W,0,H)},.3,Enum.EasingStyle.Back)
    end)

    MakeDraggable(Root, TBar)

    ------------------------------------------------------------------
    -- SIDEBAR
    ------------------------------------------------------------------
    local Sidebar = New("Frame",{
        BackgroundColor3=T.BGPanel,
        Size=UDim2.new(0,TAB_W,1,-42),
        Position=UDim2.new(0,0,0,42),
        ClipsDescendants=true,
        ZIndex=3,
    },Root)
    -- right border
    New("Frame",{BackgroundColor3=T.AccentLine,BackgroundTransparency=.45,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),ZIndex=4},Sidebar)

    local SideScroll = New("ScrollingFrame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=2,
        ScrollBarImageColor3=T.Accent,
        ScrollBarImageTransparency=.5,
        ZIndex=4,
        BorderSizePixel=0,
    },Sidebar)
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},SideScroll)
    Pad(8,8,6,6,SideScroll)

    ------------------------------------------------------------------
    -- CONTENT AREA
    ------------------------------------------------------------------
    local ContentArea = New("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,-(TAB_W+1),1,-42),
        Position=UDim2.new(0,TAB_W+1,0,42),
        ClipsDescendants=true,
        ZIndex=3,
    },Root)

    ------------------------------------------------------------------
    -- OPEN ANIMATION
    ------------------------------------------------------------------
    Root.Size     = UDim2.new(0,W,0,0)
    Root.Position = UDim2.new(.5,-W/2,.5,0)
    Tw(Root,{
        Size    = UDim2.new(0,W,0,H),
        Position= UDim2.new(.5,-W/2,.5,-H/2),
    },.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    ------------------------------------------------------------------
    -- WINDOW OBJECT
    ------------------------------------------------------------------
    local Window    = {}
    local activeTab = nil
    local allTabs   = {}

    local function switchTab(t)
        if activeTab == t then return end
        if activeTab then
            Tw(activeTab.Btn,{BackgroundColor3=T.BGCard},.2)
            activeTab.Btn.TL.TextColor3 = T.TextSec
            activeTab.Ind.BackgroundTransparency = 1
            activeTab.Panel.Visible = false
        end
        activeTab = t
        Tw(t.Btn,{BackgroundColor3=T.AccentDk},.2)
        t.Btn.TL.TextColor3 = T.TextPri
        Tw(t.Ind,{BackgroundTransparency=0},.2)
        t.Panel.Visible = true
    end

    function Window:Notify(opts) Notify(opts) end

    ----------------------------------------------------------------
    -- AddTab
    ----------------------------------------------------------------
    function Window:AddTab(name)
        local btn = New("TextButton",{
            BackgroundColor3=T.BGCard,
            Size=UDim2.new(1,0,0,30),
            Text="",AutoButtonColor=false,ZIndex=5,
        },SideScroll)
        Rnd(8,btn)

        local tl = New("TextLabel",{Name="TL",BackgroundTransparency=1,
            Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,10,0,0),
            Font=Enum.Font.GothamSemibold,Text=name,
            TextColor3=T.TextSec,TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},btn)
        btn.TL = tl

        local ind = New("Frame",{
            BackgroundColor3=T.AccentGlow,BackgroundTransparency=1,
            Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,.5,0),AnchorPoint=Vector2.new(0,.5),
            ZIndex=7,
        },btn)
        Rnd(99,ind)
        btn.Ind = ind -- not used as field, so store via tabObj

        -- Scroll panel
        local panel = New("ScrollingFrame",{
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,1,0),
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollBarThickness=3,
            ScrollBarImageColor3=T.Accent,
            ScrollBarImageTransparency=.4,
            Visible=false,ZIndex=4,
            BorderSizePixel=0,
        },ContentArea)
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},panel)
        Pad(10,10,10,10,panel)

        local tabObj = {Btn=btn, Panel=panel, Ind=ind}
        table.insert(allTabs, tabObj)

        btn.MouseButton1Click:Connect(function() switchTab(tabObj) end)
        btn.MouseEnter:Connect(function()
            if activeTab~=tabObj then Tw(btn,{BackgroundColor3=T.BGHover},.14) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=tabObj then Tw(btn,{BackgroundColor3=T.BGCard},.14) end
        end)

        if #allTabs==1 then switchTab(tabObj) end

        --------------------------------------------------------------
        -- TAB API
        --------------------------------------------------------------
        local Tab = {}

        local function Card(h)
            local c=New("Frame",{
                BackgroundColor3=T.BGCard,
                Size=UDim2.new(1,0,0,h),
                ZIndex=5,
            },panel)
            Rnd(8,c)
            return c
        end

        ------ BUTTON ------------------------------------------------
        function Tab:AddButton(opts)
            opts=opts or{}
            local card=Card(36)

            local b=New("TextButton",{
                BackgroundColor3=T.AccentDk,
                Size=UDim2.new(1,-16,0,23),Position=UDim2.new(0,8,.5,0),AnchorPoint=Vector2.new(0,.5),
                Text=opts.Text or "Button",Font=Enum.Font.GothamBold,
                TextColor3=T.TextPri,TextSize=12,
                AutoButtonColor=false,ClipsDescendants=true,ZIndex=6,
            },card)
            Rnd(6,b)
            New("UIGradient",{
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,T.Accent),
                    ColorSequenceKeypoint.new(1,T.AccentDk),
                }),Rotation=90,
            },b)
            Ripple(b)

            b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=T.AccentGlow},.14) end)
            b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=T.AccentDk},.14) end)
            b.MouseButton1Click:Connect(function()
                Tw(b,{Size=UDim2.new(1,-22,0,20)},.07)
                task.delay(.08,function() Tw(b,{Size=UDim2.new(1,-16,0,23)},.12,Enum.EasingStyle.Back) end)
                if opts.Callback then opts.Callback() end
            end)
            return b
        end

        ------ TOGGLE ------------------------------------------------
        function Tab:AddToggle(opts)
            opts=opts or{}
            local state=opts.Default or false
            local card=Card(38)

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,12,0,0),
                Font=Enum.Font.GothamSemibold,Text=opts.Text or "Toggle",
                TextColor3=T.TextPri,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)

            local track=New("Frame",{
                BackgroundColor3=state and T.Accent or T.ToggleOff,
                Size=UDim2.new(0,40,0,20),Position=UDim2.new(1,-52,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=6,
            },card)
            Rnd(99,track)
            New("UIStroke",{Color=T.AccentLine,Thickness=1,Transparency=.4},track)

            local thumb=New("Frame",{
                BackgroundColor3=T.TextPri,
                Size=UDim2.new(0,14,0,14),
                Position=state and UDim2.new(1,-17,.5,0) or UDim2.new(0,3,.5,0),
                AnchorPoint=Vector2.new(0,.5),ZIndex=7,
            },track)
            Rnd(99,thumb)

            local hit=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=8},card)
            hit.MouseButton1Click:Connect(function()
                state=not state
                Tw(track,{BackgroundColor3=state and T.Accent or T.ToggleOff},.2)
                Tw(thumb,{Position=state and UDim2.new(1,-17,.5,0) or UDim2.new(0,3,.5,0)},.2,Enum.EasingStyle.Back)
                if opts.Callback then opts.Callback(state) end
            end)

            local api={}
            function api:Set(v)
                state=v
                Tw(track,{BackgroundColor3=v and T.Accent or T.ToggleOff},.2)
                Tw(thumb,{Position=v and UDim2.new(1,-17,.5,0) or UDim2.new(0,3,.5,0)},.2,Enum.EasingStyle.Back)
            end
            function api:Get() return state end
            return api
        end

        ------ SLIDER ------------------------------------------------
        function Tab:AddSlider(opts)
            opts=opts or{}
            local mn=opts.Min or 0; local mx=opts.Max or 100
            local val=math.clamp(opts.Default or mn, mn, mx)
            local card=Card(54)

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-60,0,18),Position=UDim2.new(0,12,0,6),
                Font=Enum.Font.GothamSemibold,Text=opts.Text or "Slider",
                TextColor3=T.TextPri,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)

            local valLbl=New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(0,46,0,18),Position=UDim2.new(1,-58,0,6),
                Font=Enum.Font.GothamBold,Text=tostring(val),
                TextColor3=T.AccentGlow,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6},card)

            local track=New("Frame",{
                BackgroundColor3=T.TrackBG,
                Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,34),ZIndex=6,
            },card)
            Rnd(99,track)

            local pct=(val-mn)/(mx-mn)
            local fill=New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(pct,0,1,0),ZIndex=7},track)
            Rnd(99,fill)
            New("UIGradient",{Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,T.AccentDk),ColorSequenceKeypoint.new(1,T.AccentGlow),
            })},fill)

            local thumb=New("Frame",{
                BackgroundColor3=Color3.new(1,1,1),
                Size=UDim2.new(0,14,0,14),
                Position=UDim2.new(pct,-7,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=8,
            },track)
            Rnd(99,thumb)
            New("UIStroke",{Color=T.Accent,Thickness=1.5,Transparency=.2},thumb)

            local dragging=false
            local function upd(inp)
                local rx=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                val=math.floor(mn+rx*(mx-mn))
                valLbl.Text=tostring(val)
                fill.Size=UDim2.new(rx,0,1,0)
                thumb.Position=UDim2.new(rx,-7,.5,0)
                if opts.Callback then opts.Callback(val) end
            end

            track.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;upd(i) end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end)

            local api={}
            function api:Set(v)
                val=math.clamp(v,mn,mx);local r=(val-mn)/(mx-mn)
                valLbl.Text=tostring(val)
                Tw(fill,{Size=UDim2.new(r,0,1,0)},.15)
                Tw(thumb,{Position=UDim2.new(r,-7,.5,0)},.15)
            end
            function api:Get() return val end
            return api
        end

        ------ DROPDOWN ----------------------------------------------
        function Tab:AddDropdown(opts)
            opts=opts or{}
            local options=opts.Options or{}
            local selected=opts.Default or nil
            local open=false
            local card=Card(38)

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(0,118,1,0),Position=UDim2.new(0,12,0,0),
                Font=Enum.Font.GothamSemibold,Text=opts.Text or "Dropdown",
                TextColor3=T.TextPri,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)

            local selBtn=New("TextButton",{
                BackgroundColor3=T.BGInput,
                Size=UDim2.new(0,138,0,24),Position=UDim2.new(1,-148,.5,0),AnchorPoint=Vector2.new(0,.5),
                Text=selected or "Select...",Font=Enum.Font.Gotham,
                TextColor3=selected and T.TextPri or T.TextMuted,TextSize=10,
                AutoButtonColor=false,ClipsDescendants=true,ZIndex=6,
            },card)
            Rnd(6,selBtn)
            New("UIStroke",{Color=T.AccentLine,Thickness=1,Transparency=.3},selBtn)
            Pad(0,0,8,4,selBtn)

            local arrow=New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),
                Font=Enum.Font.GothamBold,Text="▾",TextColor3=T.AccentGlow,TextSize=11,ZIndex=7},selBtn)

            local listH=#options*26+6
            local list=New("Frame",{
                BackgroundColor3=T.BGPanel,
                Size=UDim2.new(0,138,0,0),Position=UDim2.new(1,-148,1,3),
                ZIndex=20,ClipsDescendants=true,
            },card)
            Rnd(8,list)
            New("UIStroke",{Color=T.Accent,Thickness=1,Transparency=.4},list)

            local inner=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,listH),ZIndex=21},list)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},inner)
            Pad(3,3,3,3,inner)

            for _,opt in ipairs(options) do
                local item=New("TextButton",{
                    BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,24),
                    Text=opt,Font=Enum.Font.Gotham,TextColor3=T.TextPri,TextSize=10,
                    AutoButtonColor=false,ZIndex=22,
                },inner)
                Rnd(5,item)
                item.MouseEnter:Connect(function() Tw(item,{BackgroundColor3=T.BGHover},.1) end)
                item.MouseLeave:Connect(function() Tw(item,{BackgroundColor3=T.BGCard},.1) end)
                item.MouseButton1Click:Connect(function()
                    selected=opt;selBtn.Text=opt;selBtn.TextColor3=T.TextPri
                    open=false
                    Tw(list,{Size=UDim2.new(0,138,0,0)},.2)
                    Tw(arrow,{Rotation=0},.2)
                    if opts.Callback then opts.Callback(opt) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                Tw(list,{Size=UDim2.new(0,138,0,open and listH or 0)},.22,Enum.EasingStyle.Quart)
                Tw(arrow,{Rotation=open and 180 or 0},.2)
            end)

            local api={}
            function api:Set(v) selected=v;selBtn.Text=v;selBtn.TextColor3=T.TextPri end
            function api:Get() return selected end
            return api
        end

        ------ MULTI-DROPDOWN ----------------------------------------
        function Tab:AddMultiDropdown(opts)
            opts=opts or{}
            local options=opts.Options or{}
            local selected={}
            local open=false
            local card=Card(38)

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(0,118,1,0),Position=UDim2.new(0,12,0,0),
                Font=Enum.Font.GothamSemibold,Text=opts.Text or "Multi-Select",
                TextColor3=T.TextPri,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)

            local selBtn=New("TextButton",{
                BackgroundColor3=T.BGInput,
                Size=UDim2.new(0,138,0,24),Position=UDim2.new(1,-148,.5,0),AnchorPoint=Vector2.new(0,.5),
                Text="Select...",Font=Enum.Font.Gotham,TextColor3=T.TextMuted,TextSize=9,
                AutoButtonColor=false,ClipsDescendants=true,ZIndex=6,
            },card)
            Rnd(6,selBtn)
            New("UIStroke",{Color=T.AccentLine,Thickness=1,Transparency=.3},selBtn)
            Pad(0,0,8,4,selBtn)

            local arrow=New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),
                Font=Enum.Font.GothamBold,Text="▾",TextColor3=T.AccentGlow,TextSize=11,ZIndex=7},selBtn)

            local listH=#options*28+6
            local list=New("Frame",{
                BackgroundColor3=T.BGPanel,
                Size=UDim2.new(0,138,0,0),Position=UDim2.new(1,-148,1,3),
                ZIndex=20,ClipsDescendants=true,
            },card)
            Rnd(8,list)
            New("UIStroke",{Color=T.Accent,Thickness=1,Transparency=.4},list)

            local inner=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,listH),ZIndex=21},list)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},inner)
            Pad(3,3,3,3,inner)

            local function refreshLbl()
                local t={}
                for _,v in ipairs(options) do if selected[v] then table.insert(t,v) end end
                if #t==0 then selBtn.Text="Select...";selBtn.TextColor3=T.TextMuted
                else selBtn.Text=table.concat(t,", ");selBtn.TextColor3=T.TextPri end
            end

            for _,opt in ipairs(options) do
                local row=New("TextButton",{
                    BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,26),
                    Text="",AutoButtonColor=false,ZIndex=22,
                },inner)
                Rnd(5,row)
                local chk=New("Frame",{
                    BackgroundColor3=selected[opt] and T.Accent or T.TrackBG,
                    Size=UDim2.new(0,13,0,13),Position=UDim2.new(0,7,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=23,
                },row)
                Rnd(3,chk)
                New("TextLabel",{BackgroundTransparency=1,
                    Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,24,0,0),
                    Text=opt,Font=Enum.Font.Gotham,TextColor3=T.TextPri,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=23},row)

                row.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=T.BGHover},.1) end)
                row.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=T.BGCard},.1) end)
                row.MouseButton1Click:Connect(function()
                    selected[opt]=not selected[opt]
                    Tw(chk,{BackgroundColor3=selected[opt] and T.Accent or T.TrackBG},.14)
                    refreshLbl()
                    if opts.Callback then opts.Callback(selected) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                Tw(list,{Size=UDim2.new(0,138,0,open and listH or 0)},.22,Enum.EasingStyle.Quart)
                Tw(arrow,{Rotation=open and 180 or 0},.2)
            end)

            local api={}
            function api:Get()
                local t={} for k,v in pairs(selected) do if v then table.insert(t,k) end end return t
            end
            return api
        end

        ------ INPUT BOX ---------------------------------------------
        function Tab:AddInputBox(opts)
            opts=opts or{}
            local card=Card(54)

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,12,0,6),
                Font=Enum.Font.GothamSemibold,Text=opts.Text or "Input",
                TextColor3=T.TextPri,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)

            local box=New("TextBox",{
                BackgroundColor3=T.BGInput,
                Size=UDim2.new(1,-22,0,22),Position=UDim2.new(0,11,0,24),
                Font=Enum.Font.Gotham,Text=opts.Default or "",
                PlaceholderText=opts.Placeholder or "Type here...",
                PlaceholderColor3=T.TextMuted,TextColor3=T.TextPri,TextSize=11,
                ClearTextOnFocus=opts.ClearOnFocus~=false,
                ZIndex=6,ClipsDescendants=true,BorderSizePixel=0,
            },card)
            Rnd(6,box)
            local boxStroke=New("UIStroke",{Color=T.AccentLine,Thickness=1,Transparency=.35},box)
            Pad(0,0,8,0,box)

            box.Focused:Connect(function()
                Tw(box,{BackgroundColor3=T.BGCard},.15)
                Tw(boxStroke,{Color=T.Accent,Transparency=.05},.15)
            end)
            box.FocusLost:Connect(function(enter)
                Tw(box,{BackgroundColor3=T.BGInput},.15)
                Tw(boxStroke,{Color=T.AccentLine,Transparency=.35},.15)
                if opts.Callback then opts.Callback(box.Text,enter) end
            end)

            local api={}
            function api:Get() return box.Text end
            function api:Set(v) box.Text=v end
            return api
        end

        ------ PARAGRAPH ---------------------------------------------
        function Tab:AddParagraph(opts)
            opts=opts or{}
            local txt=opts.Text or ""
            local hasTitle=opts.Title~=nil
            local lines=math.max(1,math.ceil(#txt/50))
            local h=14+(hasTitle and 18 or 0)+lines*14+10
            local card=Card(h)

            -- left accent bar
            New("Frame",{BackgroundColor3=T.Accent,BackgroundTransparency=.35,
                Size=UDim2.new(0,3,0.7,0),Position=UDim2.new(0,0,.15,0),ZIndex=6},card)

            if hasTitle then
                New("TextLabel",{BackgroundTransparency=1,
                    Size=UDim2.new(1,-18,0,16),Position=UDim2.new(0,14,0,7),
                    Font=Enum.Font.GothamBold,Text=opts.Title,
                    TextColor3=T.AccentGlow,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},card)
            end

            New("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-20,0,lines*14),
                Position=UDim2.new(0,14,0,7+(hasTitle and 16 or 0)),
                Font=Enum.Font.Gotham,Text=txt,TextColor3=T.TextSec,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=6},card)

            return {}
        end

        return Tab
    end -- AddTab

    return Window
end -- CreateWindow

return OceanUI
