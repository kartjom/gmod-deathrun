ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:AcceptInput(inputName, activator, caller, data)
    if (inputName == "RoundWin") then
        local winTeam = self:GetInternalVariable("TeamNum")
        DEATHRUN.RoundManager.EndRound(winTeam, team.GetName(winTeam).." win!")
    end
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end