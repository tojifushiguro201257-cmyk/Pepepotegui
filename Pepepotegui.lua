--// pepepotegui

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--[seguridad

local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then return end

local gui = Instance.new("ScreenGui")
gui.Name = "pepepotegui_delta"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999999
gui.IgnoreGuiInset = true

local success, _ = pcall(function()
	gui.Parent = CoreGui
end)
if not success then
	gui.Parent = playerGui
end

--[GUI PRINCIPAL

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 520, 0, 260)
main.Position = UDim2.new(0.5, -260, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(255,140,0)
main.BorderColor3 = Color3.fromRGB(0,255,0)
main.BorderSizePixel = 4
main.Active = true

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

--------------------------------------------------
-- TOP BAR
--------------------------------------------------
local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(255,140,0)
top.BorderColor3 = Color3.fromRGB(0,255,0)
top.BorderSizePixel = 3

local title = Instance.new("TextLabel")
title.Parent = top
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "pepepotegui"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------
local minimized = false

local minimize = Instance.new("TextButton")
minimize.Parent = top
minimize.Size = UDim2.new(0,35,0,35)
minimize.Position = UDim2.new(1,-80,0,2)
minimize.Text = "-"
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 30
minimize.TextColor3 = Color3.fromRGB(0,0,0)
minimize.BackgroundColor3 = Color3.fromRGB(255,170,0)
minimize.BorderColor3 = Color3.fromRGB(0,255,0)
minimize.BorderSizePixel = 3

-- CLOSE

local close = Instance.new("TextButton")
close.Parent = top
close.Size = UDim2.new(0,35,0,35)
close.Position = UDim2.new(1,-40,0,2)
close.Text = "X"
close.Font = Enum.Font.SourceSansBold
close.TextSize = 22
close.TextColor3 = Color3.fromRGB(0,0,0)
close.BackgroundColor3 = Color3.fromRGB(255,0,0)
close.BorderColor3 = Color3.fromRGB(0,255,0)
close.BorderSizePixel = 3

--------------------------------------------------
-- HOLDER
--------------------------------------------------
local holder = Instance.new("Frame")
holder.Parent = main
holder.BackgroundTransparency = 1
holder.Position = UDim2.new(0,10,0,50)
holder.Size = UDim2.new(1,-20,1,-60)

local grid = Instance.new("UIGridLayout")
grid.Parent = holder
grid.CellSize = UDim2.new(0,115,0,90)
grid.CellPadding = UDim2.new(0,10,0,10)

--------------------------------------------------
-- SCRIPT STATES
-------------------------------------------------
local states = {
	Fly = false,
	Noclip = false,
	Platform = false,
	Antifling = false,
	Fire = false,
	Aura = false
}

--------------------------------------------------
-- LOGICA INTERNA DE LOS EXPLOITS
--------------------------------------------------
local flyConnection
local noclipConnection
local platformConnection
local platformPart
local antiflingConnection
local fireConnection

local function disconnect(connection)
	if connection then
		connection:Disconnect()
	end
	return nil
end

local function ToggleFly(state)
	states.Fly = state
	flyConnection = disconnect(flyConnection)

	if state then
		flyConnection = RunService.Heartbeat:Connect(function()
			if character and character:FindFirstChild("HumanoidRootPart") then
				local hrp = character.HumanoidRootPart
				local camera = workspace.CurrentCamera
				hrp.AssemblyLinearVelocity = camera.CFrame.LookVector * 65
			end
		end)
	else
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
		end
	end
end

local function ToggleNoclip(state)
	states.Noclip = state
	noclipConnection = disconnect(noclipConnection)

	if state then
		noclipConnection = RunService.Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end

local function TogglePlatform(state)
	states.Platform = state
	platformConnection = disconnect(platformConnection)
	
	if platformPart then 
		platformPart:Destroy() 
		platformPart = nil
	end

	if state then
		platformPart = Instance.new("Part")
		platformPart.Anchored = true
		platformPart.Size = Vector3.new(10, 1, 10)
		platformPart.Material = Enum.Material.SmoothPlastic
		platformPart.Transparency = 0.4
		platformPart.Color = Color3.fromRGB(0, 255, 0)
		platformPart.Name = "DeltaPlatform"
		platformPart.Parent = workspace

		platformConnection = RunService.PostSimulation:Connect(function()
			if character and character:FindFirstChild("HumanoidRootPart") and platformPart then
				platformPart.Position = character.HumanoidRootPart.Position - Vector3.new(0, 3.5, 0)
			end
		end)
	end
end

-- Anti-fling Definitivo: Bloquea colisiones externas y estabiliza caídas/subidas lentas si hay un empuje brusco
local function ToggleAntiFling(state)
	states.Antifling = state
	antiflingConnection = disconnect(antiflingConnection)

	if state then
		antiflingConnection = RunService.Heartbeat:Connect(function()
			if character and character:FindFirstChild("HumanoidRootPart") then
				local hrp = character.HumanoidRootPart
				
				-- Estabilizador vertical definitivo: amortigua velocidades Y exageradas
				local currentVelocity = hrp.AssemblyLinearVelocity
				if math.abs(currentVelocity.Y) > 5 then
					-- Suaviza el desplazamiento vertical (caída o subida lenta de seguridad)
					local clampedY = math.clamp(currentVelocity.Y, -2, 2)
					hrp.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, clampedY, currentVelocity.Z)
				end

				-- Desactivar colisión y fuerzas de otros jugadores locales
				for _, otherPlayer in ipairs(Players:GetPlayers()) do
					if otherPlayer ~= player and otherPlayer.Character then
						for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
								part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
								part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
							end
						end
					end
				end
			end
		end)
	end
end

-- Fire: Enciende a todos en el servidor con fuego azul y rojo (Efecto Visual Local de alta fidelidad)
local function ToggleFire(state)
	states.Fire = state
	fireConnection = disconnect(fireConnection)

	local function applyFire(char)
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if root then
			-- Fuego Azul
			local fBlue = root:FindFirstChild("NullFireBlue")
			if not fBlue and state then
				fBlue = Instance.new("Fire")
				fBlue.Name = "NullFireBlue"
				fBlue.Color = Color3.fromRGB(0, 100, 255)
				fBlue.SecondaryColor = Color3.fromRGB(0, 200, 255)
				fBlue.Size = 7
				fBlue.Heat = 9
				fBlue.Parent = root
			elseif fBlue and not state then
				fBlue:Destroy()
			end

			-- Fuego Rojo
			local fRed = root:FindFirstChild("NullFireRed")
			if not fRed and state then
				fRed = Instance.new("Fire")
				fRed.Name = "NullFireRed"
				fRed.Color = Color3.fromRGB(255, 0, 0)
				fRed.SecondaryColor = Color3.fromRGB(255, 100, 0)
				fRed.Size = 6
				fRed.Heat = 9
				fRed.Parent = root
			elseif fRed and not state then
				fRed:Destroy()
			end
		end
	end

	if state then
		fireConnection = RunService.Heartbeat:Connect(function()
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character then
					applyFire(p.Character)
				end
			end
		end)
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				applyFire(p.Character)
			end
		end
	end
end

-- Aura: Enciende al cliente local en un fuego verde intenso
local function ToggleAura(state)
	states.Aura = state
	if character then
		local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if root then
			local fGreen = root:FindFirstChild("NullAuraGreen")
			if state then
				if not fGreen then
					fGreen = Instance.new("Fire")
					fGreen.Name = "NullAuraGreen"
					fGreen.Color = Color3.fromRGB(0, 255, 0)
					fGreen.SecondaryColor = Color3.fromRGB(100, 255, 100)
					fGreen.Size = 9
					fGreen.Heat = 12
					fGreen.Parent = root
				end
			else
				if fGreen then
					fGreen:Destroy()
				end
			end
		end
	end
end

--------------------------------------------------
-- GENERADOR DE SLOTS (ESTRUCTURA ORIGINAL FIJA)
--------------------------------------------------
local function CreateSlot(name, callback)

	local frame = Instance.new("Frame")
	frame.Parent = holder
	frame.BackgroundColor3 = Color3.fromRGB(255,140,0)
	frame.BorderColor3 = Color3.fromRGB(0,255,0)
	frame.BorderSizePixel = 3

	local text = Instance.new("TextLabel")
	text.Parent = frame
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1,0,0,40)
	text.Text = name
	text.TextColor3 = Color3.fromRGB(0,0,0)
	text.Font = Enum.Font.SourceSansBold
	text.TextSize = 24

	local toggle = Instance.new("TextButton")
	toggle.Parent = frame
	toggle.Size = UDim2.new(1,-10,0,30)
	toggle.Position = UDim2.new(0,5,1,-35)
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.SourceSansBold
	toggle.TextSize = 18
	toggle.TextColor3 = Color3.fromRGB(0,0,0)
	toggle.BorderColor3 = Color3.fromRGB(0,255,0)
	toggle.BorderSizePixel = 2
	toggle.BackgroundColor3 = Color3.fromRGB(0,100,255)

	local enabled = false

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled

		if enabled then
			toggle.Text = "ON"
			toggle.BackgroundColor3 = Color3.fromRGB(255,0,0)
		else
			toggle.Text = "OFF"
			toggle.BackgroundColor3 = Color3.fromRGB(0,100,255)
		end

		callback(enabled)
	end)
end

--------------------------------------------------
-- INICIALIZACIÓN DE BOTONES (Añadidos Fire y Aura)
--------------------------------------------------
CreateSlot("Fly", ToggleFly)
CreateSlot("Noclip", ToggleNoclip)
CreateSlot("Platform", TogglePlatform)
CreateSlot("Antifling", ToggleAntiFling)
CreateSlot("Fire", ToggleFire)
CreateSlot("Aura", ToggleAura)

--------------------------------------------------
-- CONTROLES DE INTERFAZ
--------------------------------------------------
close.MouseButton1Click:Connect(function()
	flyConnection = disconnect(flyConnection)
	noclipConnection = disconnect(noclipConnection)
	platformConnection = disconnect(platformConnection)
	antiflingConnection = disconnect(antiflingConnection)
	fireConnection = disconnect(fireConnection)
	
	if platformPart then platformPart:Destroy() end
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root and root:FindFirstChild("NullAuraGreen") then root.NullAuraGreen:Destroy() end
	end
	
	gui:Destroy()
end)

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	holder.Visible = not minimized

	if minimized then
		main.Size = UDim2.new(0,520,0,40)
	else
		main.Size = UDim2.new(0,520,0,260)
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	task.spawn(function()
		task.wait(0.5)
		if states.Fly then ToggleFly(true) end
		if states.Noclip then ToggleNoclip(true) end
		if states.Platform then TogglePlatform(true) end
		if states.Antifling then ToggleAntiFling(true) end
		if states.Fire then ToggleFire(true) end
		if states.Aura then ToggleAura(true) end
	end)
end)

