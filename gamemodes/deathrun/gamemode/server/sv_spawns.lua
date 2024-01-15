function GM:LookupSpawns()
    local mapver = self:GetMapVersion()
    self.TeamSpawns = { [TEAM.RUNNER] = {}, [TEAM.ACTIVATOR] = {} }

    if (mapver == MAPVER.CSS) then
        self.TeamSpawns[TEAM.RUNNER] = table.Add(self.TeamSpawns[TEAM.RUNNER], ents.FindByClass("info_player_counterterrorist"))
        self.TeamSpawns[TEAM.ACTIVATOR] = table.Add(self.TeamSpawns[TEAM.ACTIVATOR], ents.FindByClass("info_player_terrorist"))
    end

    if (mapver == MAPVER.TF2) then
        local tfSpawns = ents.FindByClass("info_player_teamspawn")
        for k,v in pairs(tfSpawns) do
            local TeamNum = v:GetInternalVariable("TeamNum")

            if (TeamNum == 2) then
                table.insert(self.TeamSpawns[TEAM.RUNNER], v)
            end

            if (TeamNum == 3) then
                table.insert(self.TeamSpawns[TEAM.ACTIVATOR], v)
            end
        end
    end
end

function GM:PlayerSelectSpawn(ply, transiton)
    local ent = self:PlayerSelectTeamSpawn( ply:Team(), ply )
    if ( IsValid( ent ) ) then return ent end

	if (!IsTableOfEntitiesValid(self.TeamSpawns)) then
		self:LookupSpawns()
	end

    local SpawnPoints = {}

    if (ply:IsRunner() || ply:IsActivator()) then
        SpawnPoints = self.TeamSpawns[ply:Team()]
    else
        SpawnPoints = self.TeamSpawns[TEAM.RUNNER]
    end

	local Count = table.Count(SpawnPoints)

	if (Count == 0) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil
	end

	-- If any of the spawnpoints have a MASTER flag then only use that one.
	-- This is needed for single player maps.
	for k, v in pairs(SpawnPoints) do

		if ( v:HasSpawnFlags( 1 ) && hook.Call( "IsSpawnpointSuitable", GAMEMODE, ply, v, true ) ) then
			return v
		end

	end

	local ChosenSpawnPoint = nil

	-- Try to work out the best, random spawnpoint
	for i = 1, Count do

		ChosenSpawnPoint = table.Random(SpawnPoints)

		if ( IsValid( ChosenSpawnPoint ) && ChosenSpawnPoint:IsInWorld() ) then
			if ( ( ChosenSpawnPoint == ply:GetVar( "LastSpawnpoint" ) || ChosenSpawnPoint == self.LastSpawnPoint ) && Count > 1 ) then continue end

			if ( hook.Call( "IsSpawnpointSuitable", GAMEMODE, ply, ChosenSpawnPoint, i == Count ) ) then

				self.LastSpawnPoint = ChosenSpawnPoint
				ply:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint

			end

		end

	end

	return ChosenSpawnPoint
end