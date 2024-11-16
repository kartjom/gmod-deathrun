ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	end
end

-- function ENT:AcceptInput(inputName, activator, caller, data)
--     PrintMessage(HUD_PRINTTALK, "[DEV] tf_gamerules "..inputName..": "..tostring(data))
-- end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end

function tf_gamerules_handleRoundEnd(winnerTeam)
    for k,v in pairs(ents.FindByClass("tf_gamerules")) do
        if (winnerTeam == DEATHRUN.TeamRunner()) then
            v:TriggerOutput("OnWonByTeam1", v)
        elseif (winnerTeam == DEATHRUN.TeamActivator()) then
            v:TriggerOutput("OnWonByTeam2", v)
        else
            v:TriggerOutput("OnWonByTeam1", v)
            v:TriggerOutput("OnWonByTeam2", v)
        end
    end
end