
local addon,ns = ...; local L=ns.L;

function HizurosToolbox_OnEvent(self,event,arg1,...)
	if event=="ADDON_LOADED" and arg1==addon then
		if HizurosToolbox_ConfigDB==nil then
			HizurosToolbox_ConfigDB = {
				use_default_profile = true,
				default_profile = DEFAULT,
				profiles = {[DEFAULT]={}},
				use_profile = {},
			};
		end
		if HizurosToolbox_ConfigDB.use_default_profile then
			if HizurosToolbox_ConfigDB.use_profile[ns.player.name_realm]==nil then
				HizurosToolbox_ConfigDB.use_profile[ns.player.name_realm] = DEFAULT;
			end
		else
			if HizurosToolbox_ConfigDB.use_profile[ns.player.name_realm]==nil then
				if HizurosToolbox_ConfigDB.profiles[ns.player.name_realm]==nil then
					HizurosToolbox_ConfigDB.profiles[ns.player.name_realm] = {};
				end
				HizurosToolbox_ConfigDB.use_profile[ns.player.name_realm] = ns.player.name_realm;
			end
		end

		ns.profile = HizurosToolbox_ConfigDB.profiles[HizurosToolbox_ConfigDB.use_profile[ns.player.name_realm]];
		if ns.profile.GeneralOptions==nil then
			ns.profile.GeneralOptions = {};
		end

		-- character cache
		if(HizurosToolbox_CharacterDB==nil)then
			HizurosToolbox_CharacterDB={order={}};
		end
		if(HizurosToolbox_CharacterDB.order==nil)then
			HizurosToolbox_CharacterDB.order={};
		end
		if(not HizurosToolbox_CharacterDB[ns.player.name_realm])then
			tinsert(HizurosToolbox_CharacterDB.order,ns.player.name_realm);
			HizurosToolbox_CharacterDB[ns.player.name_realm] = {orderId=#HizurosToolbox_CharacterDB.order};
		end

		HizurosToolbox_CharacterDB[ns.player.name_realm].basics = ns.player;

		-- data cache
		if HizurosToolbox_DataDB==nil then
			HizurosToolbox_DataDB = {realms={}};
		end
		if HizurosToolbox_DataDB.realms==nil then
			HizurosToolbox_DataDB.realms={}; -- ?
		end
		ns.data = HizurosToolbox_DataDB;

		-- enable registered modules
		ns.RegisterModules();

		ns.print("AddOn loaded...");
	elseif event=="PLAYER_ENTERING_WORLD" then
		ns.RegisterOptionPanel();
		self:UnregisterEvent(event);
	end
end

-- function HizurosToolbox_OnShow(self) end

function HizurosToolbox_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

