
local OceanUI = {}
OceanUI.__index = OceanUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Tween settings
local TWEEN_INFO = {
    NORMAL = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SMOOTH = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    BOUNCE = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
}

-- Color palette - Ocean Theme
local COLORS = {
    PRIMARY = Color3.fromRGB(0, 105, 148),      -- Deep Ocean Blue
    PRIMARY_DARK = Color3.fromRGB(0, 78, 110),  -- Dark Ocean
    PRIMARY_LIGHT = Color3.fromRGB(64, 163, 201), -- Light Ocean
    SECONDARY = Color3.fromRGB(0, 168, 168),    -- Sea Green
    ACCENT = Color3.fromRGB(255, 193, 7),       -- Coral/Sunlight
    BACKGROUND = Color3.fromRGB(15, 32, 46),    -- Deep Sea Dark
    SURFACE = Color3.fromRGB(27, 48, 66),       -- Ocean Surface
    SURFACE_HOVER = Color3.fromRGB(35, 62, 84), -- Slightly Lighter
    TEXT = Color3.fromRGB(240, 248, 255),       -- Foam White
    TEXT_DARK = Color3.fromRGB(200, 214, 229),  -- Muted Foam
    ERROR = Color3.fromRGB(255, 82, 82),        -- Coral Red
    SUCCESS = Color3.fromRGB(76, 175, 80),      -- Seaweed Green
    WARNING = Color3.fromRGB(255, 193, 7),      -- Sandy Yellow
    BORDER = Color3.fromRGB(64, 108, 137)       -- Deep Border
}

-- Utility functions
local function createRoundedFrame(parent, size, position, color, transparency)
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

local function createTextLabel(parent, text, size, position, textSize, color)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.TEXT
    label.TextSize = textSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Font = Enum.Font.GothamMedium
    label.Parent = parent
    return label
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.BORDER
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Main UI Manager
function OceanUI.new(screenGui)
    local self = setmetatable({}, OceanUI)
    self.ScreenGui = screenGui or Instance.new("ScreenGui")
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.Components = {}
    self.Notifications = {}
    
    -- Main container
    self.MainContainer = Instance.new("Frame")
    self.MainContainer.Size = UDim2.new(1, 0, 1, 0)
    self.MainContainer.BackgroundTransparency = 1
    self.MainContainer.Parent = self.ScreenGui
    
    return self
end

-- Button Component
function OceanUI:CreateButton(options)
    local button = {}
    
    button.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 200, 0, 45),
        options.Position or UDim2.new(0.5, -100, 0.5, -22),
        COLORS.PRIMARY,
        0
    )
    
    button.Label = createTextLabel(
        button.Frame,
        options.Text or "Button",
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        options.TextSize or 16,
        COLORS.TEXT
    )
    
    -- Hover effects
    local hoverTween = TweenService:Create(button.Frame, TWEEN_INFO.SMOOTH, {
        BackgroundColor3 = COLORS.PRIMARY_LIGHT
    })
    
    local leaveTween = TweenService:Create(button.Frame, TWEEN_INFO.SMOOTH, {
        BackgroundColor3 = COLORS.PRIMARY
    })
    
    button.Frame.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.Frame.MouseLeave:Connect(function()
        leaveTween:Play()
    end)
    
    -- Click event
    if options.OnClick then
        button.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local clickTween = TweenService:Create(button.Frame, TWEEN_INFO.NORMAL, {
                    BackgroundColor3 = COLORS.PRIMARY_DARK
                })
                clickTween:Play()
                clickTween.Completed:Connect(function()
                    leaveTween:Play()
                end)
                options.OnClick()
            end
        end)
    end
    
    button:SetText = function(newText)
        button.Label.Text = newText
    end
    
    button:SetEnabled = function(enabled)
        button.Frame.Active = enabled
        button.Frame.BackgroundTransparency = enabled and 0 or 0.5
    end
    
    table.insert(self.Components, button)
    return button
end

-- Toggle Button Component
function OceanUI:CreateToggle(options)
    local toggle = {}
    toggle.Value = options.Default or false
    
    toggle.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 250, 0, 50),
        options.Position or UDim2.new(0.5, -125, 0.5, -25),
        COLORS.SURFACE,
        0
    )
    
    toggle.Label = createTextLabel(
        toggle.Frame,
        options.Text or "Toggle",
        UDim2.new(0, 180, 1, 0),
        UDim2.new(0, 10, 0, 0),
        14,
        COLORS.TEXT
    )
    toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle switch
    toggle.Switch = createRoundedFrame(
        toggle.Frame,
        UDim2.new(0, 50, 0, 26),
        UDim2.new(1, -60, 0.5, -13),
        toggle.Value and COLORS.PRIMARY_LIGHT or COLORS.TEXT_DARK,
        0
    )
    
    toggle.Knob = createRoundedFrame(
        toggle.Switch,
        UDim2.new(0, 22, 0, 22),
        toggle.Value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
        COLORS.TEXT,
        0
    )
    toggle.Knob.BackgroundColor3 = COLORS.TEXT
    
    local function updateToggle(value)
        toggle.Value = value
        local targetColor = value and COLORS.PRIMARY_LIGHT or COLORS.TEXT_DARK
        local targetPosition = value and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        
        TweenService:Create(toggle.Switch, TWEEN_INFO.SMOOTH, {
            BackgroundColor3 = targetColor
        }):Play()
        
        TweenService:Create(toggle.Knob, TWEEN_INFO.SMOOTH, {
            Position = targetPosition
        }):Play()
        
        if options.OnChanged then
            options.OnChanged(value)
        end
    end
    
    toggle.Switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle(not toggle.Value)
        end
    end)
    
    toggle:SetValue = updateToggle
    toggle:GetValue = function() return toggle.Value end
    
    table.insert(self.Components, toggle)
    return toggle
end

-- Slider Component
function OceanUI:CreateSlider(options)
    local slider = {}
    slider.Value = options.Default or options.Min or 0
    slider.Min = options.Min or 0
    slider.Max = options.Max or 100
    
    slider.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 300, 0, 70),
        options.Position or UDim2.new(0.5, -150, 0.5, -35),
        COLORS.SURFACE,
        0
    )
    
    slider.Label = createTextLabel(
        slider.Frame,
        options.Text or "Slider",
        UDim2.new(1, 0, 0, 20),
        UDim2.new(0, 10, 0, 5),
        14,
        COLORS.TEXT
    )
    slider.Label.TextXAlignment = Enum.TextXAlignment.Left
    
    slider.ValueLabel = createTextLabel(
        slider.Frame,
        tostring(slider.Value),
        UDim2.new(1, -10, 0, 20),
        UDim2.new(0, 0, 0, 5),
        14,
        COLORS.PRIMARY_LIGHT
    )
    slider.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Slider track
    slider.Track = createRoundedFrame(
        slider.Frame,
        UDim2.new(0, options.TrackWidth or 280, 0, 4),
        UDim2.new(0, 10, 1, -15),
        COLORS.BORDER,
        0
    )
    
    slider.Fill = createRoundedFrame(
        slider.Track,
        UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        COLORS.PRIMARY_LIGHT,
        0
    )
    
    slider.Handle = createRoundedFrame(
        slider.Track,
        UDim2.new(0, 16, 0, 16),
        UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -8, 0.5, -8),
        COLORS.PRIMARY,
        0
    )
    slider.Handle.BackgroundColor3 = COLORS.TEXT
    
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, slider.Min, slider.Max)
        slider.Value = value
        local percent = (value - slider.Min) / (slider.Max - slider.Min)
        
        slider.Fill.Size = UDim2.new(percent, 0, 1, 0)
        slider.Handle.Position = UDim2.new(percent, -8, 0.5, -8)
        slider.ValueLabel.Text = options.Decimal and string.format("%.1f", value) or tostring(math.floor(value))
        
        if options.OnChanged then
            options.OnChanged(value)
        end
    end
    
    slider.Handle.InputBegan:Connect(function(input)
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
            local trackAbsPos = slider.Track.AbsolutePosition
            local trackWidth = slider.Track.AbsoluteSize.X
            
            local percent = math.clamp((mousePos.X - trackAbsPos.X) / trackWidth, 0, 1)
            local value = slider.Min + (slider.Max - slider.Min) * percent
            updateSlider(value)
        end
    end)
    
    slider:SetValue = updateSlider
    slider:GetValue = function() return slider.Value end
    
    table.insert(self.Components, slider)
    return slider
end

-- Dropdown Component
function OceanUI:CreateDropdown(options)
    local dropdown = {}
    dropdown.Open = false
    dropdown.Selected = options.Default or options.Items[1] or ""
    dropdown.Items = options.Items or {}
    
    dropdown.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 200, 0, 40),
        options.Position or UDim2.new(0.5, -100, 0.5, -20),
        COLORS.SURFACE,
        0
    )
    
    dropdown.SelectedLabel = createTextLabel(
        dropdown.Frame,
        dropdown.Selected,
        UDim2.new(1, -30, 1, 0),
        UDim2.new(0, 10, 0, 0),
        14,
        COLORS.TEXT
    )
    dropdown.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Arrow icon
    dropdown.Arrow = createTextLabel(
        dropdown.Frame,
        "▼",
        UDim2.new(0, 30, 1, 0),
        UDim2.new(1, -30, 0, 0),
        12,
        COLORS.PRIMARY_LIGHT
    )
    
    -- Dropdown list
    dropdown.List = createRoundedFrame(
        dropdown.Frame,
        UDim2.new(1, 0, 0, #dropdown.Items * 35),
        UDim2.new(0, 0, 1, 5),
        COLORS.SURFACE,
        0
    )
    dropdown.List.Visible = false
    
    dropdown.Buttons = {}
    
    for i, item in ipairs(dropdown.Items) do
        local itemBtn = createRoundedFrame(
            dropdown.List,
            UDim2.new(1, -10, 0, 30),
            UDim2.new(0, 5, 0, 5 + (i-1) * 35),
            COLORS.SURFACE_HOVER,
            0
        )
        
        local itemLabel = createTextLabel(
            itemBtn,
            item,
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            13,
            COLORS.TEXT
        )
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        itemBtn.MouseEnter:Connect(function()
            TweenService:Create(itemBtn, TWEEN_INFO.NORMAL, {
                BackgroundColor3 = COLORS.PRIMARY
            }):Play()
        end)
        
        itemBtn.MouseLeave:Connect(function()
            TweenService:Create(itemBtn, TWEEN_INFO.NORMAL, {
                BackgroundColor3 = COLORS.SURFACE_HOVER
            }):Play()
        end)
        
        itemBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dropdown.Selected = item
                dropdown.SelectedLabel.Text = item
                dropdown:Toggle()
                if options.OnSelected then
                    options.OnSelected(item)
                end
            end
        end)
        
        dropdown.Buttons[item] = itemBtn
    end
    
    local function toggleDropdown()
        dropdown.Open = not dropdown.Open
        dropdown.List.Visible = dropdown.Open
        dropdown.Arrow.Text = dropdown.Open and "▲" or "▼"
        
        if dropdown.Open then
            TweenService:Create(dropdown.List, TWEEN_INFO.SMOOTH, {
                BackgroundTransparency = 0
            }):Play()
        end
    end
    
    dropdown.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleDropdown()
        end
    end)
    
    dropdown:Toggle = toggleDropdown
    dropdown:GetSelected = function() return dropdown.Selected end
    dropdown:SetItems = function(newItems)
        dropdown.Items = newItems
        -- Rebuild list (simplified for brevity)
    end
    
    table.insert(self.Components, dropdown)
    return dropdown
end

-- Multi Dropdown Component
function OceanUI:CreateMultiDropdown(options)
    local multidd = {}
    multidd.Open = false
    multidd.Selected = {}
    multidd.Items = options.Items or {}
    
    multidd.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 220, 0, 45),
        options.Position or UDim2.new(0.5, -110, 0.5, -22),
        COLORS.SURFACE,
        0
    )
    
    multidd.Label = createTextLabel(
        multidd.Frame,
        options.Text or "Multi Select",
        UDim2.new(0, 100, 0, 20),
        UDim2.new(0, 10, 0, 5),
        12,
        COLORS.TEXT_DARK
    )
    multidd.Label.TextXAlignment = Enum.TextXAlignment.Left
    
    multidd.SelectedLabel = createTextLabel(
        multidd.Frame,
        "None selected",
        UDim2.new(1, -30, 1, -25),
        UDim2.new(0, 10, 0, 25),
        13,
        COLORS.TEXT
    )
    multidd.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    multidd.Arrow = createTextLabel(
        multidd.Frame,
        "▼",
        UDim2.new(0, 30, 0, 20),
        UDim2.new(1, -30, 1, -38),
        12,
        COLORS.PRIMARY_LIGHT
    )
    
    multidd.List = createRoundedFrame(
        multidd.Frame,
        UDim2.new(1, 0, 0, #multidd.Items * 35),
        UDim2.new(0, 0, 1, 5),
        COLORS.SURFACE,
        0
    )
    multidd.List.Visible = false
    
    multidd.Checkboxes = {}
    
    for i, item in ipairs(multidd.Items) do
        local itemFrame = createRoundedFrame(
            multidd.List,
            UDim2.new(1, -10, 0, 30),
            UDim2.new(0, 5, 0, 5 + (i-1) * 35),
            COLORS.SURFACE_HOVER,
            0
        )
        
        local checkBox = createRoundedFrame(
            itemFrame,
            UDim2.new(0, 16, 0, 16),
            UDim2.new(0, 10, 0.5, -8),
            COLORS.PRIMARY_DARK,
            0
        )
        
        local checkMark = createTextLabel(
            checkBox,
            "✓",
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            12,
            COLORS.TEXT
        )
        checkMark.Visible = false
        
        local itemLabel = createTextLabel(
            itemFrame,
            item,
            UDim2.new(1, -40, 1, 0),
            UDim2.new(0, 35, 0, 0),
            13,
            COLORS.TEXT
        )
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        multidd.Checkboxes[item] = {
            Frame = itemFrame,
            CheckBox = checkBox,
            CheckMark = checkMark,
            Selected = false
        }
        
        itemFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local cb = multidd.Checkboxes[item]
                cb.Selected = not cb.Selected
                cb.CheckMark.Visible = cb.Selected
                
                if cb.Selected then
                    table.insert(multidd.Selected, item)
                else
                    for j, v in ipairs(multidd.Selected) do
                        if v == item then
                            table.remove(multidd.Selected, j)
                            break
                        end
                    end
                end
                
                -- Update selected label
                if #multidd.Selected == 0 then
                    multidd.SelectedLabel.Text = "None selected"
                else
                    multidd.SelectedLabel.Text = table.concat(multidd.Selected, ", ")
                end
                
                if options.OnSelected then
                    options.OnSelected(multidd.Selected)
                end
            end
        end)
    end
    
    local function toggleDropdown()
        multidd.Open = not multidd.Open
        multidd.List.Visible = multidd.Open
        multidd.Arrow.Text = multidd.Open and "▲" or "▼"
    end
    
    multidd.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleDropdown()
        end
    end)
    
    multidd:Toggle = toggleDropdown
    multidd:GetSelected = function() return multidd.Selected end
    
    table.insert(self.Components, multidd)
    return multidd
end

-- Input Box Component
function OceanUI:CreateInputBox(options)
    local inputBox = {}
    
    inputBox.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 250, 0, 60),
        options.Position or UDim2.new(0.5, -125, 0.5, -30),
        COLORS.SURFACE,
        0
    )
    
    inputBox.Label = createTextLabel(
        inputBox.Frame,
        options.Label or "Input",
        UDim2.new(1, -10, 0, 20),
        UDim2.new(0, 10, 0, 5),
        12,
        COLORS.TEXT_DARK
    )
    inputBox.Label.TextXAlignment = Enum.TextXAlignment.Left
    
    inputBox.TextBox = Instance.new("TextBox")
    inputBox.TextBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.TextBox.Position = UDim2.new(0, 10, 0, 25)
    inputBox.TextBox.BackgroundColor3 = COLORS.SURFACE_HOVER
    inputBox.TextBox.TextColor3 = COLORS.TEXT
    inputBox.TextBox.TextSize = 14
    inputBox.TextBox.Font = Enum.Font.GothamMedium
    inputBox.TextBox.PlaceholderText = options.Placeholder or "Enter text..."
    inputBox.TextBox.PlaceholderColor3 = COLORS.TEXT_DARK
    inputBox.TextBox.Text = options.Default or ""
    inputBox.TextBox.ClearTextOnFocus = false
    inputBox.TextBox.Parent = inputBox.Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = inputBox.TextBox
    
    local stroke = createStroke(inputBox.TextBox, COLORS.BORDER, 1)
    
    inputBox.TextBox.Focused:Connect(function()
        stroke.Color = COLORS.PRIMARY_LIGHT
        stroke.Thickness = 2
    end)
    
    inputBox.TextBox.FocusLost:Connect(function(enterPressed)
        stroke.Color = COLORS.BORDER
        stroke.Thickness = 1
        if options.OnSubmit and enterPressed then
            options.OnSubmit(inputBox.TextBox.Text)
        elseif options.OnChanged then
            options.OnChanged(inputBox.TextBox.Text)
        end
    end)
    
    inputBox:GetText = function() return inputBox.TextBox.Text end
    inputBox:SetText = function(text) inputBox.TextBox.Text = text end
    
    table.insert(self.Components, inputBox)
    return inputBox
end

-- Paragraph Component
function OceanUI:CreateParagraph(options)
    local paragraph = {}
    
    paragraph.Frame = createRoundedFrame(
        options.Parent or self.MainContainer,
        options.Size or UDim2.new(0, 350, 0, 150),
        options.Position or UDim2.new(0.5, -175, 0.5, -75),
        COLORS.SURFACE,
        0
    )
    
    if options.Title then
        paragraph.Title = createTextLabel(
            paragraph.Frame,
            options.Title,
            UDim2.new(1, -20, 0, 30),
            UDim2.new(0, 10, 0, 10),
            18,
            COLORS.PRIMARY_LIGHT
        )
        paragraph.Title.TextXAlignment = Enum.TextXAlignment.Left
        paragraph.Title.Font = Enum.Font.GothamBold
    end
    
    paragraph.Text = Instance.new("TextLabel")
    paragraph.Text.Size = UDim2.new(1, -20, 1, -50)
    paragraph.Text.Position = UDim2.new(0, 10, 0, (options.Title and 45 or 10))
    paragraph.Text.BackgroundTransparency = 1
    paragraph.Text.Text = options.Text or ""
    paragraph.Text.TextColor3 = COLORS.TEXT
    paragraph.Text.TextSize = options.TextSize or 14
    paragraph.Text.TextXAlignment = Enum.TextXAlignment.Left
    paragraph.Text.TextYAlignment = Enum.TextYAlignment.Top
    paragraph.Text.TextWrapped = true
    paragraph.Text.Font = Enum.Font.GothamBook
    paragraph.Text.Parent = paragraph.Frame
    
    paragraph:SetText = function(newText)
        paragraph.Text.Text = newText
    end
    
    table.insert(self.Components, paragraph)
    return paragraph
end

-- Notify Component
function OceanUI:Notify(options)
    local notification = {}
    
    local notifFrame = createRoundedFrame(
        self.MainContainer,
        UDim2.new(0, 300, 0, 70),
        UDim2.new(1, -320, 0, 10),
        COLORS.SURFACE,
        0
    )
    
    -- Icon based on type
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
    
    local iconLabel = createTextLabel(
        notifFrame,
        icon,
        UDim2.new(0, 40, 1, 0),
        UDim2.new(0, 0, 0, 0),
        24,
        iconColor
    )
    
    local titleLabel = createTextLabel(
        notifFrame,
        options.Title or "Notification",
        UDim2.new(1, -50, 0, 25),
        UDim2.new(0, 50, 0, 8),
        14,
        COLORS.PRIMARY_LIGHT
    )
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local messageLabel = createTextLabel(
        notifFrame,
        options.Message or "",
        UDim2.new(1, -50, 0, 35),
        UDim2.new(0, 50, 0, 33),
        12,
        COLORS.TEXT
    )
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    
    local closeBtn = createTextLabel(
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
                Position = UDim2.new(1, -320, 0, -100)
            }):Play()
            task.wait(0.3)
            notifFrame:Destroy()
        end
    end)
    
    -- Animate in
    notifFrame.Position = UDim2.new(1, -320, 0, -100)
    TweenService:Create(notifFrame, TWEEN_INFO.BOUNCE, {
        Position = UDim2.new(1, -320, 0, 10)
    }):Play()
    
    -- Auto dismiss
    if options.Duration ~= false then
        task.wait(options.Duration or 3)
        if notifFrame and notifFrame.Parent then
            TweenService:Create(notifFrame, TWEEN_INFO.SMOOTH, {
                Position = UDim2.new(1, -320, 0, -100)
            }):Play()
            task.wait(0.3)
            notifFrame:Destroy()
        end
    end
    
    table.insert(self.Notifications, notification)
    return notification
end

-- Example usage script
local function CreateExampleUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OceanUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Initialize OceanUI
    local ui = OceanUI.new(screenGui)
    
    -- Create main panel
    local mainPanel = createRoundedFrame(
        screenGui,
        UDim2.new(0, 400, 0, 600),
        UDim2.new(0.5, -200, 0.5, -300),
        COLORS.BACKGROUND,
        0.95
    )
    
    -- Title
    local title = createTextLabel(
        mainPanel,
        "🌊 Ocean UI Library",
        UDim2.new(1, 0, 0, 50),
        UDim2.new(0, 0, 0, 0),
        24,
        COLORS.PRIMARY_LIGHT
    )
    title.Font = Enum.Font.GothamBold
    
    -- Separator line
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.9, 0, 0, 2)
    line.Position = UDim2.new(0.05, 0, 0, 55)
    line.BackgroundColor3 = COLORS.BORDER
    line.Parent = mainPanel
    
    -- Button Example
    ui:CreateButton({
        Parent = mainPanel,
        Text = "Click Me! 🌊",
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0.5, -100, 0, 70),
        OnClick = function()
            ui:Notify({
                Title = "Button Clicked",
                Message = "You clicked the ocean button!",
                Type = "success"
            })
        end
    })
    
    -- Toggle Example
    local toggle = ui:CreateToggle({
        Parent = mainPanel,
        Text = "Dark Mode",
        Size = UDim2.new(0, 250, 0, 40),
        Position = UDim2.new(0.5, -125, 0, 130),
        Default = true,
        OnChanged = function(value)
            local newColor = value and COLORS.BACKGROUND or COLORS.SURFACE
            TweenService:Create(mainPanel, TWEEN_INFO.SMOOTH, {
                BackgroundColor3 = newColor
            }):Play()
        end
    })
    
    -- Slider Example
    local slider = ui:CreateSlider({
        Parent = mainPanel,
        Text = "Volume",
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(0.5, -140, 0, 190),
        Min = 0,
        Max = 100,
        Default = 50,
        Decimal = false,
        OnChanged = function(value)
            ui:Notify({
                Title = "Volume Changed",
                Message = "Volume set to " .. value .. "%",
                Duration = 1
            })
        end
    })
    
    -- Dropdown Example
    local dropdown = ui:CreateDropdown({
        Parent = mainPanel,
        Items = {"Ocean Blue", "Coral Reef", "Deep Sea", "Shallows"},
        Default = "Ocean Blue",
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0.5, -100, 0, 280),
        OnSelected = function(item)
            ui:Notify({
                Title = "Theme Changed",
                Message = "Selected: " .. item,
                Type = "success",
                Duration = 1.5
            })
        end
    })
    
    -- Multi Dropdown Example
    local multidd = ui:CreateMultiDropdown({
        Parent = mainPanel,
        Text = "Select Features",
        Items = {"Wave Effects", "Bubbles", "Fish", "Corals", "Treasure"},
        Size = UDim2.new(0, 220, 0, 45),
        Position = UDim2.new(0.5, -110, 0, 340),
        OnSelected = function(selected)
            print("Selected:", table.concat(selected, ", "))
        end
    })
    
    -- Input Box Example
    local inputBox = ui:CreateInputBox({
        Parent = mainPanel,
        Label = "Username",
        Placeholder = "Enter your name...",
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(0.5, -125, 0, 405),
        OnSubmit = function(text)
            ui:Notify({
                Title = "Welcome",
                Message = "Hello, " .. text .. "!",
                Type = "success"
            })
        end
    })
    
    -- Paragraph Example
    local paragraph = ui:CreateParagraph({
        Parent = mainPanel,
        Title = "About Ocean UI",
        Text = "This is a modern UI library with an ocean theme. It features smooth animations, beautiful colors, and a variety of components to create amazing interfaces for your Roblox games.",
        Size = UDim2.new(0, 340, 0, 100),
        Position = UDim2.new(0.5, -170, 0, 485),
        TextSize = 12
    })
    
    -- Show welcome notification
    ui:Notify({
        Title = "Welcome to Ocean UI",
        Message = "Your modern UI library for Roblox! 🌊",
        Type = "success",
        Duration = 3
    })
end

-- Run the example
CreateExampleUI()

return OceanUI
