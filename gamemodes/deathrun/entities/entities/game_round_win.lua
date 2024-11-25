ENT.Base = "base_point"
ENT.Type = "point"

function ENT:AcceptInput(inputName, activator, caller, data)
    if ( string.iequals(inputName, "RoundWin") ) then
        local winTeam = self:GetInternalVariable("TeamNum")
        DEATHRUN.RoundManager.EndRound(winTeam, team.GetName(winTeam).." win!")
    end
end