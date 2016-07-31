
local addon,ns = ...; local L=ns.L;

ns.moduleLoaded = {};
ns.moduleNames = {};

ns.modules = setmetatable({},{__newindex=function(t,k,v)
	tinsert(ns.moduleNames,k);
	rawset(t,k,v);
	ns.debug("new module",k);
end});

function ns.RegisterModules()
	for _,modName in ipairs(ns.moduleNames) do
		local mod = ns.modules[modName];
		if mod then
			if ns.profile[modName]==nil then
				ns.profile[modName] = {};
			end

			if mod.config then
				if ns.profile[modName]==nil then
					ns.profile[modName]=mod.config;
				else
					for k,v in pairs(mod.config) do
						if ns.profile[modName][k]==nil then
							ns.profile[modName][k]=v;
						end
					end
				end
			end

			if mod.onload then
				mod.onload();
			end

			if type(mod.onevent)=="function" and type(mod.events)=="table" and #mod.events>0 and not mod.eventFrame then
				mod.eventFrame = CreateFrame("frame");
				mod.eventFrame:SetScript("OnEvent",mod.onevent);
				for i,v in ipairs(mod.events)do
					if v=="ADDON_LOADED" then
						mod.onevent(mod.eventFrame,"ADDON_LOADED",addon.."_"..modName);
					end
					mod.eventFrame:RegisterEvent(v);
				end
			end

			if type(mod.onupdate)=="function" and type(mod.update_interval)=="number" and not mod.onupdate_ticker then
				mod.onupdate_ticker = C_Timer.NewTicker(mod.update_interval,mod.onupdate);
			end

			ns.moduleLoaded[modName] = true;

			ns.addModuleOptions(modName,mod);
		end
	end
end
