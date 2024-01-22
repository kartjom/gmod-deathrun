local ply = FindMetaTable("Player")

function ply:IsRunner()
    return self:Alive() && self:Team() == TEAM.RUNNER
end

function ply:IsActivator()
    return self:Alive() && self:Team() == TEAM.ACTIVATOR
end

function ply:ResetData()
    self.Initialized = false

    self:SetParent(NULL)
    self:SetGravity(0)
    self:Extinguish()

    self:StripWeapons()
    self:RemoveAllAmmo()

    self:SetNoDraw(false)
    self:SetColor(Color(255, 255, 255, 255))
    self:SetNoCollideWithTeammates(true)
    self:SetCustomCollisionCheck(false)
    self:SetNoTarget(false)
    self:AllowFlashlight(true)
    self:SetCanZoom(true)
    self:Freeze(false)
    self:SetMoveType(MOVETYPE_WALK)

    self:GodDisable()
    self:SetArmor(0)
    self:SetHealth(100)
    self:SetMaxHealth(100)
end

function ply:SetRunner()
    self:ResetData()
    self.Initialized = true
    
    self:SetTeam(TEAM.RUNNER)
    self:SetPlayerColor(team.GetColor(self:Team()):ToVector())

    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SelectWeapon("weapon_crowbar")

    self:SetJumpPower(180)
    self:SetWalkSpeed(270)
    self:SetRunSpeed(270)
end

function ply:SetActivator()
    self:ResetData()
    self.Initialized = true

    self:SetTeam(TEAM.ACTIVATOR)
    self:SetPlayerColor(team.GetColor(self:Team()):ToVector())

    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SelectWeapon("weapon_crowbar")

    self:SetJumpPower(220)
    self:SetWalkSpeed(360)
    self:SetRunSpeed(360)
end

function ply:SyncTeams()
    net.Start("SyncTeamCreation")
        net.WriteUInt(TEAM.RUNNER, 4)
        net.WriteUInt(TEAM.ACTIVATOR, 4)
    net.Send(self)
end

function ply:SyncTime()
    net.Start("RoundTimeUpdate")
        net.WriteUInt(RoundManager.CurrentTime, 16)
    net.Send(self)
end

function ply:SyncGameState()
    net.Start("GameStateUpdate")
        net.WriteUInt(RoundManager.GameState, 4)
    net.Send(self)
end

function ply:PlaySound(snd)
    net.Start("PlaySound")
        net.WriteString(snd)
    net.Send(self)
end

function PlaySound(snd)
    net.Start("PlaySound")
        net.WriteString(snd)
    net.Broadcast()
end