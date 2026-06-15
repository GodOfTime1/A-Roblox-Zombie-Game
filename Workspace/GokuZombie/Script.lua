-- @ScriptType: Script
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

humanoid.WalkSpeed = 16

local Animation = script.Parent.AttackAnimation
local LoadedAnimation = humanoid:LoadAnimation(Animation)

local Attacking = false

local function DetectPlayer()
	local nearestPlayer = nil
	local shortestDistance = math.huge
	
	for i, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local Distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
			if Distance < shortestDistance and Distance < 60 then
				shortestDistance = Distance
				nearestPlayer = player.Character
			end
		end
	end
	
	return nearestPlayer
end

local function MoveTo(TargetPosition)
	if Attacking == true then return end
	
	local Path = PathfindingService:CreatePath()
	Path:ComputeAsync(rootPart.Position, TargetPosition)
	
	if Path.Status == Enum.PathStatus.Success then
		for i, waypoint in pairs(Path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	end
end

local function Attack(Target)
	if Attacking then return end
	
	Attacking = true
	humanoid:MoveTo(rootPart.Position)
	LoadedAnimation:Play()
	
	task.wait(0.35)
	
	if Target.Humanoid.Health > 0 then
		Target.Humanoid:TakeDamage(25)
	end
	
	wait(3)
	Attacking = false
	
end

RunService.Heartbeat:Connect(function()
	if humanoid.Health <= 0 then return end
	
	local NearestPlayer = DetectPlayer()
	if NearestPlayer == nil then return end
	
	local TargetRootPart = NearestPlayer:WaitForChild("HumanoidRootPart")
	local TargetHumanoid = NearestPlayer:WaitForChild("Humanoid")
	if TargetHumanoid == nil then return end
	
	local Distance = (TargetRootPart.Position - rootPart.Position).Magnitude
	if Distance <= 5 then
		Attack(NearestPlayer)
	else
		MoveTo(TargetRootPart.Position)
	end
	
	
	MoveTo(TargetRootPart.Position)
end)
