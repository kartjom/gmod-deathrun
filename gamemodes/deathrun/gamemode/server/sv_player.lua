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
    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SetJumpPower(160)

    self:SetWalkSpeed(250)
    self:SetRunSpeed(250)
end

function ply:SetActivator()
    self:ResetData()
    self.Initialized = true

    self:SetTeam(TEAM.ACTIVATOR)
    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SetJumpPower(220)

    self:SetWalkSpeed(360)
    self:SetRunSpeed(360)
end

function ply:SyncTeams()
    net.Start("SyncTeamCreation")
        net.WriteInt(TEAM.RUNNER, 16)
        net.WriteInt(TEAM.ACTIVATOR, 16)
    net.Send(self)
end

function ply:SyncTime()
    net.Start("RoundTimeUpdate")
        net.WriteInt(RoundManager.CurrentTime, 32)
    net.Send(self)
end

function ply:SyncGameState()
    net.Start('GameStateUpdate')
        net.WriteInt(RoundManager.GameState, 8)
    net.Send(self)
end