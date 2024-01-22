function GM:PlayerInitialSpawn(ply)
    ply:SyncTeams()

    net.Start('GameStateUpdate')
        net.WriteInt(RoundManager.GameState, 8)
    net.Send(ply)

    ply:SetModel(string.format("models/player/group01/male_0%d.mdl", math.random(1, 9)))

    ply.InitialSpawn = true
end

function GM:PlayerSpawn(ply)
    if (ply.Initialized == nil) then ply.Initialized = false end

	if (!ply.Initialized) then
		ply.Initialized = true

		if (RoundManager.GameState == STATE.AWAIT) then
			ply:SetRunner()
		else
			ply:SetSpectator()
		end
	end

	ply.InitialSpawn = false
end

function GM:PlayerDeath(ply)
    ply.NextRespawn = CurTime() + 3

    if (ply:Team() == TEAM.RUNNER) then
        local runnersRemaining = #RoundManager.GetRunners()
    
        if (!RoundManager.FirstBlood && runnersRemaining > 1) then
            RoundManager.FirstBlood = true
    
            PlaySound(string.format("vo/announcer_am_firstblood0%d.mp3", math.random(1, 6)))
        end
    
        if (!RoundManager.LastManAlive && runnersRemaining == 1) then
            RoundManager.LastManAlive = true
    
            PlaySound(string.format("vo/announcer_am_lastmanalive0%d.mp3", math.random(1, 4)))
        end
    end
end

function GM:PlayerDeathThink(ply)
    if (CurTime() > ply.NextRespawn) then
        ply.Initialized = false
        ply:Spawn()
        return
    end

    return false
end

function GM:PlayerNoClip()
    return true
end

function GM:PlayerSpawnAsSpectator(ply)
    ply:SetSpectator()
end

function GM:CanPlayerSuicide(ply)
    return ply:IsRunner() || ply:IsActivator()
end

function GM:GetFallDamage(ply, speed)
    return (5 * ( speed / 300 ))
end