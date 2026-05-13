local OceanUI = {}
OceanUI.__index = OceanUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

OceanUI.Version = "1.0.0"

----------------------------------------------------
-- WINDOW
----------------------------------------------------
function OceanUI:CreateWindow(config)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OceanUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Window = Instance.new("Frame")
    Window.Size = config.Size or UDim2.fromOffset(600,450)
    Window.Position = UDim2.new(0.5,-300,0.5,-225)
    Window.BackgroundColor3 = Color3.fromRGB(20,30,45)
    Window.Parent = ScreenGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0,16)

    -- Title Bar
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Ocean UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Parent = Window

    -- Drag
    local dragging, dragStart, startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
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

    -- Tab Container
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(1,-20,1,-60)
    TabsFrame.Position = UDim2.new(0,10,0,50)
    TabsFrame.BackgroundTransparency = 1
    TabsFrame.Parent = Window

    local Layout = Instance.new("UIListLayout", TabsFrame)
    Layout.Padding = UDim.new(0,8)

    return {
        Window = Window,
        Tabs = TabsFrame
    }
end

----------------------------------------------------
-- TAB
----------------------------------------------------
function OceanUI:AddTab(window, name)

    local Tab = Instance.new("Frame")
    Tab.Size = UDim2.new(1,0,1,0)
    Tab.BackgroundTransparency = 1
    Tab.Visible = false
    Tab.Parent = window.Tabs

    local Layout = Instance.new("UIListLayout", Tab)
    Layout.Padding = UDim.new(0,6)

    return Tab
end

----------------------------------------------------
-- BUTTON
----------------------------------------------------
function OceanUI:AddButton(tab, config)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,38)
    Button.Text = config.Title or "Button"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundColor3 = Color3.fromRGB(0,120,200)
    Button.Parent = tab
    Instance.new("UICorner", Button)

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button,TweenInfo.new(0.2),{
            BackgroundColor3 = Color3.fromRGB(0,170,255)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button,TweenInfo.new(0.2),{
            BackgroundColor3 = Color3.fromRGB(0,120,200)
        }):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)
end

----------------------------------------------------
-- TOGGLE
----------------------------------------------------
function OceanUI:AddToggle(tab, config)

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1,0,0,38)
    Toggle.Text = config.Title or "Toggle"
    Toggle.BackgroundColor3 = Color3.fromRGB(40,60,90)
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.Parent = tab
    Instance.new("UICorner", Toggle)

    local state = config.Default or false

    local function Update()
        Toggle.BackgroundColor3 = state and
            Color3.fromRGB(0,170,255) or
            Color3.fromRGB(40,60,90)
    end

    Update()

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Update()
        if config.Callback then
            config.Callback(state)
        end
    end)
end

----------------------------------------------------
-- NOTIFY
----------------------------------------------------
function OceanUI:Notify(config)

    local Gui = Instance.new("ScreenGui")
    Gui.Parent = LocalPlayer.PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(250,70)
    Frame.Position = UDim2.new(1,-270,1,-90)
    Frame.BackgroundColor3 = Color3.fromRGB(25,35,55)
    Frame.Parent = Gui
    Instance.new("UICorner", Frame)

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1,0,1,0)
    Text.BackgroundTransparency = 1
    Text.Text = config.Content or "Notification"
    Text.TextColor3 = Color3.new(1,1,1)
    Text.Parent = Frame

    task.delay(config.Duration or 3,function()
        Gui:Destroy()
    end)
end

return OceanUI
