--!strict

-- OceanUI: A Comprehensive Ocean-Themed UI Library for Roblox
-- Features: Button, Toggle, Slider, MultiDropdown, Dropdown, InputBox, Paragraph, Notify

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local OceanUI = {}
OceanUI.__index = OceanUI

-- Theme Configuration
local Theme = {
    MainColor = Color3.fromRGB(6, 66, 115), -- Deep Ocean Blue
    SecondaryColor = Color3.fromRGB(118, 182, 196), -- Aqua Marine
    AccentColor = Color3.fromRGB(255, 127, 80), -- Coral Sunset
    BackgroundColor = Color3.fromRGB(222, 243, 246), -- Light Foam
    BorderColor = Color3.fromRGB(169, 188, 207), -- Seafoam Grey
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryTextColor = Color3.fromRGB(51, 51, 51),
    Font = Enum.Font.SourceSansSemibold,
    TextSize = 14,
    Rounding = UDim.new(0, 8)
}

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.Rounding
    corner.Parent = parent
    return corner
end

-- Library Initialization
function OceanUI.new(title)
    local self = setmetatable({}, OceanUI)
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OceanUI"
    screenGui.ResetOnSpawn = false
    self.ScreenGui = screenGui
    
    -- Main Window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = Theme.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    createCorner(mainFrame)
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Theme.SecondaryColor
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    createCorner(topBar)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Ocean UI"
    titleLabel.TextColor3 = Theme.TextColor
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Container for Tabs/Content
    local container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -20, 1, -60)
    container.Position = UDim2.new(0, 10, 0, 50)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = Theme.SecondaryColor
    container.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container
    
    self.MainFrame = mainFrame
    self.Container = container
    
    return self
end

-- Components

-- Button
function OceanUI:AddButton(text, callback)
    local textButton = Instance.new("TextButton")
    textButton.Name = "Button_" .. text
    textButton.Size = UDim2.new(1, 0, 0, 35)
    textButton.BackgroundColor3 = Theme.SecondaryColor
    textButton.BorderSizePixel = 0
    textButton.Text = text
    textButton.TextColor3 = Theme.TextColor
    textButton.Font = Theme.Font
    textButton.TextSize = Theme.TextSize
    textButton.AutoButtonColor = true
    textButton.Parent = self.Container
    createCorner(textButton)
    
    textButton.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return textButton
end

-- Toggle
function OceanUI:AddToggle(text, default, callback)
    local state = default or false
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. text
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    createCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = state and Theme.AccentColor or Theme.BorderColor
    toggleBtn.Text = ""
    toggleBtn.Parent = frame
    createCorner(toggleBtn, UDim.new(1, 0))
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = Theme.TextColor
    indicator.Parent = toggleBtn
    createCorner(indicator, UDim.new(1, 0))
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Theme.AccentColor or Theme.BorderColor
        indicator:TweenPosition(state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.2, true)
        if callback then callback(state) end
    end)
    
    return frame
end

-- Slider
function OceanUI:AddSlider(text, min, max, default, callback)
    local value = default or min
    
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. text
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    createCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 25)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Theme.TextColor
    valueLabel.Font = Theme.Font
    valueLabel.TextSize = Theme.TextSize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 0, 35)
    sliderBar.BackgroundColor3 = Theme.BorderColor
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame
    createCorner(sliderBar, UDim.new(1, 0))
    
    local fill = Instance.new("Frame")
    local percent = (value - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = sliderBar
    createCorner(fill, UDim.new(1, 0))
    
    local trigger = Instance.new("TextButton")
    trigger.Size = UDim2.new(1, 0, 1, 0)
    trigger.BackgroundTransparency = 1
    trigger.Text = ""
    trigger.Parent = sliderBar
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end
    
    trigger.InputBegan:Connect(function(input)
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
    
    return frame
end

-- Dropdown
function OceanUI:AddDropdown(text, options, callback)
    local selected = nil
    local open = false
    
    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. text
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = self.Container
    createCorner(frame)
    
    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 35)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = text .. ": (None)"
    mainBtn.TextColor3 = Theme.TextColor
    mainBtn.Font = Theme.Font
    mainBtn.TextSize = Theme.TextSize
    mainBtn.Parent = frame
    
    local optionContainer = Instance.new("Frame")
    optionContainer.Size = UDim2.new(1, 0, 0, #options * 30)
    optionContainer.Position = UDim2.new(0, 0, 0, 35)
    optionContainer.BackgroundTransparency = 1
    optionContainer.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = optionContainer
    
    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = Theme.SecondaryColor
        optBtn.BackgroundTransparency = 0.5
        optBtn.BorderSizePixel = 0
        optBtn.Text = option
        optBtn.TextColor3 = Theme.TextColor
        optBtn.Font = Theme.Font
        optBtn.TextSize = Theme.TextSize - 2
        optBtn.Parent = optionContainer
        
        optBtn.MouseButton1Click:Connect(function()
            selected = option
            mainBtn.Text = text .. ": " .. option
            open = false
            frame:TweenSize(UDim2.new(1, 0, 0, 35), "Out", "Quad", 0.2, true)
            if callback then callback(option) end
        end)
    end
    
    mainBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            frame:TweenSize(UDim2.new(1, 0, 0, 35 + #options * 30), "Out", "Quad", 0.2, true)
        else
            frame:TweenSize(UDim2.new(1, 0, 0, 35), "Out", "Quad", 0.2, true)
        end
    end)
    
    return frame
end

-- MultiDropdown
function OceanUI:AddMultiDropdown(text, options, callback)
    local selected = {}
    local open = false
    
    local frame = Instance.new("Frame")
    frame.Name = "MultiDropdown_" .. text
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = self.Container
    createCorner(frame)
    
    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 35)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = text .. ": (None)"
    mainBtn.TextColor3 = Theme.TextColor
    mainBtn.Font = Theme.Font
    mainBtn.TextSize = Theme.TextSize
    mainBtn.Parent = frame
    
    local optionContainer = Instance.new("Frame")
    optionContainer.Size = UDim2.new(1, 0, 0, #options * 30)
    optionContainer.Position = UDim2.new(0, 0, 0, 35)
    optionContainer.BackgroundTransparency = 1
    optionContainer.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = optionContainer
    
    local function updateText()
        local selectedText = ""
        for opt, val in pairs(selected) do
            if val then selectedText = selectedText .. opt .. ", " end
        end
        if selectedText == "" then
            mainBtn.Text = text .. ": (None)"
        else
            mainBtn.Text = text .. ": " .. selectedText:sub(1, -3)
        end
    end
    
    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = Theme.SecondaryColor
        optBtn.BackgroundTransparency = 0.5
        optBtn.BorderSizePixel = 0
        optBtn.Text = option
        optBtn.TextColor3 = Theme.TextColor
        optBtn.Font = Theme.Font
        optBtn.TextSize = Theme.TextSize - 2
        optBtn.Parent = optionContainer
        
        optBtn.MouseButton1Click:Connect(function()
            selected[option] = not selected[option]
            optBtn.BackgroundColor3 = selected[option] and Theme.AccentColor or Theme.SecondaryColor
            updateText()
            if callback then callback(selected) end
        end)
    end
    
    mainBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            frame:TweenSize(UDim2.new(1, 0, 0, 35 + #options * 30), "Out", "Quad", 0.2, true)
        else
            frame:TweenSize(UDim2.new(1, 0, 0, 35), "Out", "Quad", 0.2, true)
        end
    end)
    
    return frame
end

-- InputBox
function OceanUI:AddInputBox(text, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Name = "InputBox_" .. text
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    createCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextColor
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize - 2
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 20)
    textBox.Position = UDim2.new(0, 10, 0, 25)
    textBox.BackgroundColor3 = Theme.BackgroundColor
    textBox.BorderSizePixel = 0
    textBox.PlaceholderText = placeholder or "Type here..."
    textBox.Text = ""
    textBox.TextColor3 = Theme.SecondaryTextColor
    textBox.Font = Theme.Font
    textBox.TextSize = Theme.TextSize
    textBox.ClipsDescendants = true
    textBox.Parent = frame
    createCorner(textBox, UDim.new(0, 4))
    
    textBox.FocusLost:Connect(function(enterPressed)
        if callback then callback(textBox.Text, enterPressed) end
    end)
    
    return frame
end

-- Paragraph
function OceanUI:AddParagraph(title, content)
    local frame = Instance.new("Frame")
    frame.Name = "Paragraph_" .. title
    frame.Size = UDim2.new(1, 0, 0, 100)
    frame.BackgroundColor3 = Theme.SecondaryColor
    frame.BackgroundTransparency = 0.9
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    createCorner(frame)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.TextColor
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = Theme.TextSize
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 1, -35)
    contentLabel.Position = UDim2.new(0, 10, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Theme.TextColor
    contentLabel.Font = Theme.Font
    contentLabel.TextSize = Theme.TextSize - 2
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = frame
    
    local function updateSize()
        local textBounds = contentLabel.TextBounds
        frame.Size = UDim2.new(1, 0, 0, 40 + textBounds.Y)
    end
    
    contentLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
    updateSize()
    
    return frame
end

-- Notify
function OceanUI:Notify(title, content, duration)
    local container = self.ScreenGui:FindFirstChild("NotifyContainer")
    if not container then
        container = Instance.new("Frame")
        container.Name = "NotifyContainer"
        container.Size = UDim2.new(0, 300, 1, 0)
        container.Position = UDim2.new(1, -310, 0, 10)
        container.BackgroundTransparency = 1
        container.Parent = self.ScreenGui
        
        local layout = Instance.new("UIListLayout")
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 10)
        layout.Parent = container
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = Theme.MainColor
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = container
    createCorner(frame)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.TextColor
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = Theme.TextSize
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 0, 40)
    contentLabel.Position = UDim2.new(0, 10, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Theme.TextColor
    contentLabel.Font = Theme.Font
    contentLabel.TextSize = Theme.TextSize - 2
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = frame
    
    frame:TweenSize(UDim2.new(1, 0, 0, 80), "Out", "Quad", 0.3, true)
    
    task.delay(duration or 5, function()
        frame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        frame:Destroy()
    end)
    
    return frame
end

return OceanUI
