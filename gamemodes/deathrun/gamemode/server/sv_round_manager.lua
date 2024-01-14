RoundManager = {}

function RoundManager.GetAlive()
    local players = player.GetAll()
    local alive = {}

    for k,v in pairs(players) do
        if ( v:Alive() && (v:IsRunner() || v:IsActivator()) ) then
            table.insert(alive, v)
        end
    end

    return alive
end

function RoundManager.GetRunners(alive)
    local players = team.GetPlayers(TEAM.RUNNER)
    local alive = {}

    for k,v in pairs(players) do
        if (v:Alive()) then
            table.insert(alive, v)
        end
    end

    return alive
end

function RoundManager.GetActivator(alive)
    local players = team.GetPlayers(TEAM.ACTIVATOR)
    local alive = {}

    for k,v in pairs(players) do
        if (v:Alive()) then
            table.insert(alive, v)
        end
    end

    return alive
end