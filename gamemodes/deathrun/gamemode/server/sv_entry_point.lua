function GM:InitPostEntity()
    self:SetupTeams()
    self:Main()
end

function GM:Main()
	timer.RemoveAllManaged()

    RoundManager.AwaitPlayers()  
end