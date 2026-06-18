-- @ScriptType: LocalScript
-- Services
local Player = game:GetService("Players").LocalPlayer

local TweenService = game:GetService('TweenService')
local StarterGUI = game:GetService('StarterGui')
local ContentProvider = game:GetService('ContentProvider')

local GameName="ANIME APOCALYPSE"

local function setup()
	local setup_successful, error_settingup = pcall(function()
		script.Parent:RemoveDefaultLoadingScreen()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local GUI=script:WaitForChild('LoadingScreen')
		
		local Frame = GUI.Frame
		local Title = Frame.TextLabel
		local AssetsLabel = Frame.Assets
		local PercentageLabel = Frame.Percentage
		local FillBar = Frame.Bar.Fill
		local Fade = GUI.Fade

		local BarTweenInfo = TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local FadeTweenInfo = TweenInfo.new(
			0.75,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local function start_settings()

			local tries = 5

			repeat 

				local success = pcall(function()
					StarterGUI:SetCoreGuiEnabled(
						Enum.CoreGuiType.All, 
						false
					)
				end)

				tries = tries - 1

				task.wait()

			until tries < 1 or success
		end

		local function preload()
			local LoadingAssets = {}
			for _, obj in ipairs(game:GetDescendants()) do
				if obj:IsA("ImageLabel")
					or obj:IsA("ImageButton")
					or obj:IsA("Decal")
					or obj:IsA("Texture")
					or obj:IsA("Sound")
					or obj:IsA("Animation") then

					table.insert(LoadingAssets,obj)

				end
			end

			local TotalAssets = #LoadingAssets
			local Loaded = 0

			repeat 
				task.wait() 
			until Player:FindFirstChild('PlayerGui')

			Title.Text = GameName
			Title.TextTransparency = 1
			Title.Position = UDim2.new(0.231,0,0.35,0)

			FillBar.Size = UDim2.new(0,0,1,0)

			PercentageLabel.Text = "0%"
			AssetsLabel.Text = "Assets Loaded: 0/" .. TotalAssets

			GUI.Parent = Player.PlayerGui

			task.delay(1, function()
				TweenService:Create(
					Title,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						TextTransparency = 0,
						Position = UDim2.new(0.231,0,0.386,0)
					}
				):Play()
			end)

			for i = 1, TotalAssets do 
				local asset = LoadingAssets[i]

				local success, err = pcall(function()
					ContentProvider:PreloadAsync({asset})
				end)

				if not success then
					warn("Failed to preload", asset.Name)
					warn(err)
				end

				Loaded += 1

				local XSize = Loaded / TotalAssets

				if Loaded % 5 == 0 or Loaded == TotalAssets then
					AssetsLabel.Text = 
						"Assets Loaded: "
						.. Loaded
						.. "/"
						.. TotalAssets

					PercentageLabel.Text = 
						math.floor((XSize * 100) + 0.5)
						.. "%"

					TweenService:Create(
						FillBar,
						BarTweenInfo,
						{
							Size = UDim2.new(XSize,0,1,0)
						}
					):Play()
				end
			end

			task.wait(2)

			local FadeIn = TweenService:Create(
				Fade,
				FadeTweenInfo,
				{
					BackgroundTransparency = 0
				}
			)

			FadeIn:Play()

			FadeIn.Completed:Wait()

			StarterGUI:SetCoreGuiEnabled(
				Enum.CoreGuiType.Health,
				true
			)
			StarterGUI:SetCoreGuiEnabled(
				Enum.CoreGuiType.Backpack, 
				true
			)
			StarterGUI:SetCoreGuiEnabled(
				Enum.CoreGuiType.Chat, 
				true
			)
			StarterGUI:SetCoreGuiEnabled(
				Enum.CoreGuiType.PlayerList, 
				true
			)

			Frame:Destroy()

			local FadeOut = TweenService:Create(
				Fade,
				FadeTweenInfo,
				{
					BackgroundTransparency = 1
				}
			)	

			FadeOut:Play()
			FadeOut.Completed:Wait()

			GUI:Destroy()

			print("Loading Completed")
		end

		start_settings()		
		preload()
	end)

	if not setup_successful then
		warn("Loading screen setup failed:")
		warn(error_settingup)
	end
end

setup()