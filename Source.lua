local MarketplaceService = game:service'MarketplaceService'
local Songs = {}


--// AudioPoint Creation & Run Function
local function PlaySong(ID)
	local address = 'rbxassetid://'
	local AudioPoint = workspace:FindFirstChild('AdminAudioPoint')
	
	if not AudioPoint then
		AudioPoint = Instance.new('Sound',workspace)
		AudioPoint.Name = 'AdminAudioPoint'

		AudioPoint.Volume = 1
		AudioPoint.Looped = false
	end

	AudioPoint.SoundId = address..ID
	AudioPoint:Play()
end


--// Queue Control Function
local function PlayQueue()
	local IndexPos = 0
	for index = 1, #Songs do
		
		PlaySong(Songs[index-IndexPos])
		
		wait(1) --// Important Delay
		wait(workspace['AdminAudioPoint'].TimeLength)
		
		table.remove(Songs, index-IndexPos)
		IndexPos = IndexPos + 1
	end

	if #Songs > 0 then
		PlayQueue()
	end
end


--// Validation & Control Function
local function RunCommand(SongID)
	assert(tonumber(SongID), 'Invalid Argument')
	local ProductData = MarketplaceService:GetProductInfo(SongID)
	
	if ProductData and ProductData.AssetTypeId == 3 then
		Songs[#Songs+1] = SongID
		if #Songs == 1 then
			PlayQueue()
		end
	else
		error('Song ID not found!')
	end
end


--// Chat Command Function
game.Players.PlayerAdded:connect(function(player)
	player.Chatted:connect(function(message)
		
		if (message:lower()):sub(1,5) == ':play' then
			RunCommand(message:sub(7))
		end
	end)
end)
