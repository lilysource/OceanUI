local UILibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create Window
function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OceanUILibrary"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 400, 0, 500)
    Main.Position = UDim2.new(0.5, -200, 0.5, -250)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", Main)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = title or "UI Library"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = Main

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 8)

    return Container
end

----------------------------------------------------
-- TOGGLE
----------------------------------------------------
function UILibrary:CreateToggle(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Text = text
    Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = parent

    local state = false

    Button.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        Button.BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(40,40,40)
    end)
end

----------------------------------------------------
-- SLIDER
----------------------------------------------------
function UILibrary:CreateSlider(parent, text, min, max, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,50)
    Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1,-20,0,10)
    Bar.Position = UDim2.new(0,10,0,30)
    Bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Bar.Parent = Frame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    Fill.Parent = Bar

    local dragging = false

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(percent,0,1,0)
            local value = math.floor(min + (max - min) * percent)
            callback(value)
        end
    end)
end

----------------------------------------------------
-- DROPDOWN
----------------------------------------------------
function UILibrary:CreateDropdown(parent, text, options, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,35)
    Button.Text = text
    Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = parent

    local Open = false

    Button.MouseButton1Click:Connect(function()
        Open = not Open

        for _,v in pairs(parent:GetChildren()) do
            if v:IsA("TextButton") and v ~= Button then
                v:Destroy()
            end
        end

        if Open then
            for _,option in pairs(options) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.new(1,0,0,30)
                Opt.Text = option
                Opt.Parent = parent
                Opt.MouseButton1Click:Connect(function()
                    callback(option)
                end)
            end
        end
    end)
end

----------------------------------------------------
-- INPUT BOX
----------------------------------------------------
function UILibrary:CreateInput(parent, placeholder, callback)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1,0,0,35)
    Box.PlaceholderText = placeholder
    Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Box.TextColor3 = Color3.new(1,1,1)
    Box.Parent = parent

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

----------------------------------------------------
-- PARAGRAPH
----------------------------------------------------
function UILibrary:CreateParagraph(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,60)
    Label.BackgroundTransparency = 1
    Label.TextWrapped = true
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Parent = parent
end

----------------------------------------------------
-- NOTIFY
----------------------------------------------------
function UILibrary:Notify(title, text, time)
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,250,0,80)
    Frame.Position = UDim2.new(1,-260,1,-90)
    Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", Frame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,30)
    Title.Text = title
    Title.TextColor3 = Color3.new(1,1,1)
    Title.BackgroundTransparency = 1
    Title.Parent = Frame

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1,0,1,-30)
    Text.Position = UDim2.new(0,0,0,30)
    Text.Text = text
    Text.TextColor3 = Color3.fromRGB(200,200,200)
    Text.BackgroundTransparency = 1
    Text.Parent = Frame

    task.delay(time or 3, function()
        ScreenGui:Destroy()
    end)
end

return UILibrary
