--[[if game.PlaceId ~= 1296094037 then
	warn("wrong game fool")
	return
end]]

if _G.buildingowoloaded == true then
	warn("buildingowo~ is already loaded!")
	return
end

while not game:IsLoaded() do
	task.wait()
end

_G.buildingowoloaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PhysicsService = game:GetService("PhysicsService")

local function getSecureGui():{Gui:Instance}
	local _, v = xpcall(function()
		return gethui and gethui() or Instance.new("Frame", game:GetService("CoreGui")):Destroy() and game:GetService("CoreGui")
	end, function()
		return nil
	end)
	return v or LocalPlayer.PlayerGui
end

local function getPlayerByName(Name):{Player:Player | nil}
	return Players:FindFirstChild(Name)
end

--[[local function getInfo(Player:Player):{info:Instance}
	return Player:FindFirstChild("info")
end]]

local function getPlayerContract(Player:Player)
	if Player:FindFirstChild("info") then
		return Player.info:FindFirstChild("currentWorldContract").Value
	end
	return nil
end

local function characterSanity(Character:Model):{Pass:boolean}
	if Character and Character.Parent == workspace and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") then
		return true
	end
	return false
end

local function setModelsNoCollision(Model1:Model, Model2:Model) -- because stinky roblox doesn't allow collision group creation on client
	for _, v0 in ipairs(Model1:GetDescendants()) do
		if v0:IsA("BasePart") then
			for _, v1 in ipairs(Model2:GetDescendants()) do
				if v1:IsA("BasePart") then
					local noColl = v0:FindFirstChild("_NoColl") or v1:FindFirstChild("_NoColl") or Instance.new("NoCollisionConstraint", v0 or v1)
					noColl.Name = "_NoColl"
					noColl.Part0 = v0 or v1
					noColl.Part1 = v1 or v0
				end
			end
		end
	end
end

local hugeVector3 = Vector3.new(10000,10000,10000)
local zeroVector3 = Vector3.zero

local function resetModelVelocity(Model:Model)
	for _, v in ipairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.AssemblyLinearVelocity = zeroVector3
			v.AssemblyAngularVelocity = zeroVector3
		end
	end
end

local function cPivotTo(Model:Model, Position:CFrame, resetVelocity:boolean?)
	Model:PivotTo(Position)
	if resetVelocity then resetModelVelocity(Model) end
end

local PartPP = PhysicalProperties.new(0, 0, 0, 0, 0)

local function demolishBuilding(building:Model):{TimeTaken:number}
	local startTime = os.clock()
	if building:FindFirstChild("buildingStatus").Value == "inProgress" and building:FindFirstChild("contractedPlayer").Value then
		local Character = LocalPlayer.Character
		if characterSanity(Character) then 
			Character.PrimaryPart = Character:FindFirstChild("HumanoidRootPart")

			local parts = {}
			for _, v:BasePart in ipairs(building:GetDescendants()) do
				if v:IsA("BasePart") and v:FindFirstChild("health") and v:FindFirstChild("partPosition") and not v.Anchored then
					print(v.Name, v:FindFirstChild("partPosition").Value, v:FindFirstChild("partOrientation").Value)
					local pP, pO = v:FindFirstChild("partPosition").Value, v:FindFirstChild("partOrientation").Value  -- THE FUCK YOU MEAN??
					parts[v] = CFrame.new(pP.X, pP.Y, pP.Z) * CFrame.fromOrientation(pO.X, pO.Y, pO.Z)
					v.CustomPhysicalProperties = PartPP
				end
			end
			table.sort(parts, function(a, b)
				return a.Y < b.Y
			end)
			setModelsNoCollision(building, Character)

			for part:BasePart, cframe:CFrame in pairs(parts) do
				if part.Parent and (part.Position-cframe.Position).Magnitude < 8 and (part.Orientation-cframe.Rotation).Magnitude < 180 then
					cPivotTo(Character, cframe, true)
					task.wait()
					part.CustomPhysicalProperties = PartPP
					part.AssemblyLinearVelocity = hugeVector3
					part.AssemblyAngularVelocity = hugeVector3
					task.wait()
				end
			end
		end
	end
	return os.clock()-startTime
end

local SG = Instance.new("ScreenGui", getSecureGui())
SG.Name = "building"
local your = Instance.new("TextButton", SG)
your.Name = "your"
your.AnchorPoint = Vector2.new(0, 1)
your.BackgroundColor3 = Color3.new(1,0,0)
your.Position = UDim2.new(0,0,1,0)
your.Size = UDim2.new(0, 200, 0, 50)
your.Text = "owo your buildings"
your.TextScaled = true
local other = Instance.new("TextButton", SG)
other.Name = "other"
other.AnchorPoint = Vector2.new(0, 1)
other.BackgroundColor3 = Color3.new(1,0,0)
other.Position = UDim2.new(0,205,1,0)
other.Size = UDim2.new(0, 200, 0, 50)
other.Text = "owo other's buildings"
other.TextScaled = true

local yourtoggle = false
your.Activated:Connect(function()
	yourtoggle = not yourtoggle
	your.BackgroundColor3 = yourtoggle and Color3.new(0,1,0) or Color3.new(1,0,0)
end)

while task.wait() do
	if yourtoggle then
		local contract = getPlayerContract(LocalPlayer)
		if contract  then
			print("Demolishing "..contract.buildingId.Value)
			print("Took: "..demolishBuilding(contract))
		end
	end
end
