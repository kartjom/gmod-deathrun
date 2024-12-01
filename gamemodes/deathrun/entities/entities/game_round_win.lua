ENT.Base = "base_point"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "RoundWin")) then self:RoundWin() end
    if (string.iequals(inputName, "SetTeam")) then self:SetTeam( tonumber(data) ) return end
end

function ENT:Initialize()
    self.TeamNum = self:GetStoredValue("TeamNum", "int", 0)
end

function ENT:RoundWin()
    DEATHRUN.RoundManager.EndRound(self.TeamNum, team.GetName(self.TeamNum).." win!")
    self:TriggerOutput("OnRoundWin")
end

function ENT:SetTeam(num)
    self.TeamNum = num
end