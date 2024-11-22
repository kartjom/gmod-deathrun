AddCSLuaFile()
function util.GetAlivePlayers()
	local alive = {}
	for k, p in player.Iterator() do
	   if (IsValid(p) && p:Alive()) then
		  table.insert(alive, p)
	   end
	end
 
	return alive
 end
 
 function util.GetNextAlivePlayer(ply)
	local alive = util.GetAlivePlayers()
 
	if (#alive < 1) then return nil end

	local prev = nil
	local choice = nil
 
	if IsValid(ply) then
	   for k,p in ipairs(alive) do
		  if (prev == ply) then
			 choice = p
		  end
 
		  prev = p
	   end
	end
 
	if (!IsValid(choice)) then
	   choice = alive[1]
	end

	return choice
 end

 function util.GetPreviousAlivePlayer(ply)
	local alive = util.GetAlivePlayers()
	alive = table.Reverse(alive)
 
	if (#alive < 1) then return nil end
 
	local prev = nil
	local choice = nil
 
	if IsValid(ply) then
	   for k,p in ipairs(alive) do
		  if (prev == ply) then
			 choice = p
		  end
 
		  prev = p
	   end
	end
 
	if (!IsValid(choice)) then
	   choice = alive[1]
	end
 
	return choice
 end

 function string.iequals(a, b)
	return string.lower(a) == string.lower(b)
 end

function ternary(cond, a, b)
	if (cond) then
		return a
	else
		return b
	end
end