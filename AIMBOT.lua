-- Сервисы
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

-- Настройки
_G.AimbotEnabled = true
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 0

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotStatusGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "AimbotStatus"
StatusLabel.Size = UDim2.new(0, 200, 0, 30)
StatusLabel.Position = UDim2.new(1, -210, 0, 10) -- Правый верхний угол
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextStrokeTransparency = 0
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 20
StatusLabel.Visible = false
StatusLabel.Text = ""
StatusLabel.Parent = ScreenGui

-- Обновление текста GUI и авто-скрытие через 5 секунд
local debounce = false
local function ShowNotification()
	if debounce then return end
	debounce = true

	StatusLabel.Text = "Aimbot: " .. (_G.AimbotEnabled and "ON" or "OFF")
	StatusLabel.Visible = true

	task.delay(5, function()
		StatusLabel.Visible = false
		debounce = false
	end)
end

-- Поиск ближайшего игрока
local function GetClosestPlayer()
	local MaximumDistance = math.huge
	local Target = nil

	coroutine.wrap(function()
		wait(20)
		MaximumDistance = math.huge
	end)()

	for _, v in next, Players:GetPlayers() do
		if v ~= LocalPlayer then
			if _G.TeamCheck and v.Team == LocalPlayer.Team then
				continue
			end

			local character = v.Character
			if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
				local screenPoint = Camera:WorldToScreenPoint(character.HumanoidRootPart.Position)
				local mouseLocation = UserInputService:GetMouseLocation()
				local vectorDistance = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude

				if vectorDistance < MaximumDistance then
					Target = v
					MaximumDistance = vectorDistance
				end
			end
		end
	end

	return Target
end

-- Обработка ПКМ
UserInputService.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Holding = true
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Holding = false
	end
end)

-- Переключение Aimbot по F + уведомление
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
		_G.AimbotEnabled = not _G.AimbotEnabled
		ShowNotification()
	end
end)

-- Aimbot логика
RunService.RenderStepped:Connect(function()
	if Holding and _G.AimbotEnabled then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild(_G.AimPart) then
			local aimPosition = target.Character[_G.AimPart].Position
			local tween = TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
			})
			tween:Play()
		end
	end
end)
