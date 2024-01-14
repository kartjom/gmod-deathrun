local ply = FindMetaTable("Player")

function ply:IsSpectator()
    return self:Alive() && self:Team() == TEAM.SPECTATOR
end

function ply:IsRunner()
    return self:Alive() && self:Team() == TEAM.RUNNER
end

function ply:IsActivator()
    return self:Alive() && self:Team() == TEAM.ACTIVATOR
end

function ply:ResetData()
    self:StripWeapons()
    self:RemoveAllAmmo()
end

function ply:SetRunner()
    self:SetTeam(TEAM.RUNNER)
    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SetJumpPower(160)

    self:SetWalkSpeed(220)
    self:SetRunSpeed(220)
end

function ply:SetActivator()
    self:SetTeam(TEAM.ACTIVATOR)
    self:UnSpectate()
    self:Spawn()

    self:Give("weapon_crowbar")
    self:SetJumpPower(220)

    self:SetWalkSpeed(340)
    self:SetRunSpeed(340)
end