--[[
══════════════════════════════════════════════════════════════
  ✨ LALOL OVERDRIVE V11 — SUPREME EDITION ✨
  Enhanced GUI · Live Feed · Stats · Speed Control · Hotkeys
  Animated · Draggable · Minimizable · Auto-Rescan
══════════════════════════════════════════════════════════════
]]

local UIS           = game:GetService("UserInputService")
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- ── Destroy Previous Instance ──────────────────────────────
local TAG = "LALOL_Overdrive_V11"
local old = PlayerGui:FindFirstChild(TAG)
if old then old:Destroy() end

-- ════════════════════════════════════════════════════════════
-- 🎨  GUI  CONSTRUCTION
-- ════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name               = TAG
ScreenGui.ResetOnSpawn        = false
ScreenGui.ZIndexBehavior      = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder        = 999
ScreenGui.Parent              = PlayerGui

local EXPANDED  = UDim2.new(0, 480, 0, 410)
local COLLAPSED = UDim2.new(0, 480, 0, 44)

-- Main Frame ------------------------------------------------
local Main = Instance.new("Frame", ScreenGui)
Main.Name                 = "Main"
Main.BackgroundColor3     = Color3.fromRGB(10, 3, 16)
Main.Size                 = UDim2.new(0, 480, 0, 0)          -- starts tiny for anim
Main.Position             = UDim2.new(0.5, -240, 0.5, -205)
Main.Active               = true
Main.ClipsDescendants     = true
Main.BackgroundTransparency = 1                                -- fades in
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainStroke      = Instance.new("UIStroke", Main)
MainStroke.Thickness  = 2.4
MainStroke.Color      = Color3.fromRGB(255, 0, 200)

-- Accent gradient bar (top) ---------------------------------
local AccentBar = Instance.new("Frame", Main)
AccentBar.Size            = UDim2.new(1, 0, 0, 3)
AccentBar.BorderSizePixel = 0
AccentBar.BackgroundColor3 = Color3.new(1,1,1)
local AccentGrad = Instance.new("UIGradient", AccentBar)
AccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 0, 200)),
})

-- Title bar -------------------------------------------------
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size                 = UDim2.new(1, 0, 0, 41)
TitleBar.Position             = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundTransparency = 1

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size                 = UDim2.new(1, -90, 1, 0)
TitleLabel.Position             = UDim2.new(0, 16, 0, 0)
TitleLabel.Text                 = "⚡ OVERDRIVE V11 — SUPREME"
TitleLabel.TextColor3           = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize             = 17
TitleLabel.Font                 = Enum.Font.GothamBold
TitleLabel.TextXAlignment       = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

-- helper: small title‑bar button
local function titleBtn(text, offset, color)
    local b = Instance.new("TextButton", TitleBar)
    b.Size              = UDim2.new(0, 28, 0, 28)
    b.Position           = UDim2.new(1, offset, 0.5, -14)
    b.Text               = text
    b.TextColor3         = color
    b.TextSize           = 15
    b.Font               = Enum.Font.GothamBold
    b.BackgroundColor3   = Color3.fromRGB(35, 15, 45)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end
local MinBtn   = titleBtn("—", -68, Color3.fromRGB(200,200,200))
local CloseBtn = titleBtn("✕", -34, Color3.fromRGB(255,100,100))

-- Separator helper
local function sep(yOff)
    local s = Instance.new("Frame", Main)
    s.Size              = UDim2.new(0.9, 0, 0, 1)
    s.Position           = UDim2.new(0.05, 0, 0, yOff)
    s.BackgroundColor3   = Color3.fromRGB(255, 0, 200)
    s.BackgroundTransparency = 0.6
    s.BorderSizePixel    = 0
    return s
end
sep(44)

-- ── Stats Row ──────────────────────────────────────────────
local StatsFrame = Instance.new("Frame", Main)
StatsFrame.Size                 = UDim2.new(0.9, 0, 0, 48)
StatsFrame.Position             = UDim2.new(0.05, 0, 0, 49)
StatsFrame.BackgroundTransparency = 1

local function statLabel(xScale, header, color)
    local l = Instance.new("TextLabel", StatsFrame)
    l.Size                 = UDim2.new(0.25, 0, 1, 0)
    l.Position             = UDim2.new(xScale, 0, 0, 0)
    l.Text                 = header .. "\n0"
    l.TextColor3           = color
    l.TextSize             = 13
    l.Font                 = Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    return l
end
local StatFound   = statLabel(0,    "FOUND",   Color3.fromRGB(0, 200, 255))
local StatFired   = statLabel(0.25, "FIRED",   Color3.fromRGB(255, 0, 200))
local StatErrors  = statLabel(0.50, "ERRORS",  Color3.fromRGB(255, 90, 90))
local StatUptime  = statLabel(0.75, "UPTIME",  Color3.fromRGB(180, 180, 180))

sep(100)

-- ── Toggle Button ──────────────────────────────────────────
local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size              = UDim2.new(0.9, 0, 0, 46)
ToggleBtn.Position          = UDim2.new(0.05, 0, 0, 106)
ToggleBtn.Text              = "⚡  SERVE : OFF"
ToggleBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize           = 21
ToggleBtn.Font               = Enum.Font.GothamBold
ToggleBtn.BackgroundColor3   = Color3.fromRGB(28, 8, 38)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
local ToggleStroke       = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness   = 1.6
ToggleStroke.Color       = Color3.fromRGB(70, 30, 90)

-- ── Speed Row ──────────────────────────────────────────────
local SpeedFrame = Instance.new("Frame", Main)
SpeedFrame.Size                 = UDim2.new(0.9, 0, 0, 30)
SpeedFrame.Position             = UDim2.new(0.05, 0, 0, 160)
SpeedFrame.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size                 = UDim2.new(0.22, 0, 1, 0)
SpeedLabel.Text                 = "SPEED:"
SpeedLabel.TextColor3           = Color3.fromRGB(160,160,160)
SpeedLabel.TextSize             = 13
SpeedLabel.Font                 = Enum.Font.GothamBold
SpeedLabel.TextXAlignment       = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1

local SPEEDS = {{"SLOW", 3.0}, {"MED", 1.5}, {"FAST", 0.5}, {"TURBO", 0.15}, {"MAX", 0.02}}
local speedBtns = {}
for i, spd in ipairs(SPEEDS) do
    local b = Instance.new("TextButton", SpeedFrame)
    b.Name              = "Spd_"..spd[1]
    b.Size              = UDim2.new(0.145, 0, 0.88, 0)
    b.Position           = UDim2.new(0.22 + (i-1)*0.155, 0, 0.06, 0)
    b.Text               = spd[1]
    b.TextColor3         = Color3.fromRGB(180,180,180)
    b.TextSize           = 11
    b.Font               = Enum.Font.GothamBold
    b.BackgroundColor3   = Color3.fromRGB(28, 8, 38)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    speedBtns[i] = b
end

-- ── Rescan Button ──────────────────────────────────────────
local RescanBtn = Instance.new("TextButton", Main)
RescanBtn.Size              = UDim2.new(0.9, 0, 0, 28)
RescanBtn.Position          = UDim2.new(0.05, 0, 0, 196)
RescanBtn.Text              = "🔄  RESCAN REMOTES"
RescanBtn.TextColor3        = Color3.fromRGB(0, 220, 180)
RescanBtn.TextSize           = 13
RescanBtn.Font               = Enum.Font.GothamBold
RescanBtn.BackgroundColor3   = Color3.fromRGB(20, 6, 30)
Instance.new("UICorner", RescanBtn).CornerRadius = UDim.new(0, 8)

sep(230)

-- ── Live Feed ──────────────────────────────────────────────
local FeedHeader = Instance.new("TextLabel", Main)
FeedHeader.Size                 = UDim2.new(0.5, 0, 0, 18)
FeedHeader.Position             = UDim2.new(0.05, 0, 0, 234)
FeedHeader.Text                 = "📡  LIVE FEED"
FeedHeader.TextColor3           = Color3.fromRGB(255, 200, 0)
FeedHeader.TextSize             = 12
FeedHeader.Font                 = Enum.Font.GothamBold
FeedHeader.TextXAlignment       = Enum.TextXAlignment.Left
FeedHeader.BackgroundTransparency = 1

local ClearLogBtn = Instance.new("TextButton", Main)
ClearLogBtn.Size              = UDim2.new(0.18, 0, 0, 18)
ClearLogBtn.Position          = UDim2.new(0.77, 0, 0, 234)
ClearLogBtn.Text              = "CLEAR"
ClearLogBtn.TextColor3        = Color3.fromRGB(150,150,150)
ClearLogBtn.TextSize           = 10
ClearLogBtn.Font               = Enum.Font.GothamBold
ClearLogBtn.BackgroundColor3   = Color3.fromRGB(25, 8, 35)
Instance.new("UICorner", ClearLogBtn).CornerRadius = UDim.new(0, 5)

local LogScroll = Instance.new("ScrollingFrame", Main)
LogScroll.Size                    = UDim2.new(0.9, 0, 0, 140)
LogScroll.Position                = UDim2.new(0.05, 0, 0, 256)
LogScroll.BackgroundColor3        = Color3.fromRGB(6, 1, 10)
LogScroll.BorderSizePixel         = 0
LogScroll.ScrollBarThickness      = 4
LogScroll.ScrollBarImageColor3    = Color3.fromRGB(255, 0, 200)
LogScroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
LogScroll.CanvasSize              = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollingDirection      = Enum.ScrollingDirection.Y
Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 8)
Instance.new("UIListLayout", LogScroll).Padding  = UDim.new(0, 1)

-- Hotkey hint
local HintLabel = Instance.new("TextLabel", Main)
HintLabel.Size                 = UDim2.new(1, 0, 0, 14)
HintLabel.Position             = UDim2.new(0, 0, 1, -14)
HintLabel.Text                 = "F6 Toggle  ·  F7 Rescan  ·  F8 Clear  ·  F9 Console"
HintLabel.TextColor3           = Color3.fromRGB(80, 80, 80)
HintLabel.TextSize             = 9
HintLabel.Font                 = Enum.Font.Code
HintLabel.BackgroundTransparency = 1

-- ════════════════════════════════════════════════════════════
-- 🖱️  DRAGGING  (works on desktop & mobile)
-- ════════════════════════════════════════════════════════════
do
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = Main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════
-- 🛡️  BLACKLIST  (keyword set for O(k) lookup per name)
-- ════════════════════════════════════════════════════════════
local BLACKLIST_KEYWORDS = {
    -- voice / social
    "updatecurrentcall","call","voice","rsvp","social","friend","invite","party",
    -- tutorials / sequences
    "tutorial","starttutorial","loading","intro","cutscene",
    -- progression / economy
    "rebirth","rebirthevent","purchase","buy","sell","trade","market","shop",
    "store","robux","premium","gamepass","devproduct","receipt",
    "leaderboard","rank","level","xp","exp","experience",
    -- timing / sync
    "timer","clock","time","sync","heartbeat","ping",
    -- physics exploits
    "stopfalling","stopfallingactive","velocity","noclip","fly","gravity","falling",
    -- security / anti‑cheat
    "kick","ban","admin","check","detect","anticheat","security","integrity",
    "processor","cmdr","dispatcher","log","report","analytics","telemetry",
    "verification","validate","authenticate","token","session",
    "punishment","moderate","filter","censor","whitelist","permission",
    -- data
    "save","load","data","datastore","database","profile",
    -- teleport / matchmaking
    "teleport","placeid","transfer","universe","jump","join","queue","arena","lobby",
    -- chat
    "chat","message","whisper","mute","block",
    -- crashes
    "crash","error","exception","debug","trace","stack",
}

local blSet = {}
for _, kw in ipairs(BLACKLIST_KEYWORDS) do blSet[kw] = true end

local function isBlacklisted(name)
    local low = string.lower(name)
    for kw in pairs(blSet) do
        if string.find(low, kw, 1, true) then return true end
    end
    return false
end

-- ════════════════════════════════════════════════════════════
-- 📂  SERVICES TO SCAN
-- ════════════════════════════════════════════════════════════
local scanServices = {}
for _, n in ipairs({
    "Workspace","Players","Lighting","MaterialService",
    "ReplicatedFirst","ReplicatedStorage","ServerScriptService",
    "ServerStorage","StarterGui","StarterPack","StarterPlayer",
    "Teams","SoundService","TextChatService",
}) do pcall(function() table.insert(scanServices, game:GetService(n)) end) end

-- ════════════════════════════════════════════════════════════
-- 🔧  STATE
-- ════════════════════════════════════════════════════════════
local autoFiring   = false
local targets      = {}
local firedCount   = 0
local errorCount   = 0
local loopDelay    = 1.5          -- current speed
local logCount     = 0
local MAX_LOG      = 120
local minimized    = false
local startTick    = 0            -- for uptime

-- ════════════════════════════════════════════════════════════
-- 📝  LOGGING
-- ════════════════════════════════════════════════════════════
local function addLog(text, color)
    color = color or Color3.fromRGB(170,170,170)
    logCount = logCount + 1

    -- prune oldest
    if logCount > MAX_LOG then
        for _, c in ipairs(LogScroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy(); logCount = logCount - 1; break end
        end
    end

    local e = Instance.new("TextLabel")
    e.Size                 = UDim2.new(1, -6, 0, 14)
    e.BackgroundTransparency = 1
    e.RichText             = true
    e.Text                 = '<font color="#666">' .. os.date("%H:%M:%S") .. '</font>  ' .. text
    e.TextColor3           = color
    e.TextSize             = 11
    e.Font                 = Enum.Font.Code
    e.TextXAlignment       = Enum.TextXAlignment.Left
    e.TextTruncate         = Enum.TextTruncate.AtEnd
    e.LayoutOrder          = logCount
    e.Parent               = LogScroll

    -- auto‑scroll
    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
    end)
end

local function clearLog()
    for _, c in ipairs(LogScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    logCount = 0
    addLog("Log cleared.", Color3.fromRGB(120,120,120))
end

-- ════════════════════════════════════════════════════════════
-- 📊  STATS UPDATE  (runs every 0.5 s)
-- ════════════════════════════════════════════════════════════
local function fmtUptime(s)
    local m = math.floor(s/60)
    local sec = math.floor(s%60)
    return string.format("%02d:%02d", m, sec)
end

task.spawn(function()
    while ScreenGui.Parent do
        StatFound.Text  = "FOUND\n"  .. #targets
        StatFired.Text  = "FIRED\n"  .. firedCount
        StatErrors.Text = "ERRORS\n" .. errorCount
        if autoFiring then
            StatUptime.Text = "UPTIME\n" .. fmtUptime(tick() - startTick)
        end
        task.wait(0.5)
    end
end)

-- ════════════════════════════════════════════════════════════
-- 🔍  SCANNER
-- ════════════════════════════════════════════════════════════
local function scan()
    table.clear(targets)
    local skipped = 0

    for _, svc in ipairs(scanServices) do
        pcall(function()
            for _, d in ipairs(svc:GetDescendants()) do
                if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                    if isBlacklisted(d.Name) then
                        skipped = skipped + 1
                    else
                        targets[#targets + 1] = d
                    end
                end
            end
        end)
    end

    addLog(
        string.format("Scan done — <b>%d</b> targets, %d blacklisted", #targets, skipped),
        Color3.fromRGB(0, 255, 140)
    )
    print(("✨ [OVERDRIVE] %d remotes found, %d skipped"):format(#targets, skipped))
end

-- ════════════════════════════════════════════════════════════
-- 🔄  TOGGLE HELPER
-- ════════════════════════════════════════════════════════════
local function setActive(state)
    autoFiring = state
    if autoFiring then
        startTick = tick()
        ToggleBtn.Text       = "⚡  SERVING TRUTH…"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 0, 200)
        ToggleStroke.Color   = Color3.fromRGB(255, 0, 200)
        addLog("ENGINE  ▶  STARTED", Color3.fromRGB(255, 200, 0))
        scan()
    else
        ToggleBtn.Text       = "⚡  SERVE : OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleStroke.Color   = Color3.fromRGB(70, 30, 90)
        StatUptime.Text      = "UPTIME\n--:--"
        addLog("ENGINE  ■  STOPPED", Color3.fromRGB(255, 200, 0))
    end
end

-- ════════════════════════════════════════════════════════════
-- ⚡  FIRING LOOP
-- ════════════════════════════════════════════════════════════
local PAYLOADS = {
    function() return {Target="All", State=math.huge, Overflow=true} end,
    function() return {Action="Execute", Value=math.random(1,999999), Tick=tick()} end,
    function() return "trigger", true, math.huge end,
    function() return {Mode="Global", Intensity=999999, Timestamp=os.clock()} end,
}

task.spawn(function()
    while ScreenGui.Parent do
        if autoFiring and #targets > 0 then
            -- Fisher‑Yates shuffle
            for i = #targets, 2, -1 do
                local j = math.random(i)
                targets[i], targets[j] = targets[j], targets[i]
            end

            for idx, remote in ipairs(targets) do
                if not autoFiring then break end
                if not (remote and remote.Parent) then continue end   -- pruned object

                local rName = remote.Name
                local payloadFn = PAYLOADS[math.random(#PAYLOADS)]

                task.spawn(function()
                    local ok, err = pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(payloadFn())
                        else
                            remote:InvokeServer(payloadFn())
                        end
                    end)

                    if ok then
                        firedCount = firedCount + 1
                        addLog("🔥  " .. rName, Color3.fromRGB(255, 0, 200))
                    else
                        errorCount = errorCount + 1
                        addLog(
                            "❌  " .. rName .. " — " .. tostring(err):sub(1, 50),
                            Color3.fromRGB(255, 80, 80)
                        )
                    end
                end)

                -- micro‑yield every few remotes to avoid throttle
                if idx % 5 == 0 then task.wait(0.06) end
            end
        end
        task.wait(loopDelay)
    end
end)

-- ════════════════════════════════════════════════════════════
-- 🎮  BUTTON HANDLERS
-- ════════════════════════════════════════════════════════════
ToggleBtn.MouseButton1Click:Connect(function() setActive(not autoFiring) end)

RescanBtn.MouseButton1Click:Connect(function()
    scan()
    -- quick flash effect
    TweenService:Create(RescanBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0,180,140)}):Play()
    task.delay(0.2, function()
        TweenService:Create(RescanBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20,6,30)}):Play()
    end)
end)

ClearLogBtn.MouseButton1Click:Connect(function() clearLog() end)

-- Speed buttons
local function highlightSpeed(activeIdx)
    for i, btn in ipairs(speedBtns) do
        if i == activeIdx then
            btn.BackgroundColor3 = Color3.fromRGB(90, 0, 130)
            btn.TextColor3       = Color3.fromRGB(255, 0, 200)
        else
            btn.BackgroundColor3 = Color3.fromRGB(28, 8, 38)
            btn.TextColor3       = Color3.fromRGB(180,180,180)
        end
    end
end

for i, spd in ipairs(SPEEDS) do
    speedBtns[i].MouseButton1Click:Connect(function()
        loopDelay = spd[2]
        highlightSpeed(i)
        addLog("Speed → " .. spd[1] .. "  (" .. spd[2] .. " s)", Color3.fromRGB(0, 200, 255))
    end)
end
highlightSpeed(2)  -- default = MED

-- Minimize / Expand
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local goal = minimized and COLLAPSED or EXPANDED
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = goal}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    autoFiring = false
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 480, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.3, function() ScreenGui:Destroy() end)
end)

-- ════════════════════════════════════════════════════════════
-- ⌨️  HOTKEYS
-- ════════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F6 then setActive(not autoFiring)
    elseif inp.KeyCode == Enum.KeyCode.F7 then scan()
    elseif inp.KeyCode == Enum.KeyCode.F8 then clearLog()
    end
end)

-- ════════════════════════════════════════════════════════════
-- 🌈  ANIMATIONS  (gradient scroll + active pulse)
-- ════════════════════════════════════════════════════════════
task.spawn(function()
    local off = 0
    while ScreenGui.Parent do
        off = (off + 0.004) % 1
        AccentGrad.Offset = Vector2.new(off, 0)

        if autoFiring then
            local p = math.abs(math.sin(tick() * 2.5))
            MainStroke.Color = Color3.fromRGB(255, math.floor(p * 120), math.floor(180 + p * 75))
        else
            MainStroke.Color = Color3.fromRGB(255, 0, 200)
        end
        RunService.Heartbeat:Wait()
    end
end)

-- ── Opening animation ──────────────────────────────────────
TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Back), {
    Size = EXPANDED,
    BackgroundTransparency = 0,
}):Play()

-- ════════════════════════════════════════════════════════════
-- 🎉  READY
-- ════════════════════════════════════════════════════════════
addLog("OVERDRIVE V11 SUPREME loaded ✨", Color3.fromRGB(255, 200, 0))
addLog("F6 Toggle · F7 Rescan · F8 Clear", Color3.fromRGB(120,120,120))
print("💖 Overdrive V11 Supreme is live — check F9 for logs 💖")
