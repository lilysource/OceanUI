-- OceanUI Premium

local OceanUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------
-- TRUE GLASS EFFECT
----------------------------------------------------
local function CreateGlass(parent)
    local Glass = Instance.new("Frame")
    Glass.Size = UDim2.new(1,0,1,0)
    Glass.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Glass.BackgroundTransparency = 0.92
    Glass.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,18)
    Corner.Parent = Glass

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(255,255,255)
    Stroke.Transparency = 0.7
    Stroke.Parent = Glass

    return Glass
end

----------------------------------------------------
-- WINDOW
----------------------------------------------------
function OceanUI:CreateWindow(title)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 650, 0, 450)
    Main.Position = UDim2.new(0.5,-325,0.5,-225)
    Main.BackgroundColor3 = Color3.fromRGB(15,25,40)
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

    CreateGlass(Main)

    -- Premium Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1,40,1,40)
    Shadow.Position = UDim2.new(0,-20,0,-20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageTransparency = 0.4
    Shadow.ZIndex = 0
    Shadow.Parent = Main

    -- Header
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1,0,0,50)
    Header.BackgroundTransparency = 1
    Header.Text = title or "Ocean Premium"
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 20
    Header.TextColor3 = Color3.new(1,1,1)
    Header.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0,150,1,-60)
    Sidebar.Position = UDim2.new(0,10,0,55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main

    local TabArea = Instance.new("Frame")
    TabArea.Size = UDim2.new(1,-180,1,-60)
    TabArea.Position = UDim2.new(0,170,0,55)
    TabArea.BackgroundTransparency = 1
    TabArea.Parent = Main

    local Layout = Instance.new("UIListLayout", TabArea)
    Layout.Padding = UDim.new(0,8)

    return {
        Window = Main,
        Tabs = TabArea,
        Sidebar = Sidebar,
        Screen = ScreenGui
    }
end

----------------------------------------------------
-- ICON TAB SYSTEM
----------------------------------------------------
function OceanUI:CreateTab(ui, name, iconId)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,45)
    Button.Text = "  "..name
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BackgroundColor3 = Color3.fromRGB(25,45,70)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = ui.Sidebar

    Instance.new("UICorner", Button)

    -- Icon
    if iconId then
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0,20,0,20)
        Icon.Position = UDim2.new(0,10,0.5,-10)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconId
        Icon.Parent = Button
    end

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,0,1,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = ui.Tabs

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0,140,255)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25,45,70)
        }):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(ui.Tabs:GetChildren()) do
            v.Visible = false
        end
        TabFrame.Visible = true
    end)

    return TabFrame
end

----------------------------------------------------
-- PREMIUM BUTTON
----------------------------------------------------
function OceanUI:CreateButton(parent, text, callback)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,40)
    Button.Text = text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundColor3 = Color3.fromRGB(0,120,200)
    Button.Parent = parent

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0,170,255)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0,120,200)
        }):Play()
    end)

    Button.MouseButton1Click:Connect(callback)
end

----------------------------------------------------
-- REAL SEARCH FILTER
----------------------------------------------------
function OceanUI:EnableSearch(ui)

    ui.Search:GetPropertyChangedSignal("Text"):Connect(function()

        local query = string.lower(ui.Search.Text)

        for _,tab in pairs(ui.Tabs:GetChildren()) do
            for _,element in pairs(tab:GetChildren()) do
                if element:IsA("TextButton") then
                    local match = string.find(string.lower(element.Text), query)
                    element.Visible = query == "" or match
                end
            end
        end
    end)
end

----------------------------------------------------
-- OPEN ANIMATION
----------------------------------------------------
function OceanUI:AnimateOpen(frame)

    frame.Size = UDim2.new(0,0,0,0)

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0,650,0,450)
    }):Play()
end

return OceanUI
