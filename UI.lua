-- OceanUI (Modern Framework)

local OceanUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------
-- SETTINGS SAVE SYSTEM (Client Session Save)
----------------------------------------------------
local function SaveSetting(name, value)
    LocalPlayer:SetAttribute(name, value)
end

local function LoadSetting(name)
    return LocalPlayer:GetAttribute(name)
end

----------------------------------------------------
-- ACYLIC BLUR
----------------------------------------------------
local function CreateBlur()
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Parent = game:GetService("Lighting")
    return blur
end

----------------------------------------------------
-- MOVING WAVE BACKGROUND
----------------------------------------------------
local function CreateWave(parent)
    local wave = Instance.new("Frame")
    wave.Size = UDim2.new(2,0,2,0)
    wave.Position = UDim2.new(-0.5,0,-0.5,0)
    wave.BackgroundColor3 = Color3.fromRGB(0,170,255)
    wave.BackgroundTransparency = 0.85
    wave.Parent = parent

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,120,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,200,255))
    }
    gradient.Parent = wave

    RunService.RenderStepped:Connect(function()
        gradient.Rotation += 0.3
    end)
end

----------------------------------------------------
-- WINDOW
----------------------------------------------------
function OceanUI:CreateWindow(title)
    local blur = CreateBlur()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 600)
    Main.Position = UDim2.new(0.5,-250,0.5,-300)
    Main.BackgroundColor3 = Color3.fromRGB(15,25,40)
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main)

    CreateWave(Main)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,45)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Ocean UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Parent = Main

    -- Search Bar
    local Search = Instance.new("TextBox")
    Search.Size = UDim2.new(1,-20,0,35)
    Search.Position = UDim2.new(0,10,0,50)
    Search.PlaceholderText = "Search..."
    Search.Parent = Main
    Instance.new("UICorner", Search)

    -- Tab Container
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(1,0,0,40)
    TabButtons.Position = UDim2.new(0,0,0,95)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = Main

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1,-20,1,-150)
    TabContent.Position = UDim2.new(0,10,0,140)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = Main

    local Layout = Instance.new("UIListLayout", TabContent)
    Layout.Padding = UDim.new(0,8)

    -- Open Animation
    Main.Size = UDim2.new(0,0,0,0)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0,500,0,600)
    }):Play()

    -- Drag (Mobile + PC)
    local dragging = false
    local dragStart
    local startPos

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Window = Main,
        Tabs = TabContent,
        TabButtons = TabButtons,
        Search = Search
    }
end

----------------------------------------------------
-- TAB SYSTEM
----------------------------------------------------
function OceanUI:CreateTab(ui, name)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0,100,1,0)
    Button.Text = name
    Button.Parent = ui.TabButtons
    Instance.new("UICorner", Button)

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = ui.Tabs

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(ui.Tabs:GetChildren()) do
            v.Visible = false
        end
        TabFrame.Visible = true
    end)

    return TabFrame
end

----------------------------------------------------
-- TOGGLE (With Save)
----------------------------------------------------
function OceanUI:CreateToggle(parent, text, saveName, callback)

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1,0,0,40)
    Toggle.Text = text
    Toggle.Parent = parent
    Instance.new("UICorner", Toggle)

    local state = LoadSetting(saveName) or false
    callback(state)

    local function update()
        SaveSetting(saveName, state)
        callback(state)
        TweenService:Create(Toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0,170,255)
            or Color3.fromRGB(30,60,90)
        }):Play()
    end

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()
end

----------------------------------------------------
-- CLOSE WITH ANIMATION
----------------------------------------------------
function OceanUI:Close(ui)
    TweenService:Create(ui.Window, TweenInfo.new(0.3), {
        Size = UDim2.new(0,0,0,0)
    }):Play()

    task.wait(0.3)
    ui.Window.Parent:Destroy()
end

return OceanUI
