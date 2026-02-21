-- Leaderboard: manages player points using leaderstats
-- Points persist during the session; awarded when a player finishes the obby

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObbyConfig = require(ReplicatedStorage:WaitForChild("ObbyConfig"))

local Leaderboard = {}

-- Set up leaderstats when a player joins
function Leaderboard.OnPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local points = Instance.new("IntValue")
	points.Name = "Points"
	points.Value = 0
	points.Parent = leaderstats
end

-- Award points to a player for finishing the course
function Leaderboard.AwardWin(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local points = leaderstats:FindFirstChild("Points")
		if points then
			points.Value = points.Value + ObbyConfig.WIN_POINTS
		end
	end
end

-- Get a player's current points
function Leaderboard.GetPoints(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local points = leaderstats:FindFirstChild("Points")
		if points then
			return points.Value
		end
	end
	return 0
end

return Leaderboard
