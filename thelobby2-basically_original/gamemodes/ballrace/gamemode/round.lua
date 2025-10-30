include("roundrestart.lua")

local placement = 0
local timecompleted = 0
local level = 1

tries = 0

LEVEL_MUSIC = 1
BONUS_STAGE = 2
STAGE_FAILED = 3

local lcount = 0

function LvlAmount()

	if lcount != 0 then return lcount end

	for k,v in pairs(ents.FindByClass( "info_target" )) do

		if (string.StartWith(v:GetName(),"lvl") || string.StartWith(v:GetName(),"lv")) then
			lcount = lcount + 1
		end
	end

	return lcount

end

hook.Add("GTowerMsg", "GamemodeMessage", function()
	if player.GetCount() < 1 then
		return "#nogame"
	else
		if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
			return "-1/" .. LvlAmount()+1
		else
			return tostring(math.Clamp( level, 1, LvlAmount()+1 )) .. "/" .. LvlAmount()+1
		end
	end
end )

function GM:RoundMessage( msg )
	net.Start("roundmessage")
		net.WriteInt( msg, 3 )
	net.Broadcast()
end

function GetNextSpawn()

	// Check if it's lvl 1.
	for k,v in pairs(ents.FindByClass("info_target")) do
		if LateSpawn == nil then
			if (v:GetName() == "lvl2_start" || v:GetName() == "lv2_start") then
				return v
			end
		end
	end

	if LateSpawn == nil then return end

	if string.StartWith( game.GetMap(), "gmt_ballracer_memories" ) then
		if LateSpawn:GetName() == "lvl6_start" then
			for k,v in pairs(ents.FindByClass("info_target")) do
				// On the path level, choose random.
				if math.random(1,2) == 1 then if v:GetName() == "lvlRT_1_start" then return v end
				else if v:GetName() == "lvlLT_1_start" then return v end end
			end
		else

		// Path management
		for k,v in pairs(ents.FindByClass("info_target")) do
		if string.StartWith( LateSpawn:GetName(), "lvlRT" ) or string.StartWith( LateSpawn:GetName(), "lvlLT" ) then
			if LateSpawn:GetName() != "lvlLT_2_start" and LateSpawn:GetName() != "lvlRT_2_start" then
				if string.StartWith( LateSpawn:GetName(), "lvlRT" ) then
					if v:GetName() == "lvlRT_2_start" then return v end
				elseif string.StartWith( LateSpawn:GetName(), "lvlLT" ) then
					if v:GetName() == "lvlLT_2_start" then return v end
				end
			else
				if v:GetName() == "lvl7_start" then return v end
			end
		end
		end
		end

		--return false

	end

	// Prevents the other code from running
	local memlvls = {"lvl6_start","lvlLT_1_start","lvlLT_2_start","lvlRT_1_start","lvlRT_2_start"}
	if string.StartWith( game.GetMap(), "gmt_ballracer_memories" ) and table.HasValue(memlvls,LateSpawn:GetName()) then return end

	// Get the next level under normal circumstances
	for k,v in pairs(ents.FindByClass("info_target")) do
		// Gets the number of the current spawn
		local CurLVL = string.gsub( LateSpawn:GetName(), '[%a _]', '' )

		// Gets the name before the number, in every map always 'lvl'.
		local CurLVLName = string.gsub( LateSpawn:GetName(), '%d', '' )

		// Checks for the left/right paths on Memories.

		// No paths found, gets the first 3 letters.
		if string.StartWith( game.GetMap(), "gmt_ballracer_neonlights" ) then
			CurLVLName = string.sub( CurLVLName, 1, 2 )
		else
			CurLVLName = string.sub( CurLVLName, 1, 3 )
		end

		// Makes it 'lvlnumber_start'
		if v:GetName() == CurLVLName .. ( tonumber( CurLVL ) + 1 ) .. "_start" then return v end
	end
end

function GM:UpdateStatus(disc)

	if ( self:GetState() != STATE_PLAYING && self:GetState() != STATE_PLAYINGBONUS ) then return end

	local dead = NumPlayers(TEAM_DEAD)
	local complete = NumPlayers(TEAM_COMPLETED)

	local total = player.GetCount()
	if disc then
		total = total - 1
		dead = dead - 1
	end

	if total == 0 then
		self:RestartLevel()
		return
	end

	if dead + complete >= total then

		self.PreviousState = self:GetState()

		if complete > 0 then

			for k,v in pairs(player.GetAll()) do
				for ply,afk in pairs(afks) do
					if !afk then continue end
					if !IsValid(ply) or !IsValid(v) then return end

					if afk then
						GAMEMODE:ColorNotifyAll( ply:Name().." has automatically forfeited due to being AFK.", Color(200, 200, 200, 255) )
					end
				end
			end

			timer.Simple( 1.25, function() level = level + 1 end )
			tries = 0
			// Fokin' network delay
			timer.Simple( 0.01, function() GAMEMODE:GiveMoney() end )
			GetWorldEntity():SetNet( "Passed", true )

			if NextMap then
				if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
					for k,v in pairs(player.GetAll()) do v:AddAchievement( ACHIEVEMENTS.BRMEMORIES, 1 ) end
				end
				for k,v in pairs(player.GetAll()) do if !v:GetNWBool("Popped") then v:AddAchievement( ACHIEVEMENTS.BRUNPOPABLE, 1 ) end end
				self:RoundMessage( MSGSHOW_WORLDCOMPLETE )
			else
				self:RoundMessage( MSGSHOW_LEVELCOMPLETE )
			end

			LateSpawn = ActiveTeleport

		else

			if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
				self:RoundMessage( MSGSHOW_LEVELCOMPLETE )
				LateSpawn = BonusTeleport
				ActiveTeleport = BonusTeleport
				timer.Simple( 0.01, function() GAMEMODE:GiveMoney() end )
				GetWorldEntity():SetNet( "Passed", true )
			else
				if tries < 2 then
					self:RoundMessage( MSGSHOW_LEVELFAIL )
				else
					self:RoundMessage( MSGSHOW_LEVELCOMPLETE )
				end
				self:ResetGame(true)
			end

		end

		self:SetState( STATE_INTERMISSION )
		self:SetTime( self.IntermissionTime )

	end

end

function GM:StopRound()

	for k,v in ipairs(player.GetAll()) do
		if v:Team() == TEAM_PLAYERS then
			v:SetDeaths(1)
			v:Kill()
		end
	end

end

function GM:StartRound()

	for k,v in pairs(player.GetAll()) do v.BestTime = nil end
	self:SetState( STATE_SPAWNING )

	if NextMap then
		self:EndServer()
		return
	end

	for k, v in pairs( ents.FindByClass( "secret_banana" ) ) do
		v:Remove()
	end

	GAMEMODE:SpawnAllPlayers()

	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("Died",false)
		v:SetNWBool("PressedButton",false)

		v:SetFrags(0)

		v:SetNet( "CompletedTime", "" )
		v:SetNet( "CompletedRank", 99 )
	end

	GetWorldEntity():SetNet( "Passed", false )

	local NextRoundTime
	local NextRoundState

	if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
		music.Play( 1, MUSIC_BONUS )
		NextRoundState = STATE_PLAYINGBONUS
		NextRoundTime = ( self.DefaultLevelTime/2 )
	else
		music.Play( 1, MUSIC_LEVEL )
		NextRoundState = STATE_PLAYING
		NextRoundTime = self.DefaultLevelTime
	end

	self:SetState( NextRoundState )
	self:SetTime( NextRoundTime )

	local banana = ents.Create( "secret_banana" )

	if game.GetMap() == "gmt_ballracer_facile" then
		banana:SetPos( Vector( 6529.704102, -2639.191895, 976.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_grassworld01" then
		banana:SetPos( Vector( -11604.712891, 1274.085327, -87.976440 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_iceworld03" then
		banana:SetPos( Vector( -8052.416016, -1020.629761, 3399.081299 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_khromidro02" then
		banana:SetPos( Vector( -3301.433105, 894.710388, 816.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_memories02" then
		banana:SetPos( Vector( -7167.748535, -3720.391846, 313.542908 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_metalworld" then
		banana:SetPos( Vector( 12423.720703, 2957.742188, 616.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_midori02" then
		banana:SetPos( Vector( 3265.398926, -2512.039307, 688.281250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_nightball" then
		banana:SetPos( Vector( 5349.190430, 1247.135376, -105.520416 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_paradise03" then
		banana:SetPos( Vector( 4976.476563, 13198.571289, -227.520325 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_prism03" then
		banana:SetPos( Vector( 2617.929688, 5062.750488, 959.974976 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_sandworld02" then
		banana:SetPos( Vector( 584.904602, 7399.568848, 370.634308 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_skyworld01" then
		banana:SetPos( Vector( 1216.430298, -223.383209, 408.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_spaceworld01" then
		banana:SetPos( Vector( -5632.618652, -4192.765137, -127.968750 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_summit" then
		banana:SetPos( Vector( -8089.092773, -5857.746094, 208.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_waterworld02" then
		banana:SetPos( Vector( 8755.546875, -1417.295654, 288.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_flyinhigh01" then
		banana:SetPos( Vector( -1664.000000, -9344.000000, 16.031250 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_neonlights01" then
		banana:SetPos( Vector( -1076.816895, -3247.885742, -336.675140 ) )
		banana:Spawn()
	elseif game.GetMap() == "gmt_ballracer_tranquil01" then
		banana:SetPos( Vector( -6645.774414, 6593.495117, 110 ) )
		banana:Spawn()
	end

	placement = 0

end

hook.Add( "Think", "RoundController", function()

	if GAMEMODE:GetState() == STATE_WAITING && GAMEMODE:GetTimeLeft() <= 0 then
		GAMEMODE:StartRound()
	elseif ( GAMEMODE:GetState() == STATE_PLAYING || GAMEMODE:GetState() == STATE_PLAYINGBONUS ) && GAMEMODE:GetTimeLeft() <= 0 then
		GAMEMODE:StopRound()
		GAMEMODE:UpdateStatus(false)
	elseif GAMEMODE:GetState() == STATE_INTERMISSION && GAMEMODE:GetTimeLeft() <= 0 then
		GAMEMODE:StartRound()
	end

end )

function GM:RestartLevel()

	game.ConsoleCommand("changelevel " .. table.Random(Levels) .. "\n")

end

function GM:ResetGame()

	for k,v in pairs(player.GetAll()) do v.BestTime = nil end

	tries = tries + 1

	if tries == GAMEMODE.MaxFailedAttempts then
		tries = 0

		local lvls = {}

		for k,v in pairs(ents.FindByClass("info_target")) do
			local LVL = string.gsub( v:GetName(), '[%a _]', '' )
			table.insert(lvls,LVL)
		end

		if level != #lvls then
			level = level + 1
			local NextLVL = GetNextSpawn()

			if NextLVL == nil then
				self:RoundMessage( MSGSHOW_WORLDCOMPLETE )

				self:ColorNotifyAll( "You've failed too many times! Ending game!" )

				NextMap = true

				return
			end

			timer.Simple(0.2,function()
				ActiveTeleport = NextLVL
				LateSpawn = NextLVL
			end)

			self:ColorNotifyAll( "You've failed too many times! Moving to the next level!" )
		else
			self:RoundMessage( MSGSHOW_WORLDCOMPLETE )

			self:ColorNotifyAll( "You've failed too many times! Ending game!" )

			NextMap = true
		end

	end

	/*net.Start("BGM")
	net.WriteInt( STAGE_FAILED, 3 )
	net.Broadcast()

	music.StopAll( true, 1 )*/

	for k,v in pairs(player.GetAll()) do
		v:SetFrags(0)
	end

	timer.Simple( 0, function()
		game.CleanUpMapEx()
		GAMEMODE.SpawnPoints = nil
	end )

end

function GM:LostPlayer(ply, disc)

	if IsValid(ply.Ball) then
		ply.Ball:Remove()
	end

	ply.Ball = nil
	ply:SetBall(NULL)

	GAMEMODE:UpdateStatus(disc)

end

function GM:SaveBestTime(ply, lvl, time, update)

	if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 71 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 81 end

		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 72 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 82 end
	end

	if !tmysql and SQL.getDB() != false then
		return
	end

	if update then
		SQL.getDB():Query(
		"UPDATE gm_ballrace SET time=".. time .." WHERE ply='"..ply:SteamID64().."' AND name='"..ply:Name().."' AND map='"..game.GetMap().."' AND lvl='"..lvl.."'", SQLLogResult)
		ply:AddAchievement( ACHIEVEMENTS.BRTHATSARECORD, 1 )
		ply:AddAchievement( ACHIEVEMENTS.BRHARDERBETTERFASTERSTRONGER, 1 )
		return
	end

	SQL.getDB():Query("CREATE TABLE IF NOT EXISTS gm_ballrace(ply TINYTEXT, name TINYTEXT,map TINYTEXT, lvl TINYTEXT, time FLOAT NOT NULL)")

	SQL.getDB():Query(
	"INSERT INTO gm_ballrace(`ply`,`name`,`map`,`lvl`,`time`) VALUES ('".. ply:SteamID64() .."','".. ply:Name() .."','".. game.GetMap() .."','".. lvl .."',".. time ..")", SQLLogResult)

end

function GM:GetBestTime(ply, lvl)

	if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 71 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 81 end

		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 72 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 82 end
	end

	if !tmysql and SQL.getDB() != false then
		return
	end

	local res = SQL.getDB():Query("SELECT * FROM gm_ballrace WHERE ply='"..ply:SteamID64().."' AND map='"..game.GetMap().."' AND lvl='"..lvl.."'", function(res)

		if !res then return end

		local row = res[1].data[1]
		if row then
			ply.BestTime = tonumber(row.time)
		end
	end)

end

function GetRaceTime()
	return GAMEMODE.DefaultLevelTime-GAMEMODE:GetTimeLeft()
end

function GM:PlayerComplete(ply)

	ply.RaceTime = GetRaceTime()
	ply.NextSpawn = CurTime()
	ply:KillSilent()

	ply:AddAchievement( ACHIEVEMENTS.BRMASTER, 1 )
	ply:AddAchievement( ACHIEVEMENTS.BRMILESTONE1, 1 )

	if ply:Frags() == 0 then ply:AddAchievement( ACHIEVEMENTS.BRLASTINLINE, 1 ) end

	if tmysql and SQL.getDB() != false then

	self:GetBestTime(ply, level)

	timer.Simple(1,function()

		if ply.BestTime == nil then
			self:SaveBestTime(ply, level, ply.RaceTime, false)
			self:ColorNotifyPlayer( ply, "New best time!", Color(100, 100, 255, 255) )
		else
			if ply.BestTime <= ply.RaceTime then
				self:ColorNotifyPlayer( ply, "Your best time is still "..math.Round(ply.BestTime,2), Color(100, 100, 255, 255) )
			end

			if ply.BestTime > ply.RaceTime then
				self:SaveBestTime(ply, level, ply.RaceTime, true)
				self:ColorNotifyPlayer( ply, "New best time "..math.Round(ply.RaceTime,2).."! Old time was "..math.Round(ply.BestTime,2), Color(100, 100, 255, 255) )
			end

		end

		ply.BestTime = nil

	end)

	end

	local vPoint = ply:GetPos()
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( "ball_transport", effectdata )

	ply:SetTeam(TEAM_COMPLETED)
	GAMEMODE:UpdateSpecs(ply, true)

	GAMEMODE:LostPlayer(ply)

	placement = placement + 1

	local finishTime = string.FormattedTime( ply.RaceTime )

	ply:SetNet( "CompletedRank", placement )
	ply:SetNet( "CompletedTime", tostring(string.format("%0.2i", math.floor(finishTime.s)).."."..string.format("%0.2i", math.floor(finishTime.ms) ) ) )

	--PrintMessage( HUD_PRINTTALK, ply:Name()..' got '..PlacementPostfix(placement)..' place! Time Completed: '..string.FormattedTime(ply.RaceTime, "%02i:%02i:%02i")..'.' )
	self:ColorNotifyAll( "LVL "..level.." #"..placement.." "..ply:Name().." | "..ply:GetNet( "CompletedTime" ) )

end

function GM:SpawnAllPlayers()

	for k,v in ipairs(player.GetAll()) do
		v:SetDeaths(GAMEMODE.Lives)
		v:Spawn()
	end

end

function GM:UpdateSpecs(ply, dead)

	// don't bother updating specs when we're spawning
	if self:GetState() == STATE_SPAWNING then return end

	for k,v in ipairs(player.GetAll()) do
		if v:Team() != TEAM_PLAYERS && v.Spectating == ply:EntIndex() then
			if dead then
				GAMEMODE:SpectateNext(v)
			else
				v:SetBall(ply.Ball)
			end
		end
	end

end

function GM:SpectateNext(ply)

	local start = ply.Spectating

	local newspec = start

	local players = player.GetAll()

	local k, v = next(players, start)
	if !k then k, v = next(players) end

	while k != start do
		if v:Team() == TEAM_PLAYERS then
			newspec = k
			break
		end

		k, v = next(players, k)
		if !k then
			if start == nil then break end
			k, v = next(players)
		end

		if v == ply then start = k break end --hack to stop this from doing an infinite loop
	end

	ply.Spectating = newspec

	local ent = nil
	if players[newspec] then ent = players[newspec].Ball end

	ply:SetBall(ent)

end

function PlacementPostfix(num)

	if ( num == 1 ) then
		return tostring(num.."st")
	elseif ( num == 2 ) then
		return tostring(num.."nd")
	elseif ( num == 3 ) then
		return tostring(num.."rd")
	elseif ( num > 3 ) then
		return tostring(num.."th")
	end

end