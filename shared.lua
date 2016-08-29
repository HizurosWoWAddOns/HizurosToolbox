
local addon,ns=...;
local L = ns.L;
ns.profile={};
ns.media = "Interface\\AddOns\\"..addon.."\\media\\";

HIZUROSTOOLBOX = "Hizuro's Toolbox";
ns.L[addon]=HIZUROSTOOLBOX;
BINDING_CATEGORY_HIZUROSTOOLBOX = HIZUROSTOOLBOX;
BINDING_NAME_HTBSCREENSHOT = "Screenshot without UI";
BINDING_NAME_HTBFRAMESTACK = "Frame stack tooltip";

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
local C = ns.LC.color;

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
	["silver"]		= "ddddef",
	["copper"]		= "f0a55f",
	["unknown"]		= "ee0000",
	["dailyblue"]	= "00b3ff"
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

-- -------------------------------------------------- --
-- Function to Sort a table by the keys               --
-- Sort function fom http://www.lua.org/pil/19.3.html --
-- -------------------------------------------------- --
ns.pairsByKeys = function(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

--

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

do
	local usage = "Usage: HTB_GetWoWHeadLink(type,id)";
	local info = "Info: /run HTB_GetWoWHeadLink(\"info\"); to get a list of valid types";
	local url = "";
	local lang = {
		deDE="de", esES="es", esMX="es", frFR="fr",
		itIT="it", ptPT="pt", ptBR="pt", ruRU="ru",
		koKR="ko", zhCN="cn", zhTW="cn"
	}
	local field = {
		a="achievement", c="currency", f="faction",
		b="building",    i="item",     m="mission",
		n="npc",         o="object",   q="quest",
		s="spell",       gf="follower"
	}
	StaticPopupDialogs["HTB_WOWHEADLINK_DIALOG"] = {
		text = "WoWHead URL",
		button2 = CLOSE,
		timeout = 0,
		whileDead = 1,
		hasEditBox = 1,
		hideOnEscape = 1,
		maxLetters = 1024,
		editBoxWidth = 250,
		OnShow = function(f,...)
			local e,b = _G[f:GetName().."EditBox"],_G[f:GetName().."Button2"]
			if e then e:SetText(url) e:SetFocus() e:HighlightText(0) end
			if b then b:ClearAllPoints() b:SetWidth(100) b:SetPoint("CENTER",e,"CENTER",0,-30) end
		end,
		EditBoxOnEscapePressed = function(f)
			f:GetParent():Hide()
		end
	}
	function HTB_GetWoWHeadLink(Type,Id)
		assert(type(Type)=="string",usage.."\n"..info);
		if Type=="info" then
			ns.print("HTB_GetWoWHeadLink",ns.L["Valid types"]);
			for k,v in pairs(field)do
				ns.print(false,k," ("..v..")");
			end
			return;
		end
		assert(type(Id)=="number",usage);
		if field[Type] then
			url = ("http://%s.wowhead.com/%s=%d"):format(lang[GetLocale()] or "www",field[Type],Id);
			StaticPopup_Show("HTB_WOWHEADLINK_DIALOG");
		end
	end
end

ns.get = function(mod,opt)
	return ns.profile[mod][opt];
end

ns.set = function(mod,opt,value)
	ns.profile[mod][opt] = value;
end

function GuildMotDAlertFrame_SetUp()
	GuildMotDAlertFrameText:SetText(C("ltgreen",GetGuildRosterMOTD()));
	SetLargeGuildTabardTextures("player", GuildMotDAlertFrameEmblemIcon, GuildMotDAlertFrameEmblemBackground, GuildMotDAlertFrameEmblemBorder);
end

function GuildMotDAlertFrame_OnClick(self)
	self:Hide();
end

function GuildMotDAlertFrame_OnLoad()
	GuildMotDAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem(GuildMotDAlertFrame, GuildMotDAlertFrame_SetUp);
end
