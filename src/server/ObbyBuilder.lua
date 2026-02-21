-- ObbyBuilder: creates the lobby, spawn, and random obstacle course
-- Each obstacle type is built from simple Part primitives

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObbyConfig = require(ReplicatedStorage:WaitForChild("ObbyConfig"))

local ObbyBuilder = {}

--------------------------------------------------------------------------------
-- Helper: pick a random color from the config
--------------------------------------------------------------------------------
local function randomColor()
	local colors = ObbyConfig.COLORS
	return colors[math.random(#colors)]
end

--------------------------------------------------------------------------------
-- Helper: create a basic anchored part
--------------------------------------------------------------------------------
local function makePart(parent, size, cframe, color, material, name)
	local part = Instance.new("Part")
	part.Name = name or "ObbyPart"
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.BrickColor = BrickColor.new("Medium stone grey")
	part.Color = color or randomColor()
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

--------------------------------------------------------------------------------
-- Build the lobby spawn platform
--------------------------------------------------------------------------------
function ObbyBuilder.BuildLobby(folder)
	-- Big spawn platform
	local platform = makePart(
		folder,
		Vector3.new(30, 3, 30),
		CFrame.new(0, 1.5, 0),
		Color3.fromRGB(100, 200, 100),
		Enum.Material.Grass,
		"SpawnPlatform"
	)

	-- SpawnLocation on top of the platform
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LobbySpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 3.5, 0)
	spawn.Anchored = true
	spawn.Color = Color3.fromRGB(255, 255, 255)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Parent = folder

	-- Title sign
	local signPart = makePart(
		folder,
		Vector3.new(16, 6, 1),
		CFrame.new(0, 9, -14),
		Color3.fromRGB(255, 105, 180),
		Enum.Material.Neon,
		"TitleSign"
	)

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "TitleGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = signPart

	local label = Instance.new("TextLabel")
	label.Name = "Title"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "CHARLOBBY!"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surfaceGui

	-- Arrow pointing to the course start
	local arrow = makePart(
		folder,
		Vector3.new(4, 1, 10),
		CFrame.new(0, 3.5, -20),
		Color3.fromRGB(255, 255, 0),
		Enum.Material.Neon,
		"ArrowPath"
	)
end

--------------------------------------------------------------------------------
-- OBSTACLE BUILDERS
-- Each function places obstacles starting at `origin` and returns the
-- ending Y height so the next segment can connect properly.
--------------------------------------------------------------------------------

-- 1) Jump Platforms: a series of floating platforms the player hops across
local function buildJumpPlatforms(folder, origin, index)
	local group = Instance.new("Model")
	group.Name = "JumpPlatforms_" .. index
	group.Parent = folder

	local y = origin.Y
	local z = origin.Z
	local platformCount = math.random(3, 5)

	for i = 1, platformCount do
		local xOffset = math.random(-6, 6)
		local yJump = math.random(0, 4)
		y = y + yJump
		z = z - math.random(6, 10)

		makePart(
			group,
			Vector3.new(5, 1.5, 5),
			CFrame.new(origin.X + xOffset, y, z),
			randomColor(),
			Enum.Material.SmoothPlastic,
			"Platform_" .. i
		)
	end

	return Vector3.new(origin.X, y, z)
end

-- 2) Stairs: a staircase the player runs up
local function buildStairs(folder, origin, index)
	local group = Instance.new("Model")
	group.Name = "Stairs_" .. index
	group.Parent = folder

	local stepCount = math.random(6, 10)
	local y = origin.Y
	local z = origin.Z

	for i = 1, stepCount do
		y = y + 2
		z = z - 4

		makePart(
			group,
			Vector3.new(8, 2, 4),
			CFrame.new(origin.X, y, z),
			randomColor(),
			Enum.Material.Concrete,
			"Step_" .. i
		)
	end

	-- Landing platform at the top
	makePart(
		group,
		Vector3.new(8, 2, 8),
		CFrame.new(origin.X, y, z - 6),
		randomColor(),
		Enum.Material.SmoothPlastic,
		"Landing"
	)

	return Vector3.new(origin.X, y, z - 10)
end

-- 3) Climb Wall: a tall wall with ladder-like rungs (TrussParts)
local function buildClimbWall(folder, origin, index)
	local group = Instance.new("Model")
	group.Name = "ClimbWall_" .. index
	group.Parent = folder

	local wallHeight = math.random(15, 25)

	-- Back wall (decoration)
	makePart(
		group,
		Vector3.new(10, wallHeight, 3),
		CFrame.new(origin.X, origin.Y + wallHeight / 2, origin.Z - 5),
		Color3.fromRGB(139, 90, 43),
		Enum.Material.Wood,
		"Wall"
	)

	-- Truss (climbable ladder)
	local truss = Instance.new("TrussPart")
	truss.Name = "Ladder"
	truss.Size = Vector3.new(2, wallHeight, 2)
	truss.CFrame = CFrame.new(origin.X, origin.Y + wallHeight / 2, origin.Z - 4)
	truss.Anchored = true
	truss.Color = Color3.fromRGB(200, 200, 200)
	truss.Material = Enum.Material.Metal
	truss.Parent = group

	-- Platform at the top to land on
	local topY = origin.Y + wallHeight
	makePart(
		group,
		Vector3.new(8, 2, 8),
		CFrame.new(origin.X, topY + 1, origin.Z - 10),
		randomColor(),
		Enum.Material.SmoothPlastic,
		"TopPlatform"
	)

	return Vector3.new(origin.X, topY + 1, origin.Z - 14)
end

-- 4) Hoop Ring: big rings (toruses) the player jumps through between platforms
local function buildHoopRing(folder, origin, index)
	local group = Instance.new("Model")
	group.Name = "HoopRing_" .. index
	group.Parent = folder

	local z = origin.Z
	local y = origin.Y
	local hoopCount = math.random(2, 3)

	for i = 1, hoopCount do
		z = z - 12

		-- Landing platform before/after hoop
		makePart(
			group,
			Vector3.new(6, 1.5, 6),
			CFrame.new(origin.X, y, z),
			randomColor(),
			Enum.Material.SmoothPlastic,
			"HoopPlatform_" .. i
		)

		-- The hoop ring (built from a ring of small parts)
		local hoopZ = z - 6
		local ringRadius = 6
		local segments = 16

		for s = 1, segments do
			local angle = (s / segments) * math.pi * 2
			local rx = math.cos(angle) * ringRadius
			local ry = math.sin(angle) * ringRadius

			local ringPart = makePart(
				group,
				Vector3.new(1.5, 1.5, 1.5),
				CFrame.new(origin.X + rx, y + 4 + ry, hoopZ),
				Color3.fromRGB(255, 215, 0),
				Enum.Material.Neon,
				"Ring_" .. i .. "_" .. s
			)
			ringPart.Shape = Enum.PartType.Ball
			ringPart.CanCollide = false
		end

		z = hoopZ - 6

		-- Landing platform after hoop
		makePart(
			group,
			Vector3.new(6, 1.5, 6),
			CFrame.new(origin.X, y, z),
			randomColor(),
			Enum.Material.SmoothPlastic,
			"HoopLanding_" .. i
		)
	end

	return Vector3.new(origin.X, y, z)
end

--------------------------------------------------------------------------------
-- Builder lookup table
--------------------------------------------------------------------------------
local builders = {
	JumpPlatforms = buildJumpPlatforms,
	Stairs        = buildStairs,
	ClimbWall     = buildClimbWall,
	HoopRing      = buildHoopRing,
}

--------------------------------------------------------------------------------
-- Generate a full random course
--------------------------------------------------------------------------------
function ObbyBuilder.GenerateCourse(courseFolder)
	local obstacleTypes = ObbyConfig.OBSTACLE_TYPES
	local courseLength = ObbyConfig.COURSE_LENGTH
	local currentPos = ObbyConfig.START_POSITION

	-- Starting bridge from lobby to first obstacle
	makePart(
		courseFolder,
		Vector3.new(6, 1, 20),
		CFrame.new(0, 3, -20),
		Color3.fromRGB(200, 200, 200),
		Enum.Material.Concrete,
		"StartBridge"
	)

	for i = 1, courseLength do
		local obstacleType = obstacleTypes[math.random(#obstacleTypes)]
		local builder = builders[obstacleType]

		if builder then
			currentPos = builder(courseFolder, currentPos, i)
		end
	end

	-- Finish platform with a win pad
	local finishPlatform = makePart(
		courseFolder,
		Vector3.new(16, 3, 16),
		CFrame.new(currentPos.X, currentPos.Y, currentPos.Z - 10),
		Color3.fromRGB(50, 255, 50),
		Enum.Material.Neon,
		"FinishPlatform"
	)

	-- Win detection pad on top
	local winPad = makePart(
		courseFolder,
		Vector3.new(12, 1, 12),
		CFrame.new(currentPos.X, currentPos.Y + 2, currentPos.Z - 10),
		Color3.fromRGB(255, 215, 0),
		Enum.Material.Neon,
		"WinPad"
	)

	-- Finish sign
	local signPart = makePart(
		courseFolder,
		Vector3.new(12, 5, 1),
		CFrame.new(currentPos.X, currentPos.Y + 8, currentPos.Z - 17),
		Color3.fromRGB(255, 215, 0),
		Enum.Material.Neon,
		"FinishSign"
	)

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = signPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "YOU WON! +10 POINTS!"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surfaceGui

	return winPad
end

return ObbyBuilder
