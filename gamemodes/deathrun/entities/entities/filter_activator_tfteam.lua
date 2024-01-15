ENT.Base = "base_filter"
ENT.Type = "filter"

function ENT:AcceptInput(inputName, activator, caller, data)
    PrintMessage(HUD_PRINTTALK, "[DEV] filter_activator_tfteam "..inputName.." - "..data)
end

function ENT:PassesFilter(trigger, ent)
    local teamNum = self:GetInternalVariable("TeamNum")
	return ent:IsPlayer() && ent:Team() == teamNum
end