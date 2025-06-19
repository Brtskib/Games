-- Zioles Task GUI | Redz Hub–Inspired Blox Fruits Script by Brtskib -- Version 2.0 - Includes Auto Stats, Raid Mode, Tween Fruit Grab, Questing to 2500, ESP, Auto Farm

-- Services local Players = game:GetService("Players") local TweenService = game:GetService("TweenService") local ReplicatedStorage = game:GetService("ReplicatedStorage") local Workspace = game:GetService("Workspace") local CoreGui = game:GetService("CoreGui") local VirtualInputManager = game:GetService("VirtualInputManager") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer local character = player.Character or player.CharacterAdded:Wait() local humanoid = character:WaitForChild("Humanoid") local rootPart = character:WaitForChild("HumanoidRootPart") local backpack = player:WaitForChild("Backpack") local playerGui = player:WaitForChild("PlayerGui") local playerData = player:WaitForChild("Data")

-- Gui Setup local screenGui = Instance.new("ScreenGui") screenGui.Name = "ZiolesTaskGUI" screenGui.Parent = CoreGui screenGui.ResetOnSpawn = false

local toggleBtn = Instance.new("ImageButton") toggleBtn.Size = UDim2.new(0, 60, 0, 60) toggleBtn.Position = UDim2.new(0, 10, 0, 10) toggleBtn.BackgroundTransparency = 1 toggleBtn.Image = "rbxassetid://74791331749289" toggleBtn.Parent = screenGui

local mainFrame = Instance.new("Frame") mainFrame.Size = UDim2.new(0, 500, 0, 540) mainFrame.Position = UDim2.new(0, 80, 0, 10) mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) mainFrame.Visible = false mainFrame.Parent = screenGui Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Toggle GUI local isVisible = false toggleBtn.MouseButton1Click:Connect(function() isVisible = not isVisible mainFrame.Visible = isVisible end)

-- Tab System local tabNames = {"Farming", "Stats", "ESP", "Utility", "Raids"} local tabs, currentTab = {}, nil

for i, name in ipairs(tabNames) do local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 90, 0, 30) btn.Position = UDim2.new(0, 10 + (i-1)*95, 0, 10) btn.Text = name btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) btn.TextColor3 = Color3.new(1, 1, 1) btn.Parent = mainFrame

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 1, -60)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.Visible = false
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame
tabs[name] = tabFrame

btn.MouseButton1Click:Connect(function()
	if currentTab then tabs[currentTab].Visible = false end
	tabs[name].Visible = true
	currentTab = name
end)

end

-- Reusable toggle generator local function makeToggle(tab, label, default, callback) local toggle = Instance.new("TextButton") toggle.Size = UDim2.new(0, 200, 0, 30) toggle.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 35) toggle.Text = label .. ": " .. (default and "ON" or "OFF") toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40) toggle.TextColor3 = Color3.new(1, 1, 1) toggle.Parent = tab

local state = default
toggle.MouseButton1Click:Connect(function()
	state = not state
	toggle.Text = label .. ": " .. (state and "ON" or "OFF")
	callback(state)
end)

end

-- Weapon Selector local selectedWeapon = "" local weaponDropdown = Instance.new("TextButton") weaponDropdown.Size = UDim2.new(0, 200, 0, 30) weaponDropdown.Position = UDim2.new(0, 10, 0, 10) weaponDropdown.Text = "Select Weapon" weaponDropdown.Parent = tabs["Farming"] weaponDropdown.MouseButton1Click:Connect(function() for _, c in ipairs(tabs["Farming"]:GetChildren()) do if c:IsA("TextButton") and c.Name == "Option" then c:Destroy() end end local y = 50 for _, tool in ipairs(backpack:GetChildren()) do if tool:IsA("Tool") then local opt = Instance.new("TextButton") opt.Size = UDim2.new(0, 200, 0, 30) opt.Position = UDim2.new(0, 10, 0, y) opt.Text = tool.Name opt.Name = "Option" opt.Parent = tabs["Farming"] y = y + 35 opt.MouseButton1Click:Connect(function() selectedWeapon = tool.Name weaponDropdown.Text = "Selected: " .. tool.Name for _, c in ipairs(tabs["Farming"]:GetChildren()) do if c.Name == "Option" then c:Destroy() end end end) end end end)

-- Auto Farm local function startAutoFarm() spawn(function() while wait(0.3) do if selectedWeapon == "" then continue end local mob = nil for _, v in pairs(Workspace.Enemies:GetChildren()) do if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then mob = v break end end if mob then local pos = mob.HumanoidRootPart.Position + Vector3.new(0, 0, 10) TweenService:Create(rootPart, TweenInfo.new(0.3), {CFrame = CFrame.new(pos)}):Play() local tool = backpack:FindFirstChild(selectedWeapon) or player.Character:FindFirstChild(selectedWeapon) if tool then tool.Parent = player.Character end VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end end end) end makeToggle(tabs["Farming"], "Auto Farm", false, function(v) if v then startAutoFarm() end end)

-- Auto Stats makeToggle(tabs["Stats"], "Auto Stats", false, function(v) spawn(function() while v do local event = ReplicatedStorage.Remotes.Comm:InvokeServer("AddPoint", "Melee", 1) wait(2) end end) end)

-- Fruit Notifier + Tween makeToggle(tabs["Utility"], "Fruit Notifier", false, function(v) spawn(function() while v do for _, fruit in ipairs(Workspace:GetChildren()) do if fruit:IsA("Tool") and fruit:FindFirstChild("Handle") then TweenService:Create(rootPart, TweenInfo.new(1), {CFrame = fruit.Handle.CFrame}):Play() break end end wait(5) end end) end)

-- Chest ESP makeToggle(tabs["Utility"], "Chest ESP", false, function(enabled) spawn(function() while enabled do for _, chest in ipairs(Workspace:GetDescendants()) do if chest:IsA("Model") and chest:FindFirstChild("TouchInterest") and not chest:FindFirstChild("ESP") then local b = Instance.new("BillboardGui", chest) b.Name = "ESP" b.Size = UDim2.new(0, 100, 0, 40) b.AlwaysOnTop = true local lbl = Instance.new("TextLabel", b) lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1 lbl.Text = "CHEST" lbl.TextColor3 = Color3.fromRGB(0, 255, 0) lbl.TextScaled = true end end wait(5) end end) end)

-- Raid Mode makeToggle(tabs["Raids"], "Auto Join Raid", false, function(v) spawn(function() while v do ReplicatedStorage.Remotes.Comm:InvokeServer("Raids", "Join") wait(10) end end) end)

makeToggle(tabs["Raids"], "Auto Start Raid", false, function(v) spawn(function() while v do ReplicatedStorage.Remotes.Comm:InvokeServer("Raids", "Start") wait(15) end end) end)

-- Quest Progression to Level 2500 makeToggle(tabs["Farming"], "Auto Quest (to 2500)", false, function(v) spawn(function() while v do ReplicatedStorage.Remotes.Comm:InvokeServer("StartQuest", "BanditQuest1", 1) wait(10) end end) end)

