-- WinAnnouncement: client script that shows a banner when someone wins
-- Displays the winner's name and their total points

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local announceEvent = ReplicatedStorage:WaitForChild("AnnounceWin")
local player = Players.LocalPlayer

--------------------------------------------------------------------------------
-- Create the announcement GUI
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WinAnnouncementGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Banner"
frame.Size = UDim2.new(0.6, 0, 0.12, 0)
frame.Position = UDim2.new(0.2, 0, -0.15, 0) -- starts off-screen (above)
frame.AnchorPoint = Vector2.new(0, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Name = "WinText"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = ""
label.TextColor3 = Color3.fromRGB(50, 50, 50)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = frame

--------------------------------------------------------------------------------
-- Animate the banner sliding down then back up
--------------------------------------------------------------------------------
local TweenService = game:GetService("TweenService")

local function showBanner(text)
	label.Text = text

	-- Slide down into view
	local tweenIn = TweenService:Create(
		frame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.2, 0, 0.05, 0) }
	)
	tweenIn:Play()
	tweenIn.Completed:Wait()

	-- Hold for a few seconds
	task.wait(3)

	-- Slide back up off screen
	local tweenOut = TweenService:Create(
		frame,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.new(0.2, 0, -0.15, 0) }
	)
	tweenOut:Play()
end

--------------------------------------------------------------------------------
-- Listen for win announcements from the server
--------------------------------------------------------------------------------
announceEvent.OnClientEvent:Connect(function(winnerName, totalPoints)
	local msg = winnerName .. " finished the obby! " .. totalPoints .. " points! New course incoming!"
	showBanner(msg)
end)
