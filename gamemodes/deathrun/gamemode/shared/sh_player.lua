AddCSLuaFile()
local ply = FindMetaTable("Player")

function ply:IsSpectator()
    local mode = self:GetObserverMode()
    return !self:Alive() && (mode == OBS_MODE_ROAMING || mode == OBS_MODE_IN_EYE || mode == OBS_MODE_CHASE)
end

function ply:IsRunner(allowDead)
    if (!allowDead && self:IsSpectator()) then return false end

    return self:Team() == DEATHRUN.TeamRunner()
end

function ply:IsActivator(allowDead)
    if (!allowDead && self:IsSpectator()) then return false end

    return self:Team() == DEATHRUN.TeamActivator()
end

if SERVER then return end -- CLIENT CODE

net.Receive("DEATHRUN.PlaySound", function()
    local snd = net.ReadString()
    surface.PlaySound(snd)
end)

net.Receive("DEATHRUN.RoundEnd", function()
    local winnerTeam = net.ReadUInt(3)
    local plyTeam = LocalPlayer():Team()

    if (winnerTeam == 0) then
        surface.PlaySound("vo/announcer_stalemate.mp3")
        return
    end

    if (plyTeam == winnerTeam) then
        surface.PlaySound("ui/mm_match_end_win_music_casual.wav")
    else
        surface.PlaySound("ui/mm_match_end_lose_music_casual.wav")
    end
end)