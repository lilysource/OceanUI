-- OceanUI.lua

local OceanUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

----------------------------------------------------
-- BLUR BACKGROUND
----------------------------------------------------
local function CreateBlur()
    local blur = Instance.new("BlurEffect")
    blur.Size = 18
    blur.Parent = game:GetService("Lighting")
    return blur
end

----------------------------------------------------
-- DRAG SYSTEM
----------------------------------------------------
local function MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame

    local dragging = false
    local dragInput
    local startPos
    local startMouse

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = frame.Position
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

----------------------------------------------------
-- WINDOW
----------------------------------------------------
function OceanUI:CreateWindow(title)
    local blur = CreateBlur()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OceanUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 420, 0, 520)
    Main.Position = UDim2.new(0.5, -210, 0.5, -260)
    Main.BackgroundColor3 = Color3.fromRGB(10, 25, 40)
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    -- Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,90,180))
    }
    Gradient.Parent = Main

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,45)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Ocean UI"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = Main

    MakeDraggable(Main, Title)

    -- Content
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,-20,1,-60)
    Container.Position = UDim2.new(0,10,0,50)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0,8)

    return {
        Parent = Container,
        Blur = blur,
        ScreenGui = ScreenGui
    }
end

----------------------------------------------------
-- TOGGLE
----------------------------------------------------
function OceanUI:CreateToggle(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,38)
    Button.Text = text
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundColor3 = Color3.fromRGB(20,60,90)
    Button.Parent = parent

    Instance.new("UICorner", Button)

    local state = false

    Button.MouseButton1Click:Connect(function()
        state = not state
        callback(state)

        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0,170,255)
                or Color3.fromRGB(20,60,90)
        }):Play()
    end)
end

----------------------------------------------------
-- SLIDER
----------------------------------------------------
function OceanUI:CreateSlider(parent, text, min, max, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,0,60)
    Frame.BackgroundColor3 = Color3.fromRGB(20,40,70)
    Frame.Parent = parent
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1,-20,0,8)
    Bar.Position = UDim2.new(0,10,0,35)
    Bar.BackgroundColor3 = Color3.fromRGB(40,80,120)
    Bar.Parent = Frame
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    Fill.Parent = Bar
    Instance.new("UICorner", Fill)

    local dragging = false

    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp(
                (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                0,1
            )
            Fill.Size = UDim2.new(percent,0,1,0)
            callback(math.floor(min + (max-min)*percent))
        end
    end)
end

----------------------------------------------------
-- MULTI DROPDOWN (FIXED)
----------------------------------------------------
function OceanUI:CreateMultiDropdown(parent, text, options, callback)
    local selected = {}

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,38)
    Button.Text = text
    Button.BackgroundColor3 = Color3.fromRGB(20,60,90)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = parent
    Instance.new("UICorner", Button)

    local Open = false

    Button.MouseButton1Click:Connect(function()
        Open = not Open

        for _,v in pairs(parent:GetChildren()) do
            if v:IsA("TextButton") and v ~= Button then
                v:Destroy()
            end
        end

        if Open then
            for _,option in ipairs(options) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.new(1,0,0,30)
                Opt.Text = option
                Opt.Parent = parent
                Opt.BackgroundColor3 = Color3.fromRGB(30,70,100)
                Instance.new("UICorner", Opt)

                Opt.MouseButton1Click:Connect(function()
                    if selected[option] then
                        selected[option] = nil
                        Opt.BackgroundColor3 = Color3.fromRGB(30,70,100)
                    else
                        selected[option] = true
                        Opt.BackgroundColor3 = Color3.fromRGB(0,170,255)
                    end

                    local result = {}
                    for k,_ in pairs(selected) do
                        table.insert(result, k)
                    end
                    callback(result)
                end)
            end
        end
    end)
end

----------------------------------------------------
-- KEYBIND
----------------------------------------------------
function OceanUI:CreateKeybind(toggleFunction, key)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == key then
            toggleFunction()
        end
    end)
end

----------------------------------------------------
-- NOTIFY
----------------------------------------------------
function OceanUI:Notify(title, text, time)
    local Gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,260,0,70)
    Frame.Position = UDim2.new(1,-270,1,-90)
    Frame.BackgroundColor3 = Color3.fromRGB(15,40,70)
    Frame.Parent = Gui
    Instance.new("UICorner", Frame)

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
    Text.TextColor3 = Color3.fromRGB(200,220,255)
    Text.BackgroundTransparency = 1
    Text.Parent = Frame

    task.delay(time or 3, function()
        Gui:Destroy()
    end)
end

return OceanUI
