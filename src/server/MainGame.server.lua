-- MainGame: the main server script for Charlobby
-- Handles course generation, win detection, leaderboard, and regeneration

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObbyBuilder = require(script.Parent:WaitForChild("ObbyBuilder"))
local Leaderboard = require(script.Parent:WaitForChild("Leaderboard"))
local ObbyConfig = require(ReplicatedStorage:WaitForChild("ObbyConfig"))

--------------------------------------------------------------------------------
-- Remote event for announcing wins to all clients
--------------------------------------------------------------------------------
local announceEvent = Instance.new("RemoteEvent")
announceEvent.Name = "AnnounceWin"
announceEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- Folders in Workspace
--------------------------------------------------------------------------------
local lobbyFolder = Instance.new("Folder")
lobbyFolder.Name = "Lobby"
lobbyFolder.Parent = Workspace

local courseFolder = Instance.new("Folder")
courseFolder.Name = "ObbyCourse"
courseFolder.Parent = Workspace

--------------------------------------------------------------------------------
-- Build the lobby (only once)
--------------------------------------------------------------------------------
ObbyBuilder.BuildLobby(lobbyFolder)

--------------------------------------------------------------------------------
-- Course management
--------------------------------------------------------------------------------
local currentWinPad = nil
local winConnection = nil
local isRegenerating = false

-- Track which players have already won the current course
local hasWonCurrent = {}

local function clearCourse()
	if winConnection then
		winConnection:Disconnect()
		winConnection = nil
	end
	currentWinPad = nil
	hasWonCurrent = {}

	for _, child in ipairs(courseFolder:GetChildren()) do
		child:Destroy()
	end
end

local function generateNewCourse()
	isRegenerating = true
	clearCourse()

	-- Small delay so players see the course disappear
	task.wait(1)

	-- Generate fresh obstacles
	currentWinPad = ObbyBuilder.GenerateCourse(courseFolder)

	-- Listen for players touching the win pad
	winConnection = currentWinPad.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		if hasWonCurrent[player.UserId] then return end

		-- Mark this player as having won the current course
		hasWonCurrent[player.UserId] = true

		-- Award points
		Leaderboard.AwardWin(player)

		-- Tell all clients who won
		local points = Leaderboard.GetPoints(player)
		announceEvent:FireAllClients(player.Name, points)

		-- Respawn the winner back to lobby
		player:LoadCharacter()

		-- Regenerate a brand new course after a short celebration delay
		if not isRegenerating then return end
		isRegenerating = false

		task.wait(3)
		generateNewCourse()
	end)

	isRegenerating = false
end

--------------------------------------------------------------------------------
-- Player join / leave
--------------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	Leaderboard.OnPlayerAdded(player)
end)

Players.PlayerRemoving:Connect(function(player)
	hasWonCurrent[player.UserId] = nil
end)

--------------------------------------------------------------------------------
-- Generate the first course on server start
--------------------------------------------------------------------------------
generateNewCourse()

print("[Charlobby] Game is ready! Course generated.")
