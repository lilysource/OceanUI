--[[
    ╔══════════════════════════════════════════╗
    ║          OceanUI — Roblox Library        ║
    ║       Ocean Theme · v1                   ║
    ╚══════════════════════════════════════════╝

--]]

local OceanUI   = {}
OceanUI.__index = OceanUI

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------------
-- THEME — bright explicit colors, no transparency issues
----------------------------------------------------------------------
local T = {
    BG         = Color3.fromRGB(13, 30, 55),
    BGPanel    = Color3.fromRGB(17, 38, 66),
    BGCard     = Color3.fromRGB(22, 48, 80),
    BGHover    = Color3.fromRGB(28, 58, 94),
    BGInput    = Color3.fromRGB(14, 34, 60),
    BGDrop     = Color3.fromRGB(17, 38, 68),

    Accent     = Color3.fromRGB(0,   200, 220),
    AccentDk   = Color3.fromRGB(0,   150, 175),
    AccentGlow = Color3.fromRGB(100, 240, 255),
    AccentLine = Color3.fromRGB(0,   90,  130),

    TextPri    = Color3.fromRGB(230, 248, 255),   -- near-white, always visible
    TextSec    = Color3.fromRGB(150, 200, 220),
    TextMuted  = Color3.fromRGB(90,  135, 165),

    BtnText    = Color3.fromRGB(255, 255, 255),   -- pure white for button labels

    Success    = Color3.fromRGB(0,   215, 135),
    Warning    = Color3.fromRGB(255, 190, 30),
    Error      = Color3.fromRGB(255, 75,  75),
    Info       = Color3.fromRGB(0,   200, 220),

    TrackBG    = Color3.fromRGB(12, 30, 52),
    ToggleOff  = Color3.fromRGB(25, 52, 82),
}

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Tw(obj, goal, dur, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or .2, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        goal):Play()
end

local function Rnd(r, p) return New("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function Pad(t,b,l,r,p) return New("UIPadding",{PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)},p) end
local function Stroke(c,th,tr,p) return New("UIStroke",{Color=c,Thickness=th or 1,Transparency=tr or 0},p) end

-- Label helper — always bright, always visible
local function Lbl(props, parent)
    props.BackgroundTransparency = 1
    props.Font = props.Font or Enum.Font.GothamSemibold
    props.TextSize = props.TextSize or 12
    props.TextColor3 = props.TextColor3 or T.TextPri
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    props.ZIndex = props.ZIndex or 10
    return New("TextLabel", props, parent)
end

----------------------------------------------------------------------
-- DRAGGABLE
----------------------------------------------------------------------
local function Draggable(frame, handle)
    local drag, ms, fs
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        drag=true; ms=i.Position; fs=frame.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ms
            frame.Position=UDim2.new(fs.X.Scale,fs.X.Offset+d.X,fs.Y.Scale,fs.Y.Offset+d.Y)
        end
    end)
end

----------------------------------------------------------------------
-- RIPPLE
----------------------------------------------------------------------
local function Ripple(btn)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local r=New("Frame",{
            BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.7,
            Size=UDim2.new(0,0,0,0),AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.new(0,i.Position.X-btn.AbsolutePosition.X,0,i.Position.Y-btn.AbsolutePosition.Y),
            ZIndex=btn.ZIndex+5,
        },btn)
        Rnd(999,r)
        local sz=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*2.6
        Tw(r,{Size=UDim2.new(0,sz,0,sz),BackgroundTransparency=1},.42)
        task.delay(.45,function() r:Destroy() end)
    end)
end

----------------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------------
local _NG=New("ScreenGui",{Name="OceanNotify",IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)
local _NS=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-316,0,16)},_NG)
New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top,Padding=UDim.new(0,8)},_NS)

local function Notify(opts)
    opts=opts or{}
    local nt=opts.Type or "Info"
    local ac=({Info=T.Info,Success=T.Success,Warning=T.Warning,Error=T.Error})[nt] or T.Info
    local ic={Info="ℹ",Success="✓",Warning="⚠",Error="✕"}
    local dur=opts.Duration or 4

    local card=New("Frame",{BackgroundColor3=T.BGPanel,Size=UDim2.new(1,0,0,72),ClipsDescendants=true},_NS)
    Rnd(10,card); Stroke(ac,1.3,.35,card)
    New("Frame",{BackgroundColor3=ac,Size=UDim2.new(0,4,1,0),ZIndex=2},card)

    local ib=New("Frame",{BackgroundColor3=ac,BackgroundTransparency=.72,Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,14,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=3},card)
    Rnd(99,ib)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text=ic[nt] or "ℹ",TextColor3=ac,TextSize=15,ZIndex=4},ib)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-64,0,20),Position=UDim2.new(0,56,0,9),Font=Enum.Font.GothamBold,Text=opts.Title or "OceanUI",TextColor3=T.TextPri,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},card)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-64,0,28),Position=UDim2.new(0,56,0,30),Font=Enum.Font.Gotham,Text=opts.Text or "",TextColor3=T.TextSec,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=3},card)

    local pb=New("Frame",{BackgroundColor3=T.TrackBG,Size=UDim2.new(1,-8,0,2),Position=UDim2.new(0,4,1,-4),AnchorPoint=Vector2.new(0,1),ZIndex=3},card)
    Rnd(99,pb)
    local pf=New("Frame",{BackgroundColor3=ac,Size=UDim2.new(1,0,1,0),ZIndex=4},pb); Rnd(99,pf)

    card.Position=UDim2.new(1,10,0,0)
    Tw(card,{Position=UDim2.new(0,0,0,0)},.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    Tw(pf,{Size=UDim2.new(0,0,1,0)},dur,Enum.EasingStyle.Linear)
    task.delay(dur,function() Tw(card,{Position=UDim2.new(1,10,0,0)},.28); task.delay(.3,function() card:Destroy() end) end)
end

OceanUI.Notify = Notify

----------------------------------------------------------------------
-- CREATE WINDOW
----------------------------------------------------------------------
function OceanUI:CreateWindow(cfg)
    cfg=cfg or{}
    local TITLE=cfg.Title or "Ocean Hub"
    local W=cfg.Width or 660
    local H=cfg.Height or 420
    local TW=130  -- tab sidebar width

    local SG=New("ScreenGui",{Name="OceanUI",IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)

    -- Root window
    local Root=New("Frame",{Name="Root",BackgroundColor3=T.BG,Size=UDim2.new(0,W,0,H),Position=UDim2.new(.5,-W/2,.5,-H/2),ClipsDescendants=true,ZIndex=1},SG)
    Rnd(14,Root); Stroke(T.AccentLine,1.5,.2,Root)

    -- Wave lines (decorative, low ZIndex so they don't block anything)
    for i=1,3 do
        local wl=New("Frame",{BackgroundColor3=T.Accent,BackgroundTransparency=.9,Size=UDim2.new(1.6,0,0,1),Position=UDim2.new(-.6,0,.3+i*.2,0),ZIndex=1},Root)
        Rnd(99,wl)
        local function aw()
            Tw(wl,{Position=UDim2.new(0,0,.3+i*.2+(i%2==0 and .03 or -.03),0)},3+i*.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.delay(3+i*.4,function()
                Tw(wl,{Position=UDim2.new(-.6,0,.3+i*.2,0)},3+i*.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
                task.delay(3+i*.4,aw)
            end)
        end
        task.delay(i*.8,aw)
    end

    --------------------------------------------------------------------
    -- TITLE BAR
    --------------------------------------------------------------------
    local TBar=New("Frame",{BackgroundColor3=T.BGPanel,Size=UDim2.new(1,0,0,44),ZIndex=8},Root)
    Rnd(14,TBar)
    New("Frame",{BackgroundColor3=T.BGPanel,Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),ZIndex=8},TBar)
    New("Frame",{BackgroundColor3=T.AccentLine,BackgroundTransparency=.4,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),ZIndex=9},TBar)

    -- Icon + title
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,12,.5,0),AnchorPoint=Vector2.new(0,.5),Font=Enum.Font.GothamBold,Text="〜",TextColor3=T.AccentGlow,TextSize=20,ZIndex=10},TBar)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-110,1,0),Position=UDim2.new(0,44,0,0),Font=Enum.Font.GothamBold,Text=TITLE,TextColor3=T.TextPri,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10},TBar)

    -- Minimize
    local MinBtn=New("TextButton",{BackgroundColor3=Color3.fromRGB(230,170,0),Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-40,.5,0),AnchorPoint=Vector2.new(1,.5),Text="",AutoButtonColor=false,ZIndex=11},TBar)
    Rnd(99,MinBtn)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text="–",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=12},MinBtn)

    -- Close
    local CloseBtn=New("TextButton",{BackgroundColor3=Color3.fromRGB(218,58,58),Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-16,.5,0),AnchorPoint=Vector2.new(1,.5),Text="",AutoButtonColor=false,ZIndex=11},TBar)
    Rnd(99,CloseBtn)
    New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text="×",TextColor3=Color3.new(1,1,1),TextSize=16,ZIndex=12},CloseBtn)

    CloseBtn.MouseEnter:Connect(function() Tw(CloseBtn,{BackgroundColor3=Color3.fromRGB(255,85,85),Size=UDim2.new(0,18,0,18)},.12) end)
    CloseBtn.MouseLeave:Connect(function() Tw(CloseBtn,{BackgroundColor3=Color3.fromRGB(218,58,58),Size=UDim2.new(0,16,0,16)},.12) end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tw(Root,{Size=UDim2.new(0,W,0,0),Position=UDim2.new(.5,-W/2,.5,0)},.28,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.delay(.3,function() SG:Destroy() end)
    end)

    local minimised=false
    MinBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        Tw(Root,{Size=minimised and UDim2.new(0,W,0,44) or UDim2.new(0,W,0,H)},.3,Enum.EasingStyle.Back)
    end)

    Draggable(Root,TBar)

    --------------------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------------------
    local Sidebar=New("Frame",{BackgroundColor3=T.BGPanel,Size=UDim2.new(0,TW,1,-44),Position=UDim2.new(0,0,0,44),ClipsDescendants=true,ZIndex=5},Root)
    New("Frame",{BackgroundColor3=T.AccentLine,BackgroundTransparency=.4,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),ZIndex=6},Sidebar)

    local SideScroll=New("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=T.Accent,ZIndex=6,BorderSizePixel=0},Sidebar)
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},SideScroll)
    Pad(8,8,6,6,SideScroll)

    --------------------------------------------------------------------
    -- CONTENT AREA
    --------------------------------------------------------------------
    local ContentArea=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-(TW+1),1,-44),Position=UDim2.new(0,TW+1,0,44),ClipsDescendants=true,ZIndex=5},Root)

    --------------------------------------------------------------------
    -- OPEN ANIMATION
    --------------------------------------------------------------------
    Root.Size=UDim2.new(0,W,0,0); Root.Position=UDim2.new(.5,-W/2,.5,0)
    Tw(Root,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(.5,-W/2,.5,-H/2)},.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    --------------------------------------------------------------------
    -- WINDOW OBJECT
    --------------------------------------------------------------------
    local Window={}
    local activeTab=nil
    local allTabs={}

    local function switchTab(t)
        if activeTab==t then return end
        if activeTab then
            Tw(activeTab.Btn,{BackgroundColor3=T.BGCard},.18)
            activeTab.Btn.TL.TextColor3=T.TextSec
            activeTab.Ind.BackgroundTransparency=1
            activeTab.Panel.Visible=false
        end
        activeTab=t
        Tw(t.Btn,{BackgroundColor3=T.AccentDk},.18)
        t.Btn.TL.TextColor3=T.TextPri
        t.Ind.BackgroundTransparency=0
        t.Panel.Visible=true
    end

    function Window:Notify(opts) Notify(opts) end

    ------------------------------------------------------------------
    -- AddTab
    ------------------------------------------------------------------
    function Window:AddTab(name)
        local btn=New("TextButton",{BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,32),Text="",AutoButtonColor=false,ZIndex=7},SideScroll)
        Rnd(8,btn)

        -- indicator bar
        local ind=New("Frame",{BackgroundColor3=T.AccentGlow,BackgroundTransparency=1,Size=UDim2.new(0,3,0,16),Position=UDim2.new(0,0,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=9},btn)
        Rnd(99,ind)

        local tl=New("TextLabel",{Name="TL",BackgroundTransparency=1,Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,12,0,0),Font=Enum.Font.GothamSemibold,Text=name,TextColor3=T.TextSec,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},btn)
        btn.TL=tl

        local panel=New("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,ScrollBarImageTransparency=.3,Visible=false,ZIndex=6,BorderSizePixel=0},ContentArea)
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},panel)
        Pad(10,10,10,10,panel)

        local tabObj={Btn=btn,Panel=panel,Ind=ind}
        table.insert(allTabs,tabObj)

        btn.MouseButton1Click:Connect(function() switchTab(tabObj) end)
        btn.MouseEnter:Connect(function() if activeTab~=tabObj then Tw(btn,{BackgroundColor3=T.BGHover},.14) end end)
        btn.MouseLeave:Connect(function() if activeTab~=tabObj then Tw(btn,{BackgroundColor3=T.BGCard},.14) end end)

        if #allTabs==1 then switchTab(tabObj) end

        ----------------------------------------------------------------
        -- TAB API
        ----------------------------------------------------------------
        local Tab={}

        -- CARD — explicit high ZIndex so children are always on top
        local function Card(h)
            local c=New("Frame",{BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,h),ZIndex=7},panel)
            Rnd(9,c)
            Stroke(T.AccentLine,1,.6,c)
            return c
        end

        ---- SECTION HEADER -------------------------------------------
        function Tab:AddSection(text)
            local sec=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),ZIndex=7},panel)
            New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,4,0,0),Font=Enum.Font.GothamBold,Text=("── "..text.." ──"),TextColor3=T.Accent,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},sec)
            return sec
        end

        ---- BUTTON ---------------------------------------------------
        function Tab:AddButton(opts)
            opts=opts or{}
            local card=Card(40)

            local b=New("TextButton",{
                BackgroundColor3=T.AccentDk,
                Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,.5,0),AnchorPoint=Vector2.new(0,.5),
                Text=opts.Text or "Button",
                Font=Enum.Font.GothamBold,TextColor3=T.BtnText,TextSize=13,
                AutoButtonColor=false,ClipsDescendants=true,ZIndex=9,
            },card)
            Rnd(7,b)
            New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentDk)}),Rotation=90},b)
            Ripple(b)

            b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=T.AccentGlow},.13) end)
            b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=T.AccentDk},.13) end)
            b.MouseButton1Click:Connect(function()
                Tw(b,{Size=UDim2.new(1,-22,0,22)},.07)
                task.delay(.08,function() Tw(b,{Size=UDim2.new(1,-16,0,26)},.13,Enum.EasingStyle.Back) end)
                if opts.Callback then task.spawn(opts.Callback) end
            end)
            return b
        end

        ---- TOGGLE ---------------------------------------------------
        function Tab:AddToggle(opts)
            opts=opts or{}
            local state=opts.Default or false
            local card=Card(40)

            Lbl({Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,12,0,0),Text=opts.Text or "Toggle",TextSize=12},card)

            local track=New("Frame",{BackgroundColor3=state and T.Accent or T.ToggleOff,Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-54,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=9},card)
            Rnd(99,track); Stroke(T.AccentLine,1,.3,track)

            local thumb=New("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,16,0,16),Position=state and UDim2.new(1,-19,.5,0) or UDim2.new(0,3,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=10},track)
            Rnd(99,thumb)

            local hit=New("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=11},card)
            hit.MouseButton1Click:Connect(function()
                state=not state
                Tw(track,{BackgroundColor3=state and T.Accent or T.ToggleOff},.2)
                Tw(thumb,{Position=state and UDim2.new(1,-19,.5,0) or UDim2.new(0,3,.5,0)},.2,Enum.EasingStyle.Back)
                if opts.Callback then task.spawn(opts.Callback,state) end
            end)

            local api={}
            function api:Set(v) state=v; Tw(track,{BackgroundColor3=v and T.Accent or T.ToggleOff},.2); Tw(thumb,{Position=v and UDim2.new(1,-19,.5,0) or UDim2.new(0,3,.5,0)},.2,Enum.EasingStyle.Back) end
            function api:Get() return state end
            return api
        end

        ---- SLIDER ---------------------------------------------------
        function Tab:AddSlider(opts)
            opts=opts or{}
            local mn=opts.Min or 0; local mx=opts.Max or 100
            local val=math.clamp(opts.Default or mn,mn,mx)
            local card=Card(56)

            Lbl({Size=UDim2.new(1,-70,0,18),Position=UDim2.new(0,12,0,7),Text=opts.Text or "Slider",TextSize=12},card)

            local valLbl=New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-64,0,7),Font=Enum.Font.GothamBold,Text=tostring(val),TextColor3=T.AccentGlow,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=9},card)

            local track=New("Frame",{BackgroundColor3=T.TrackBG,Size=UDim2.new(1,-24,0,7),Position=UDim2.new(0,12,0,36),ZIndex=9},card)
            Rnd(99,track); Stroke(T.AccentLine,1,.5,track)

            local pct=(val-mn)/(mx-mn)
            local fill=New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(pct,0,1,0),ZIndex=10},track)
            Rnd(99,fill)
            New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentDk),ColorSequenceKeypoint.new(1,T.AccentGlow)})},fill)

            local thumb=New("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,16,0,16),Position=UDim2.new(pct,-8,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=11},track)
            Rnd(99,thumb); Stroke(T.Accent,2,.1,thumb)

            local dragging=false
            local function upd(inp)
                local rx=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                val=math.floor(mn+rx*(mx-mn))
                valLbl.Text=tostring(val)
                fill.Size=UDim2.new(rx,0,1,0)
                thumb.Position=UDim2.new(rx,-8,.5,0)
                if opts.Callback then task.spawn(opts.Callback,val) end
            end

            track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;upd(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

            local api={}
            function api:Set(v) val=math.clamp(v,mn,mx);local r=(val-mn)/(mx-mn);valLbl.Text=tostring(val);Tw(fill,{Size=UDim2.new(r,0,1,0)},.15);Tw(thumb,{Position=UDim2.new(r,-8,.5,0)},.15) end
            function api:Get() return val end
            return api
        end

        ---- DROPDOWN -------------------------------------------------
        function Tab:AddDropdown(opts)
            opts=opts or{}
            local options=opts.Options or{}
            local selected=opts.Default or nil
            local open=false
            local card=Card(40)

            Lbl({Size=UDim2.new(0,130,1,0),Position=UDim2.new(0,12,0,0),Text=opts.Text or "Dropdown",TextSize=12},card)

            local selBtn=New("TextButton",{BackgroundColor3=T.BGInput,Size=UDim2.new(0,150,0,26),Position=UDim2.new(1,-158,.5,0),AnchorPoint=Vector2.new(0,.5),Text=selected or "Select...",Font=Enum.Font.Gotham,TextColor3=selected and T.TextPri or T.TextMuted,TextSize=11,AutoButtonColor=false,ClipsDescendants=true,ZIndex=9},card)
            Rnd(7,selBtn); Stroke(T.AccentLine,1,.25,selBtn)
            New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,22)},selBtn)

            local arrow=New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-22,0,0),Font=Enum.Font.GothamBold,Text="▾",TextColor3=T.AccentGlow,TextSize=12,ZIndex=10},selBtn)

            local listH=#options*28+8
            local list=New("Frame",{BackgroundColor3=T.BGDrop,Size=UDim2.new(0,150,0,0),Position=UDim2.new(1,-158,1,3),ZIndex=30,ClipsDescendants=true},card)
            Rnd(8,list); Stroke(T.Accent,1,.35,list)

            local inner=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,listH),ZIndex=31},list)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},inner)
            Pad(4,4,4,4,inner)

            for _,opt in ipairs(options) do
                local item=New("TextButton",{BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,26),Text=opt,Font=Enum.Font.Gotham,TextColor3=T.TextPri,TextSize=11,AutoButtonColor=false,ZIndex=32},inner)
                Rnd(5,item)
                item.MouseEnter:Connect(function() Tw(item,{BackgroundColor3=T.BGHover},.1) end)
                item.MouseLeave:Connect(function() Tw(item,{BackgroundColor3=T.BGCard},.1) end)
                item.MouseButton1Click:Connect(function()
                    selected=opt;selBtn.Text=opt;selBtn.TextColor3=T.TextPri
                    open=false; Tw(list,{Size=UDim2.new(0,150,0,0)},.2); Tw(arrow,{Rotation=0},.2)
                    if opts.Callback then task.spawn(opts.Callback,opt) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                Tw(list,{Size=UDim2.new(0,150,0,open and listH or 0)},.22,Enum.EasingStyle.Quart)
                Tw(arrow,{Rotation=open and 180 or 0},.2)
            end)

            local api={}
            function api:Set(v) selected=v;selBtn.Text=v;selBtn.TextColor3=T.TextPri end
            function api:Get() return selected end
            return api
        end

        ---- MULTI-DROPDOWN ------------------------------------------
        function Tab:AddMultiDropdown(opts)
            opts=opts or{}
            local options=opts.Options or{}
            local selected={}
            local open=false
            local card=Card(40)

            Lbl({Size=UDim2.new(0,130,1,0),Position=UDim2.new(0,12,0,0),Text=opts.Text or "Multi-Select",TextSize=12},card)

            local selBtn=New("TextButton",{BackgroundColor3=T.BGInput,Size=UDim2.new(0,150,0,26),Position=UDim2.new(1,-158,.5,0),AnchorPoint=Vector2.new(0,.5),Text="Select...",Font=Enum.Font.Gotham,TextColor3=T.TextMuted,TextSize=10,AutoButtonColor=false,ClipsDescendants=true,ZIndex=9},card)
            Rnd(7,selBtn); Stroke(T.AccentLine,1,.25,selBtn)
            New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,22)},selBtn)

            local arrow=New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-22,0,0),Font=Enum.Font.GothamBold,Text="▾",TextColor3=T.AccentGlow,TextSize=12,ZIndex=10},selBtn)

            local listH=#options*30+8
            local list=New("Frame",{BackgroundColor3=T.BGDrop,Size=UDim2.new(0,150,0,0),Position=UDim2.new(1,-158,1,3),ZIndex=30,ClipsDescendants=true},card)
            Rnd(8,list); Stroke(T.Accent,1,.35,list)

            local inner=New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,listH),ZIndex=31},list)
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},inner)
            Pad(4,4,4,4,inner)

            local function refresh()
                local t={}
                for _,v in ipairs(options) do if selected[v] then table.insert(t,v) end end
                if #t==0 then selBtn.Text="Select...";selBtn.TextColor3=T.TextMuted
                else selBtn.Text=table.concat(t,", ");selBtn.TextColor3=T.TextPri end
            end

            for _,opt in ipairs(options) do
                local row=New("TextButton",{BackgroundColor3=T.BGCard,Size=UDim2.new(1,0,0,28),Text="",AutoButtonColor=false,ZIndex=32},inner)
                Rnd(5,row)
                local chk=New("Frame",{BackgroundColor3=selected[opt] and T.Accent or T.TrackBG,Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,8,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=33},row)
                Rnd(4,chk)
                New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,28,0,0),Text=opt,Font=Enum.Font.Gotham,TextColor3=T.TextPri,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=33},row)
                row.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=T.BGHover},.1) end)
                row.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=T.BGCard},.1) end)
                row.MouseButton1Click:Connect(function()
                    selected[opt]=not selected[opt]
                    Tw(chk,{BackgroundColor3=selected[opt] and T.Accent or T.TrackBG},.14)
                    refresh()
                    if opts.Callback then task.spawn(opts.Callback,selected) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                Tw(list,{Size=UDim2.new(0,150,0,open and listH or 0)},.22,Enum.EasingStyle.Quart)
                Tw(arrow,{Rotation=open and 180 or 0},.2)
            end)

            local api={}
            function api:Get() local t={};for k,v in pairs(selected) do if v then table.insert(t,k) end end;return t end
            return api
        end

        ---- INPUT BOX ------------------------------------------------
        function Tab:AddInputBox(opts)
            opts=opts or{}
            local card=Card(56)

            Lbl({Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,12,0,6),Text=opts.Text or "Input",TextSize=12},card)

            local box=New("TextBox",{BackgroundColor3=T.BGInput,Size=UDim2.new(1,-22,0,24),Position=UDim2.new(0,11,0,26),Font=Enum.Font.Gotham,Text=opts.Default or "",PlaceholderText=opts.Placeholder or "Type here...",PlaceholderColor3=T.TextMuted,TextColor3=T.TextPri,TextSize=12,ClearTextOnFocus=opts.ClearOnFocus~=false,ZIndex=9,BorderSizePixel=0},card)
            Rnd(6,box)
            New("UIPadding",{PaddingLeft=UDim.new(0,8)},box)
            local bStroke=Stroke(T.AccentLine,1,.3,box)

            box.Focused:Connect(function() Tw(box,{BackgroundColor3=T.BGCard},.14); Tw(bStroke,{Color=T.Accent,Transparency=0},.14) end)
            box.FocusLost:Connect(function(enter) Tw(box,{BackgroundColor3=T.BGInput},.14); Tw(bStroke,{Color=T.AccentLine,Transparency=.3},.14); if opts.Callback then task.spawn(opts.Callback,box.Text,enter) end end)

            local api={}; function api:Get() return box.Text end; function api:Set(v) box.Text=v end
            return api
        end

        ---- PARAGRAPH -----------------------------------------------
        function Tab:AddParagraph(opts)
            opts=opts or{}
            local txt=opts.Text or ""
            local hasT=opts.Title~=nil
            local lines=math.max(1,math.ceil(#txt/54))
            local h=10+(hasT and 20 or 0)+lines*15+10
            local card=Card(h)

            New("Frame",{BackgroundColor3=T.Accent,BackgroundTransparency=.3,Size=UDim2.new(0,3,.72,0),Position=UDim2.new(0,0,.14,0),ZIndex=9},card)

            if hasT then
                New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,14,0,7),Font=Enum.Font.GothamBold,Text=opts.Title,TextColor3=T.AccentGlow,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},card)
            end

            New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-20,0,lines*15),Position=UDim2.new(0,14,0,7+(hasT and 18 or 0)),Font=Enum.Font.Gotham,Text=txt,TextColor3=T.TextSec,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=9},card)
            return {}
        end

        ---- STATUS DISPLAY ------------------------------------------
        function Tab:AddStatus(opts)
            opts=opts or{}
            local card=Card(40)
            Lbl({Size=UDim2.new(0,140,1,0),Position=UDim2.new(0,12,0,0),Text=opts.Text or "Status",TextSize=12},card)
            local dot=New("Frame",{BackgroundColor3=opts.Color or T.Success,Size=UDim2.new(0,10,0,10),Position=UDim2.new(1,-130,.5,0),AnchorPoint=Vector2.new(0,.5),ZIndex=9},card)
            Rnd(99,dot)
            -- pulse
            local function pulse()
                Tw(dot,{Size=UDim2.new(0,13,0,13),BackgroundTransparency=.3},.5,Enum.EasingStyle.Sine)
                task.delay(.5,function() Tw(dot,{Size=UDim2.new(0,10,0,10),BackgroundTransparency=0},.5,Enum.EasingStyle.Sine); task.delay(.6,pulse) end)
            end
            pulse()
            local valLbl=New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,110,1,0),Position=UDim2.new(1,-118,.5,0),AnchorPoint=Vector2.new(0,.5),Font=Enum.Font.GothamBold,Text=opts.Value or "Online",TextColor3=opts.Color or T.Success,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},card)
            local api={}
            function api:Set(v,c)
                valLbl.Text=v
                if c then valLbl.TextColor3=c; dot.BackgroundColor3=c end
            end
            function api:Get() return valLbl.Text end
            return api
        end

        return Tab
    end -- AddTab

    return Window
end -- CreateWindow

return OceanUI
