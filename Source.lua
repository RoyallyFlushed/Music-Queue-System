local MarketplaceService = game:service'MarketplaceService'

local SkipCurrentSongToggle = false
local RepeatPlaylistToggle = false
local RepeatToggleWarden = false

--// Song Storage Entities
local CurrentPlaylist = {}
local RepeatPlaylist = {}


--// Repeat Playlist Function: Dumps songs into carbon copy
local function DumpSongs()
	for i,value in next, CurrentPlaylist do
		RepeatPlaylist[#RepeatPlaylist+1] = value
	end
end


--// Repeat Playlist Function: Normalise Dump
local function Filter()
	if (#RepeatPlaylist > 0) and (not RepeatPlaylistToggle) then
		for i,RepeatSongID in next, RepeatPlaylist do
			CurrentPlaylist[#CurrentPlaylist+1] = RepeatSongID
		end
	end
end


--// AudioPoint Creation & Run Function
local function PlaySong(ID)
    local address = 'rbxassetid://'
    local AudioPoint = workspace:FindFirstChild('AdminAudioPoint')
    
    if not AudioPoint then
        AudioPoint = Instance.new('Sound',workspace)
        AudioPoint.Name = 'AdminAudioPoint'
		Instance.new('NumberValue',AudioPoint).Name = 'SongTime'

        AudioPoint.Volume = 1
        AudioPoint.Looped = false
    end
	
    AudioPoint.SoundId = address..ID
    AudioPoint:Play()
end


--// Queue Control Function
local function PlayQueue(Playlist)
    local IndexPos = 0
    for index = 1, #Playlist do
		
        PlaySong(Playlist[index-IndexPos])
		local AudioPoint = workspace['AdminAudioPoint']
        
        wait(1) --// Important Delay

		--// Skip Song Function
		for WaitTime = 1, AudioPoint.TimeLength do
        	wait(1)
			if SkipCurrentSongToggle then
				SkipCurrentSongToggle = false
				AudioPoint:Stop()
				break
			end
		end
		
		--// Repeat Playlist Function: Dump into Source Playlist for iteration
		if RepeatToggleWarden then
			CurrentPlaylist[#CurrentPlaylist+1] = Playlist[index-IndexPos]
		end
		
        table.remove(Playlist, index-IndexPos)
        IndexPos = IndexPos + 1
    end

	--// Repeat Playlist Function: Validation & Switch Control
    if #CurrentPlaylist > 0 and (not RepeatPlaylistToggle) then
        PlayQueue(CurrentPlaylist)
	elseif (#RepeatPlaylist > 0) and (#CurrentPlaylist > 0) and (RepeatPlaylistToggle) then
		PlayQueue(CurrentPlaylist)
	elseif (#RepeatPlaylist > 0) and (#CurrentPlaylist == 0) and (RepeatPlaylistToggle) then
		RepeatToggleWarden = true
		PlayQueue(RepeatPlaylist)
	elseif (#RepeatPlaylist == 0) and (#CurrentPlaylist > 0) and (RepeatPlaylistToggle) then
	
		for i,value in next, CurrentPlaylist do
			RepeatPlaylist[#RepeatPlaylist+1] = value
		end
		
		--// Reset Source Playlist for no duplicates
		CurrentPlaylist = {}
		PlayQueue(RepeatPlaylist)
    end
end


--// Validation & Control Function
local function RunCommand(SongID)
    assert(tonumber(SongID), 'Invalid Argument')
    local ProductData = MarketplaceService:GetProductInfo(SongID)
    
    if ProductData and ProductData.AssetTypeId == 3 then
		
		--// Repeat Playlist Function: Traffic Diversion
		if not RepeatPlaylistToggle then
			CurrentPlaylist[#CurrentPlaylist+1] = SongID
		else
			warn('Song requests are prohibited during playlist loop')
		end
		
        if #CurrentPlaylist == 1 then
            PlayQueue(CurrentPlaylist)
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
		elseif (message:lower()):sub(1,5) == ':skip' then
			SkipCurrentSongToggle = true
		elseif (message:lower()):sub(1,7) == ':repeat' then
			RepeatPlaylistToggle = true
			DumpSongs()
		elseif (message:lower()):sub(1,10) == ':normalise' then
			RepeatPlaylistToggle = false
			RepeatToggleWarden = false
			Filter()
        end
    end)
end)
