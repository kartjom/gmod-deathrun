local managedTimers = {}

function timer.CreateManaged(identifier, delay, repetitions, callback)
    timer.Create(identifier, delay, repetitions, callback)
    managedTimers[identifier] = true
end

function timer.RemoveManaged(identifier)
    timer.Remove(identifier)
    managedTimers[identifier] = nil
end

function timer.RemoveAllManaged()
    for k,v in pairs(managedTimers) do
        timer.Remove(k)
    end

    managedTimers = {}
end