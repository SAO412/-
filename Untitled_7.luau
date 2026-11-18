print("Hello, world!");-- ==============================================================================
-- 🌸✨ Carl Tool - 《一掌轟仙界》自由調整大小旗艦版 🚀💎
-- ==============================================================================

local RAW_ASSET_ID = "135295556334883" -- 💡 您的專屬圖標 ID[cite: 4]
local DISCORD_INVITE_URL = "https://discord.gg/XknhQjbE4z" -- 💡 您的 Discord 連結
local CONFIG_FILE_NAME = "CarlTool_YiZhang_Resize_Config.json"

local function generateDynamicSignature()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local sig = "CarlResize_"
    math.randomseed(os.time() + tick())
    for i = 1, math.random(12, 24) do
        local randIndex = math.random(1, #chars)
        sig = sig .. chars:sub(randIndex, randIndex)
    end
    return sig
end

local _POLY_ID = generateDynamicSignature()

local function getExecutorName()
    if identifyexecutor then return identifyexecutor()
    elseif getexecutorname then return getexecutorname()
    elseif syn then return "Synapse X"
    elseif KRNL_LOADED then return "Krnl"
    elseif Fluxus then return "Fluxus"
    elseif Solara then return "Solara"
    elseif Delta then return "Delta"
    elseif Codex then return "Codex"
    else return "Universal Executor" end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local currentLanguage = "zh"
local currentThemeIndex = 1

local ThemePresets = {
    Pink = Color3.fromRGB(255, 105, 180),   -- 🌸 櫻花粉
    NeonCyan = Color3.fromRGB(0, 245, 255),  -- 💎 電光青
    NeonPurple = Color3.fromRGB(199, 125, 255), -- 🔮 霓虹紫
    Gold = Color3.fromRGB(255, 215, 0),     -- 👑 閃耀金
    Green = Color3.fromRGB(50, 235, 130),   -- 🍃 翡翠綠
    Red = Color3.fromRGB(255, 99, 71),      -- 🍎 活力紅
    Blue = Color3.fromRGB(30, 144, 255),    -- 🌊 湛藍海
    Orange = Color3.fromRGB(255, 140, 0),   -- 🍊 蜜柑橘
    Lime = Color3.fromRGB(173, 255, 47),    -- 🍋 青檸黃
    White = Color3.fromRGB(240, 248, 255)   -- ☁️ 雲朵白
}

local ThemeNames = {
    "🌸 櫻花粉 (Sakura)", "💎 電光青 (Neon Cyan)", "🔮 霓虹紫 (Neon Purple)", 
    "👑 閃耀金 (Gold)", "🍃 翡翠綠 (Green)", "🍎 活力紅 (Red)", 
    "🌊 湛藍海 (Blue)", "🍊 蜜柑橘 (Orange)", "🍋 青檸黃 (Lime)", "☁️ 雲朵白 (White)"
}
local ThemeKeys = {"Pink", "NeonCyan", "NeonPurple", "Gold", "Green", "Red", "Blue", "Orange", "Lime", "White"}

local function getAccentColor()
    return ThemePresets[ThemeKeys[currentThemeIndex]] or ThemePresets.Pink
end

local Config = {
    AutoLaunch = false,
    AutoWalk = false,
    TargetPercent = 95,
    ClickDelay = 0.35,
    MenuTextSize = 15,
    MenuBackgroundAlpha = 15,
    SavedThemeIndex = 1,
    SavedLanguage = "zh",
    PanelWidth = 780,
    PanelHeight = 510
}

local SessionStats = {
    StartTime = tick(),
    LaunchCount = 0,
    DetectedCount = 0
}

local _LastTick = 0
local _saveQueued = false

local function saveConfig()
    if _saveQueued then return end
    _saveQueued = true
    task.delay(0.5, function()
        _saveQueued = false
        if writefile then
            pcall(function()
                Config.SavedThemeIndex = currentThemeIndex
                Config.SavedLanguage = currentLanguage
                writefile(CONFIG_FILE_NAME, HttpService:JSONEncode(Config))
            end)
        end
    end)
end

local function loadConfig()
    if readfile and isfile and isfile(CONFIG_FILE_NAME) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE_NAME))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if k ~= "AutoLaunch" and k ~= "AutoWalk" then
                        Config[k] = v
                    end
                end
                currentThemeIndex = Config.SavedThemeIndex or 1
                currentLanguage = Config.SavedLanguage or "zh"
            end
        end)
    end
end
loadConfig()

local TextDict = {
    zh = {
        LogsTab = "📊 運行日誌",
        MainTab = "⚡ 自動掛機",
        BagTab = "🎒 法寶檢測",
        CfgTab = "⚙️ 參數設定",
        AutoLaunch = "🚀 自動發射開關",
        TargetPct = "🎯 觸發目標百分比 (%)",
        ClickDelay = "⏳ 點擊冷卻延遲 (ms)",
        AutoWalk = "🚶 自動往前走 (修正偏移)",
        ScanBagNow = "🔍 立即重新掃描背包",
        SelectAll = "☑ 全選 / 取消全選",
        ExportSelected = "📋 匯出選取法寶資訊",
        ResetStats = "🔄 重置運行計時與數據",
        FontSize = "🔤 選單字體大小",
        MenuAlpha = "🎨 背景透明度 %",
        AccentTheme = "✨ 介面主題配色",
        ConfigSavedMsg = "💾 參數設定已優化並自動儲存！",
        On = "開",
        Off = "關"
    },
    en = {
        LogsTab = "📊 Logs",
        MainTab = "⚡ Farm",
        BagTab = "🎒 Artifacts",
        CfgTab = "⚙️ Settings",
        AutoLaunch = "🚀 Auto Launch",
        TargetPct = "🎯 Target Percent (%)",
        ClickDelay = "⏳ Click Delay (ms)",
        AutoWalk = "🚶 Auto Walk",
        ScanBagNow = "🔍 Scan Bag",
        SelectAll = "☑ Select All",
        ExportSelected = "📋 Export Selected",
        ResetStats = "🔄 Reset Stats",
        FontSize = "🔤 Font Size",
        MenuAlpha = "🎨 Menu Alpha %",
        AccentTheme = "✨ Theme Style",
        ConfigSavedMsg = "💾 Settings optimized & saved!",
        On = "ON",
        Off = "OFF"
    }
}

local function t(key)
    return TextDict[currentLanguage][key] or key
end

local refreshLanguageText, updateThemeStyle

local gui = Instance.new("ScreenGui")
gui.Name = "Core_" .. _POLY_ID
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = pg
    end
end)
if not gui.Parent or not gui:IsDescendantOf(game) then
    gui.Parent = pg
end

local function applyCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 24)
    c.Parent = p
end

local function applyHoverEffect(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = btn.Size + UDim2.new(0, 4, 0, 2)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = btn.Size - UDim2.new(0, 4, 0, 2)
        }):Play()
    end)
end

local function setupImage(imageLabel, assetId)
    pcall(function()
        imageLabel.Image = "rbxassetid://" .. tostring(assetId)
        task.spawn(function()
            task.wait(1.5)
            if imageLabel and imageLabel.Parent and not imageLabel.IsLoaded then
                imageLabel.Image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=420&h=420"
            end
        end)
    end)
end

-- 🌸 櫻花飄落裝飾特效層
local sakuraGui = Instance.new("ScreenGui")
sakuraGui.Name = "SakuraParticles_" .. _POLY_ID
sakuraGui.ResetOnSpawn = false
sakuraGui.IgnoreGuiInset = true
pcall(function()
    if gethui then sakuraGui.Parent = gethui() else sakuraGui.Parent = gui.Parent end
end)

task.spawn(function()
    while sakuraGui and sakuraGui.Parent do
        task.wait(math.random(15, 30) / 10)
        pcall(function()
            local sakura = Instance.new("TextLabel")
            sakura.Size = UDim2.new(0, 24, 0, 24)
            sakura.Position = UDim2.new(math.random(5, 95) / 100, 0, -0.05, 0)
            sakura.BackgroundTransparency = 1
            sakura.Text = "🌸"
            sakura.TextSize = math.random(14, 22)
            sakura.ZIndex = 999
            sakura.Parent = sakuraGui

            local targetX = sakura.Position.X.Scale + (math.random(-15, 15) / 100)
            local fallTween = TweenService:Create(sakura, TweenInfo.new(math.random(6, 12), Enum.EasingStyle.Linear), {
                Position = UDim2.new(targetX, 0, 1.05, 0),
                Rotation = math.random(-180, 180)
            })
            fallTween:Play()
            fallTween.Completed:Connect(function()
                sakura:Destroy()
            end)
        end)
    end
end)

-- 🎀 懸浮球
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "Float_" .. _POLY_ID
floatGui.ResetOnSpawn = false
floatGui.IgnoreGuiInset = true
pcall(function()
    if gethui then floatGui.Parent = gethui() else floatGui.Parent = gui.Parent end
end)

local floatingBtn = Instance.new("ImageButton")
floatingBtn.Size = UDim2.new(0, 64, 0, 64)
floatingBtn.Position = UDim2.new(0, 40, 0, 180)
floatingBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 242)
floatingBtn.ScaleType = Enum.ScaleType.Fit
floatingBtn.Active = true
floatingBtn.Draggable = true
floatingBtn.Visible = false
floatingBtn.ZIndex = 100
floatingBtn.Parent = floatGui
applyCorner(floatingBtn, 20)
setupImage(floatingBtn, RAW_ASSET_ID)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = getAccentColor()
floatStroke.Thickness = 2.5
floatStroke.Parent = floatingBtn

-- 主面板 (支援動態大小與拖曳縮放)
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, Config.PanelWidth, 0, Config.PanelHeight)
mainPanel.Position = UDim2.new(0.5, -Config.PanelWidth/2, 0.5, -Config.PanelHeight/2)
mainPanel.BackgroundColor3 = Color3.fromRGB(255, 240, 246)
mainPanel.BackgroundTransparency = Config.MenuBackgroundAlpha / 100
mainPanel.Active = true
mainPanel.Draggable = true
mainPanel.Parent = gui
applyCorner(mainPanel, 32)

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 225, 238)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 242, 255))
}
grad.Rotation = 45
grad.Parent = mainPanel

local glow = Instance.new("UIStroke")
glow.Color = getAccentColor()
glow.Thickness = 5
glow.Transparency = 0.5
glow.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = getAccentColor()
panelStroke.Transparency = 0.3
panelStroke.Thickness = 1.5
panelStroke.Parent = mainPanel

-- 🖱️ 右下角縮放把手 (Resize Handle)
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 24, 0, 24)
resizeHandle.Position = UDim2.new(1, -24, 1, -24)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = "◢"
resizeHandle.TextColor3 = Color3.fromRGB(255, 105, 180)
resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 14
resizeHandle.ZIndex = 90
resizeHandle.Parent = mainPanel

local resizing = false
local resizeStartPos = Vector2.new(0, 0)
local startSize = Vector2.new(Config.PanelWidth, Config.PanelHeight)

resizeHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStartPos = Vector2.new(inp.Position.X, inp.Position.Y)
        startSize = Vector2.new(mainPanel.AbsoluteSize.X, mainPanel.AbsoluteSize.Y)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if resizing then
            resizing = false
            Config.PanelWidth = mainPanel.AbsoluteSize.X
            Config.PanelHeight = mainPanel.AbsoluteSize.Y
            saveConfig()
        end
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector2.new(inp.Position.X, inp.Position.Y) - resizeStartPos
        local newW = math.clamp(startSize.X + delta.X, 550, 1100)
        local newH = math.clamp(startSize.Y + delta.Y, 380, 750)
        mainPanel.Size = UDim2.new(0, newW, 0, newH)
    end
end)

-- 側邊欄 (精緻半透明粉白玻璃風格)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 200, 1, -28)
sidebar.Position = UDim2.new(0, 14, 0, 14)
sidebar.BackgroundColor3 = Color3.fromRGB(255, 250, 253)
sidebar.BackgroundTransparency = 0.35
sidebar.ZIndex = 5
sidebar.Parent = mainPanel
applyCorner(sidebar, 24)

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(255, 190, 215)
sidebarStroke.Transparency = 0.5
sidebarStroke.Thickness = 1.2
sidebarStroke.Parent = sidebar

local sideLogo = Instance.new("ImageLabel")
sideLogo.Size = UDim2.new(0, 68, 0, 68)
sideLogo.Position = UDim2.new(0.5, -34, 0, 14)
sideLogo.BackgroundTransparency = 1
sideLogo.ScaleType = Enum.ScaleType.Fit
sideLogo.ZIndex = 50
sideLogo.Parent = sidebar
setupImage(sideLogo, RAW_ASSET_ID)

local sideLogoText = Instance.new("TextLabel")
sideLogoText.Size = UDim2.new(1, 0, 0, 24)
sideLogoText.Position = UDim2.new(0, 0, 0, 86)
sideLogoText.BackgroundTransparency = 1
sideLogoText.Text = "🌸 CARL TOOL 🌸"
sideLogoText.TextColor3 = Color3.fromRGB(120, 80, 105)
sideLogoText.Font = Enum.Font.GothamBlack
sideLogoText.TextSize = 14
sideLogoText.ZIndex = 50
sideLogoText.Parent = sidebar

local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(1, -20, 1, -120)
navContainer.Position = UDim2.new(0, 10, 0, 116)
navContainer.BackgroundTransparency = 1
navContainer.ZIndex = 5
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 8)
navLayout.Parent = navContainer

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -232, 1, -28)
contentArea.Position = UDim2.new(0, 220, 0, 14)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 5
contentArea.Parent = mainPanel

-- 頂部控制按鈕列
local topControls = Instance.new("Frame")
topControls.Size = UDim2.new(0, 160, 0, 32)
topControls.Position = UDim2.new(1, -160, 0, 6)
topControls.BackgroundTransparency = 1
topControls.ZIndex = 60
topControls.Parent = contentArea

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 32, 0, 32)
discordBtn.Position = UDim2.new(0, 0, 0, 0)
discordBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 245)
discordBtn.Text = "💬"
discordBtn.TextColor3 = Color3.fromRGB(114, 137, 218)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 14
discordBtn.ZIndex = 60
discordBtn.Parent = topControls
applyCorner(discordBtn, 12)
applyHoverEffect(discordBtn)

local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0, 32, 0, 32)
langBtn.Position = UDim2.new(0, 40, 0, 0)
langBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 245)
langBtn.Text = (currentLanguage == "zh") and "EN" or "中文"
langBtn.TextColor3 = Color3.fromRGB(120, 80, 105)
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 11
langBtn.ZIndex = 60
langBtn.Parent = topControls
applyCorner(langBtn, 12)
applyHoverEffect(langBtn)

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(0, 80, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 245)
minimizeBtn.Text = "➖"
minimizeBtn.TextColor3 = Color3.fromRGB(120, 80, 105)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.ZIndex = 60
minimizeBtn.Parent = topControls
applyCorner(minimizeBtn, 12)
applyHoverEffect(minimizeBtn)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0, 120, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 245)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 60
closeBtn.Parent = topControls
applyCorner(closeBtn, 12)
applyHoverEffect(closeBtn)

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(DISCORD_INVITE_URL) end) end
end)

langBtn.MouseButton1Click:Connect(function()
    currentLanguage = (currentLanguage == "zh") and "en" or "zh"
    langBtn.Text = (currentLanguage == "zh") and "EN" or "中文"
    refreshLanguageText()
    saveConfig()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainPanel.Visible = false
    floatingBtn.Visible = true
end)

floatingBtn.MouseButton1Click:Connect(function()
    mainPanel.Visible = true
    floatingBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    Config.AutoLaunch = false
    Config.AutoWalk = false
    pcall(function()
        if lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character.Humanoid:Move(Vector3.new(0, 0, 0))
        end
    end)
    pcall(function()
        if sakuraGui then sakuraGui:Destroy() end
        if floatGui then floatGui:Destroy() end
        if gui then gui:Destroy() end
    end)
end)

local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, 0, 1, -46)
pageContainer.Position = UDim2.new(0, 0, 0, 46)
pageContainer.BackgroundTransparency = 1
pageContainer.ZIndex = 10
pageContainer.Parent = contentArea

local function createPage(useListLayout)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0, 0, 0, 560)
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = getAccentColor()
    p.Visible = false
    p.ZIndex = 10
    p.Parent = pageContainer
    if useListLayout then
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 12)
        layout.Parent = p
    end
    return p
end

local mainPage = createPage(true)
local bagPage = createPage(false)
local logsPage = createPage(true)
local cfgPage = createPage(true)
mainPage.Visible = true

local navButtons = {}
local function createNavBtn(textKey, pageRef, order, isDefault)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = isDefault and Color3.fromRGB(255, 220, 238) or Color3.fromRGB(255, 242, 248)
    btn.BackgroundTransparency = isDefault and 0.2 or 0.5
    btn.Text = "   " .. t(textKey)
    btn.TextColor3 = isDefault and Color3.fromRGB(180, 50, 110) or Color3.fromRGB(110, 90, 105)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = Config.MenuTextSize
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 20
    btn.LayoutOrder = order
    btn.Parent = navContainer
    applyCorner(btn, 16)
    applyHoverEffect(btn)

    btn.MouseButton1Click:Connect(function()
        for _, p in ipairs({mainPage, bagPage, logsPage, cfgPage}) do
            if p == pageRef then
                p.Visible = true
                p.Position = UDim2.new(1, 0, 0, 0)
                TweenService:Create(p, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0)
                }):Play()
            else
                p.Visible = false
            end
        end
        for _, b in ipairs(navButtons) do
            b.Btn.BackgroundColor3 = (b.Btn == btn) and Color3.fromRGB(255, 220, 238) or Color3.fromRGB(255, 242, 248)
            b.Btn.BackgroundTransparency = (b.Btn == btn) and 0.2 or 0.5
            b.Btn.TextColor3 = (b.Btn == btn) and Color3.fromRGB(180, 50, 110) or Color3.fromRGB(110, 90, 105)
        end
    end)
    table.insert(navButtons, {Btn = btn, Key = textKey})
    return btn
end

createNavBtn("MainTab", mainPage, 1, true)
createNavBtn("BagTab", bagPage, 2, false)
createNavBtn("LogsTab", logsPage, 3, false)
createNavBtn("CfgTab", cfgPage, 4, false)

local allInteractiveElements = {}

local function makeToggle(parent, textKey, initialState, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -6, 0, 56)
    f.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
    f.BackgroundTransparency = 0.3
    f.ZIndex = 15
    f.Parent = parent
    applyCorner(f, 16)

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(255, 210, 230)
    fStroke.Transparency = 0.6
    fStroke.Thickness = 1
    fStroke.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = t(textKey)
    lbl.TextColor3 = Color3.fromRGB(90, 70, 85)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = Config.MenuTextSize
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 16
    lbl.Parent = f
    table.insert(allInteractiveElements, {Obj = lbl, Key = textKey})

    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(0, 58, 0, 32)
    tBtn.Position = UDim2.new(1, -70, 0.5, -16)
    tBtn.BackgroundColor3 = initialState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 205, 215)
    tBtn.AutoButtonColor = false
    tBtn.Text = ""
    tBtn.ZIndex = 16
    tBtn.Parent = f
    applyCorner(tBtn, 16)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 26, 0, 26)
    knob.Position = initialState and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 3, 0.5, -13)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 17
    knob.Parent = tBtn
    applyCorner(knob, 13)
    
    local state = initialState
    local function applyState(newState)
        state = newState
        local targetColor = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(220, 205, 215)
        local targetPos = state and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 3, 0.5, -13)

        TweenService:Create(tBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()

        callback(state)
        saveConfig()
    end

    tBtn.MouseButton1Click:Connect(function()
        applyState(not state)
    end)

    table.insert(allInteractiveElements, {ToggleBtn = tBtn, Knob = knob, GetState = function() return state end})
end

local function makeSlider(parent, textKey, defaultVal, minVal, maxVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 64)
    container.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
    container.BackgroundTransparency = 0.3
    container.ZIndex = 15
    container.Parent = parent
    applyCorner(container, 16)

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 210, 230)
    cStroke.Transparency = 0.6
    cStroke.Thickness = 1
    cStroke.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 0, 24)
    lbl.Position = UDim2.new(0, 18, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = t(textKey)
    lbl.TextColor3 = Color3.fromRGB(90, 70, 85)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = Config.MenuTextSize
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 16
    lbl.Parent = container
    table.insert(allInteractiveElements, {Obj = lbl, Key = textKey})

    local valBox = Instance.new("TextLabel")
    valBox.Size = UDim2.new(0, 70, 0, 24)
    valBox.Position = UDim2.new(1, -88, 0, 10)
    valBox.BackgroundTransparency = 1
    valBox.Text = tostring(defaultVal)
    valBox.TextColor3 = Color3.fromRGB(180, 50, 110)
    valBox.Font = Enum.Font.Code
    valBox.TextSize = Config.MenuTextSize
    valBox.TextXAlignment = Enum.TextXAlignment.Right
    valBox.ZIndex = 16
    valBox.Parent = container
    table.insert(allInteractiveElements, {ValBox = valBox})

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -36, 0, 8)
    sliderBg.Position = UDim2.new(0, 18, 0, 42)
    sliderBg.BackgroundColor3 = Color3.fromRGB(235, 215, 225)
    sliderBg.ZIndex = 16
    sliderBg.Parent = container
    applyCorner(sliderBg, 4)

    local sliderFill = Instance.new("Frame")
    local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    sliderFill.ZIndex = 17
    sliderFill.Parent = sliderBg
    applyCorner(sliderFill, 4)
    table.insert(allInteractiveElements, {SliderFill = sliderFill})

    local dragging = false
    local function update(inputPos)
        local rel = math.clamp((inputPos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * rel)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        valBox.Text = tostring(val)
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            saveConfig()
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            update(inp.Position.X)
        end
    end)
end

-- ==============================================================================
-- ⚡ 1. 自動掛機 (MainTab)
-- ==============================================================================
local liveStatusText = "🌸 狀態：待機中 (Standby)..."

makeToggle(mainPage, "AutoLaunch", Config.AutoLaunch, function(v)
    Config.AutoLaunch = v
    if not v then liveStatusText = "⏸️ 狀態：已暫停 (Paused)" end
end)

makeSlider(mainPage, "TargetPct", Config.TargetPercent, 50, 100, function(v)
    Config.TargetPercent = v
    saveConfig()
end)

makeSlider(mainPage, "ClickDelay", math.floor(Config.ClickDelay * 1000), 100, 1000, function(v)
    Config.ClickDelay = v / 1000
    saveConfig()
end)

makeToggle(mainPage, "AutoWalk", Config.AutoWalk, function(v)
    Config.AutoWalk = v
    if not v then
        pcall(function()
            lp.Character.Humanoid:Move(Vector3.new(0, 0, 0))
        end)
    end
end)

-- ==============================================================================
-- 🎒 2. 法寶檢測 (BagTab)
-- ==============================================================================
bagPage.CanvasSize = UDim2.new(0, 0, 0, 0)
bagPage.ScrollingEnabled = false

local bagTopBar = Instance.new("Frame")
bagTopBar.Size = UDim2.new(1, -6, 0, 46)
bagTopBar.Position = UDim2.new(0, 0, 0, 0)
bagTopBar.BackgroundTransparency = 1
bagTopBar.ZIndex = 15
bagTopBar.Parent = bagPage

local scanNowBtn = Instance.new("TextButton")
scanNowBtn.Size = UDim2.new(1, 0, 1, 0)
scanNowBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 230)
scanNowBtn.Text = t("ScanBagNow")
scanNowBtn.TextColor3 = Color3.fromRGB(160, 50, 100)
scanNowBtn.Font = Enum.Font.GothamBold
scanNowBtn.TextSize = Config.MenuTextSize
scanNowBtn.ZIndex = 16
scanNowBtn.Parent = bagTopBar
applyCorner(scanNowBtn, 16)
applyHoverEffect(scanNowBtn)
table.insert(allInteractiveElements, {Obj = scanNowBtn, Key = "ScanBagNow"})

local bagScroll = Instance.new("ScrollingFrame")
bagScroll.Size = UDim2.new(1, -6, 1, -126)
bagScroll.Position = UDim2.new(0, 0, 0, 54)
bagScroll.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
bagScroll.BackgroundTransparency = 0.4
bagScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
bagScroll.ScrollBarThickness = 4
bagScroll.ScrollBarImageColor3 = getAccentColor()
bagScroll.ZIndex = 15
bagScroll.Parent = bagPage
applyCorner(bagScroll, 16)

local bagListLayout = Instance.new("UIListLayout")
bagListLayout.SortOrder = Enum.SortOrder.LayoutOrder
bagListLayout.Padding = UDim.new(0, 6)
bagListLayout.Parent = bagScroll

local bagPadding = Instance.new("UIPadding")
bagPadding.PaddingTop = UDim.new(0, 8)
bagPadding.PaddingBottom = UDim.new(0, 8)
bagPadding.PaddingLeft = UDim.new(0, 8)
bagPadding.PaddingRight = UDim.new(0, 8)
bagPadding.Parent = bagScroll

local bagStatusLbl = Instance.new("TextLabel")
bagStatusLbl.Size = UDim2.new(1, -6, 0, 22)
bagStatusLbl.Position = UDim2.new(0, 4, 1, -66)
bagStatusLbl.BackgroundTransparency = 1
bagStatusLbl.Text = "💡 提示：請開啟法寶背包後點擊上方按鈕進行檢測"
bagStatusLbl.TextColor3 = Color3.fromRGB(150, 50, 100)
bagStatusLbl.Font = Enum.Font.Code
bagStatusLbl.TextSize = Config.MenuTextSize - 1
bagStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
bagStatusLbl.ZIndex = 15
bagStatusLbl.Parent = bagPage

local bagBottomBar = Instance.new("Frame")
bagBottomBar.Size = UDim2.new(1, -6, 0, 42)
bagBottomBar.Position = UDim2.new(0, 0, 1, -42)
bagBottomBar.BackgroundTransparency = 1
bagBottomBar.ZIndex = 15
bagBottomBar.Parent = bagPage

local selectAllBagBtn = Instance.new("TextButton")
selectAllBagBtn.Size = UDim2.new(0.48, 0, 1, 0)
selectAllBagBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 242)
selectAllBagBtn.Text = t("SelectAll")
selectAllBagBtn.TextColor3 = Color3.fromRGB(120, 80, 105)
selectAllBagBtn.Font = Enum.Font.GothamBold
selectAllBagBtn.TextSize = Config.MenuTextSize
selectAllBagBtn.ZIndex = 16
selectAllBagBtn.Parent = bagBottomBar
applyCorner(selectAllBagBtn, 16)
applyHoverEffect(selectAllBagBtn)
table.insert(allInteractiveElements, {Obj = selectAllBagBtn, Key = "SelectAll"})

local exportSelectedBtn = Instance.new("TextButton")
exportSelectedBtn.Size = UDim2.new(0.49, 0, 1, 0)
exportSelectedBtn.Position = UDim2.new(0.51, 0, 0, 0)
exportSelectedBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
exportSelectedBtn.Text = t("ExportSelected")
exportSelectedBtn.TextColor3 = Color3.new(1, 1, 1)
exportSelectedBtn.Font = Enum.Font.GothamBold
exportSelectedBtn.TextSize = Config.MenuTextSize
exportSelectedBtn.ZIndex = 16
exportSelectedBtn.Parent = bagBottomBar
applyCorner(exportSelectedBtn, 16)
applyHoverEffect(exportSelectedBtn)
table.insert(allInteractiveElements, {Obj = exportSelectedBtn, Key = "ExportSelected"})

local RarityStyles = {
    ["七彩"] = {Color = Color3.fromRGB(200, 50, 200), Icon = "✨"},
    ["金光"] = {Color = Color3.fromRGB(210, 160, 0), Icon = "👑"},
    ["神品"] = {Color = Color3.fromRGB(220, 80, 20), Icon = "🔥"},
    ["仙品"] = {Color = Color3.fromRGB(0, 160, 200), Icon = "💎"},
    ["靈品"] = {Color = Color3.fromRGB(40, 160, 90), Icon = "🍃"},
    ["凡品"] = {Color = Color3.fromRGB(120, 120, 130), Icon = "📦"}
}

local function getRarityStyle(text)
    for k, style in pairs(RarityStyles) do
        if text:find(k) then
            return style
        end
    end
    return {Color = Color3.fromRGB(100, 100, 120), Icon = "🔹"}
end

local selectedBagItems = {}
local bagCardRefs = {}
local bagRowButtons = {}

local function scanBagInventory()
    local foundCount = 0
    local currentSeen = {}

    pcall(function()
        for _, guiObj in ipairs(pg:GetDescendants()) do
            if guiObj and (guiObj:IsA("Frame") or guiObj:IsA("ScrollingFrame")) then
                local gName = guiObj.Name:lower()
                if (gName:find("bag") or gName:find("inventory") or gName:find("grid")) and guiObj.Visible then
                    for _, item in ipairs(guiObj:GetDescendants()) do
                        if item and item:IsA("Frame") and item.Visible and item.AbsoluteSize.X > 40 then
                            local texts = {}
                            for _, sub in ipairs(item:GetDescendants()) do
                                if sub and sub:IsA("TextLabel") and sub.Visible and sub.Text ~= "" then
                                    table.insert(texts, sub.Text)
                                end
                            end
                            if #texts > 0 then
                                local combined = table.concat(texts, " | ")
                                if not combined:find("法寶背包") and not combined:find("功法") and not combined:find("仙緣商城") and not combined:find("展示台") and not currentSeen[combined] then
                                    currentSeen[combined] = true
                                    foundCount = foundCount + 1

                                    if not bagCardRefs[combined] then
                                        bagCardRefs[combined] = item
                                        local style = getRarityStyle(combined)

                                        local rowBtn = Instance.new("TextButton")
                                        rowBtn.Size = UDim2.new(1, -6, 0, 40)
                                        rowBtn.BackgroundColor3 = Color3.fromRGB(255, 238, 245)
                                        rowBtn.Text = string.format("   [  ]  %s  %s", style.Icon, combined)
                                        rowBtn.TextColor3 = style.Color
                                        rowBtn.Font = Enum.Font.Code
                                        rowBtn.TextSize = Config.MenuTextSize - 1
                                        rowBtn.TextXAlignment = Enum.TextXAlignment.Left
                                        rowBtn.ZIndex = 16
                                        rowBtn.Parent = bagScroll
                                        applyCorner(rowBtn, 12)
                                        bagRowButtons[combined] = rowBtn

                                        rowBtn.MouseButton1Click:Connect(function()
                                            if selectedBagItems[combined] then
                                                selectedBagItems[combined] = nil
                                                rowBtn.BackgroundColor3 = Color3.fromRGB(255, 238, 245)
                                                rowBtn.Text = string.format("   [  ]  %s  %s", style.Icon, combined)
                                            else
                                                selectedBagItems[combined] = true
                                                rowBtn.BackgroundColor3 = Color3.fromRGB(255, 210, 230)
                                                rowBtn.Text = string.format("   [☑]  %s  %s", style.Icon, combined)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    for key, card in pairs(bagCardRefs) do
        if not currentSeen[key] or not card or not card.Parent then
            bagCardRefs[key] = nil
            selectedBagItems[key] = nil
            if bagRowButtons[key] then
                bagRowButtons[key]:Destroy()
                bagRowButtons[key] = nil
            end
        end
    end

    bagScroll.CanvasSize = UDim2.new(0, 0, 0, foundCount * 46 + 16)
    SessionStats.DetectedCount = foundCount
    if foundCount > 0 then
        bagStatusLbl.Text = string.format("✨ 檢測完成：成功識別 %d 件法寶！", foundCount)
    else
        bagStatusLbl.Text = "⚠️ 提示：未在畫面上偵測到法寶項目"
    end
end

scanNowBtn.MouseButton1Click:Connect(function()
    scanBagInventory()
end)

local isAllBagSelected = false
selectAllBagBtn.MouseButton1Click:Connect(function()
    isAllBagSelected = not isAllBagSelected
    for key, btn in pairs(bagRowButtons) do
        local style = getRarityStyle(key)
        if isAllBagSelected then
            selectedBagItems[key] = true
            btn.BackgroundColor3 = Color3.fromRGB(255, 210, 230)
            btn.Text = string.format("   [☑]  %s  %s", style.Icon, key)
        else
            selectedBagItems[key] = nil
            btn.BackgroundColor3 = Color3.fromRGB(255, 238, 245)
            btn.Text = string.format("   [  ]  %s  %s", style.Icon, key)
        end
    end
end)

exportSelectedBtn.MouseButton1Click:Connect(function()
    local count = 0
    local exportSummary = ""
    for key, _ in pairs(selectedBagItems) do
        count = count + 1
        exportSummary = exportSummary .. "- " .. key .. "\n"
    end
    if setclipboard and count > 0 then
        pcall(function() setclipboard(exportSummary) end)
        bagStatusLbl.Text = string.format("📋 已成功複製 %d 件法寶資訊至剪貼簿！", count)
    else
        bagStatusLbl.Text = "⚠️ 提示：未選取項目或剪貼簿無權限"
    end
end)

-- ==============================================================================
-- 📊 3. 運行日誌 (LogsTab)
-- ==============================================================================
local statsCard = Instance.new("Frame")
statsCard.Size = UDim2.new(1, -6, 0, 145)
statsCard.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
statsCard.BackgroundTransparency = 0.3
statsCard.ZIndex = 15
statsCard.Parent = logsPage
applyCorner(statsCard, 16)

local statsCardStroke = Instance.new("UIStroke")
statsCardStroke.Color = Color3.fromRGB(255, 210, 230)
statsCardStroke.Transparency = 0.6
statsCardStroke.Thickness = 1
statsCardStroke.Parent = statsCard

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -24, 0, 26)
statsTitle.Position = UDim2.new(0, 12, 0, 10)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "⏱️ 掛機運行計時與數據看板"
statsTitle.TextColor3 = Color3.fromRGB(180, 50, 110)
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = Config.MenuTextSize
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.ZIndex = 16
statsTitle.Parent = statsCard

local statsDetailText = Instance.new("TextLabel")
statsDetailText.Size = UDim2.new(1, -24, 1, -42)
statsDetailText.Position = UDim2.new(0, 12, 0, 38)
statsDetailText.BackgroundTransparency = 1
statsDetailText.Text = "🌸 計時與日誌載入中..."
statsDetailText.TextColor3 = Color3.fromRGB(90, 70, 85)
statsDetailText.Font = Enum.Font.Code
statsDetailText.TextSize = Config.MenuTextSize
statsDetailText.TextXAlignment = Enum.TextXAlignment.Left
statsDetailText.TextYAlignment = Enum.TextYAlignment.Top
statsDetailText.ZIndex = 16
statsDetailText.Parent = statsCard
table.insert(allInteractiveElements, {Obj = statsDetailText})

local resetStatsBtn = Instance.new("TextButton")
resetStatsBtn.Size = UDim2.new(1, -6, 0, 42)
resetStatsBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 242)
resetStatsBtn.Text = t("ResetStats")
resetStatsBtn.TextColor3 = Color3.fromRGB(120, 80, 105)
resetStatsBtn.Font = Enum.Font.GothamBold
resetStatsBtn.TextSize = Config.MenuTextSize
resetStatsBtn.ZIndex = 15
resetStatsBtn.Parent = logsPage
applyCorner(resetStatsBtn, 16)
applyHoverEffect(resetStatsBtn)
table.insert(allInteractiveElements, {Obj = resetStatsBtn, Key = "ResetStats"})

resetStatsBtn.MouseButton1Click:Connect(function()
    SessionStats.StartTime = tick()
    SessionStats.LaunchCount = 0
    SessionStats.DetectedCount = 0
end)

local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -6, 0, 135)
statusCard.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
statusCard.BackgroundTransparency = 0.3
statusCard.ZIndex = 15
statusCard.Parent = logsPage
applyCorner(statusCard, 16)

local statusCardStroke = Instance.new("UIStroke")
statusCardStroke.Color = Color3.fromRGB(255, 210, 230)
statusCardStroke.Transparency = 0.6
statusCardStroke.Thickness = 1
statusCardStroke.Parent = statusCard

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -24, 0, 26)
statusTitle.Position = UDim2.new(0, 12, 0, 10)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "🖥️ 系統即時監控狀態"
statusTitle.TextColor3 = Color3.fromRGB(180, 50, 110)
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextSize = Config.MenuTextSize
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.ZIndex = 16
statusTitle.Parent = statusCard

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -24, 1, -42)
statusText.Position = UDim2.new(0, 12, 0, 38)
statusText.BackgroundTransparency = 1
statusText.Text = "🔮 初始化中..."
statusText.TextColor3 = Color3.fromRGB(90, 70, 85)
statusText.Font = Enum.Font.Code
statusText.TextSize = Config.MenuTextSize
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.TextYAlignment = Enum.TextYAlignment.Top
statusText.ZIndex = 16
statusText.Parent = statusCard
table.insert(allInteractiveElements, {Obj = statusText})

-- ==============================================================================
-- ⚙️ 4. 參數設定 (CfgTab)
-- ==============================================================================
local cfgStatusLbl = Instance.new("TextLabel")
cfgStatusLbl.Size = UDim2.new(1, -6, 0, 24)
cfgStatusLbl.BackgroundTransparency = 1
cfgStatusLbl.Text = t("ConfigSavedMsg")
cfgStatusLbl.TextColor3 = Color3.fromRGB(180, 50, 110)
cfgStatusLbl.Font = Enum.Font.Code
cfgStatusLbl.TextSize = Config.MenuTextSize - 1
cfgStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
cfgStatusLbl.ZIndex = 15
cfgStatusLbl.Parent = cfgPage

local themeBtn
do
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -6, 0, 56)
    f.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
    f.BackgroundTransparency = 0.3
    f.ZIndex = 15
    f.Parent = cfgPage
    applyCorner(f, 16)
    
    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(255, 210, 230)
    fStroke.Transparency = 0.6
    fStroke.Thickness = 1
    fStroke.Parent = f

    local themeLbl = Instance.new("TextLabel")
    themeLbl.Size = UDim2.new(0.5, 0, 1, 0)
    themeLbl.Position = UDim2.new(0, 18, 0, 0)
    themeLbl.BackgroundTransparency = 1
    themeLbl.Text = t("AccentTheme")
    themeLbl.TextColor3 = Color3.fromRGB(90, 70, 85)
    themeLbl.Font = Enum.Font.GothamMedium
    themeLbl.TextSize = Config.MenuTextSize
    themeLbl.TextXAlignment = Enum.TextXAlignment.Left
    themeLbl.ZIndex = 16
    themeLbl.Parent = f
    table.insert(allInteractiveElements, {Obj = themeLbl, Key = "AccentTheme"})

    themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 190, 0, 34)
    themeBtn.Position = UDim2.new(1, -202, 0.5, -17)
    themeBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 242)
    themeBtn.Text = ThemeNames[currentThemeIndex]
    themeBtn.TextColor3 = Color3.fromRGB(180, 50, 110)
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.TextSize = Config.MenuTextSize
    themeBtn.ZIndex = 16
    themeBtn.Parent = f
    applyCorner(themeBtn, 12)
    applyHoverEffect(themeBtn)

    themeBtn.MouseButton1Click:Connect(function()
        currentThemeIndex = currentThemeIndex % #ThemeNames + 1
        themeBtn.Text = ThemeNames[currentThemeIndex]
        updateThemeStyle()
        saveConfig()
        cfgStatusLbl.Text = t("ConfigSavedMsg")
    end)
end

makeSlider(cfgPage, "FontSize", Config.MenuTextSize, 10, 22, function(v)
    Config.MenuTextSize = v
    for _, item in ipairs(allInteractiveElements) do
        if item.Obj then pcall(function() item.Obj.TextSize = v end) end
        if item.ValBox then pcall(function() item.ValBox.TextSize = v end) end
    end
    saveConfig()
end)

makeSlider(cfgPage, "MenuAlpha", Config.MenuBackgroundAlpha, 0, 80, function(v)
    Config.MenuBackgroundAlpha = v
    mainPanel.BackgroundTransparency = v / 100
    saveConfig()
end)

updateThemeStyle = function()
    local accCol = getAccentColor()
    glow.Color = accCol
    panelStroke.Color = accCol
    floatStroke.Color = accCol
    statusTitle.TextColor3 = accCol
    statsTitle.TextColor3 = accCol
    themeBtn.TextColor3 = accCol
    bagScroll.ScrollBarImageColor3 = accCol
    resizeHandle.TextColor3 = accCol

    for _, item in ipairs(allInteractiveElements) do
        if item.ValBox then item.ValBox.TextColor3 = accCol end
        if item.SliderFill then item.SliderFill.BackgroundColor3 = accCol end
    end
end

refreshLanguageText = function()
    for _, item in ipairs(navButtons) do
        item.Btn.Text = "   " .. t(item.Key)
    end
    for _, item in ipairs(allInteractiveElements) do
        if item.Key and item.Obj then
            item.Obj.Text = t(item.Key)
        end
        if item.ToggleBtn and item.GetState then
            item.ToggleBtn.Text = item.GetState() and t("On") or t("Off")
        end
    end
    cfgStatusLbl.Text = t("ConfigSavedMsg")
end

updateThemeStyle()

-- ==============================================================================
-- 【執行循環】
-- ==============================================================================
local function _Click()
    local _now = tick()
    local _randomCooldown = Config.ClickDelay + math.random(1, 15) / 100
    if _now - _LastTick < _randomCooldown then return end
    _LastTick = _now

    local _cam = workspace.CurrentCamera
    local _cx, _cy = _cam.ViewportSize.X / 2, _cam.ViewportSize.Y / 2

    pcall(function()
        if VirtualInputManager and VirtualInputManager.SendMouseButtonEvent then
            VirtualInputManager:SendMouseButtonEvent(_cx, _cy, 0, true, game, 1)
            task.wait(math.random(15, 30) / 1000)
            VirtualInputManager:SendMouseButtonEvent(_cx, _cy, 0, false, game, 1)
        elseif mouse1click then
            mouse1click()
        end
    end)
    SessionStats.LaunchCount = SessionStats.LaunchCount + 1
    liveStatusText = string.format("⚡ 狀態：已發射 [%d%%] (總計: %d次)", Config.TargetPercent, SessionStats.LaunchCount)
end

local function formatElapsedTime(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

RunService.RenderStepped:Connect(function()
    local elapsed = tick() - SessionStats.StartTime
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    statsDetailText.Text = string.format(
        "• ⏳ 累計掛機時長: %s\n• 🚀 自動發射總次數: %d 次\n• 💎 檢測法寶總數: %d 件",
        formatElapsedTime(elapsed),
        SessionStats.LaunchCount,
        SessionStats.DetectedCount
    )

    statusText.Text = string.format(
        "• 💻 執行環境: %s\n• 📶 網路延遲: %d ms\n• %s",
        getExecutorName(),
        ping,
        liveStatusText
    )

    pcall(function()
        if Config.AutoWalk then
            local _char = lp.Character
            local _hum = _char and _char:FindFirstChildOfClass("Humanoid")
            if _hum then
                local _cam = workspace.CurrentCamera
                local _look = _cam.CFrame.LookVector
                local _flatLook = Vector3.new(_look.X, 0, _look.Z).Unit
                _hum:Move(_flatLook, true)
            end
        end
    end)

    if not Config.AutoLaunch then return end

    pcall(function()
        local _mainUI = pg:FindFirstChild("MainUI")
        if not _mainUI then return end

        for _, _obj in ipairs(_mainUI:GetDescendants()) do
            if _obj:IsA("Frame") and _obj.Visible and _obj.AbsoluteSize.X > 160 then
                local _bar = _obj
                for _, _child in ipairs(_bar:GetChildren()) do
                    if _child:IsA("Frame") and _child.Visible and _child.AbsoluteSize.X < 50 and _child.AbsoluteSize.X > 5 then
                        local _barPos = _bar.AbsolutePosition.X
                        local _barSize = _bar.AbsoluteSize.X
                        local _sliderPos = _child.AbsolutePosition.X

                        local _pct = math.clamp(((_sliderPos - _barPos) / _barSize) * 100, 0, 100)
                        liveStatusText = string.format("📊 進度掃描: %.1f%% / 目標: %d%%", _pct, Config.TargetPercent)

                        if _pct >= Config.TargetPercent then
                            _Click()
                            return
                        end
                    end
                end
            end
        end
    end)
end)