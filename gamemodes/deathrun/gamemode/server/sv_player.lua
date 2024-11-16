local ply = FindMetaTable("Player")

function ply:SetRunner()
    player_manager.SetPlayerClass(self, "deathrun_runner")
    player_manager.RunClass(self, "SetTeam")
    self:Spawn()
end

function ply:SetActivator()
    player_manager.SetPlayerClass(self, "deathrun_activator")
    player_manager.RunClass(self, "SetTeam")
    self:Spawn()
end

function ply:PlaySound(snd)
    net.Start("DEATHRUN.PlaySound")
        net.WriteString(snd)
    net.Send(self)
end

function PlaySound(snd)
    net.Start("DEATHRUN.PlaySound")
        net.WriteString(snd)
    net.Broadcast()
end

hook.Add("EntityTakeDamage", "DEATHRUN.DamageMultiplier", function(target, dmginfo)
    if (target:IsPlayer() && dmginfo:GetAttacker():IsPlayer() && dmginfo:GetDamageType() == DMG_CLUB) then
        dmginfo:SetDamage(target:GetMaxHealth() / 2)
    end
end)

hook.Add("PlayerShouldTakeDamage", "DEATHRUN.AntiTeamKill", function(ply, attacker)
	if (attacker:IsPlayer() && ply:Team() == attacker:Team()) then
		return false
	end
end)