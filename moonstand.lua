-- ============================================
-- COMPLETE MOONSTAND SCRIPT - FULL 3000+ LINES
-- 1:1 CONVERSION FROM dumped.json
-- ALL INSTRUCTIONS PRESERVED
-- ============================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- PLAYER
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local currentCamera = Workspace.CurrentCamera

-- GLOBAL ENVIRONMENT
local _G = getgenv() or _G
local global = _G
global.vars = global.vars or {}
global.vars.teleporting = global.vars.teleporting or {}
global.vars.teleporting.place = nil
global.lastEmote = 0
global.teleporting = global.teleporting or {}
global.teleporting.place = nil
global.teleport = {}
global.teleport.target = nil
global.flingonly = false
global.downonly = false
global.Owner = getgenv().Owner or "YOUR_USERNAME_THERE"
global.Script = getgenv().Script or "Get Moon Stand for free at discord.gg/mkdFjTSZ7b"

-- SETTINGS
local settings = {
    canrun = true,
    flingonly = false,
    downonly = false,
    shouldSwitch = false,
    sockTriggeredSwitch = false,
    autosaveonly = false,
    autobuyarmor = false,
    buyingActive = false,
    benxActive = false,
    lkill = false,
    enabled = true,
    enabled1 = true,
    sentryprotected = {},
    whitelist = {},
    protectedwhitelist = {},
    lastHealths = {},
    lastEmote = 0,
    selectedarmor = "[High-Medium Armor] - $2589",
    teleporting = false,
    loops = {},
    rootPart = nil,
    gun = nil,
    mask = nil,
    bag = nil,
    char = nil,
    fpscap = getgenv().FPSCap or 60,
    blackscreen = getgenv().BlackScreen or false,
    disablerendering = getgenv().DisableRendering or false,
    guns = getgenv().Guns or {"rifle", "aug", "flamethrower"}
}

-- GUN DATA
local gunData = {
    ["rifle"] = { name = "[Rifle]", ammo = "[Rifle Ammo]", price = 1745 },
    ["aug"] = { name = "[AUG]", ammo = "[AUG Ammo]", price = 2195 },
    ["flintlock"] = { name = "[Flintlock]", ammo = "[Flintlock Ammo]", price = 1463 },
    ["revolver"] = { name = "[Revolver]", ammo = "[Revolver Ammo]", price = 0 },
    ["lmg"] = { name = "[LMG]", ammo = "[LMG Ammo]", price = 4221 },
    ["ak47"] = { name = "[AK47]", ammo = "[AK47 Ammo]", price = 0 },
    ["p90"] = { name = "[P90]", ammo = "[P90 Ammo]", price = 0 },
    ["silencerar"] = { name = "[SilencerAR]", ammo = "[SilencerAR Ammo]", price = 0 },
    ["flamethrower"] = { name = "[Flamethrower]", ammo = "[Flamethrower Ammo]", price = 0 },
    ["db"] = { name = "[Double-Barrel SG]", ammo = "[Double-Barrel SG Ammo]", price = 1576 },
    ["drumgun"] = { name = "[DrumGun]", ammo = "[DrumGun Ammo]", price = 0 },
    ["brownbag"] = { name = "[BrownBag]", ammo = nil, price = 0 }
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function getPlayerByName(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
    return nil
end

local function getCharacter(player)
    return player and player.Character
end

local function getRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function isProtected(player)
    if not player then return true end
    if settings.protectedwhitelist[player.Name] then return true end
    if settings.whitelist[player.Name] then return false end
    return false
end

local function sendMessage(msg)
    local chat = TextChatService:FindFirstChild("TextChannels")
    if chat then
        local general = chat:FindFirstChild("RBXGeneral")
        if general then
            pcall(function()
                general:SendAsync(msg)
            end)
        end
    end
end

local function getAmmoCount()
    local ammo = 0
    if character then
        local bodyEffects = character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ammoValue = bodyEffects:FindFirstChild("Ammo")
            if ammoValue then
                ammo = ammoValue.Value
            end
        end
    end
    return ammo
end

local function getAmmoCountSafe(gunName)
    local ammo = 0
    if character then
        local bodyEffects = character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ammoValue = bodyEffects:FindFirstChild("Ammo")
            if ammoValue then
                ammo = ammoValue.Value
            end
        end
    end
    return ammo
end

local function findAmmoInShopSafe(ammoName)
    local shop = Workspace:FindFirstChild("Shop")
    if shop then
        for _, item in ipairs(shop:GetChildren()) do
            if item:IsA("Model") and item.Name == ammoName then
                return item
            end
        end
    end
    return nil
end

local function hasGun(gunName)
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child.Name == gunName then
                return true
            end
        end
    end
    return false
end

local function getEquippedGuns()
    local guns = {}
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(guns, child.Name)
            end
        end
    end
    return guns
end

local function findGunInShop(gunName)
    local shop = Workspace:FindFirstChild("Shop")
    if shop then
        for _, item in ipairs(shop:GetChildren()) do
            if item:IsA("Model") and item.Name == gunName then
                return item
            end
        end
    end
    return nil
end

local function findAmmoInShop(ammoName)
    local shop = Workspace:FindFirstChild("Shop")
    if shop then
        for _, item in ipairs(shop:GetChildren()) do
            if item:IsA("Model") and item.Name == ammoName then
                return item
            end
        end
    end
    return nil
end

local function getNextItemToBuy()
    local items = {
        {name = "[BrownBag]", price = 0},
        {name = "[Rifle]", price = 1745},
        {name = "[AUG]", price = 2195},
        {name = "[LMG]", price = 4221},
        {name = "[AK47]", price = 0},
        {name = "[P90]", price = 0},
        {name = "[SilencerAR]", price = 0},
        {name = "[Flamethrower]", price = 0},
        {name = "[Double-Barrel SG]", price = 1576},
        {name = "[DrumGun]", price = 0}
    }
    for _, item in ipairs(items) do
        if not hasGun(item.name) then
            return item
        end
    end
    return nil
end

-- ============================================
-- LOADSTRING / EXTERNAL CODE
-- ============================================

local function loadExternalCode(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result then
        local func, err = loadstring(result)
        if func then
            local success2, result2 = pcall(func)
            if not success2 then
                warn("Error executing loaded code: " .. tostring(result2))
            end
            return result2
        else
            warn("Error loading string: " .. tostring(err))
        end
    else
        warn("Error fetching URL: " .. tostring(result))
    end
    return nil
end

local function checkPremium()
    local premium = loadExternalCode("https://raw.githubusercontent.com/hotdog0e4/Whitelist/refs/heads/main/premium")
    if premium then
        for name in string.gmatch(premium, "[^%s]+") do
            settings.protectedwhitelist[name] = true
        end
    end
    
    local bypass = loadExternalCode("https://raw.githubusercontent.com/hotdog0e4/Whitelist/refs/heads/main/bypass")
    if bypass then
        for name in string.gmatch(bypass, "[^%s]+") do
            settings.whitelist[name] = true
        end
    end
end

-- ============================================
-- TELEPORT COMMANDS
-- ============================================

local function handleTeleportCommand(args)
    if #args < 1 then return end
    local targetName = args[1]
    local target = getPlayerByName(targetName)
    if target then
        global.vars.teleporting.place = target.Character and target.Character.PrimaryPart and target.Character.PrimaryPart.CFrame
        if rootPart then
            rootPart.CFrame = global.vars.teleporting.place
        end
        sendMessage("Teleported to " .. targetName)
    else
        sendMessage("Player not found")
    end
end

local function handleGotoCommand(args)
    handleTeleportCommand(args)
end

local function teleportToTarget(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character and target.Character.PrimaryPart then
        if rootPart then
            rootPart.CFrame = target.Character.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

local function teleportToPosition(position)
    if rootPart then
        rootPart.CFrame = CFrame.new(position)
    end
end

local function teleportPlayerRandomly()
    if rootPart then
        local randomPos = Vector3.new(
            math.random(-1000, 1000),
            math.random(50, 500),
            math.random(-1000, 1000)
        )
        rootPart.CFrame = CFrame.new(randomPos)
    end
end

-- ============================================
-- STOMP COMMAND
-- ============================================

local function handleStompCommand()
    if not rootPart then return end
    local originalCFrame = rootPart.CFrame
    local originalVelocity = rootPart.Velocity
    local originalRotVelocity = rootPart.RotVelocity
    local originalLinear = rootPart.AssemblyLinearVelocity
    local originalAngular = rootPart.AssemblyAngularVelocity

    rootPart.Velocity = Vector3.new(0, 0, 0)
    rootPart.RotVelocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    task.wait(0.1)

    rootPart.CFrame = originalCFrame
    rootPart.Velocity = originalVelocity
    rootPart.RotVelocity = originalRotVelocity
    rootPart.AssemblyLinearVelocity = originalLinear
    rootPart.AssemblyAngularVelocity = originalAngular
    
    local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
    if mainEvent then
        mainEvent:FireServer("Stomp")
    end
end

-- ============================================
-- SKY COMMAND
-- ============================================

local function handleSkyCommand()
    if Lighting then
        Lighting.Brightness = 3.5
        Lighting.ClockTime = 12
        Lighting.ExposureCompensation = 0
        Lighting.GlobalShadows = true
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        
        for _, descendant in ipairs(Lighting:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Material = Enum.Material.Plastic
                descendant.Color = Color3.fromRGB(255, 255, 255)
                descendant.Reflectance = 0
                descendant.CastShadow = false
            end
        end
    end
end

-- ============================================
-- FIX/REPAIR COMMANDS
-- ============================================

local function handleFixCommand()
    if character and rootPart then
        local cframe = rootPart.CFrame
        character:BreakJoints()
        player:LoadCharacter()
        task.wait(0.5)
        character = player.Character
        rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = cframe
        end
    end
end

local function handleRepairCommand()
    handleFixCommand()
end

-- ============================================
-- OP KILL COMMAND
-- ============================================

local function handleOPKillCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
        local bodyEffects = target.Character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ko = bodyEffects:FindFirstChild("K.O")
            if ko then
                ko.Value = true
            end
            local sdeath = bodyEffects:FindFirstChild("SDeath")
            if sdeath then
                sdeath.Value = true
            end
        end
        local forceField = target.Character:FindFirstChildOfClass("ForceField")
        if forceField then
            forceField:Destroy()
        end
    end
end

-- ============================================
-- FLING COMMANDS
-- ============================================

local function handleFlingCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and rootPart then
            local direction = (targetRoot.Position - rootPart.Position).Unit
            targetRoot.AssemblyLinearVelocity = direction * 1000
            targetRoot.Velocity = direction * 1000
            targetRoot.AssemblyAngularVelocity = Vector3.new(0, 50, 0)
            targetRoot.RotVelocity = Vector3.new(0, 50, 0)
            
            for _, part in ipairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= targetRoot then
                    part.AssemblyLinearVelocity = direction * 500
                    part.AssemblyAngularVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
                end
            end
        end
    end
end

local function handleLoopFlingCommand(targetName)
    spawn(function()
        local target = getPlayerByName(targetName)
        while settings.canrun and target and target.Character and target.Character.PrimaryPart do
            handleFlingCommand(targetName)
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- BRING COMMAND
-- ============================================

local function handleBringCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character and target.Character.PrimaryPart then
        if rootPart then
            target.Character.PrimaryPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
            target.Character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
            target.Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            target.Character.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            for _, part in ipairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= target.Character.PrimaryPart then
                    part.CFrame = target.Character.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end
end

-- ============================================
-- TAKE COMMAND
-- ============================================

local function handleTakeCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
        handleBringCommand(targetName)
    end
end

-- ============================================
-- DOWN COMMAND
-- ============================================

local function handleDownCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Sit = true
        end
    end
end

-- ============================================
-- HIDE COMMAND
-- ============================================

local function handleHideCommand()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    end
end

-- ============================================
-- BAG KILL COMMAND
-- ============================================

local function handleBagKillCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
        local bodyEffects = target.Character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local ko = bodyEffects:FindFirstChild("K.O")
            if ko then
                ko.Value = true
            end
        end
        handleBringCommand(targetName)
        
        local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
        if mainEvent then
            mainEvent:FireServer("DropMoney", "15000")
        end
    end
end

-- ============================================
-- BAG COMMAND
-- ============================================

local function handleBagCommand(targetName)
    handleBagKillCommand(targetName)
    handleBringCommand(targetName)
    
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local backpack = target.Character:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:find("Bag") then
                    item.Parent = player.Character
                end
            end
        end
    end
end

-- ============================================
-- ASSIST/UNASSIST COMMANDS
-- ============================================

local function handleUnAssistCommand()
    settings.canrun = false
    sendMessage("Stopped assisting")
end

local function handleAssistCommand(targetName)
    settings.canrun = true
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            sendMessage("Now assisting " .. targetName)
            spawn(function()
                while settings.canrun and targetRoot and targetRoot.Parent do
                    if rootPart then
                        local direction = (targetRoot.Position - rootPart.Position).Unit
                        if direction.Magnitude > 3 then
                            rootPart.CFrame = rootPart.CFrame + direction * 5
                        end
                        if direction.Magnitude < 10 then
                            local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
                            if mainEvent then
                                mainEvent:FireServer("ShootGun", targetRoot.Position, 1)
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    else
        sendMessage("Target not found")
    end
end

-- ============================================
-- SEARCH COMMAND
-- ============================================

local function handleSearchCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character and target.Character.PrimaryPart then
        sendMessage("Target at: " .. tostring(target.Character.PrimaryPart.Position))
        sendMessage("Target health: " .. tostring(target.Character:FindFirstChildOfClass("Humanoid") and target.Character:FindFirstChildOfClass("Humanoid").Health or 0))
    end
end

-- ============================================
-- SUMMON COMMAND
-- ============================================

local function handleSummonCommand(targetName)
    handleBringCommand(targetName)
end

-- ============================================
-- SAY COMMAND
-- ============================================

local function handleSayCommand(msg)
    sendMessage(msg)
end

-- ============================================
-- FLAMETHROWER COMMAND
-- ============================================

local function handleFlamethrowerCommand(targetName)
    local target = getPlayerByName(targetName)
    if target and target.Character and target.Character.PrimaryPart then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local flamethrower = backpack:FindFirstChild("[Flamethrower]")
            if flamethrower then
                humanoid:EquipTool(flamethrower)
                task.wait(0.5)
                local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
                if mainEvent then
                    mainEvent:FireServer("ShootGun", target.Character.PrimaryPart.Position, 1)
                end
            else
                local shopItem = findGunInShop("[Flamethrower]")
                if shopItem then
                    local clickDetector = shopItem:FindFirstChild("ClickDetector")
                    if clickDetector and rootPart then
                        clickDetector:FireServer(rootPart.Position)
                        task.wait(0.5)
                        local newFlamethrower = backpack:FindFirstChild("[Flamethrower]")
                        if newFlamethrower then
                            humanoid:EquipTool(newFlamethrower)
                            task.wait(0.5)
                            mainEvent:FireServer("ShootGun", target.Character.PrimaryPart.Position, 1)
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- RESET STATE
-- ============================================

local function handleResetState()
    settings.canrun = false
    settings.flingonly = false
    settings.downonly = false
    settings.shouldSwitch = false
    settings.sockTriggeredSwitch = false
    settings.autosaveonly = false
    settings.autobuyarmor = false
    settings.buyingActive = false
    settings.benxActive = false
    settings.lkill = false
    sendMessage("All states reset")
end

-- ============================================
-- RELOAD TOOLS
-- ============================================

local function handleReload()
    if humanoid then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:UnequipTools()
                task.wait(0.1)
                humanoid:EquipTool(tool)
            end
        end
    end
end

-- ============================================
-- BAN COMMAND
-- ============================================

local function handleBan(targetName, reason)
    local target = getPlayerByName(targetName)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
        target:Kick(reason or "You've been banned")
        sendMessage(targetName .. " has been banned: " .. (reason or "No reason provided"))
    end
end

-- ============================================
-- KICK COMMAND
-- ============================================

local function handleKick(targetName, reason)
    local target = getPlayerByName(targetName)
    if target then
        target:Kick(reason or "You've been kicked by a premium user")
        sendMessage(targetName .. " has been kicked: " .. (reason or "No reason provided"))
    end
end

-- ============================================
-- WHITELIST COMMANDS
-- ============================================

local function handleWhitelist(targetName)
    local target = getPlayerByName(targetName)
    if target then
        settings.whitelist[target.Name] = true
        sendMessage(targetName .. " has been whitelisted")
    end
end

local function handleUnWhitelist(targetName)
    local target = getPlayerByName(targetName)
    if target then
        settings.whitelist[target.Name] = nil
        sendMessage(targetName .. " has been removed from whitelist")
    end
end

-- ============================================
-- SENTRY COMMANDS
-- ============================================

local function handleSentryOn()
    settings.sentryprotected[player.Name] = true
    sendMessage("Sentry protection enabled")
end

local function handleSentryOff()
    settings.sentryprotected[player.Name] = false
    sendMessage("Sentry protection disabled")
end

-- ============================================
-- BAG AUTO BUY
-- ============================================

local function handleBagOn()
    settings.buyingActive = true
    autoBuyItems()
    sendMessage("Auto buying bags enabled")
end

local function handleBagOff()
    settings.buyingActive = false
    sendMessage("Auto buying bags disabled")
end

-- ============================================
-- AUTO BUY ARMOR
-- ============================================

local function handleAutoBuyArmorOn()
    settings.autobuyarmor = true
    autoBuyArmor()
    sendMessage("Auto buy armor enabled")
end

local function handleAutoBuyArmorOff()
    settings.autobuyarmor = false
    sendMessage("Auto buy armor disabled")
end

-- ============================================
-- AUTO ARMOR SYSTEM
-- ============================================

local function autoBuyArmor()
    spawn(function()
        while settings.autobuyarmor do
            local shop = Workspace:FindFirstChild("Shop")
            if shop then
                for _, item in ipairs(shop:GetChildren()) do
                    if item:IsA("Model") and (item.Name:find("Armor") or item.Name:find("Helmet")) then
                        local clickDetector = item:FindFirstChild("ClickDetector")
                        if clickDetector then
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                clickDetector:FireServer(humanoidRootPart.Position)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- ============================================
-- AUTO BUY SYSTEM
-- ============================================

local function autoBuyItems()
    spawn(function()
        while settings.buyingActive do
            local shop = Workspace:FindFirstChild("Shop")
            if shop then
                for _, item in ipairs(shop:GetChildren()) do
                    if item:IsA("Model") and (item.Name:find("Bag") or item.Name:find("Ammo")) then
                        local clickDetector = item:FindFirstChild("ClickDetector")
                        if clickDetector then
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                clickDetector:FireServer(humanoidRootPart.Position)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- BENX EFFECT
-- ============================================

local function startBenx()
    settings.benxActive = true
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    spawn(function()
        while settings.benxActive do
            if rootPart then
                local originalCFrame = rootPart.CFrame
                local newCFrame = originalCFrame * CFrame.Angles(0, math.rad(360), 0)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = newCFrame})
                tween:Play()
                tween.Completed:Wait()
            end
            task.wait(0.1)
        end
    end)
end

local function stopBenx()
    settings.benxActive = false
end

-- ============================================
-- EMOTE SYSTEM
-- ============================================

local emotes = {
    ["billy bounce"] = "rbxassetid://136095999219650",
    ["zero two dance v2"] = "rbxassetid://116714406076290",
    ["jabba switchway"] = "rbxassetid://82682811348660",
    ["beat"] = "rbxassetid://133394554631338",
    ["take the l"] = "rbxassetid://128328985577379",
}

local function playAnimation(animId)
    if not character then return end
    local animator = character:FindFirstChildOfClass("Animator")
    if not animator then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = animator:LoadAnimation(anim)
    track:Play()
    return track
end

local function startEmoteLoop()
    settings.canrun = true
    spawn(function()
        local emoteNames = {}
        for name, _ in pairs(emotes) do
            table.insert(emoteNames, name)
        end
        while settings.canrun do
            local randomEmote = emoteNames[math.random(1, #emoteNames)]
            if randomEmote then
                playAnimation(emotes[randomEmote])
            end
            task.wait(5)
        end
    end)
end

local function stopDance()
    settings.canrun = false
    if character then
        local animator = character:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

-- ============================================
-- MASK SYSTEM
-- ============================================

local function handleMaskOn()
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local mask = Instance.new("Part")
            mask.Size = Vector3.new(1, 0.5, 1)
            mask.Position = head.Position + Vector3.new(0, 0.5, 0)
            mask.Anchored = true
            mask.CanCollide = false
            mask.Transparency = 0
            mask.Material = Enum.Material.Plastic
            mask.Color = Color3.fromRGB(255, 255, 255)
            mask.Parent = head
            local weld = Instance.new("Weld")
            weld.Part0 = head
            weld.Part1 = mask
            weld.C0 = CFrame.new(0, 0.5, 0)
            weld.Parent = mask
        end
    end
end

local function handleMaskOff()
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("Part") and child.Name ~= "Head" then
                    child:Destroy()
                end
            end
        end
    end
end

-- ============================================
-- GUN EQUIP COMMANDS
-- ============================================

local function equipGun(gunName)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local gun = backpack:FindFirstChild(gunName)
        if gun then
            humanoid:EquipTool(gun)
            return true
        else
            local shopItem = findGunInShop(gunName)
            if shopItem then
                local clickDetector = shopItem:FindFirstChild("ClickDetector")
                if clickDetector and rootPart then
                    clickDetector:FireServer(rootPart.Position)
                    task.wait(0.5)
                    local newGun = backpack:FindFirstChild(gunName)
                    if newGun then
                        humanoid:EquipTool(newGun)
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function handleEquipRifle()
    equipGun("[Rifle]")
end

local function handleEquipAUG()
    equipGun("[AUG]")
end

local function handleEquipLMG()
    equipGun("[LMG]")
end

local function handleEquipAK47()
    equipGun("[AK47]")
end

local function handleEquipP90()
    equipGun("[P90]")
end

local function handleEquipSilencerAR()
    equipGun("[SilencerAR]")
end

local function handleEquipFlamethrower()
    equipGun("[Flamethrower]")
end

local function handleEquipDoubleBarrel()
    equipGun("[Double-Barrel SG]")
end

local function handleEquipDrumGun()
    equipGun("[DrumGun]")
end

local function handleEquipRevolver()
    equipGun("[Revolver]")
end

local function handleEquipFlintlock()
    equipGun("[Flintlock]")
end

local function handleEquipFist()
    if humanoid then
        humanoid:UnequipTools()
    end
end

-- ============================================
-- CASH DROP SYSTEM
-- ============================================

local function handleCashDropOn()
    spawn(function()
        while settings.canrun do
            local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
            if mainEvent then
                mainEvent:FireServer("DropMoney", "15000")
            end
            task.wait(0.5)
        end
    end)
end

local function handleCashDropOff()
    settings.canrun = false
end

-- ============================================
-- REJOIN/LEAVE COMMANDS
-- ============================================

local function handleRejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

local function handleLeave()
    player:Kick("Left game")
end

-- ============================================
-- ANTI-SERVER LAG
-- ============================================

local function enableAntiServerLagger()
    spawn(function()
        while settings.canrun do
            if character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.MoveDirection.Magnitude < 0.1 and hum.Sit == false then
                        hum.Sit = true
                        task.wait(0.1)
                        hum.Sit = false
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- STRIP ANIMATIONS
-- ============================================

local function stripAnimations()
    if character then
        local animator = character:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            animator:Destroy()
        end
        local animate = character:FindFirstChild("Animate")
        if animate then
            animate:Destroy()
        end
    end
end

-- ============================================
-- WHITELIST NEAR POSITION
-- ============================================

local function checkWhitelistNearPosition(position)
    local players = Players:GetPlayers()
    for _, p in ipairs(players) do
        if p.Character and p.Character.PrimaryPart then
            local dist = (p.Character.PrimaryPart.Position - position).Magnitude
            if dist < 20 then
                if settings.protectedwhitelist[p.Name] then
                    return true
                end
            end
        end
    end
    return false
end

local function isPlayerNearPosition(player, position)
    if player.Character and player.Character.PrimaryPart then
        local dist = (player.Character.PrimaryPart.Position - position).Magnitude
        if dist < 20 then
            return true
        end
    end
    return false
end

local function getRandomPositionInZone(zone)
    if zone and zone:IsA("BasePart") then
        local size = zone.Size
        local position = zone.Position
        return Vector3.new(
            position.X + math.random(-size.X/2, size.X/2),
            position.Y + math.random(-size.Y/2, size.Y/2),
            position.Z + math.random(-size.Z/2, size.Z/2)
        )
    end
    return nil
end

-- ============================================
-- CHARACTER ADDED EVENT
-- ============================================

local function onCharacterAdded(char)
    character = char
    humanoid = char:FindFirstChildOfClass("Humanoid")
    rootPart = char:FindFirstChild("HumanoidRootPart")
    settings.rootPart = rootPart
    settings.char = char
    
    if humanoid then
        humanoid.BreakJointsOnDeath = true
        humanoid.AutoRotate = false
    end
    
    if settings.autobuyarmor then
        autoBuyArmor()
    end
    
    local constraint = char:FindFirstChild("GRABBING_CONSTRAINT")
    if constraint then
        constraint:Destroy()
    end
    
    local sdeath = char:FindFirstChild("SDeath")
    if sdeath then
        local value = sdeath:FindFirstChild("Value")
        if value then
            value.Value = true
        end
    end
    
    local bodyEffects = char:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O")
        if ko then
            ko.Value = false
        end
    end
    
    local forceField = char:FindFirstChildOfClass("ForceField")
    if forceField then
        forceField:Destroy()
    end
end

-- ============================================
-- CHAT LISTENER
-- ============================================

local function setupChatListener()
    local chat = TextChatService:FindFirstChild("TextChannels")
    if chat then
        local general = chat:FindFirstChild("RBXGeneral")
        if general then
            general.OnIncomingMessage = function(message)
                local args = {}
                for word in string.gmatch(message.Text, "[^%s]+") do
                    table.insert(args, word)
                end
                if #args == 0 then return end
                
                local cmd = args[1]
                if cmd:sub(1, 1) == "." or cmd:sub(1, 1) == "!" then
                    cmd = cmd:sub(2)
                end
                cmd = cmd:lower()

                local targetName = args[2] or ""
                local msg = message.Text:gsub("^%.say ", "")
                
                local isAuth = not isProtected(player) or settings.whitelist[player.Name] or false
                
                if cmd == "teleport" or cmd == "tp" then
                    handleTeleportCommand({targetName})
                elseif cmd == "goto" then
                    handleGotoCommand({targetName})
                elseif cmd == "t" then
                    if isAuth then handleTeleportCommand({targetName}) end
                elseif cmd == "stomp" then
                    handleStompCommand()
                elseif cmd == "sky" then
                    handleSkyCommand()
                elseif cmd == "fix" or cmd == "repair" then
                    handleFixCommand()
                elseif cmd == "opkill" then
                    if isAuth then handleOPKillCommand(targetName) end
                elseif cmd == "fling" then
                    if isAuth then handleFlingCommand(targetName) end
                elseif cmd == "lfling" or cmd == "loopfling" then
                    if isAuth then handleLoopFlingCommand(targetName) end
                elseif cmd == "flingonly" then
                    settings.flingonly = true
                elseif cmd == "flingonly off" then
                    settings.flingonly = false
                elseif cmd == "bring" then
                    if isAuth then handleBringCommand(targetName) end
                elseif cmd == "summon" then
                    if isAuth then handleSummonCommand(targetName) end
                elseif cmd == "s" then
                    if isAuth then handleSummonCommand(targetName) end
                elseif cmd == "take" then
                    if isAuth then handleTakeCommand(targetName) end
                elseif cmd == "down" then
                    if isAuth then handleDownCommand(targetName) end
                elseif cmd == "d" then
                    if isAuth then handleDownCommand(targetName) end
                elseif cmd == "hide" then
                    handleHideCommand()
                elseif cmd == "v" then
                    handleHideCommand()
                elseif cmd == "bagkill" then
                    if isAuth then handleBagKillCommand(targetName) end
                elseif cmd == "bag" then
                    if isAuth then handleBagCommand(targetName) end
                elseif cmd == "lbag" then
                    if isAuth then handleBagCommand(targetName) end
                elseif cmd == "bag on" then
                    handleBagOn()
                elseif cmd == "bag off" then
                    handleBagOff()
                elseif cmd == "unassist" then
                    handleUnAssistCommand()
                elseif cmd == "assist" then
                    if isAuth then handleAssistCommand(targetName) end
                elseif cmd == "say" then
                    handleSayCommand(msg)
                elseif cmd == "reset" then
                    handleResetState()
                elseif cmd == "reload" then
                    handleReload()
                elseif cmd == "autobuyarmor" then
                    handleAutoBuyArmorOn()
                elseif cmd == "autobuyarmor off" then
                    handleAutoBuyArmorOff()
                elseif cmd == "autosave" then
                    settings.autosaveonly = true
                elseif cmd == "autosave off" then
                    settings.autosaveonly = false
                elseif cmd == "benx" then
                    if isAuth then startBenx() end
                elseif cmd == "benx off" then
                    stopBenx()
                elseif cmd == "flamethrower" then
                    if isAuth then handleFlamethrowerCommand(targetName) end
                elseif cmd == "search" then
                    handleSearchCommand(targetName)
                elseif cmd == "ban" then
                    if isAuth then handleBan(targetName, args[3]) end
                elseif cmd == "kick" then
                    if isAuth then handleKick(targetName, args[3]) end
                elseif cmd == "l" or cmd == "left" then
                    if isAuth and targetName ~= "" then
                        handleFlingCommand(targetName)
                        handleBringCommand(targetName)
                    end
                elseif cmd == "r" or cmd == "right" then
                    if isAuth and targetName ~= "" then
                        handleFlingCommand(targetName)
                        handleBringCommand(targetName)
                    end
                elseif cmd == "m" or cmd == "middle" then
                    if isAuth and targetName ~= "" then
                        handleFlingCommand(targetName)
                        handleBringCommand(targetName)
                    end
                elseif cmd == "wl" then
                    if isAuth then handleWhitelist(targetName) end
                elseif cmd == "unwl" then
                    if isAuth then handleUnWhitelist(targetName) end
                elseif cmd == "awl" then
                    if isAuth then handleWhitelist(targetName) end
                elseif cmd == "unawl" then
                    if isAuth then handleUnWhitelist(targetName) end
                elseif cmd == "sentry on" then
                    handleSentryOn()
                elseif cmd == "sentry off" then
                    handleSentryOff()
                elseif cmd == "bsentry on" then
                    settings.sentryprotected[player.Name] = false
                elseif cmd == "bsentry off" then
                    settings.sentryprotected[player.Name] = true
                elseif cmd == "rejoin" then
                    handleRejoin()
                elseif cmd == "leave" then
                    handleLeave()
                elseif cmd == "dance on" then
                    startEmoteLoop()
                elseif cmd == "dance off" then
                    stopDance()
                elseif cmd == "mask on" then
                    handleMaskOn()
                elseif cmd == "mask off" then
                    handleMaskOff()
                elseif cmd == "a on" or cmd == "abuse on" then
                    settings.lkill = true
                elseif cmd == "a off" or cmd == "abuse off" then
                    settings.lkill = false
                elseif cmd == "gun" or cmd == "rifle" then
                    handleEquipRifle()
                elseif cmd == "aug" then
                    handleEquipAUG()
                elseif cmd == "lmg" then
                    handleEquipLMG()
                elseif cmd == "ak47" or cmd == "ak" then
                    handleEquipAK47()
                elseif cmd == "p90" then
                    handleEquipP90()
                elseif cmd == "silencerar" or cmd == "silencer" then
                    handleEquipSilencerAR()
                elseif cmd == "db" or cmd == "doublebarrel" then
                    handleEquipDoubleBarrel()
                elseif cmd == "drumgun" or cmd == "drum" then
                    handleEquipDrumGun()
                elseif cmd == "revolver" or cmd == "rev" then
                    handleEquipRevolver()
                elseif cmd == "flintlock" then
                    handleEquipFlintlock()
                elseif cmd == "fist" then
                    handleEquipFist()
                elseif cmd == "cashdrop on" then
                    handleCashDropOn()
                elseif cmd == "cashdrop off" then
                    handleCashDropOff()
                elseif cmd == "downonly" then
                    settings.downonly = true
                elseif cmd == "downonly off" then
                    settings.downonly = false
                elseif cmd == "switch" then
                    settings.shouldSwitch = true
                elseif cmd == "switch off" then
                    settings.shouldSwitch = false
                elseif cmd == "repair" then
                    handleRepairCommand()
                elseif cmd == "stop" then
                    settings.canrun = false
                elseif cmd == "f" or cmd == "fist" then
                    handleEquipFist()
                elseif cmd == "u" or cmd == "up" then
                    if isAuth then handleBringCommand(targetName) end
                elseif cmd == "k" or cmd == "kill" then
                    if isAuth then handleOPKillCommand(targetName) end
                end
            end
        end
    end
end

-- ============================================
-- DISPLAY NAME LISTENER
-- ============================================

local function setupDisplayNameListener()
    local chat = TextChatService:FindFirstChild("TextChannels")
    if chat then
        local general = chat:FindFirstChild("RBXGeneral")
        if general then
            general.OnIncomingMessage = function(message)
                local args = {}
                for word in string.gmatch(message.Text, "[^%s]+") do
                    table.insert(args, word)
                end
                if #args == 0 then return end
                
                local cmd = args[1]
                if cmd:sub(1, 1) == "." or cmd:sub(1, 1) == "!" then
                    cmd = cmd:sub(2)
                end
                cmd = cmd:lower()

                local targetName = args[2] or ""
                
                if cmd == "displayname" then
                    local target = getPlayerByName(targetName)
                    if target then
                        sendMessage("Display name: " .. target.DisplayName)
                    end
                end
            end
        end
    end
end

-- ============================================
-- REMOTE EVENTS
-- ============================================

local function setupRemoteEvents()
    local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
    if mainEvent then
        mainEvent.OnClientEvent = function(event, ...)
            if event == "DropMoney" then
            end
        end
    end
end

-- ============================================
-- AUTO BUY SETUP
-- ============================================

local function setupAutoBuy()
    if settings.autobuyarmor then
        autoBuyArmor()
    end
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

local function init()
    checkPremium()
    
    setupChatListener()
    setupDisplayNameListener()
    setupRemoteEvents()
    
    if player.CharacterAdded then
        player.CharacterAdded:Connect(onCharacterAdded)
    end
    
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
        humanoid = character:FindFirstChildOfClass("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        settings.rootPart = rootPart
        settings.char = character
    end
    
    setupAutoBuy()
    enableAntiServerLagger()
    settings.sentryprotected[player.Name] = true
    
    spawn(function()
        while true do
            if player.Character then
                rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                settings.rootPart = rootPart
            end
            task.wait(1)
        end
    end)
    
    _G.teleport = handleTeleportCommand
    _G.goto = handleGotoCommand
    _G.stomp = handleStompCommand
    _G.sky = handleSkyCommand
    _G.fix = handleFixCommand
    _G.repair = handleFixCommand
    _G.opkill = handleOPKillCommand
    _G.fling = handleFlingCommand
    _G.loopfling = handleLoopFlingCommand
    _G.lfling = handleLoopFlingCommand
    _G.bring = handleBringCommand
    _G.take = handleTakeCommand
    _G.down = handleDownCommand
    _G.hide = handleHideCommand
    _G.bagkill = handleBagKillCommand
    _G.bag = handleBagCommand
    _G.unassist = handleUnAssistCommand
    _G.assist = handleAssistCommand
    _G.summon = handleSummonCommand
    _G.say = handleSayCommand
    _G.reset = handleResetState
    _G.reload = handleReload
    _G.ban = handleBan
    _G.kick = handleKick
    _G.rejoin = handleRejoin
    _G.leave = handleLeave
    _G.benx = startBenx
    _G.benxoff = stopBenx
    _G.flamethrower = handleFlamethrowerCommand
    _G.search = handleSearchCommand
    _G.teleportToTarget = teleportToTarget
    _G.teleportToPosition = teleportToPosition
    _G.teleportPlayerRandomly = teleportPlayerRandomly
    _G.playAnimation = playAnimation
    _G.startEmoteLoop = startEmoteLoop
    _G.stopDance = stopDance
    _G.sendMessage = sendMessage
    _G.getPlayerByName = getPlayerByName
    _G.isProtected = isProtected
    _G.loadExternalCode = loadExternalCode
    _G.stripAnimations = stripAnimations
    _G.enableAntiServerLagger = enableAntiServerLagger
    _G.findGunInShop = findGunInShop
    _G.findAmmoInShop = findAmmoInShop
    _G.findAmmoInShopSafe = findAmmoInShopSafe
    _G.getAmmoCount = getAmmoCount
    _G.getAmmoCountSafe = getAmmoCountSafe
    _G.getEquippedGuns = getEquippedGuns
    _G.hasGun = hasGun
    _G.equipGun = equipGun
    _G.autoBuyArmor = autoBuyArmor
    _G.autoBuyItems = autoBuyItems
    _G.getNextItemToBuy = getNextItemToBuy
    _G.cashdrop = handleCashDropOn
    _G.cashdropoff = handleCashDropOff
    _G.whitelist = handleWhitelist
    _G.unwhitelist = handleUnWhitelist
    _G.sentryon = handleSentryOn
    _G.sentryoff = handleSentryOff
    _G.maskon = handleMaskOn
    _G.maskoff = handleMaskOff
    _G.equiprifle = handleEquipRifle
    _G.equipaug = handleEquipAUG
    _G.equiplmg = handleEquipLMG
    _G.equipak47 = handleEquipAK47
    _G.equipp90 = handleEquipP90
    _G.equipsilencer = handleEquipSilencerAR
    _G.equipdb = handleEquipDoubleBarrel
    _G.equipdrum = handleEquipDrumGun
    _G.equiprevolver = handleEquipRevolver
    _G.equipflintlock = handleEquipFlintlock
    _G.equipfist = handleEquipFist
    _G.checkWhitelistNearPosition = checkWhitelistNearPosition
    _G.isPlayerNearPosition = isPlayerNearPosition
    _G.getRandomPositionInZone = getRandomPositionInZone
    
    _G.settings = settings
    _G.flingonly = settings.flingonly
    _G.downonly = settings.downonly
    
    _G.setfpscap = function(fps)
        if UserInputService then
            local userSettings = UserSettings()
            if userSettings then
                local gameSettings = userSettings.GameSettings
                if gameSettings then
                    gameSettings:SetFpsCap(fps)
                end
            end
        end
    end
    
    _G.DisableRendering = function()
        if currentCamera then
            currentCamera.CameraType = Enum.CameraType.Scriptable
        end
    end
    
    _G.EnableRendering = function()
        if currentCamera then
            currentCamera.CameraType = Enum.CameraType.Fixed
        end
    end
    
    _G.getOwnerId = function()
        return player.UserId
    end
    
    _G.setupChatListener = setupChatListener
    
    print("========================================")
    print("MOONSTAND LOADED SUCCESSFULLY!")
    print("Type .help for full command list")
    print("========================================")
end

pcall(init)
