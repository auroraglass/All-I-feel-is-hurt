local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Aimbot = {
    Enabled = false,
    FOVRadius = 150, -- Default FOV radius in pixels
    TeamCheck = true,
    TargetPart = "Head", -- Can be "Head" or "HumanoidRootPart"
    Smoothing = 0.1, -- Lower is snappier, higher is smoother. 0 is instant lock.
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Awesome Aimbot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18.000

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16.000

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Name = "FOVLabel"
FOVLabel.Parent = MainFrame
FOVLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FOVLabel.BorderSizePixel = 0
FOVLabel.Position = UDim2.new(0, 10, 0, 80)
FOVLabel.Size = UDim2.new(0, 100, 0, 20)
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.Text = "FOV Radius: " .. Aimbot.FOVRadius
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 14.000

local FOVSlider = Instance.new("TextButton")
FOVSlider.Name = "FOVSlider"
FOVSlider.Parent = MainFrame
FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVSlider.BorderSizePixel = 0
FOVSlider.Position = UDim2.new(0, 10, 0, 100)
FOVSlider.Size = UDim2.new(0, 230, 0, 10)

local DecreaseFOV = Instance.new("TextButton")
DecreaseFOV.Name = "DecreaseFOV"
DecreaseFOV.Parent = MainFrame
DecreaseFOV.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DecreaseFOV.BorderSizePixel = 0
DecreaseFOV.Position = UDim2.new(0, 120, 0, 40)
DecreaseFOV.Size = UDim2.new(0, 30, 0, 30)
DecreaseFOV.Font = Enum.Font.SourceSans
DecreaseFOV.Text = "-"
DecreaseFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseFOV.TextSize = 20.000

local IncreaseFOV = Instance.new("TextButton")
IncreaseFOV.Name = "IncreaseFOV"
IncreaseFOV.Parent = MainFrame
IncreaseFOV.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
IncreaseFOV.BorderSizePixel = 0
IncreaseFOV.Position = UDim2.new(0, 160, 0, 40)
IncreaseFOV.Size = UDim2.new(0, 30, 0, 30)
IncreaseFOV.Font = Enum.Font.SourceSans
IncreaseFOV.Text = "+"
IncreaseFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseFOV.TextSize = 20.000

-- FOV Circle Visual
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Aimbot.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.5
FOVCircle.Visible = true

-- Functions
function updateFOV()
    FOVCircle.Radius = Aimbot.FOVRadius
    FOVLabel.Text = "FOV Radius: " .. Aimbot.FOVRadius
    local sliderWidth = (Aimbot.FOVRadius / 400) * 230 -- Map radius to slider width
    FOVSlider.Size = UDim2.new(0, sliderWidth, 0, 10)
end

function isTeammate(player)
    if not Aimbot.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

function isPlayerVisible(player)
    local character = player.Character
    if not character then return false end
    
    local targetPart = character:FindFirstChild(Aimbot.TargetPart)
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).unit * 500
    local ray = Ray.new(origin, direction)
    
    local hit, position = game.Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    
    if hit then
        -- Check if the part we hit is a descendant of the target character
        if hit:IsDescendantOf(character) then
            return true
        else
            -- Check if the hit position is very close to the target part (for thin walls)
            if (position - targetPart.Position).magnitude < 5 then
                return true
            end
        end
    end
    
    return false
end

function getClosestPlayerInFOV()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            if not isTeammate(player) then
                local targetPart = player.Character:FindFirstChild(Aimbot.TargetPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distance < Aimbot.FOVRadius then
                            if distance < shortestDistance then
                                if isPlayerVisible(player) then
                                    shortestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Main Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = getClosestPlayerInFOV()
        if target then
            local targetPart = target.Character:FindFirstChild(Aimbot.TargetPart)
            if targetPart then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                if Aimbot.Smoothing > 0 then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Aimbot.Smoothing)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end
    end
    
    -- Update FOV circle position
    FOVCircle.Position = UserInputService:GetMouseLocation()
end)

-- UI Connections
ToggleButton.MouseButton1Click:Connect(function
