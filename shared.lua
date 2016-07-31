
local addon,ns=...;

ns.profile={};

ns.L = setmetatable({},{
	__index=function(t,k)
		local v = tostring(k);
		rawset(t,k,v);
		return v;
	end
});
HIZUROSTOOLBOX = "Hizuro's Toolbox";
ns.L[addon]=HIZUROSTOOLBOX;

local chats = {
	SAY = {"s","say",SAY},
	GUILD = {"g","guild",GUILD},
	OFFICER = {"o","officer",OFFICER},
	INSTANCE_CHAT = {"i","instance",INSTANCE},
	PARTY = {"p","party",PARTY},
	YELL = {"y","yell",YELL},
	RAID = {"r","raid",RAID},
	RAID_WARNING = {"rw","raid_warning",RAID_WARNING},
};

ns.chats = {};
for ChannelName,flexibilityTable in pairs(chats)do
	for _,userOption in ipairs(flexibilityTable)do
		ns.chats[userOption] = ChannelName;
	end
end

ns.print = function (...)
	local colors,t,T,c = {"0088ff","00ff00","ff0000","44ffff","ffff00","ff8800","ff00ff","ffffff"},{},{...},1;
	if type(T[1])=="boolean" then
		T[1] = (T[1]==true) and "HTB:" or "||";
	else
		tinsert(T,1,ns.L[addon]..":");
	end
	for i,v in ipairs(T) do
		if type(v)=="string" and v:match("||c") then
			tinsert(t,v)
		elseif v then
			tinsert(t,"|cff"..colors[c]..tostring(v).."|r");
			c = c<#colors and c+1 or 1;
		end
	end
	print(unpack(t));
end

if GetAddOnMetadata(addon,"Version")=="@project-version@" then
	ns.debug = function(...)
		ns.print("debug",...);
	end
	BrokerEverything = ns;
else
	ns.debug = function() end -- dummy
end

ns.LC = LibStub("LibColors-1.0");

-- color set used in broker_everything and some other of my addons :)
ns.LC.colorset({
	["ltyellow"]	= "fff569",
	["dkyellow"]	= "ffcc00",
	["ltorange"]	= "ff9d6a",
	["dkorange"]	= "905d0a",
	["ltred"]		= "ff8080",
	["dkred"]		= "800000",
	["violet"]		= "f000f0",
	["ltviolet"]	= "f060f0",
	["dkviolet"]	= "800080",
	["ltblue"]		= "69ccf0",
	["dkblue"]		= "000088",
	["ltcyan"]		= "80ffff",
	["dkcyan"]		= "008080",
	["ltgreen"]		= "80ff80",
	["dkgreen"]		= "00aa00",
	["dkgray"]		= "404040",
	["ltgray"]		= "b0b0b0",
	["gold"]		= "ffd700",
	["silver"]		= "eeeeef",
	["copper"]		= "f0a55f",
	["unknown"]		= "ee0000",
})

ns.realm = GetRealmName();
ns.media = "Interface\\AddOns\\"..addon.."\\media\\";
ns.locale = GetLocale();
ns.player = {
	name = UnitName("player"),
	female = UnitSex("player")==3,
};
ns.player.name_realm = ns.player.name.."-"..ns.realm;
ns.player.name_realm_short = gsub(ns.player.name_realm," ","");
_, ns.player.class,ns.player.classId = UnitClass("player");
ns.player.faction,ns.player.factionL  = UnitFactionGroup("player");
ns.L[ns.player.faction] = ns.player.factionL;
ns.player.classLocale = ns.player.female and _G.LOCALIZED_CLASS_NAMES_FEMALE[ns.player.class] or _G.LOCALIZED_CLASS_NAMES_MALE[ns.player.class];
ns.player.raceLocale,ns.player.race = UnitRace("player");

function HTB_Tooltip_OnEnter(self,tooltip,anchor)
	local tt = self.tooltip or tooltip or false;
	local a = self.tooltip_anchor or anchor;
	if tt then
		if type(a)=="table" then
			GameTooltip:SetOwner(self,"ANCHOR_NONE");
			GameTooltip:SetPoint(unpack(a));
		else
			GameTooltip:SetOwner(self,"ANCHOR_".. (a or "TOP"));
		end
		GameTooltip:ClearLines();
		GameTooltip:SetText(tt[1]);
		for i=2, #tt do
			if type(tt[i])=="table" then
				GameTooltip:AddDoubleLine(tt[i][1],tt[i][2]);
			else
				GameTooltip:AddLine(tt[i],1,1,1,1);
			end
		end
		GameTooltip:Show();
	end
end

function HTB_Tooltip_OnLeave()
	GameTooltip:Hide();
end

