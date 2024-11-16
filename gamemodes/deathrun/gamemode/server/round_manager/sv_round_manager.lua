DEATHRUN.CVAR = {}
DEATHRUN.CVAR.PrepareTime = CreateConVar("dr_prepare_time", 11, FCVAR_ARCHIVE, "Preparing time in seconds", 11, 20)
DEATHRUN.CVAR.ActionTime = CreateConVar("dr_action_time", 15*60, FCVAR_ARCHIVE, "Round time in seconds", 5*60, 20*60)
DEATHRUN.CVAR.EndTime = CreateConVar("dr_end_time", 10, FCVAR_ARCHIVE, "Post round time in seconds", 5, 30)

DEATHRUN.RoundManager.FirstBlood = false
DEATHRUN.RoundManager.LastManAlive = false

include("game_states/await.lua")
include("game_states/prepare.lua")
include("game_states/action.lua")
include("game_states/end.lua")

function DEATHRUN.RoundManager.SetTime(seconds)
    return SetGlobal2Int("DEATHRUN.RoundEndTime", math.ceil(CurTime() + seconds))
end

function DEATHRUN.RoundManager.SetState(state)
    DEATHRUN.RoundManager.RunMethod(state, "OnEnter", {})
    return SetGlobal2Int("DEATHRUN.RoundState", state)
end

function DEATHRUN.RoundManager.RunMethod(state, name, args)
    if (!table.HasValue(DEATHRUN.STATE, state)) then return end

    local stateName = string.lower( table.KeyFromValue(DEATHRUN.STATE, state) ):gsub("^%l", string.upper)

    local method = DEATHRUN.RoundManager[stateName..name]
    if (method != nil) then
        method(unpack(args))
    end
end

local currentTimeEvent = 0
hook.Add("Think", "DEATHRUN.RoundTick", function()
    local currentState = DEATHRUN.RoundManager.GetState()    
    local timeLeft = math.ceil(DEATHRUN.RoundManager.GetTimeLeft())
    
    if (timeLeft == 0) then
        DEATHRUN.RoundManager.RunMethod(currentState, "OnTimeOut", {})
    elseif (timeLeft != currentTimeEvent) then
        currentTimeEvent = timeLeft
        DEATHRUN.RoundManager.RunMethod(currentState, "TimeEvent", { timeLeft })
    end
end)

function DEATHRUN.RoundManager.RestartRound()
    PrintMessage(HUD_PRINTCENTER, "Restarting")

    math.randomseed(os.time() + os.clock() + tonumber(tostring({}):sub(8)) + math.floor(math.random() * 1000000))
    game.CleanUpMap()

    for k,v in pairs(ents.FindByClass("func_door")) do
        if (v:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR) then
            v:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end

    DEATHRUN.RoundManager.FirstBlood = false
    DEATHRUN.RoundManager.LastManAlive = false

    if (player.GetCount() < 2) then
        DEATHRUN.RoundManager.SetState(DEATHRUN.STATE.AWAIT)
        
        for k,v in pairs(player.GetAll()) do
            v:SetRunner()
        end
        
        return
    end
    
    DEATHRUN.RoundManager.SetState(DEATHRUN.STATE.PREPARE)
end

function DEATHRUN.RoundManager.EndRound(winnerTeam, message)
    if (DEATHRUN.RoundManager.GetState() == DEATHRUN.STATE.END) then return end
    DEATHRUN.RoundManager.SetState(DEATHRUN.STATE.END)

    DEATHRUN.RoundManager.BroadcastRoundEnd(winnerTeam)
    tf_gamerules_handleRoundEnd(winnerTeam)

    for k,v in pairs(player.GetAll()) do
        if (v:Alive() && v:Team() != winnerTeam) then
            v:StripWeapons()
        end
    end

    PrintMessage(HUD_PRINTCENTER, message)
end