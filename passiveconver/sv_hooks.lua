local PLUGIN = PLUGIN;

util.AddNetworkString( "GetConversationLengthtwo" )

function PLUGIN:Tick()
	for k, v in pairs(player.GetAll()) do
		if (v:Team() == FACTION_MPF) then
			if (v:Alive() and ix.config.Get("Use Passive Voice", false)) then
				if (CurTime() > (v.nextChatter or 0)) then
					v.nextChatter = math.random(20, 30);
					self:PlayConversation(v);
				end;
			end;
		end;
	end;
end;


net.Receive("GetConversationLengthtwo", function()
	local length = net.ReadUInt( 16 )
	for k, v in pairs(player.GetAll()) do
		if (v:Team() == FACTION_MPF) then
			timer.Simple(length, function()
				v.conversationPlaying = false;
			end)
			v.nextChatter = CurTime() + length + math.random(15, 30);
		end
    end;
end)
