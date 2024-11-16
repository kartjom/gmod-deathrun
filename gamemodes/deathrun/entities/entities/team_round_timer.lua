ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:Initialize()
    if (self:GetStoredValue("startdisabled", "bool", false) || self:GetStoredValue("start_paused", "bool", true)) then
        self.Enabled = false
    else
        self.Enabled = true
    end

    self.OutputStatuses = {
        OnSetupStart = false,
        OnSetupFinished = false,
        OnRoundStart = false,
        On5MinRemain = false,
        On4MinRemain = false,
        On3MinRemain = false,
        On2MinRemain = false,
        On1MinRemain = false,
        On30SecRemain = false,
        On10SecRemain = false,
        On5SecRemain = false,
        On4SecRemain = false,
        On3SecRemain = false,
        On2SecRemain = false,
        On1SecRemain = false,
        OnFinished = false,
    }

    self.TimerLength = self:GetStoredValue("timer_length", "int", 0)
    self.MaxLength = self:GetStoredValue("max_length", "int", 0)
    self.AutoCountdown = self:GetStoredValue("auto_countdown", "bool", true)
    self.SetupLength = self:GetStoredValue("setup_length", "int")
    self.ResetTime = self:GetStoredValue("reset_time", "bool", false)

    self.RemainingTime = self.TimerLength
    self.Finished = (self.RemainingTime <= 0)
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "enable")) then self.Enabled = true end
    if (string.iequals(inputName, "disable")) then self.Enabled = false end
    if (string.iequals(inputName, "toggle")) then self.Enabled = !self.Enabled end

    --PrintMessage(HUD_PRINTTALK, "[DEV] team_round_timer "..inputName..": "..tostring(data))
end

function ENT:Think()
    if (self.Finished || !self.Enabled) then return end

    -- Decrement timer
    self.RemainingTime = self.RemainingTime - 1

    if (self.RemainingTime <= 300 && self:FireOutputIfAvailable("On5MinRemain")) then end
    if (self.RemainingTime <= 240 && self:FireOutputIfAvailable("On4MinRemain")) then end
    if (self.RemainingTime <= 180 && self:FireOutputIfAvailable("On3MinRemain")) then end
    if (self.RemainingTime <= 120 && self:FireOutputIfAvailable("On2MinRemain")) then end
    if (self.RemainingTime <= 60 && self:FireOutputIfAvailable("On1MinRemain")) then end
    if (self.RemainingTime <= 30 && self:FireOutputIfAvailable("On30SecRemain")) then end
    if (self.RemainingTime <= 10 && self:FireOutputIfAvailable("On10SecRemain")) then end
    if (self.RemainingTime <= 5 && self:FireOutputIfAvailable("On5SecRemain")) then end
    if (self.RemainingTime <= 3 && self:FireOutputIfAvailable("On3SecRemain")) then end
    if (self.RemainingTime <= 3 && self:FireOutputIfAvailable("On3SecRemain")) then end
    if (self.RemainingTime <= 2 && self:FireOutputIfAvailable("On2SecRemain")) then end
    if (self.RemainingTime <= 1 && self:FireOutputIfAvailable("On1SecRemain")) then end

    if (self.RemainingTime <= 0) then
        self:FireOutputIfAvailable("OnFinished")
        self.Finished = true
    end

    self:NextThink(CurTime() + 1)
    return true
end

function ENT:CanFireOutput(output)
    return !self.OutputStatuses[output]
end

function ENT:FireOutput(output)
    self.OutputStatuses[output] = true
    self:TriggerOutput(output)
end

function ENT:FireOutputIfAvailable(output)
    if (self:CanFireOutput(output)) then
        self:FireOutput(output)
    end
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end

function team_round_timer_OnSetupStart()
    for k,v in pairs(ents.FindByClass("team_round_timer")) do
        v:FireOutputIfAvailable("OnSetupStart")
    end
end

function team_round_timer_OnSetupFinished()
    for k,v in pairs(ents.FindByClass("team_round_timer")) do
        v:FireOutputIfAvailable("OnSetupFinished")
    end
end