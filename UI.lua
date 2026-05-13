-- OceanUI Library - Complete UI Library with Ocean Theme
-- API Inspired by Fluent but with Ocean Theme aesthetics

local OceanUI = {}
OceanUI.__index = OceanUI
OceanUI.Version = "1.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Color palette - Ocean Theme
local COLORS = {
    PRIMARY = Color3.fromRGB(0, 105, 148),
    PRIMARY_DARK = Color3.fromRGB(0, 78, 110),
    PRIMARY_LIGHT = Color3.fromRGB(64, 163, 201),
    SECONDARY = Color3.fromRGB(0, 168, 168),
    ACCENT = Color3.fromRGB(255, 193, 7),
    BACKGROUND = Color3.fromRGB(15, 32, 46),
    SURFACE = Color3.fromRGB(27, 48, 66),
    SURFACE_HOVER = Color3.fromRGB(35, 62, 84),
    TEXT = Color3.fromRGB(240, 248, 255),
    TEXT_DARK = Color3.fromRGB(200, 214, 229),
    ERROR = Color3.fromRGB(255, 82, 82),
    SUCCESS = Color3.fromRGB(76, 175, 80),
    WARNING = Color3.fromRGB(255, 193, 7),
    BORDER = Color3.fromRGB(64, 108, 137)
}

-- Tween settings
local TWEEN_INFO = {
    NORMAL = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SMOOTH = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    BOUNCE = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
}

-- Utility functions
local function CreateRoundedFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or COLORS.SURFACE
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

local function CreateTextLabel(parent, text, size, position, textSize, color, textXAlign, textYAlign)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.TEXT
    label.TextSize = textSize or 14
    label.TextXAlignment = textXAlign or Enum.TextXAlignment.Center
    label.TextYAlignment = textYAlign or Enum.TextYAlignment.Center
    label.Font = Enum.Font.GothamMedium
    label.RichText = true
    label.Parent = parent
    return label
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.BORDER
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Dialog Window
local function CreateDialog(options)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Parent = options.Parent
    
    local dialogFrame = CreateRoundedFrame(
        overlay,
        UDim2.new(0, 400, 0, 200),
        UDim2.new(0.5, -200, 0.5, -100),
        COLORS.SURFACE,
        0
    )
    
    local titleLabel = CreateTextLabel(
        dialogFrame,
        options.Title or "Dialog",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 10),
        18,
        COLORS.PRIMARY_LIGHT,
        Enum.TextXAlignment.Left
    )
    titleLabel.Font = Enum.Font.GothamBold
    
    local contentLabel = CreateTextLabel(
        dialogFrame,
        options.Content or "",
        UDim2.new(1, -20, 0, 80),
        UDim2.new(0, 10, 0, 50),
        14,
        COLORS.TEXT,
        Enum.TextXAlignment.Left,
        Enum.TextYAlignment.Top
    )
    contentLabel.TextWrapped = true
    
    local buttonY = 140
    local buttonWidth = 120
    local buttonSpacing = 20
    local totalWidth = (#options.Buttons * buttonWidth) + ((#options.Buttons - 1) * buttonSpacing)
    local startX = (400 - totalWidth) / 2
    
    for i, button in ipairs(options.Buttons) do
        local btn = CreateRoundedFrame(
            dialogFrame,
            UDim2.new(0, buttonWidth, 0, 40),
            UDim2.new(0, startX + (i-1) * (buttonWidth + buttonSpacing), 0, buttonY),
            COLORS.PRIMARY,
            0
        )
        
        local btnLabel = CreateTextLabel(
            btn,
            button.Title,
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            14,
            COLORS.TEXT
        )
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(btn, TWEEN_INFO.NORMAL, {
                    BackgroundColor3 = COLORS.PRIMARY_DARK
                }):Play()
                task.wait(0.1)
                if button.Callback then
                    button.Callback()
                end
                overlay:Destroy()
            end
        end)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY_LIGHT
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY
            }):Play()
        end)
    end
    
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Position.X < dialogFrame.AbsolutePosition.X or 
               input.Position.X > dialogFrame.AbsolutePosition.X + dialogFrame.AbsoluteSize.X or
               input.Position.Y < dialogFrame.AbsolutePosition.Y or
               input.Position.Y > dialogFrame.AbsoluteSize.Y + dialogFrame.AbsolutePosition.Y then
                overlay:Destroy()
            end
        end
    end)
end

-- Main Window Class
local Window = {}
Window.__index = Window

function OceanUI:CreateWindow(options)
    local self = setmetatable({}, Window)
    
    self.Title = options.Title or "OceanUI"
    self.SubTitle = options.SubTitle or ""
    self.TabWidth = options.TabWidth or 160
    self.Acrylic = options.Acrylic or false
    self.Theme = options.Theme or "Dark"
    self.MinimizeKey = options.MinimizeKey or Enum.KeyCode.LeftControl
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "OceanUI"
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Window Frame
    self.MainFrame = CreateRoundedFrame(
        self.ScreenGui,
        options.Size or UDim2.new(0, 580, 0, 460),
        UDim2.new(0.5, -290, 0.5, -230),
        COLORS.BACKGROUND,
        self.Acrylic and 0.8 or 0.95
    )
    
    if self.Acrylic then
        self.MainFrame.BackgroundTransparency = 0.8
        local blur = Instance.new("BlurEffect")
        blur.Size = 10
        blur.Parent = self.ScreenGui
    end
    
    -- Title Bar
    self.TitleBar = CreateRoundedFrame(
        self.MainFrame,
        UDim2.new(1, 0, 0, 50),
        UDim2.new(0, 0, 0, 0),
        COLORS.PRIMARY_DARK,
        0
    )
    self.TitleBar.ZIndex = 2
    
    local titleLabel = CreateTextLabel(
        self.TitleBar,
        self.Title,
        UDim2.new(0, 200, 1, 0),
        UDim2.new(0, 10, 0, 0),
        18,
        COLORS.TEXT,
        Enum.TextXAlignment.Left
    )
    titleLabel.Font = Enum.Font.GothamBold
    
    local subTitleLabel = CreateTextLabel(
        self.TitleBar,
        self.SubTitle,
        UDim2.new(0, 200, 1, 0),
        UDim2.new(0, 10, 0, 0),
        12,
        COLORS.TEXT_DARK,
        Enum.TextXAlignment.Left
    )
    subTitleLabel.Position = UDim2.new(0, 10, 0, 25)
    
    -- Minimize Button
    local minimizeBtn = CreateTextLabel(
        self.TitleBar,
        "─",
        UDim2.new(0, 30, 1, 0),
        UDim2.new(1, -60, 0, 0),
        20,
        COLORS.TEXT
    )
    
    minimizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleMinimize()
        end
    end)
    
    -- Close Button
    local closeBtn = CreateTextLabel(
        self.TitleBar,
        "✗",
        UDim2.new(0, 30, 1, 0),
        UDim2.new(1, -30, 0, 0),
        20,
        COLORS.TEXT
    )
    
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.MainFrame.Visible = false
        end
    end)
    
    -- Tab Container
    self.TabContainer = CreateRoundedFrame(
        self.MainFrame,
        UDim2.new(0, self.TabWidth, 1, -50),
        UDim2.new(0, 0, 0, 50),
        COLORS.SURFACE,
        0
    )
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Size = UDim2.new(1, -self.TabWidth, 1, -50)
    self.ContentContainer.Position = UDim2.new(0, self.TabWidth, 0, 50)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    -- Dragging functionality
    local dragging = false
    local dragStartPos = nil
    local frameStartPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = UserInputService:GetMouseLocation()
            frameStartPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - dragStartPos
            self.MainFrame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Keybind for minimize
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.MinimizeKey then
            self:ToggleMinimize()
        end
    end)
    
    return self
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.new(0, 580, 0, 50) or UDim2.new(0, 580, 0, 460)
    TweenService:Create(self.MainFrame, TWEEN_INFO.SMOOTH, {
        Size = targetSize
    }):Play()
    
    if self.Minimized then
        self.TabContainer.Visible = false
        self.ContentContainer.Visible = false
    else
        task.wait(0.3)
        self.TabContainer.Visible = true
        self.ContentContainer.Visible = true
    end
end

function Window:AddTab(options)
    local tab = {}
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or ""
    tab.Objects = {}
    
    -- Tab Button
    local yPos = (#self.Tabs) * 45 + 10
    local tabButton = CreateRoundedFrame(
        self.TabContainer,
        UDim2.new(0.9, 0, 0, 40),
        UDim2.new(0.05, 0, 0, yPos),
        (#self.Tabs == 0) and COLORS.PRIMARY or COLORS.SURFACE_HOVER,
        0
    )
    
    local tabLabel = CreateTextLabel(
        tabButton,
        tab.Title,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        14,
        (#self.Tabs == 0) and COLORS.TEXT or COLORS.TEXT_DARK,
        Enum.TextXAlignment.Left
    )
    tabLabel.Position = UDim2.new(0, 15, 0, 0)
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = (#self.Tabs == 0)
    contentFrame.Parent = self.ContentContainer
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = COLORS.PRIMARY_LIGHT
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = contentFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = scrollingFrame
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
    
    tab.Content = scrollingFrame
    tab.Button = tabButton
    
    tabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, otherTab in ipairs(self.Tabs) do
                otherTab.Content.Visible = false
                TweenService:Create(otherTab.Button, TWEEN_INFO.SMOOTH, {
                    BackgroundColor3 = COLORS.SURFACE_HOVER
                }):Play()
                local otherLabel = otherTab.Button:FindFirstChildWhichIsA("TextLabel")
                if otherLabel then
                    TweenService:Create(otherLabel, TWEEN_INFO.SMOOTH, {
                        TextColor3 = COLORS.TEXT_DARK
                    }):Play()
                end
            end
            
            contentFrame.Visible = true
            TweenService:Create(tabButton, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY
            }):Play()
            TweenService:Create(tabLabel, TWEEN_INFO.SMOOTH, {
                TextColor3 = COLORS.TEXT
            }):Play()
        end
    end)
    
    tabButton.MouseEnter:Connect(function()
        if contentFrame.Visible == false then
            TweenService:Create(tabButton, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY_DARK
            }):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if contentFrame.Visible == false then
            TweenService:Create(tabButton, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.SURFACE_HOVER
            }):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Add methods
    function tab:AddButton(buttonOptions)
        return self:CreateButton(buttonOptions)
    end
    
    function tab:AddParagraph(paragraphOptions)
        return self:CreateParagraph(paragraphOptions)
    end
    
    function tab:AddToggle(toggleId, toggleOptions)
        return self:CreateToggle(toggleId, toggleOptions)
    end
    
    function tab:AddSlider(sliderId, sliderOptions)
        return self:CreateSlider(sliderId, sliderOptions)
    end
    
    function tab:AddDropdown(dropdownId, dropdownOptions)
        return self:CreateDropdown(dropdownId, dropdownOptions)
    end
    
    function tab:AddInput(inputId, inputOptions)
        return self:CreateInput(inputId, inputOptions)
    end
    
    function tab:AddColorpicker(colorpickerId, colorpickerOptions)
        return self:CreateColorpicker(colorpickerId, colorpickerOptions)
    end
    
    function tab:AddKeybind(keybindId, keybindOptions)
        return self:CreateKeybind(keybindId, keybindOptions)
    end
    
    function tab:CreateButton(options)
        local buttonFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 45),
            UDim2.new(0, 0, 0, 0),
            COLORS.PRIMARY,
            0
        )
        
        local buttonLabel = CreateTextLabel(
            buttonFrame,
            options.Title or "Button",
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            14,
            COLORS.TEXT
        )
        
        if options.Description then
            local descLabel = CreateTextLabel(
                buttonFrame,
                options.Description,
                UDim2.new(1, -10, 0, 20),
                UDim2.new(0, 10, 0, 5),
                11,
                COLORS.TEXT_DARK,
                Enum.TextXAlignment.Left
            )
            buttonLabel.Position = UDim2.new(0, 10, 0, 20)
        end
        
        buttonFrame.MouseEnter:Connect(function()
            TweenService:Create(buttonFrame, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY_LIGHT
            }):Play()
        end)
        
        buttonFrame.MouseLeave:Connect(function()
            TweenService:Create(buttonFrame, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = COLORS.PRIMARY
            }):Play()
        end)
        
        buttonFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(buttonFrame, TWEEN_INFO.NORMAL, {
                    BackgroundColor3 = COLORS.PRIMARY_DARK
                }):Play()
                task.wait(0.1)
                TweenService:Create(buttonFrame, TWEEN_INFO.SMOOTH, {
                    BackgroundColor3 = COLORS.PRIMARY
                }):Play()
                if options.Callback then
                    options.Callback()
                end
            end
        end)
        
        return buttonFrame
    end
    
    function tab:CreateParagraph(options)
        local paragraphFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 80),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            paragraphFrame,
            options.Title or "",
            UDim2.new(1, -20, 0, 30),
            UDim2.new(0, 10, 0, 10),
            16,
            COLORS.PRIMARY_LIGHT,
            Enum.TextXAlignment.Left
        )
        titleLabel.Font = Enum.Font.GothamBold
        
        local contentLabel = CreateTextLabel(
            paragraphFrame,
            options.Content or "",
            UDim2.new(1, -20, 0, 40),
            UDim2.new(0, 10, 0, 40),
            13,
            COLORS.TEXT,
            Enum.TextXAlignment.Left,
            Enum.TextYAlignment.Top
        )
        contentLabel.TextWrapped = true
        
        return paragraphFrame
    end
    
    function tab:CreateToggle(toggleId, options)
        local toggle = {}
        toggle.Id = toggleId
        toggle.Value = options.Default or false
        toggle.Callbacks = {}
        
        local toggleFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 50),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            toggleFrame,
            options.Title or "Toggle",
            UDim2.new(0, 200, 1, 0),
            UDim2.new(0, 10, 0, 0),
            14,
            COLORS.TEXT,
            Enum.TextXAlignment.Left
        )
        
        if options.Description then
            local descLabel = CreateTextLabel(
                toggleFrame,
                options.Description,
                UDim2.new(0, 250, 0, 15),
                UDim2.new(0, 10, 0, 30),
                11,
                COLORS.TEXT_DARK,
                Enum.TextXAlignment.Left
            )
            titleLabel.Position = UDim2.new(0, 10, 0, 12)
        end
        
        -- Toggle switch
        local switch = CreateRoundedFrame(
            toggleFrame,
            UDim2.new(0, 50, 0, 26),
            UDim2.new(1, -60, 0.5, -13),
            toggle.Value and COLORS.PRIMARY_LIGHT or COLORS.TEXT_DARK,
            0
        )
        
        local knob = CreateRoundedFrame(
            switch,
            UDim2.new(0, 22, 0, 22),
            toggle.Value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
            COLORS.TEXT,
            0
        )
        
        local function UpdateToggle(value)
            toggle.Value = value
            local targetColor = value and COLORS.PRIMARY_LIGHT or COLORS.TEXT_DARK
            local targetPosition = value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            
            TweenService:Create(switch, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = targetColor
            }):Play()
            
            TweenService:Create(knob, TWEEN_INFO.SMOOTH, {
                Position = targetPosition
            }):Play()
            
            for _, callback in ipairs(toggle.Callbacks) do
                callback(value)
            end
            
            if options.Callback then
                options.Callback(value)
            end
        end
        
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateToggle(not toggle.Value)
            end
        end)
        
        function toggle:OnChanged(callback)
            table.insert(toggle.Callbacks, callback)
        end
        
        function toggle:SetValue(value)
            UpdateToggle(value)
        end
        
        function toggle:GetValue()
            return toggle.Value
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[toggleId] = toggle
        
        return toggle
    end
    
    function tab:CreateSlider(sliderId, options)
        local slider = {}
        slider.Id = sliderId
        slider.Value = options.Default or options.Min or 0
        slider.Min = options.Min or 0
        slider.Max = options.Max or 100
        slider.Rounding = options.Rounding or 0
        slider.Callbacks = {}
        
        local sliderFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 80),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            sliderFrame,
            options.Title or "Slider",
            UDim2.new(1, -60, 0, 25),
            UDim2.new(0, 10, 0, 8),
            14,
            COLORS.TEXT,
            Enum.TextXAlignment.Left
        )
        
        local valueLabel = CreateTextLabel(
            sliderFrame,
            tostring(slider.Value),
            UDim2.new(0, 50, 0, 25),
            UDim2.new(1, -60, 0, 8),
            14,
            COLORS.PRIMARY_LIGHT,
            Enum.TextXAlignment.Right
        )
        
        if options.Description then
            local descLabel = CreateTextLabel(
                sliderFrame,
                options.Description,
                UDim2.new(1, -70, 0, 20),
                UDim2.new(0, 10, 0, 30),
                11,
                COLORS.TEXT_DARK,
                Enum.TextXAlignment.Left
            )
        end
        
        -- Slider track
        local track = CreateRoundedFrame(
            sliderFrame,
            UDim2.new(1, -20, 0, 4),
            UDim2.new(0, 10, 0, 55),
            COLORS.BORDER,
            0
        )
        
        local fill = CreateRoundedFrame(
            track,
            UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            COLORS.PRIMARY_LIGHT,
            0
        )
        
        local handle = CreateRoundedFrame(
            track,
            UDim2.new(0, 16, 0, 16),
            UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -8, 0.5, -8),
            COLORS.PRIMARY,
            0
        )
        handle.BackgroundColor3 = COLORS.TEXT
        
        local dragging = false
        
        local function UpdateSlider(value)
            value = math.clamp(value, slider.Min, slider.Max)
            if slider.Rounding > 0 then
                value = math.floor(value * (10 ^ slider.Rounding) + 0.5) / (10 ^ slider.Rounding)
            end
            slider.Value = value
            local percent = (value - slider.Min) / (slider.Max - slider.Min)
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            handle.Position = UDim2.new(percent, -8, 0.5, -8)
            valueLabel.Text = tostring(value)
            
            for _, callback in ipairs(slider.Callbacks) do
                callback(value)
            end
            
            if options.Callback then
                options.Callback(value)
            end
        end
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local trackAbsPos = track.AbsolutePosition
                local trackWidth = track.AbsoluteSize.X
                
                local percent = math.clamp((mousePos.X - trackAbsPos.X) / trackWidth, 0, 1)
                local value = slider.Min + (slider.Max - slider.Min) * percent
                UpdateSlider(value)
            end
        end)
        
        function slider:OnChanged(callback)
            table.insert(slider.Callbacks, callback)
        end
        
        function slider:SetValue(value)
            UpdateSlider(value)
        end
        
        function slider:GetValue()
            return slider.Value
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[sliderId] = slider
        
        return slider
    end
    
    function tab:CreateDropdown(dropdownId, options)
        local dropdown = {}
        dropdown.Id = dropdownId
        dropdown.Values = options.Values or {}
        dropdown.Multi = options.Multi or false
        dropdown.Selected = options.Multi and (options.Default or {}) or (options.Default or dropdown.Values[1])
        dropdown.Open = false
        dropdown.Callbacks = {}
        
        local dropdownFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 50),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            dropdownFrame,
            options.Title or "Dropdown",
            UDim2.new(1, -40, 0, 20),
            UDim2.new(0, 10, 0, 5),
            12,
            COLORS.TEXT_DARK,
            Enum.TextXAlignment.Left
        )
        
        local selectedLabel = CreateTextLabel(
            dropdownFrame,
            dropdown.Multi and "Select items..." or tostring(dropdown.Selected),
            UDim2.new(1, -40, 0, 30),
            UDim2.new(0, 10, 0, 22),
            13,
            COLORS.TEXT,
            Enum.TextXAlignment.Left
        )
        
        local arrow = CreateTextLabel(
            dropdownFrame,
            "▼",
            UDim2.new(0, 30, 0, 30),
            UDim2.new(1, -35, 0, 22),
            12,
            COLORS.PRIMARY_LIGHT
        )
        
        -- Dropdown list
        local listHeight = math.min(#dropdown.Values * 35, 200)
        local listFrame = CreateRoundedFrame(
            dropdownFrame,
            UDim2.new(1, 0, 0, listHeight),
            UDim2.new(0, 0, 1, 5),
            COLORS.SURFACE,
            0
        )
        listFrame.Visible = false
        listFrame.ZIndex = 10
        
        local listScroll = Instance.new("ScrollingFrame")
        listScroll.Size = UDim2.new(1, 0, 1, 0)
        listScroll.BackgroundTransparency = 1
        listScroll.ScrollBarThickness = 4
        listScroll.Parent = listFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = listScroll
        
        dropdown.Buttons = {}
        
        for i, value in ipairs(dropdown.Values) do
            local itemFrame = CreateRoundedFrame(
                listScroll,
                UDim2.new(1, -10, 0, 30),
                UDim2.new(0, 5, 0, 0),
                COLORS.SURFACE_HOVER,
                0
            )
            
            local checkBox = nil
            local itemLabel = nil
            
            if dropdown.Multi then
                checkBox = CreateRoundedFrame(
                    itemFrame,
                    UDim2.new(0, 16, 0, 16),
                    UDim2.new(0, 10, 0.5, -8),
                    dropdown.Selected[value] and COLORS.PRIMARY_LIGHT or COLORS.BORDER,
                    0
                )
                
                local checkMark = CreateTextLabel(
                    checkBox,
                    "✓",
                    UDim2.new(1, 0, 1, 0),
                    UDim2.new(0, 0, 0, 0),
                    12,
                    COLORS.TEXT
                )
                checkMark.Visible = dropdown.Selected[value] or false
                
                itemLabel = CreateTextLabel(
                    itemFrame,
                    value,
                    UDim2.new(1, -40, 1, 0),
                    UDim2.new(0, 35, 0, 0),
                            13,
                    COLORS.TEXT,
                    Enum.TextXAlignment.Left
                )
                
                itemFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dropdown.Selected[value] = not dropdown.Selected[value]
                        checkBox.BackgroundColor3 = dropdown.Selected[value] and COLORS.PRIMARY_LIGHT or COLORS.BORDER
                        checkMark.Visible = dropdown.Selected[value]
                        
                        local selectedText = {}
                        for v, selected in pairs(dropdown.Selected) do
                            if selected then
                                table.insert(selectedText, v)
                            end
                        end
                        selectedLabel.Text = #selectedText > 0 and table.concat(selectedText, ", ") or "Select items..."
                        
                        for _, callback in ipairs(dropdown.Callbacks) do
                            callback(dropdown.Selected)
                        end
                        
                        if options.Callback then
                            options.Callback(dropdown.Selected)
                        end
                    end
                end)
            else
                itemLabel = CreateTextLabel(
                    itemFrame,
                    value,
                    UDim2.new(1, 0, 1, 0),
                    UDim2.new(0, 10, 0, 0),
                    13,
                    COLORS.TEXT,
                    Enum.TextXAlignment.Left
                )
                
                itemFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dropdown.Selected = value
                        selectedLabel.Text = value
                        dropdown:Toggle()
                        
                        for _, callback in ipairs(dropdown.Callbacks) do
                            callback(value)
                        end
                        
                        if options.Callback then
                            options.Callback(value)
                        end
                    end
                end)
            end
            
            itemFrame.MouseEnter:Connect(function()
                TweenService:Create(itemFrame, TWEEN_INFO.SMOOTH, {
                    BackgroundColor3 = COLORS.PRIMARY_DARK
                }):Play()
            end)
            
            itemFrame.MouseLeave:Connect(function()
                TweenService:Create(itemFrame, TWEEN_INFO.SMOOTH, {
                    BackgroundColor3 = COLORS.SURFACE_HOVER
                }):Play()
            end)
            
            dropdown.Buttons[value] = itemFrame
        end
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        function dropdown:Toggle()
            dropdown.Open = not dropdown.Open
            listFrame.Visible = dropdown.Open
            arrow.Text = dropdown.Open and "▲" or "▼"
        end
        
        dropdownFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dropdown:Toggle()
            end
        end)
        
        function dropdown:OnChanged(callback)
            table.insert(dropdown.Callbacks, callback)
        end
        
        function dropdown:SetValue(value)
            if dropdown.Multi then
                dropdown.Selected = value
                local selectedText = {}
                for v, selected in pairs(value) do
                    if selected then
                        table.insert(selectedText, v)
                    end
                end
                selectedLabel.Text = #selectedText > 0 and table.concat(selectedText, ", ") or "Select items..."
            else
                dropdown.Selected = value
                selectedLabel.Text = value
            end
        end
        
        function dropdown:GetValue()
            return dropdown.Selected
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[dropdownId] = dropdown
        
        return dropdown
    end
    
    function tab:CreateInput(inputId, options)
        local input = {}
        input.Id = inputId
        input.Value = options.Default or ""
        input.Callbacks = {}
        
        local inputFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 70),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            inputFrame,
            options.Title or "Input",
            UDim2.new(1, -20, 0, 25),
            UDim2.new(0, 10, 0, 8),
            13,
            COLORS.TEXT_DARK,
            Enum.TextXAlignment.Left
        )
        
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(1, -20, 0, 35)
        textBox.Position = UDim2.new(0, 10, 0, 30)
        textBox.BackgroundColor3 = COLORS.SURFACE_HOVER
        textBox.TextColor3 = COLORS.TEXT
        textBox.TextSize = 14
        textBox.Font = Enum.Font.GothamMedium
        textBox.PlaceholderText = options.Placeholder or "Enter text..."
        textBox.PlaceholderColor3 = COLORS.TEXT_DARK
        textBox.Text = input.Value
        textBox.ClearTextOnFocus = false
        textBox.Parent = inputFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = textBox
        
        local stroke = CreateStroke(textBox, COLORS.BORDER, 1)
        
        local function UpdateInput(value)
            input.Value = value
            for _, callback in ipairs(input.Callbacks) do
                callback(value)
            end
            if options.Callback then
                options.Callback(value)
            end
        end
        
        textBox.Focused:Connect(function()
            stroke.Color = COLORS.PRIMARY_LIGHT
            stroke.Thickness = 2
        end)
        
        textBox.FocusLost:Connect(function(enterPressed)
            stroke.Color = COLORS.BORDER
            stroke.Thickness = 1
            if options.Finished then
                if enterPressed then
                    UpdateInput(textBox.Text)
                end
            else
                UpdateInput(textBox.Text)
            end
        end)
        
        function input:OnChanged(callback)
            table.insert(input.Callbacks, callback)
        end
        
        function input:SetValue(value)
            input.Value = value
            textBox.Text = value
        end
        
        function input:GetValue()
            return input.Value
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[inputId] = input
        
        return input
    end
    
    function tab:CreateColorpicker(colorpickerId, options)
        local colorpicker = {}
        colorpicker.Id = colorpickerId
        colorpicker.Value = options.Default or COLORS.PRIMARY
        colorpicker.Transparency = options.Transparency or 0
        colorpicker.Callbacks = {}
        
        local cpFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 60),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            cpFrame,
            options.Title or "Colorpicker",
            UDim2.new(1, -60, 0, 25),
            UDim2.new(0, 10, 0, 8),
            14,
            COLORS.TEXT,
            Enum.TextXAlignment.Left
        )
        
        local colorDisplay = CreateRoundedFrame(
            cpFrame,
            UDim2.new(0, 40, 0, 40),
            UDim2.new(1, -50, 0.5, -20),
            colorpicker.Value,
            0
        )
        
        if options.Description then
            local descLabel = CreateTextLabel(
                cpFrame,
                options.Description,
                UDim2.new(1, -70, 0, 20),
                UDim2.new(0, 10, 0, 30),
                11,
                COLORS.TEXT_DARK,
                Enum.TextXAlignment.Left
            )
        end
        
        local function UpdateColorpicker(color, transparency)
            colorpicker.Value = color
            colorpicker.Transparency = transparency or colorpicker.Transparency
            colorDisplay.BackgroundColor3 = color
            colorDisplay.BackgroundTransparency = colorpicker.Transparency
            
            for _, callback in ipairs(colorpicker.Callbacks) do
                callback()
            end
            
            if options.Callback then
                options.Callback()
            end
        end
        
        colorDisplay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Simplified color selection (in real implementation, would open color picker)
                local randomColor = Color3.fromRGB(
                    math.random(0, 255),
                    math.random(0, 255),
                    math.random(0, 255)
                )
                UpdateColorpicker(randomColor, colorpicker.Transparency)
            end
        end)
        
        function colorpicker:OnChanged(callback)
            table.insert(colorpicker.Callbacks, callback)
        end
        
        function colorpicker:SetValueRGB(color)
            UpdateColorpicker(color, colorpicker.Transparency)
        end
        
        function colorpicker:GetValue()
            return colorpicker.Value
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[colorpickerId] = colorpicker
        
        return colorpicker
    end
    
    function tab:CreateKeybind(keybindId, options)
        local keybind = {}
        keybind.Id = keybindId
        keybind.Value = options.Default or "None"
        keybind.Mode = options.Mode or "Toggle"
        keybind.State = false
        keybind.Callbacks = {}
        keybind.ClickCallbacks = {}
        keybind.ChangedCallbacks = {}
        
        local kbFrame = CreateRoundedFrame(
            tab.Content,
            UDim2.new(1, -20, 0, 60),
            UDim2.new(0, 0, 0, 0),
            COLORS.SURFACE,
            0
        )
        
        local titleLabel = CreateTextLabel(
            kbFrame,
            options.Title or "Keybind",
            UDim2.new(1, -120, 0, 25),
            UDim2.new(0, 10, 0, 8),
            14,
            COLORS.TEXT,
            Enum.TextXAlignment.Left
        )
        
        local keyButton = CreateRoundedFrame(
            kbFrame,
            UDim2.new(0, 100, 0, 30),
            UDim2.new(1, -110, 0.5, -15),
            COLORS.SURFACE_HOVER,
            0
        )
        
        local keyLabel = CreateTextLabel(
            keyButton,
            keybind.Value,
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            13,
            COLORS.TEXT
        )
        
        if options.Description then
            local descLabel = CreateTextLabel(
                kbFrame,
                options.Description,
                UDim2.new(1, -130, 0, 20),
                UDim2.new(0, 10, 0, 30),
                11,
                COLORS.TEXT_DARK,
                Enum.TextXAlignment.Left
            )
        end
        
        local listening = false
        
        local function UpdateKeybind(newKey, newMode)
            keybind.Value = newKey
            keybind.Mode = newMode or keybind.Mode
            keyLabel.Text = newKey
            
            for _, callback in ipairs(keybind.ChangedCallbacks) do
                callback(newKey)
            end
            
            if options.ChangedCallback then
                options.ChangedCallback(newKey)
            end
        end
        
        keyButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not listening then
                    listening = true
                    keyLabel.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if not gameProcessed and listening then
                            local keyName = ""
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                                keyName = "MB1"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                keyName = "MB2"
                            else
                                return
                            end
                            
                            UpdateKeybind(keyName)
                            listening = false
                            connection:Disconnect()
                        end
                    end)
                    
                    task.wait(3)
                    if listening then
                        listening = false
                        keyLabel.Text = keybind.Value
                        connection:Disconnect()
                    end
                end
            end
        end)
        
        -- Keybind listening
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local pressedKey = ""
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                pressedKey = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                pressedKey = "MB1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                pressedKey = "MB2"
            else
                return
            end
            
            if pressedKey == keybind.Value then
                if keybind.Mode == "Toggle" then
                    keybind.State = not keybind.State
                    for _, callback in ipairs(keybind.ClickCallbacks) do
                        callback()
                    end
                    if options.Callback then
                        options.Callback(keybind.State)
                    end
                elseif keybind.Mode == "Hold" then
                    keybind.State = true
                    for _, callback in ipairs(keybind.ClickCallbacks) do
                        callback()
                    end
                    if options.Callback then
                        options.Callback(true)
                    end
                else -- Always
                    for _, callback in ipairs(keybind.ClickCallbacks) do
                        callback()
                    end
                    if options.Callback then
                        options.Callback(true)
                    end
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            local releasedKey = ""
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                releasedKey = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                releasedKey = "MB1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                releasedKey = "MB2"
            else
                return
            end
            
            if releasedKey == keybind.Value and keybind.Mode == "Hold" then
                keybind.State = false
                if options.Callback then
                    options.Callback(false)
                end
            end
        end)
        
        function keybind:OnClick(callback)
            table.insert(keybind.ClickCallbacks, callback)
        end
        
        function keybind:OnChanged(callback)
            table.insert(keybind.ChangedCallbacks, callback)
        end
        
        function keybind:SetValue(newKey, newMode)
            UpdateKeybind(newKey, newMode)
        end
        
        function keybind:GetState()
            return keybind.State
        end
        
        OceanUI.Options = OceanUI.Options or {}
        OceanUI.Options[keybindId] = keybind
        
        return keybind
    end
    
    function self:SelectTab(index)
        if self.Tabs[index] then
            for i, tab in ipairs(self.Tabs) do
                tab.Content.Visible = (i == index)
                TweenService:Create(tab.Button, TWEEN_INFO.SMOOTH, {
                    BackgroundColor3 = (i == index) and COLORS.PRIMARY or COLORS.SURFACE_HOVER
                }):Play()
                local label = tab.Button:FindFirstChildWhichIsA("TextLabel")
                if label then
                    TweenService:Create(label, TWEEN_INFO.SMOOTH, {
                        TextColor3 = (i == index) and COLORS.TEXT or COLORS.TEXT_DARK
                    }):Play()
                end
            end
        end
    end
    
    function self:Dialog(dialogOptions)
        dialogOptions.Parent = self.MainFrame
        CreateDialog(dialogOptions)
    end
    
    return self
end

-- Notification system
function OceanUI:Notify(options)
    local screenGui = nil
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == "OceanUI" then
            screenGui = gui
            break
        end
    end
    
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "OceanUI"
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local notifFrame = CreateRoundedFrame(
        screenGui,
        UDim2.new(0, 320, 0, 70),
        UDim2.new(1, -330, 0, -100),
        COLORS.SURFACE,
        0
    )
    
    local icon = "📘"
    local iconColor = COLORS.PRIMARY_LIGHT
    
    if options.Type == "success" then
        icon = "✓"
        iconColor = COLORS.SUCCESS
    elseif options.Type == "error" then
        icon = "✗"
        iconColor = COLORS.ERROR
    elseif options.Type == "warning" then
        icon = "⚠"
        iconColor = COLORS.WARNING
    end
    
    local iconLabel = CreateTextLabel(
        notifFrame,
        icon,
        UDim2.new(0, 40, 1, 0),
        UDim2.new(0, 0, 0, 0),
        24,
        iconColor
    )
    
    local titleLabel = CreateTextLabel(
        notifFrame,
        options.Title or "Notification",
        UDim2.new(1, -50, 0, 25),
        UDim2.new(0, 50, 0, 8),
        14,
        COLORS.PRIMARY_LIGHT,
        Enum.TextXAlignment.Left
    )
    
    local contentLabel = CreateTextLabel(
        notifFrame,
        options.Content or "",
        UDim2.new(1, -50, 0, 35),
        UDim2.new(0, 50, 0, 33),
        12,
        COLORS.TEXT,
        Enum.TextXAlignment.Left
    )
    contentLabel.TextWrapped = true
    
    if options.SubContent then
        local subLabel = CreateTextLabel(
            notifFrame,
            options.SubContent,
            UDim2.new(1, -50, 0, 20),
            UDim2.new(0, 50, 0, 48),
            10,
            COLORS.TEXT_DARK,
            Enum.TextXAlignment.Left
        )
        contentLabel.Size = UDim2.new(1, -50, 0, 25)
    end
    
    local closeBtn = CreateTextLabel(
        notifFrame,
        "✗",
        UDim2.new(0, 25, 0, 25),
        UDim2.new(1, -30, 0, 8),
        14,
        COLORS.TEXT_DARK
    )
    
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(notifFrame, TWEEN_INFO.SMOOTH, {
                Position = UDim2.new(1, -330, 0, -100)
            }):Play()
            task.wait(0.3)
            notifFrame:Destroy()
        end
    end)
    
    -- Animate in
    TweenService:Create(notifFrame, TWEEN_INFO.BOUNCE, {
        Position = UDim2.new(1, -330, 0, 10)
    }):Play()
    
    -- Auto dismiss
    if options.Duration ~= nil then
        task.wait(options.Duration or 5)
        if notifFrame and notifFrame.Parent then
            TweenService:Create(notifFrame, TWEEN_INFO.SMOOTH, {
                Position = UDim2.new(1, -330, 0, -100)
            }):Play()
            task.wait(0.3)
            notifFrame:Destroy()
        end
    end
end

OceanUI.Options = {}
OceanUI.Unloaded = false

-- Example usage
local function SetupExampleUI()
    local Fluent = OceanUI
    
    local Window = Fluent:CreateWindow({
        Title = "OceanUI " .. Fluent.Version,
        SubTitle = "by Ocean Team",
        TabWidth = 160,
        Size = UDim2.new(0, 580, 0, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    -- Notifications example
    Fluent:Notify({
        Title = "OceanUI",
        Content = "Welcome to OceanUI! 🌊",
        SubContent = "Your modern UI library",
        Duration = 5
    })
    
    -- Paragraph example
    Tabs.Main:AddParagraph({
        Title = "About OceanUI",
        Content = "OceanUI is a modern UI library with an ocean theme.\nIt features smooth animations and beautiful design.\nVersion: 1.0.0"
    })
    
    -- Button example with dialog
    Tabs.Main:AddButton({
        Title = "Show Dialog",
        Description = "Click to see a dialog window",
        Callback = function()
            Window:Dialog({
                Title = "Ocean Dialog",
                Content = "This is a beautiful dialog window with ocean theme!\nDo you like it?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            Fluent:Notify({
                                Title = "Great!",
                                Content = "You love OceanUI! 🌊",
                                Type = "success",
                                Duration = 3
                            })
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Dialog cancelled")
                        end
                    }
                }
            })
        end
    })
    
    -- Toggle example
    local Toggle = Tabs.Main:AddToggle("MyToggle", {
        Title = "Ocean Mode",
        Description = "Enable ocean effects",
        Default = true
    })
    
    Toggle:OnChanged(function()
        print("Toggle changed:", Fluent.Options.MyToggle.Value)
        Fluent:Notify({
            Title = "Toggle Changed",
            Content = "Ocean mode is now " .. (Fluent.Options.MyToggle.Value and "ON" or "OFF"),
            Duration = 2
        })
    end)
    
    -- Slider example
    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Volume",
        Description = "Adjust the volume level",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            print("Slider changed:", Value)
        end
    })
    
    Slider:OnChanged(function(Value)
        print("Slider value:", Value)
    end)
    
    Slider:SetValue(75)
    
    -- Dropdown example
    local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
        Title = "Theme Color",
        Values = {"Ocean Blue", "Coral Reef", "Deep Sea", "Shallows", "Midnight"},
        Multi = false,
        Default = "Ocean Blue",
    })
    
    Dropdown:SetValue("Deep Sea")
    
    Dropdown:OnChanged(function(Value)
        print("Dropdown changed:", Value)
        Fluent:Notify({
            Title = "Theme Changed",
            Content = "Selected: " .. Value,
            Type = "success",
            Duration = 2
        })
    end)
    
    -- Multi Dropdown example
    local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Features",
        Description = "Select multiple features",
        Values = {"Wave Effects", "Bubbles", "Fish", "Corals", "Lighting"},
        Multi = true,
        Default = {["Wave Effects"] = true, ["Bubbles"] = true},
    })
    
    MultiDropdown:OnChanged(function(Value)
        local selected = {}
        for v, state in pairs(Value) do
            if state then
                table.insert(selected, v)
            end
        end
        print("MultiDropdown changed:", table.concat(selected, ", "))
    end)
    
    -- Colorpicker example
    local Colorpicker = Tabs.Main:AddColorpicker("Colorpicker", {
        Title = "Accent Color",
        Default = COLORS.PRIMARY_LIGHT
    })
    
    Colorpicker:OnChanged(function()
        print("Colorpicker changed:", Colorpicker.Value)
    end)
    
    Colorpicker:SetValueRGB(Color3.fromRGB(100, 200, 255))
    
    -- Colorpicker with transparency
    local TColorpicker = Tabs.Main:AddColorpicker("TransparencyColorpicker", {
        Title = "Background Color",
        Description = "With transparency control",
        Transparency = 0.5,
        Default = COLORS.PRIMARY
    })
    
    TColorpicker:OnChanged(function()
        print("Colorpicker changed with transparency:", TColorpicker.Transparency)
    end)
    
    -- Keybind example
    local Keybind = Tabs.Main:AddKeybind("Keybind", {
        Title = "Toggle UI",
        Mode = "Toggle",
        Default = "LeftControl",
        Callback = function(Value)
            print("Keybind pressed!", Value)
            Fluent:Notify({
                Title = "Keybind Triggered",
                Content = "UI Toggle: " .. (Value and "ON" : "OFF"),
                Duration = 2
            })
        end,
        ChangedCallback = function(New)
            print("Keybind changed to:", New)
        end
    })
    
    Keybind:OnClick(function()
        print("Keybind clicked, state:", Keybind:GetState())
    end)
    
    Keybind:OnChanged(function()
        print("Keybind value changed:", Keybind.Value)
    end)
    
    -- Input example
    local Input = Tabs.Main:AddInput("Input", {
        Title = "Username",
        Default = "OceanExplorer",
        Placeholder = "Enter your username...",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            print("Input submitted:", Value)
            Fluent:Notify({
                Title = "Welcome",
                Content = "Hello, " .. Value .. "! 🌊",
                Type = "success",
                Duration = 3
            })
        end
    })
    
    Input:OnChanged(function()
        print("Input changed:", Input.Value)
    end)
    
    -- Settings tab
    Tabs.Settings:AddParagraph({
        Title = "Settings",
        Content = "Configure OceanUI to your preferences.\nMore settings coming soon!"
    })
    
    Tabs.Settings:AddButton({
        Title = "Reset All Settings",
        Description = "Reset all options to default",
        Callback = function()
            Window:Dialog({
                Title = "Confirm Reset",
                Content = "Are you sure you want to reset all settings?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            Fluent:Notify({
                                Title = "Reset Complete",
                                Content = "All settings have been reset",
                                Type = "success",
                                Duration = 3
                            })
                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                            print("Reset cancelled")
                        end
                    }
                }
            })
        end
    })
    
    -- Select main tab
    Window:SelectTab(1)
    
    -- Final notification
    Fluent:Notify({
        Title = "OceanUI Loaded",
        Content = "Your ocean-themed UI is ready! 🌊✨",
        Type = "success",
        Duration = 5
    })
end

-- Run the example
SetupExampleUI()

return OceanUI
