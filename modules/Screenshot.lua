
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "Screenshot";

local module = {
	label = BINDING_NAME_SCREENSHOT,
	desc = nil, -- L[""],
	events = {"PLAYER_ENTERING_WORLD","CVAR_UPDATE"},
	config = {
		autoRestore = false,
	},
	options_NoHeader = true,
	options = {
		quality = {
			type = "group", order = 1,
			name = L["Screenshot quality options"],
			guiInline = true,
			args = {
				formattype = {
					type = "select", order = 2,
					name = L["Screenshot file format"],
					values = {
						jpg = "JPEG (recommented)",
						png = "PNG / ProtableNetworkGraphic",
						tga = "TGA / Targa File"
					},
					get = function()
						return GetCVar("screenshotFormat");
					end,
					set = function(_,v)
						ns.get(modName,"cvar_screenshotFormat",v);
						SetCVar("screenshotFormat",v);
					end
				},
				quality = {
					type = "range", order = 3,
					name = L["Screenshot quality"],
					desc = L["Adjust screenshot quality for JPEG format. Better quality means bigger file size"],
					min = 1, max = 10, step = 1, isPercent = false,
					get = function() return tonumber(GetCVar("screenshotQuality")) or 10; end,
					set = function(_,v)
						ns.get(modName,"cvar_screenshotQuality",v);
						SetCVar("screenshotQuality",v);
					end
				},
				force = {
					type = "toggle", order = 4,
					name = L["Check and restore"],
					desc = L["Checks your screenshot settings on login/reload and restore it automatically"],
					get = function() return ns.get(modName,"autoRestore"); end,
					set = function(_,v) ns.get(modName,"autoRestore",v); end
				},
			}
		},
		--separator1 = { order=5 },
		screenshot_header2 = {
			type = "group", order = 2,
			name = L["Take screenshot without UI"],
			guiInline = true,
			args = {
				desc = {
					type = "description", order = 1,
					name = L["This key bindable function takes screenshots without ui while you are not in combat. It doesn't replace blizzards screenshot keybind"],
					fontSize = "medium"
				},
				beybind = {
					type = "keybinding", order = 2,
					name = "",
					get = function() return GetBindingKey("HTBSCREENSHOT"); end,
					set = function(_,v)
						local keyb = GetBindingKey("HTBSCREENSHOT");
						if keyb then SetBinding(keyb); end -- unset prev key
						if v~="" then SetBinding(v,"HTBSCREENSHOT"); end
						SaveBindings(GetCurrentBindingSet());
					end,
				}
			}
		}
	}
};

ns.modules[modName] = module;

local function CheckCVar(cvar)
	if ns.profile[modName]["cvar_"..cvar] and GetCVar(cvar)~=tostring(ns.profile[modName]["cvar_"..cvar]) then
		SetCVar(cvar,ns.profile[modName]["cvar_"..cvar]);
	end
end

local function SetUIVisibility(bool)
	if InCombatLockdown() then
		bool=true;
	end
	-- if argument #1 are 'false' as boolean this function react like protected functions
	_G.SetUIVisibility(bool); 
end

function HTB_Screenshot()
	local count,ticker = 0;
	ticker = C_Timer.NewTicker(0.01, function()
		if count==0 then
			SetUIVisibility(false);
		elseif count==1 then
			Screenshot();
		else
			SetUIVisibility(true);
			ticker:Cancel();
		end
		count=count+1;
	end);
end

module.onevent = function(self,event,arg1)
	if event=="PLAYER_ENTERING_WORLD" then
		if ns.profile[modName].autoRestore then
			C_Timer.After(5,function()
				CheckCVar("screenshotFormat");
				CheckCVar("screenshotQuality");
			end);
		end
	elseif event=="CVAR_UPDATE" and ns.profile[modName].autoRestore then
		if  arg1=="screenshotFormat" or arg1=="screenshotQuality" then
			CheckCVar(arg1);
		end
	end
end
