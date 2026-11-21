
--[[
    MOBILE OUTPUT CONSOLE v1.0
    Client-side debugging panel
    For your own Roblox test environment
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CLEANUP PREVIOUS VERSION
local Previous = PlayerGui:FindFirstChild("MobileOutputConsole")
if Previous then
    Previous:Destroy()
end

-- CONFIGURATION
local Config = {
    MaxLogs = 150,
    Background = Color3.fromRGB(19, 21, 29),
    Panel = Color3.fromRGB(29, 32, 43),
    Accent = Color3.fromRGB(105, 125, 255),
    Text = Color3.fromRGB(240, 240, 245),
    Muted = Color3.fromRGB(155, 160, 175),
    Success = Color3.fromRGB(100, 220, 150),
    Warning = Color3.fromRGB(255, 190, 75),
    Error = Color3.fromRGB(255, 100, 110)
}

local Logs = {}
local Minimized = false

-- GUI
local Screen = Instance.new("ScreenGui")
Screen.Name = "MobileOutputConsole"
Screen.ResetOnSpawn = false
Screen.DisplayOrder = 10000
Screen.IgnoreGuiInset = true
Screen.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0.92, 0, 0.68, 0)
Main.Position = UDim2.new(0.04, 0, 0.16, 0)
Main.BackgroundColor3 = Config.Background
Main.BorderSizePixel = 0
Main.Parent = Screen

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Accent
MainStroke.Transparency = 0.45
MainStroke.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Config.Panel
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.65, 0, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "OUTPUT CONSOLE"
Title.TextColor3 = Config.Text
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(36, 32)
Minimize.Position = UDim2.new(1, -44, 0, 6)
Minimize.BackgroundColor3 = Config.Background
Minimize.Text = "_"
Minimize.TextColor3 = Config.Text
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

-- SEARCH
local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -20, 0, 36)
Search.Position = UDim2.fromOffset(10, 52)
Search.BackgroundColor3 = Config.Panel
Search.PlaceholderText = "Search logs..."
Search.PlaceholderColor3 = Config.Muted
Search.Text = ""
Search.TextColor3 = Config.Text
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = Search

-- LOG LIST
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -20, 1, -150)
List.Position = UDim2.fromOffset(10, 96)
List.BackgroundColor3 = Config.Panel
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Config.Accent
List.CanvasSize = UDim2.new()
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 7)
Padding.PaddingBottom = UDim.new(0, 7)
Padding.PaddingLeft = UDim.new(0, 7)
Padding.PaddingRight = UDim.new(0, 7)
Padding.Parent = List

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

-- FOOTER
local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0.48, -12, 0, 36)
ClearButton.Position = UDim2.new(0, 10, 1, -44)
ClearButton.BackgroundColor3 = Color3.fromRGB(75, 55, 65)
ClearButton.Text = "CLEAR LOGS"
ClearButton.TextColor3 = Config.Text
ClearButton.TextSize = 12
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Parent = Main

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 8)
ClearCorner.Parent = ClearButton

local Count = Instance.new("TextLabel")
Count.Size = UDim2.new(0.48, -12, 0, 36)
Count.Position = UDim2.new(0.52, 2, 1, -44)
Count.BackgroundTransparency = 1
Count.Text = "0 messages"
Count.TextColor3 = Config.Muted
Count.TextSize = 11
Count.Font = Enum.Font.Gotham
Count.Parent = Main

-- RESTORE ICON
local Restore = Instance.new("TextButton")
Restore.Size = UDim2.fromOffset(54, 54)
Restore.Position = UDim2.new(1, -70, 1, -85)
Restore.BackgroundColor3 = Config.Accent
Restore.Text = "LOG"
Restore.TextColor3 = Color3.new(1, 1, 1)
Restore.TextSize = 14
Restore.Font = Enum.Font.GothamBold
Restore.Visible = false
Restore.Parent = Screen

local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(1, 0)
RestoreCorner.Parent = Restore

-- LOG RENDERING
local function RenderLogs()
    for _, Child in ipairs(List:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    local Query = string.lower(Search.Text)

    for Index, Entry in ipairs(Logs) do
        if Query == "" or string.find(
            string.lower(Entry.Message),
            Query,
            1,
            true
        ) then

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -4, 0, 34)
            Label.AutomaticSize = Enum.AutomaticSize.Y
            Label.BackgroundColor3 = Config.Background
            Label.BackgroundTransparency = 0.2
            Label.BorderSizePixel = 0
            Label.TextWrapped = true
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextYAlignment = Enum.TextYAlignment.Center
            Label.Font = Enum.Font.Code
            Label.TextSize = 12
            Label.TextColor3 = Entry.Color
            Label.Text = string.format(
                "[%s] %s",
                Entry.Type,
                Entry.Message
            )
            Label.LayoutOrder = Index
            Label.Parent = List

            local LabelPadding = Instance.new("UIPadding")
            LabelPadding.PaddingLeft = UDim.new(0, 7)
            LabelPadding.PaddingRight = UDim.new(0, 7)
            LabelPadding.PaddingTop = UDim.new(0, 5)
            LabelPadding.PaddingBottom = UDim.new(0, 5)
            LabelPadding.Parent = Label
        end
    end

    Count.Text = tostring(#Logs) .. " messages"
end

-- CUSTOM LOGGER
local function Log(Message, Type)
    Type = Type or "INFO"

    local Color = Config.Text

    if Type == "SUCCESS" then
        Color = Config.Success
    elseif Type == "WARN" then
        Color = Config.Warning
    elseif Type == "ERROR" then
        Color = Config.Error
    end

    table.insert(Logs, {
        Message = tostring(Message),
        Type = Type,
        Color = Color
    })

    while #Logs > Config.MaxLogs do
        table.remove(Logs, 1)
    end

    RenderLogs()
end

-- BUTTON EVENTS
Search:GetPropertyChangedSignal("Text"):Connect(RenderLogs)

ClearButton.MouseButton1Click:Connect(function()
    table.clear(Logs)
    RenderLogs()
end)

Minimize.MouseButton1Click:Connect(function()
    Minimized = true
    Main.Visible = false
    Restore.Visible = true
end)

Restore.MouseButton1Click:Connect(function()
    Minimized = false
    Main.Visible = true
    Restore.Visible = false
end)

-- DRAG SUPPORT
local function MakeDraggable(Object, Handle)
    local Dragging = false
    local DragStart
    local StartPosition

    Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = Input.Position
            StartPosition = Object.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (
            Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch
        ) then

            local Delta = Input.Position - DragStart

            Object.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
end

MakeDraggable(Main, Header)
MakeDraggable(Restore, Restore)

-- INITIAL MESSAGES
Log("Mobile Output Console initialized.", "SUCCESS")
Log("Use Log(message) to display custom messages.", "INFO")
Log("Console is ready.", "SUCCESS")

-- EXAMPLE TEST MESSAGES
Log("Example warning message.", "WARN")
Log("Example error message.", "ERROR")

-- EXPOSE LOGGER FOR THIS SCRIPT'S ENVIRONMENT
_G.MobileConsoleLog = Log

print("Mobile Output Console loaded.")
