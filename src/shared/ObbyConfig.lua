-- ObbyConfig: shared settings for Charlobby
-- Obstacle course configuration for Charlotte's obby!

local ObbyConfig = {}

-- Points awarded when a player completes the course
ObbyConfig.WIN_POINTS = 10

-- How many obstacles in each generated course
ObbyConfig.COURSE_LENGTH = 12

-- Starting position for the first obstacle (where the course begins)
ObbyConfig.START_POSITION = Vector3.new(0, 5, -30)

-- How far apart obstacles are spaced (along the Z axis)
ObbyConfig.OBSTACLE_SPACING = 25

-- Platform colors (bright, fun colors for Charlotte!)
ObbyConfig.COLORS = {
	Color3.fromRGB(255, 105, 180), -- Hot Pink
	Color3.fromRGB(138, 43, 226), -- Purple
	Color3.fromRGB(0, 191, 255),  -- Sky Blue
	Color3.fromRGB(50, 205, 50),  -- Lime Green
	Color3.fromRGB(255, 165, 0),  -- Orange
	Color3.fromRGB(255, 255, 0),  -- Yellow
	Color3.fromRGB(0, 255, 255),  -- Cyan
	Color3.fromRGB(255, 69, 0),   -- Red-Orange
}

-- Obstacle types that can appear in the course
ObbyConfig.OBSTACLE_TYPES = {
	"JumpPlatforms",
	"Stairs",
	"ClimbWall",
	"HoopRing",
}

return ObbyConfig
