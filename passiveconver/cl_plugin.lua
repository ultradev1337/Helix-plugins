local PLUGIN = PLUGIN;

local function offsound()
	return "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav";
end;

local function onsound()
	return "npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav";
end;

local function dispatchon()
	return "npc/overwatch/radiovoice/on3.wav";
end;

local function dispatchoff()
	return "npc/overwatch/radiovoice/off2.wav";
end;

local lookup = {};
lookup["onsound"] = onsound;
lookup["offsound"] =  offsound;
lookup["dispatchon"] = dispatchon;
lookup["dispatchoff"] = dispatchoff;

function PLUGIN:PlayConversation(player, convTable)
	if (!IsValid(player)) then return; end;
	local totalDuration = 0;
	local uid = player:AccountID();

	for k, v in pairs(convTable) do
		if (lookup[v]) then
			convTable[k] = lookup[v]();
		end;
	end;

	player:EmitSound(convTable[1], 75, 100, 0.55);

	for i = 2, #convTable do
		local wait = 0;

		for q = 1, i - 1 do
			local duration = SoundDuration(convTable[q]);

			if (convTable[q]:find("vo/off") or convTable[q]:find("radiovoice/off2")) then
				duration = duration + 0.1;
			end;

			wait = wait + duration;
		end;

		timer.Create("ConvTimer_" .. uid .. "_" .. i, wait + 0.05, 1, function()
			if (IsValid(player)) then
				player:EmitSound(convTable[i], 75, 100, 0.23);
			end;
		end);
	end;
end;

netstream.Hook("PlayConversation", function(data)
	PLUGIN:PlayConversation(data[1], data[2]);
end);

netstream.Hook("GetConversationLength", function(data)
	local totalDuration = 0;

	for k, v in pairs(data) do
		if (lookup[v]) then
			data[k] = lookup[v]();
		end;

		totalDuration = totalDuration + SoundDuration(v);
	end;

	net.Start("GetConversationLengthtwo")
	net.WriteUInt( totalDuration, 16 ) 
	net.SendToServer()
	--netstream.Start(nil, "GetConversationLengthtwo", totalDuration);
end);