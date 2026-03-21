--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local viewmodelPath = Player:WaitForChild("PlayerScripts")
    :WaitForChild("Assets")
    :WaitForChild("ViewModels")
----------------------------------------------------------------
--// SETTINGS
----------------------------------------------------------------
local DATA_KEY = "MetrixHub_Settings_"..Player.UserId..".json"
local defaultSettings = {
    Material = "Glass",
    R = 255, G = 255, B = 255,
    Transparency = 0.5,
    Reflectance = 0.8,
    Glossy = 0,
    Shininess = 0,
    TextureID = "",
    AutoLoad = true,
}
local Settings = {currentConfig = "default", configs = {default = defaultSettings}}

local function loadSettings()
    local success, raw = pcall(readfile, DATA_KEY)
    if success and raw then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok then
            Settings = decoded
            local cfg = Settings.configs[Settings.currentConfig] or defaultSettings
            for k,v in pairs(defaultSettings) do
                cfg[k] = cfg[k] or v
            end
        end
    end
end

local function saveSettings()
    writefile(DATA_KEY, HttpService:JSONEncode(Settings))
end

local function getCurrentSettings()
    return Settings.configs[Settings.currentConfig]
end

local function updateCurrentSettings(key, value)
    local cfg = getCurrentSettings()
    cfg[key] = value
    saveSettings()
end
----------------------------------------------------------------
--// AUTO-LOAD (SAFE)
----------------------------------------------------------------
local function onCharacterAdded()
    if not getCurrentSettings().AutoLoad then return end
    task.wait(2)
    pcall(applyAll)
end
Player.CharacterAdded:Connect(onCharacterAdded)
if Player.Character then
    task.spawn(onCharacterAdded)
end
----------------------------------------------------------------
--// GUI
----------------------------------------------------------------
loadSettings()
local currentCfg = getCurrentSettings()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MetrixHub_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000000
ScreenGui.Parent = PlayerGui
-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,36,0,36)
ToggleBtn.Position = UDim2.new(0,12,0,12)
ToggleBtn.BackgroundTransparency = 0.95
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.Text = ""
ToggleBtn.ZIndex = 1000000
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,8)
local ico = Instance.new("ImageLabel",ToggleBtn)
ico.Size = UDim2.new(0,20,0,20)
ico.Position = UDim2.new(0.5,-10,0.5,-10)
ico.BackgroundTransparency = 1
ico.Image = "rbxassetid://7072716799"
ico.ImageColor3 = Color3.new(1,1,1)
-- Main Container
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(0,360,0,600)
Container.Position = UDim2.new(0.5,-180,0.5,-300)
Container.CanvasSize = UDim2.new(0,0,0,0)
Container.BackgroundColor3 = Color3.fromRGB(20,20,24)
Container.BackgroundTransparency = 0.6
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 6
Container.Visible = false
Container.ZIndex = 1000000
Container.Parent = ScreenGui
Instance.new("UICorner",Container).CornerRadius = UDim.new(0,14)
local stroke = Instance.new("UIStroke",Container)
stroke.Thickness = 1.8
stroke.Color = Color3.new(1,1,1)
stroke.Transparency = 0.75
local Content = Instance.new("Frame",Container)
Content.Size = UDim2.new(1,0,1,0)
Content.BackgroundTransparency = 1
Content.Name = "Content"
local UIList = Instance.new("UIListLayout",Content)
UIList.Padding = UDim.new(0,12)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
local UIPad = Instance.new("UIPadding",Content)
UIPad.PaddingLeft = UDim.new(0,20)
UIPad.PaddingRight = UDim.new(0,20)
UIPad.PaddingTop = UDim.new(0,12)
UIPad.PaddingBottom = UDim.new(0,12)
-- Update canvas size on layout change
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 30)
end)
-- Title + Close
local Title = Instance.new("TextLabel",Content)
Title.Size = UDim2.new(1,-70,0,44)
Title.BackgroundTransparency = 1
Title.Text = "MetrixHub - Wrap Changer"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.LayoutOrder = 1
local Close = Instance.new("TextButton",Content)
Close.Size = UDim2.new(0,34,0,34)
Close.Position = UDim2.new(1,-44,0,5)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255,120,120)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.LayoutOrder = 2
Close.AnchorPoint = Vector2.new(1,0)
-- Draggable
local dragging = false
local dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
----------------------------------------------------------------
--// CONFIG SYSTEM
----------------------------------------------------------------
local ConfigLabel = Instance.new("TextLabel",Content)
ConfigLabel.Size = UDim2.new(1,0,0,26)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.Text = "Config:"
ConfigLabel.TextColor3 = Color3.fromRGB(220,220,220)
ConfigLabel.TextSize = 14
ConfigLabel.Font = Enum.Font.Gotham
ConfigLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigLabel.LayoutOrder = 3
local ConfigDropBtn = Instance.new("TextButton",Content)
ConfigDropBtn.Size = UDim2.new(1,0,0,34)
ConfigDropBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
ConfigDropBtn.BackgroundTransparency = 0.3
ConfigDropBtn.Text = Settings.currentConfig
ConfigDropBtn.TextColor3 = Color3.new(1,1,1)
ConfigDropBtn.TextSize = 13
ConfigDropBtn.Font = Enum.Font.Gotham
ConfigDropBtn.LayoutOrder = 4
Instance.new("UICorner",ConfigDropBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke",ConfigDropBtn).Transparency = 0.7
local ConfigList = Instance.new("ScrollingFrame",Content)
ConfigList.Size = UDim2.new(1,0,0,120)
ConfigList.BackgroundColor3 = Color3.fromRGB(30,30,35)
ConfigList.BackgroundTransparency = 0.4
ConfigList.BorderSizePixel = 0
ConfigList.ScrollBarThickness = 4
ConfigList.Visible = false
ConfigList.CanvasSize = UDim2.new(0,0,0,0)
ConfigList.LayoutOrder = 5
local ConfigLL = Instance.new("UIListLayout",ConfigList)
ConfigLL.Padding = UDim.new(0,2)
ConfigLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ConfigList.CanvasSize = UDim2.new(0,0,0,ConfigLL.AbsoluteContentSize.Y)
end)
local function refreshConfigList()
    for _,c in pairs(ConfigList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for name,_ in pairs(Settings.configs) do
        local b = Instance.new("TextButton",ConfigList)
        b.Size = UDim2.new(1,-8,0,26)
        b.BackgroundTransparency = 1
        b.Text = name
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.TextSize = 12
        b.Font = Enum.Font.Gotham
        b.MouseButton1Click:Connect(function()
            Settings.currentConfig = name
            ConfigDropBtn.Text = name
            ConfigList.Visible = false
            pcall(loadCurrentConfig)
            saveSettings()
        end)
    end
end
local function loadCurrentConfig()
    local cfg = getCurrentSettings()
    if DropBtn then DropBtn.Text = cfg.Material end
    if TexBox then TexBox.Text = cfg.TextureID end
    pcall(updateColor)
    if TransSlider then pcall(TransSlider.update, TransSlider, cfg.Transparency) end
    if RefSlider then pcall(RefSlider.update, RefSlider, cfg.Reflectance) end
    if GlossSlider then pcall(GlossSlider.update, GlossSlider, cfg.Glossy) end
    if ShinySlider then pcall(ShinySlider.update, ShinySlider, cfg.Shininess) end
    pcall(updateTexPrev)
    if AutoBtn then
        AutoBtn.Text = cfg.AutoLoad and "ON" or "OFF"
        AutoBtn.BackgroundColor3 = cfg.AutoLoad and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    end
    pcall(applyAll)
end
-- Config Controls Frame
local ConfigControlsFrame = Instance.new("Frame", Content)
ConfigControlsFrame.Size = UDim2.new(1, 0, 0, 40)
ConfigControlsFrame.BackgroundTransparency = 1
ConfigControlsFrame.LayoutOrder = 6
local NewConfigBox = Instance.new("TextBox", ConfigControlsFrame)
NewConfigBox.Size = UDim2.new(0,120,1,0)
NewConfigBox.Position = UDim2.new(0,0,0,0)
NewConfigBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
NewConfigBox.BackgroundTransparency = 0.3
NewConfigBox.PlaceholderText = "New Config Name"
NewConfigBox.Text = ""
NewConfigBox.TextColor3 = Color3.new(1,1,1)
NewConfigBox.TextSize = 12
NewConfigBox.Font = Enum.Font.Gotham
Instance.new("UICorner",NewConfigBox).CornerRadius = UDim.new(0,6)
local SaveAsBtn = Instance.new("TextButton", ConfigControlsFrame)
SaveAsBtn.Size = UDim2.new(0,60,1,0)
SaveAsBtn.Position = UDim2.new(0,125,0,0)
SaveAsBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
SaveAsBtn.BackgroundTransparency = 0.3
SaveAsBtn.Text = "Save As"
SaveAsBtn.TextColor3 = Color3.new(1,1,1)
SaveAsBtn.TextSize = 11
SaveAsBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner",SaveAsBtn).CornerRadius = UDim.new(0,6)
SaveAsBtn.MouseButton1Click:Connect(function()
    local name = NewConfigBox.Text:match("^%s*(.-)%s*$")
    if name == "" or Settings.configs[name] then return end
    Settings.configs[name] = HttpService:JSONDecode(HttpService:JSONEncode(getCurrentSettings()))
    Settings.currentConfig = name
    saveSettings()
    refreshConfigList()
    ConfigDropBtn.Text = name
    NewConfigBox.Text = ""
end)
local DeleteBtn = Instance.new("TextButton", ConfigControlsFrame)
DeleteBtn.Size = UDim2.new(0,60,1,0)
DeleteBtn.Position = UDim2.new(0,190,0,0)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
DeleteBtn.BackgroundTransparency = 0.3
DeleteBtn.Text = "Delete"
DeleteBtn.TextColor3 = Color3.new(1,1,1)
DeleteBtn.TextSize = 11
DeleteBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner",DeleteBtn).CornerRadius = UDim.new(0,6)
DeleteBtn.MouseButton1Click:Connect(function()
    local name = Settings.currentConfig
    if name == "default" then return end
    Settings.configs[name] = nil
    if not Settings.configs["default"] then
        Settings.configs["default"] = defaultSettings
    end
    Settings.currentConfig = "default"
    saveSettings()
    refreshConfigList()
    pcall(loadCurrentConfig)
end)
refreshConfigList()
ConfigDropBtn.MouseButton1Click:Connect(function()
    ConfigList.Visible = not ConfigList.Visible
    if DropList then DropList.Visible = false end
end)
----------------------------------------------------------------
--// MATERIAL DROPDOWN (SCROLLABLE)
----------------------------------------------------------------
local AllMats = {"Glass","Neon","ForceField","SmoothPlastic","Metal","Ice","DiamondPlate","CorrodedMetal","Foil","Fabric","Wood","Plastic","Concrete","Rock","Cement","Brick","Granite","Marble","Pebble","Asphalt","Cobblestone","Grass","Ground","Mud","Pavement","Sand","Basalt","Moss","CrackedLava","GlacialIce","HotLava","LeafyGrass","LightWood","Log","MossyRock","Mud","Rock","SaltAndPepper","Sand","Slate","Snow","Stone","Water","Wood","WoodPlanks"}
local MatLabel = Instance.new("TextLabel",Content)
MatLabel.Size = UDim2.new(1,0,0,26)
MatLabel.BackgroundTransparency = 1
MatLabel.Text = "Wrap Material"
MatLabel.TextColor3 = Color3.fromRGB(220,220,220)
MatLabel.TextSize = 14
MatLabel.Font = Enum.Font.Gotham
MatLabel.TextXAlignment = Enum.TextXAlignment.Left
MatLabel.LayoutOrder = 10
local DropBtn = Instance.new("TextButton",Content)
DropBtn.Size = UDim2.new(1,0,0,34)
DropBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
DropBtn.BackgroundTransparency = 0.3
DropBtn.Text = currentCfg.Material
DropBtn.TextColor3 = Color3.new(1,1,1)
DropBtn.TextSize = 13
DropBtn.Font = Enum.Font.Gotham
DropBtn.LayoutOrder = 11
Instance.new("UICorner",DropBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke",DropBtn).Transparency = 0.7
local DropList = Instance.new("ScrollingFrame",Content)
DropList.Size = UDim2.new(1,0,0,120)
DropList.BackgroundColor3 = Color3.fromRGB(30,30,35)
DropList.BackgroundTransparency = 0.4
DropList.BorderSizePixel = 0
DropList.ScrollBarThickness = 4
DropList.Visible = false
DropList.CanvasSize = UDim2.new(0,0,0,0)
DropList.LayoutOrder = 12
local LL = Instance.new("UIListLayout",DropList)
LL.Padding = UDim.new(0,2)
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DropList.CanvasSize = UDim2.new(0,0,0,LL.AbsoluteContentSize.Y)
end)
for _,m in ipairs(AllMats) do
    local b = Instance.new("TextButton",DropList)
    b.Size = UDim2.new(1,-8,0,26)
    b.BackgroundTransparency = 1
    b.Text = m
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.TextSize = 12
    b.Font = Enum.Font.Gotham
    b.MouseButton1Click:Connect(function()
        DropBtn.Text = m
        updateCurrentSettings("Material", m)
        DropList.Visible = false
        pcall(applyAll)
    end)
end
DropBtn.MouseButton1Click:Connect(function()
    DropList.Visible = not DropList.Visible
    ConfigList.Visible = false
end)
----------------------------------------------------------------
--// SLIDER FACTORY (OPTIMIZED: IMMEDIATE UPDATES FOR DRAG, TWEEN ONLY ON RELEASE)
----------------------------------------------------------------
local function makeSlider(parent, order, label, val, max, col, cb)
    local frame = Instance.new("Frame",parent)
    frame.Size = UDim2.new(1,0,0,44)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    local lab = Instance.new("TextLabel",frame)
    lab.Size = UDim2.new(1,0,0,20)
    lab.BackgroundTransparency = 1
    lab.Text = label..": "..(max==1 and string.format("%.2f",val) or val)
    lab.TextColor3 = Color3.fromRGB(200,200,200)
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextSize = 13
    lab.Font = Enum.Font.Gotham
    local back = Instance.new("Frame",frame)
    back.Size = UDim2.new(1,0,0,12)
    back.Position = UDim2.new(0,0,0,24)
    back.BackgroundColor3 = Color3.fromRGB(50,50,55)
    Instance.new("UICorner",back).CornerRadius = UDim.new(0,6)
    local fill = Instance.new("Frame",back)
    fill.Size = UDim2.new(val/(max==1 and 1 or 255),0,1,0)
    fill.BackgroundColor3 = col
    Instance.new("UICorner",fill).CornerRadius = UDim.new(0,6)
    local knob = Instance.new("Frame",back)
    knob.Size = UDim2.new(0,24,0,24)
    knob.Position = UDim2.new(val/(max==1 and 1 or 255),-12,0,-6)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local sliding = false
    local currentVal = val
    local function update(v, animate)
        currentVal = v
        local r = v / (max==1 and 1 or 255)
        if animate then
            TweenService:Create(fill,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{Size=UDim2.new(r,0,1,0)}):Play()
            TweenService:Create(knob,TweenInfo.new(0.12,Enum.EasingStyle.Quint),{Position=UDim2.new(r,-12,0,-6)}):Play()
        else
            fill.Size = UDim2.new(r,0,1,0)
            knob.Position = UDim2.new(r,-12,0,-6)
        end
        lab.Text = label..": "..(max==1 and string.format("%.2f",v) or v)
    end
    local function start() sliding = true end
    local function stop()
        if sliding then
            sliding = false
            update(currentVal, true) -- Animate on release
            saveSettings()
            pcall(applyAll)
        end
    end
    back.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            start()
            local rel = math.clamp((i.Position.X - back.AbsolutePosition.X)/back.AbsoluteSize.X,0,1)
            local v = max==1 and rel or math.round(rel*255)
            cb(v); update(v, false) -- Immediate during drag
        end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then start() end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - back.AbsolutePosition.X)/back.AbsoluteSize.X,0,1)
            local v = max==1 and rel or math.round(rel*255)
            cb(v); update(v, false) -- Immediate during drag
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            stop()
        end
    end)
    return {update = update}
end
local RSlider = makeSlider(Content,20,"Red", currentCfg.R,255,Color3.fromRGB(255,80,80), function(v) updateCurrentSettings("R",v) end)
local GSlider = makeSlider(Content,21,"Green", currentCfg.G,255,Color3.fromRGB(80,255,80), function(v) updateCurrentSettings("G",v) end)
local BSlider = makeSlider(Content,22,"Blue", currentCfg.B,255,Color3.fromRGB(80,80,255), function(v) updateCurrentSettings("B",v) end)
local RefSlider = makeSlider(Content,23,"Reflectance",currentCfg.Reflectance,1,Color3.fromRGB(200,200,255),function(v) updateCurrentSettings("Reflectance",v) end)
local GlossSlider = makeSlider(Content,24,"Glossy", currentCfg.Glossy,1,Color3.fromRGB(255,215,0), function(v) updateCurrentSettings("Glossy",v) end)
local ShinySlider = makeSlider(Content,25,"Shininess",currentCfg.Shininess,1,Color3.fromRGB(255,255,100), function(v) updateCurrentSettings("Shininess",v) end)
local TransSlider = makeSlider(Content,26,"Transparency",currentCfg.Transparency,1,Color3.fromRGB(0,170,255),function(v) updateCurrentSettings("Transparency",v) end)
----------------------------------------------------------------
--// TEXTURE ID + PREVIEW (FIXED)
----------------------------------------------------------------
local TexLab = Instance.new("TextLabel",Content)
TexLab.Size = UDim2.new(1,0,0,20)
TexLab.BackgroundTransparency = 1
TexLab.Text = "Texture ID:"
TexLab.TextColor3 = Color3.fromRGB(200,200,200)
TexLab.TextSize = 13
TexLab.Font = Enum.Font.Gotham
TexLab.TextXAlignment = Enum.TextXAlignment.Left
TexLab.LayoutOrder = 30
local TexInputFrame = Instance.new("Frame",Content)
TexInputFrame.Size = UDim2.new(1,0,0,48)
TexInputFrame.BackgroundTransparency = 1
TexInputFrame.LayoutOrder = 31
local TexInputList = Instance.new("UIListLayout", TexInputFrame)
TexInputList.FillDirection = Enum.FillDirection.Horizontal
TexInputList.HorizontalAlignment = Enum.HorizontalAlignment.Left
TexInputList.VerticalAlignment = Enum.VerticalAlignment.Center
TexInputList.Padding = UDim.new(0,10)
local TexBox = Instance.new("TextBox",TexInputFrame)
TexBox.Size = UDim2.new(1,-60,1,0)
TexBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
TexBox.BackgroundTransparency = 0.3
TexBox.PlaceholderText = "rbxassetid:// + ID"
TexBox.Text = currentCfg.TextureID
TexBox.TextColor3 = Color3.new(1,1,1)
TexBox.TextSize = 12
TexBox.Font = Enum.Font.Gotham
Instance.new("UICorner",TexBox).CornerRadius = UDim.new(0,6)
local TexPrev = Instance.new("ImageLabel",TexInputFrame)
TexPrev.Size = UDim2.new(0,48,1,0)
TexPrev.AnchorPoint = Vector2.new(1,0.5)
TexPrev.Position = UDim2.new(1,-24,0.5,0)
TexPrev.BackgroundColor3 = Color3.fromRGB(60,60,60)
TexPrev.Image = ""
TexPrev.ScaleType = Enum.ScaleType.Fit
Instance.new("UICorner",TexPrev).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke",TexPrev).Transparency = 0.7
local function updateTexPrev()
    local id = currentCfg.TextureID:gsub("%D","")
    TexPrev.Image = (id ~= "" and "rbxassetid://"..id) or ""
end
TexBox.FocusLost:Connect(function(enter)
    if not enter then return end
    local newId = TexBox.Text:gsub("%D","")
    updateCurrentSettings("TextureID", newId)
    updateTexPrev()
    saveSettings()
    pcall(applyAll)
end)
updateTexPrev()
----------------------------------------------------------------
--// COLOR PREVIEW + HEX
----------------------------------------------------------------
local ColorRow = Instance.new("Frame",Content)
ColorRow.Size = UDim2.new(1,0,0,28)
ColorRow.BackgroundTransparency = 1
ColorRow.LayoutOrder = 40
local ColorList = Instance.new("UIListLayout", ColorRow)
ColorList.FillDirection = Enum.FillDirection.Horizontal
ColorList.HorizontalAlignment = Enum.HorizontalAlignment.Left
ColorList.VerticalAlignment = Enum.VerticalAlignment.Center
ColorList.Padding = UDim.new(0,10)
local HexBox = Instance.new("TextBox",ColorRow)
HexBox.Size = UDim2.new(0,110,1,0)
HexBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
HexBox.BackgroundTransparency = 0.3
HexBox.Text = string.format("#%02X%02X%02X", currentCfg.R, currentCfg.G, currentCfg.B)
HexBox.TextColor3 = Color3.new(1,1,1)
HexBox.TextSize = 12
HexBox.Font = Enum.Font.Gotham
Instance.new("UICorner",HexBox).CornerRadius = UDim.new(0,6)
local ColPrev = Instance.new("Frame",ColorRow)
ColPrev.Size = UDim2.new(0,32,1,0)
ColPrev.BackgroundColor3 = Color3.fromRGB(currentCfg.R, currentCfg.G, currentCfg.B)
Instance.new("UICorner",ColPrev).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke",ColPrev).Transparency = 0.7
local function updateColor()
    local cfg = getCurrentSettings()
    local r,g,b = cfg.R, cfg.G, cfg.B
    ColPrev.BackgroundColor3 = Color3.fromRGB(r,g,b)
    HexBox.Text = string.format("#%02X%02X%02X",r,g,b)
    if RSlider then pcall(RSlider.update, RSlider, r, true) end
    if GSlider then pcall(GSlider.update, GSlider, g, true) end
    if BSlider then pcall(BSlider.update, BSlider, b, true) end
end
HexBox.FocusLost:Connect(function(enter)
    if not enter then return end
    local h = HexBox.Text:gsub("#",""):upper():gsub("%D","")
    if #h==6 then
        local r = tonumber(h:sub(1,2),16) or 255
        local g = tonumber(h:sub(3,4),16) or 255
        local b = tonumber(h:sub(5,6),16) or 255
        updateCurrentSettings("R", r)
        updateCurrentSettings("G", g)
        updateCurrentSettings("B", b)
        updateColor()
        saveSettings()
        pcall(applyAll)
    end
end)
----------------------------------------------------------------
--// AUTO-LOAD + APPLY + RESET
----------------------------------------------------------------
local AutoRow = Instance.new("Frame",Content)
AutoRow.Size = UDim2.new(1,0,0,26)
AutoRow.BackgroundTransparency = 1
AutoRow.LayoutOrder = 50
local AutoList = Instance.new("UIListLayout", AutoRow)
AutoList.FillDirection = Enum.FillDirection.Horizontal
AutoList.HorizontalAlignment = Enum.HorizontalAlignment.Left
AutoList.VerticalAlignment = Enum.VerticalAlignment.Center
AutoList.Padding = UDim.new(0,10)
local AutoLab = Instance.new("TextLabel",AutoRow)
AutoLab.Size = UDim2.new(0,100,1,0)
AutoLab.BackgroundTransparency = 1
AutoLab.Text = "Auto Load:"
AutoLab.TextColor3 = Color3.fromRGB(200,200,200)
AutoLab.TextSize = 13
AutoLab.Font = Enum.Font.Gotham
AutoLab.TextXAlignment = Enum.TextXAlignment.Left
local AutoBtn = Instance.new("TextButton",AutoRow)
AutoBtn.Size = UDim2.new(0,50,1,0)
AutoBtn.BackgroundColor3 = currentCfg.AutoLoad and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
AutoBtn.BackgroundTransparency = 0.3
AutoBtn.Text = currentCfg.AutoLoad and "ON" or "OFF"
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.TextSize = 12
AutoBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner",AutoBtn).CornerRadius = UDim.new(0,6)
AutoBtn.MouseButton1Click:Connect(function()
    local newVal = not currentCfg.AutoLoad
    updateCurrentSettings("AutoLoad", newVal)
    AutoBtn.Text = newVal and "ON" or "OFF"
    AutoBtn.BackgroundColor3 = newVal and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    saveSettings()
end)
local ResetBtn = Instance.new("TextButton",Content)
ResetBtn.Size = UDim2.new(0,80,0,38)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255,150,0)
ResetBtn.BackgroundTransparency = 0.2
ResetBtn.Text = "Reset to Default"
ResetBtn.TextColor3 = Color3.new(1,1,1)
ResetBtn.TextSize = 11
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.LayoutOrder = 55
Instance.new("UICorner",ResetBtn).CornerRadius = UDim.new(0,8)
ResetBtn.MouseButton1Click:Connect(function()
    for k,v in pairs(defaultSettings) do
        updateCurrentSettings(k, v)
    end
    pcall(loadCurrentConfig)
end)
local ApplyBtn = Instance.new("TextButton",Content)
ApplyBtn.Size = UDim2.new(1,0,0,38)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
ApplyBtn.BackgroundTransparency = 0.2
ApplyBtn.Text = "Apply Wraps"
ApplyBtn.TextColor3 = Color3.new(1,1,1)
ApplyBtn.TextSize = 14
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.LayoutOrder = 60
Instance.new("UICorner",ApplyBtn).CornerRadius = UDim.new(0,10)
----------------------------------------------------------------
--// SKIN CHANGER BUTTON
----------------------------------------------------------------
local SkinChangerBtn = Instance.new("TextButton", Content)
SkinChangerBtn.Size = UDim2.new(1, 0, 0, 38)
SkinChangerBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
SkinChangerBtn.BackgroundTransparency = 0.2
SkinChangerBtn.Text = "Skin Changer"
SkinChangerBtn.TextColor3 = Color3.new(1, 1, 1)
SkinChangerBtn.TextSize = 14
SkinChangerBtn.Font = Enum.Font.GothamBold
SkinChangerBtn.LayoutOrder = 65
Instance.new("UICorner", SkinChangerBtn).CornerRadius = UDim.new(0, 10)
SkinChangerBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://soluna-script.vercel.app/skin-changer.lua", true))()
end)
----------------------------------------------------------------
--// ??? BUTTON
----------------------------------------------------------------
local MysteryBtn = Instance.new("TextButton", Content)
MysteryBtn.Size = UDim2.new(1, 0, 0, 38)
MysteryBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
MysteryBtn.BackgroundTransparency = 0.2
MysteryBtn.Text = "???"
MysteryBtn.TextColor3 = Color3.new(1, 1, 1)
MysteryBtn.TextSize = 14
MysteryBtn.Font = Enum.Font.GothamBold
MysteryBtn.LayoutOrder = 70
Instance.new("UICorner", MysteryBtn).CornerRadius = UDim.new(0, 10)
MysteryBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/amincog/metrixhub/refs/heads/main/metrixhub"))()
end)
----------------------------------------------------------------
--// WRAP LOGIC (LOCAL ONLY - IMMEDIATE SYNCHRONOUS APPLICATION)
----------------------------------------------------------------
-- This script only modifies the local player's client-side viewmodel in PlayerScripts.
-- Changes do not replicate to other players, teammates, or enemies. It exclusively targets
-- parts descending from the local player's ViewModels folder and skips any other hierarchy.
-- Explicitly ensures no application to teammates' or enemies' guns/wraps by strict path checking.
local applying = false
local function isLocalViewmodel(part)
    -- Double-check: Ensure part is strictly under local player's ViewModels
    -- Abort immediately if not in local hierarchy or if in workspace/character models
    if not part or not part.Parent then return false end
    local p = part
    while p do
        if p == viewmodelPath then return true end
        -- Safety: Abort if we hit workspace, any character model, or non-local player hierarchy
        if p:IsA("Model") then
            local pp = p.Parent
            if pp == workspace or (pp and pp.Parent == workspace) or pp == Players then
                return false
            end
            -- Additional check: If under any other player's character or PlayerGui, abort
            if pp:IsA("Model") and pp:FindFirstChild("Humanoid") and pp ~= Player.Character then
                return false
            end
        elseif p == workspace or p == Players then
            return false
        end
        p = p.Parent
    end
    return false
end
local function changeWrap(part)
    -- Strict check: Only apply if confirmed local viewmodel part
    -- No changes to teammates/enemies: only local viewmodel parts
    if not part:IsA("BasePart") or part.Transparency >= 1 or not isLocalViewmodel(part) then return end
    -- Skip bullets/projectiles/ammo to prevent transparency/color changes on them
    local partNameLower = part.Name:lower()
    if partNameLower:find("bullet") or partNameLower:find("projectile") or partNameLower:find("ammo") or partNameLower:find("shell") then
        return
    end
    local cfg = getCurrentSettings()
    pcall(function()
        -- Detect if part is glowing/light-related and skip changes to preserve original properties
        local isGlowingPart = false
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
                isGlowingPart = true
                break
            end
        end
        if part.Name:lower():find("light") or part.Name:lower():find("glow") or part.Name:lower():find("muzzle") or part.Name:lower():find("flash") then
            isGlowingPart = true
        end
        if isGlowingPart then
            -- Skip all changes for glowing parts to preserve original color and properties
            return
        end
        local mat = cfg.TextureID ~= "" and Enum.Material.SmoothPlastic
            or Enum.Material[cfg.Material] or Enum.Material.Glass
        part.Material = mat
        part.Color = Color3.fromRGB(cfg.R, cfg.G, cfg.B)
        local trans = (mat == Enum.Material.Neon or mat == Enum.Material.ForceField) and 0 or cfg.Transparency
        part.Transparency = trans
        part.Reflectance = cfg.Reflectance + (cfg.Glossy + cfg.Shininess) * 0.5
        if (cfg.Glossy + cfg.Shininess) > 0 then
            local totalGlossy = (cfg.Glossy + cfg.Shininess) / 2
            local variant = (totalGlossy > 0.6 and "Polished") or (totalGlossy > 0.3 and "SemiGloss") or "Matte"
            pcall(function() part.MaterialVariant = variant end)
        else
            pcall(function() part.MaterialVariant = "" end)
        end
        local decal = part:FindFirstChildOfClass("Decal")
        if cfg.TextureID ~= "" then
            if not decal then 
                decal = Instance.new("Decal", part) 
                decal.Name = "MetrixHub_Decal" -- Name for reuse
            end
            decal.Texture = "rbxassetid://" .. cfg.TextureID
            decal.Transparency = 0
        else
            if decal and decal.Name == "MetrixHub_Decal" then 
                decal:Destroy() 
            end
        end
    end)
end
local function applyAll()
    if applying or not viewmodelPath then return end
    applying = true
    -- Only iterate over local viewmodel weapons - no access to others
    for _, weapon in ipairs(viewmodelPath:GetChildren()) do
        for _, obj in ipairs(weapon:GetDescendants()) do
            if obj:IsA("BasePart") and isLocalViewmodel(obj) then
                changeWrap(obj)
            end
        end
    end
    applying = false
end
viewmodelPath.ChildAdded:Connect(function(child)
    task.wait()
    if not child then return end
    -- Only new local viewmodel children
    for _, obj in ipairs(child:GetDescendants()) do
        if obj:IsA("BasePart") and isLocalViewmodel(obj) then
            changeWrap(obj)
        end
    end
end)
ApplyBtn.MouseButton1Click:Connect(applyAll)
----------------------------------------------------------------
--// TOGGLE SYSTEM
----------------------------------------------------------------
local isOpen = false
local savedPos = Container.Position
local function openGUI()
    isOpen = true
    local off = UDim2.new(savedPos.X.Scale, savedPos.X.Offset, savedPos.Y.Scale - 1, savedPos.Y.Offset)
    Container.Position = off
    Container.Visible = true
    TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = savedPos}):Play()
end
local function closeGUI()
    isOpen = false
    savedPos = Container.Position
    local off = UDim2.new(savedPos.X.Scale, savedPos.X.Offset, savedPos.Y.Scale - 1, savedPos.Y.Offset)
    TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = off}):Play()
    task.delay(0.31, function()
        if not isOpen then
            Container.Position = savedPos
            Container.Visible = false
        end
    end)
end
local function toggleGUI()
    if isOpen then closeGUI() else openGUI() end
end
ToggleBtn.MouseButton1Click:Connect(toggleGUI)
Close.MouseButton1Click:Connect(toggleGUI)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleGUI()
    end
end)
----------------------------------------------------------------
--// INITIALIZE
----------------------------------------------------------------
pcall(loadCurrentConfig)
pcall(updateColor)
Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 30)
if currentCfg.AutoLoad then
    task.defer(applyAll)
end
