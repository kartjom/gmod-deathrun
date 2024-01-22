ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:AcceptInput(inputName, activator, caller, data)
    if (inputName == "RoundWin") then
        local winTeam = self:GetInternalVariable("TeamNum")
        RoundManager.RoundEnd(winTeam, (winTeam == 2 and "Runners" or "Activator").." win!")
    end
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end