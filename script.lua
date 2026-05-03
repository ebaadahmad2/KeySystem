-- Author: Ebaad

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "ebaadahmad2",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Ebaad Hub"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local BLUE_COLOR = Color3.fromRGB(0, 150, 255)
local BG_COLOR = Color3.fromRGB(20, 20, 20)

local State = {
    Aimbot = false,
    ESP = false,
    Fly = false,
    Noclip = false,
    Target = nil
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "EBAAD HUB"
Title.TextColor3 = BLUE_COLOR
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- Helper for Buttons
local function createBtn(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    -- Offset position to account for title
    btn.Position = UDim2.new(0.05, 0, 0, #MainFrame:GetChildren() * 45 - 20)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Toggles
createBtn("Aimbot (B)", function() State.Aimbot = not State.Aimbot end)
createBtn("ESP (E)", function() State.ESP = not State.ESP end)
createBtn("Fly (F)", function() State.Fly = not State.Fly end)
createBtn("Noclip (N)", function() State.Noclip = not State.Noclip end)

-- Fly Controls
local FlyVelocity = Vector3.new(0,0,0)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then FlyVelocity = Vector3.new(0, 50, 0) end
    if input.KeyCode == Enum.KeyCode.LeftShift then FlyVelocity = Vector3.new(0, -50, 0) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then FlyVelocity = Vector3.new(0, 0, 0) end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Aimbot (Sticky)
    if State.Aimbot then
        if not State.Target or not State.Target.Character or not State.Target.Character:FindFirstChild("Head") then
            local closest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if d < dist then dist = d; closest = p end
                    end
                end
            end
            State.Target = closest
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, State.Target.Character.Head.Position)
        end
    else
        State.Target = nil
    end

    -- Fly
    if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = FlyVelocity + (Camera.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and 50 or 0))
    end

    -- Noclip
    if State.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ESP (Drawing Library)
local espBoxes = {}
RunService.RenderStepped:Connect(function()
    if State.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    if not espBoxes[p.Name] then
                        espBoxes[p.Name] = Drawing.new("Square")
                        espBoxes[p.Name].Color = BLUE_COLOR
                        espBoxes[p.Name].Thickness = 2
                    end
                    espBoxes[p.Name].Visible = true
                    espBoxes[p.Name].Size = Vector2.new(50, 50)
                    espBoxes[p.Name].Position = Vector2.new(pos.X - 25, pos.Y - 25)
                else
                    if espBoxes[p.Name] then espBoxes[p.Name].Visible = false end
                end
            end
        end
    else
        for _, box in pairs(espBoxes) do box.Visible = false end
    end
end)

-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")
