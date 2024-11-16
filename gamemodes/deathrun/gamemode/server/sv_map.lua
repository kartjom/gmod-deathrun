function DEATHRUN.GetGameVersion()
    if (!DEATHRUN.GameVersion) then
        local tfSpawns = ents.FindByClass("info_player_teamspawn")
        local cssSpawns = ents.FindByClass("info_player_*terrorist")

        if (#tfSpawns > 0) then
            DEATHRUN.GameVersion = DEATHRUN.GAME.TF2
        elseif (#cssSpawns > 0) then
            DEATHRUN.GameVersion = DEATHRUN.GAME.CSS
        else
            DEATHRUN.GameVersion = DEATHRUN.GAME.OTHER
        end
    end

    return DEATHRUN.GameVersion
end

function DEATHRUN.SetupTeams()
    local game_ver = DEATHRUN.GetGameVersion()

    if (game_ver == DEATHRUN.GAME.TF2) then
        SetGlobal2Int("DEATHRUN.Team.Runner", 2)
        SetGlobal2Int("DEATHRUN.Team.Activator", 3)
    elseif (game_ver == DEATHRUN.GAME.CSS || game_ver == DEATHRUN.GAME.OTHER) then
        SetGlobal2Int("DEATHRUN.Team.Runner", 3)
        SetGlobal2Int("DEATHRUN.Team.Activator", 2)
    end

    team.SetUp(DEATHRUN.TeamRunner(), "Runners", Color(0, 100, 255))
    team.SetUp(DEATHRUN.TeamActivator(), "Activator", Color(255, 0, 0))
end

function DEATHRUN.LookupSpawns()
    local game_ver = DEATHRUN.GetGameVersion()
    DEATHRUN.TeamSpawns = { [DEATHRUN.TeamRunner()] = {}, [DEATHRUN.TeamActivator()] = {} }

    if (game_ver == DEATHRUN.GAME.CSS) then
        DEATHRUN.TeamSpawns[DEATHRUN.TeamRunner()] = table.Add(DEATHRUN.TeamSpawns[DEATHRUN.TeamRunner()], ents.FindByClass("info_player_counterterrorist"))
        DEATHRUN.TeamSpawns[DEATHRUN.TeamActivator()] = table.Add(DEATHRUN.TeamSpawns[DEATHRUN.TeamActivator()], ents.FindByClass("info_player_terrorist"))
    end

    if (game_ver == DEATHRUN.GAME.TF2) then
        local tfSpawns = ents.FindByClass("info_player_teamspawn")
        for k,v in pairs(tfSpawns) do
            local TeamNum = v:GetInternalVariable("TeamNum")

			if (TeamNum == DEATHRUN.TeamRunner() || TeamNum == DEATHRUN.TeamActivator()) then
            	table.insert(DEATHRUN.TeamSpawns[TeamNum], v)
			end
        end
    end
end

function GM:PlayerSelectSpawn(ply, transiton)
	if (!IsTableOfEntitiesValid(DEATHRUN.TeamSpawns)) then
		DEATHRUN.LookupSpawns()
	end

    local SpawnPoints = {}

    if (ply:IsRunner() || ply:IsActivator()) then
        SpawnPoints = DEATHRUN.TeamSpawns[ply:Team()]
    else
        SpawnPoints = DEATHRUN.TeamSpawns[DEATHRUN.TeamRunner()]
    end

	local Count = #SpawnPoints
	if (Count == 0) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil
	end

	local ChosenSpawnPoint = nil

	-- Try to work out the best, random spawnpoint
	for i = 1, Count do
		ChosenSpawnPoint = table.Random(SpawnPoints)
		if (IsValid(ChosenSpawnPoint ) && ChosenSpawnPoint:IsInWorld()) then
			if ((ChosenSpawnPoint == ply:GetVar("LastSpawnpoint") || ChosenSpawnPoint == self.LastSpawnPoint) && Count > 1) then continue end

			if (hook.Call( "IsSpawnpointSuitable", GAMEMODE, ply, ChosenSpawnPoint, i == Count)) then
				self.LastSpawnPoint = ChosenSpawnPoint
				ply:SetVar("LastSpawnpoint", ChosenSpawnPoint)
				return ChosenSpawnPoint
			end
		end
	end

	return ChosenSpawnPoint
end

-- Prevent spawnkill
function GM:IsSpawnpointSuitable(ply, spawnpoint, makeSuitable)
    return true
end