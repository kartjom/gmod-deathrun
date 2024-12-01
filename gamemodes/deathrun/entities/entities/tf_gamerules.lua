ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "PlayVO")) then self:PlayVO(data) return end
    if (string.iequals(inputName, "PlayVOBlue")) then self:PlayVOBlue(data) return end
    if (string.iequals(inputName, "PlayVORed")) then self:PlayVORed(data) return end
end

function ENT:PlayVO(snd)
    PlaySound(snd)
end

function ENT:PlayVOBlue(snd)
    PlaySoundActivators(snd)
end

function ENT:PlayVORed(snd)
    PlaySoundRunners(snd)
end

function tf_gamerules_handleRoundEnd(winnerTeam)
    for k,v in pairs(ents.FindByClass("tf_gamerules")) do
        if (winnerTeam == DEATHRUN.TeamRunner()) then
            v:TriggerOutput("OnWonByTeam1", v)
        elseif (winnerTeam == DEATHRUN.TeamActivator()) then
            v:TriggerOutput("OnWonByTeam2", v)
        end
    end
end