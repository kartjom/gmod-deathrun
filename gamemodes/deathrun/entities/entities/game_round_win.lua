ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:AcceptInput(inputName, activator, caller, data)
    local winTeam = self:GetInternalVariable("TeamNum")
    PrintMessage(HUD_PRINTTALK, (winTeam == 2 and "Runners" or "Activator").." win!")
end