
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "Guild";
local guildName = false;
local current,state,lastState,PEW,module,noAlert,repeater = "","falsefalse","nilnil",false;
local repeater_ticker,repeater_last,repeater_lastRandom,repeater_resetlock,_set,_get,updateGuildStatus,alertMotD = {},0,{},false;
local motd,multiplier,rosterButtons = {},{["1"]=1,["2"]=60,["3"]=3600};
local ext = C("gray","%s").." ("..ADDON_DISABLED..", %s)";
local config_defaults = {
	alertMotDAtLoginChanged = "popup",
	alertMotDAtAnyLogin = false,
	alertMotDOnChange = "popup",
	alertMotDOnUpdate = false,
	repeater_mode = "0",
	repeater_interval = 60,
	repeater_interval_type = "2",
	repeater_dontAlertMotD = true,
	rotation_enabled = false,
	favpageFirstTime = "1",
	favpageAnyTime = false,
	rosterSelectStyle = "0",
	rosterFavPage = "1"
};
local alertMotD_values = {
	_none = ADDON_DISABLED,
	popup = L["Popup message"],
	raidwarn = L["Raid warning"],
	alertframe = L["Alert frame"],
	--talkinghead = L["Talking head (no sound)"] -- maybe an idea for next version... not tested
};

module = {
	label = GUILD,
	desc = nil,
	events = {
		"ADDON_LOADED",
		"PLAYER_ENTERING_WORLD",
		"GUILD_MOTD",
		"GUILD_RANKS_UPDATE",
		"GUILD_ROSTER_UPDATE"
	},
	config = {
		globals=CopyTable(config_defaults),
		guilds={}
	},
	options_childGroups = "tab",
	options = {
		gmotd = {
			type = "group", order = 2,
			name = L["Guild message of the day"],
			childGroups = "tab",
			args = {
				desc = {
					type = "description", order = 0,
					name = L["New guilds will be added on login automatically.\nDo you want to hide some known guilds see 'Hide guilds' under 'Global settings.\nAll options are available from any toon and without permission to change guild motd."]
				},
				globals = {
					type = "group", order = 1,
					name = L["Global settings"],
					childGroups = "tab",
					args = {
						alertMotd = {
							type = "group", order = 1,
							name = L["MotD alert"],
							args = {
								desc = {
									type = "group", order = 9,
									name = C("orange",L["Missing guild membership..."]),
									guiInline = true,
									hidden = function() return IsInGuild() end,
									args = {
										info = {
											type = "description",
											name = L["You can adjust all settings and it will be save for later use."],
											fontSize = "medium"
										}
									}
								},
								atloginchanged = {
									type = "select", order = 2,
									name = L["At login (if changed)"],
									values = alertMotD_values,
									get = function() return _get(nil,"alertMotDAtLoginChanged"); end,
									set = function(_,v) _set(nil,"alertMotDAtLoginChanged",v); end
								},
								atanylogin = {
									type = "toggle", order = 3, width = "double",
									name = L["Anytime"],
									get = function() return _get(nil,"alertMotDAtAnyLogin"); end,
									set = function(_,v) _set(nil,"alertMotDAtAnyLogin",v); end
								},
								onchanges = {
									type = "select", order = 4,
									name = L["In case of changes"], desc = L["In case of changes during the session"],
									values = alertMotD_values,
									get = function() return _get(nil,"alertMotDOnChange"); end,
									set = function(_,v) _set(nil,"alertMotDOnChange",v); end
								},
								onupdate = {
									type = "toggle", order = 5, width = "double",
									name = L["On update (without changes)"], desc = L["Show motd alert if text unchanged but forced to display in guild chat"],
									get = function() return _get(nil,"alertMotDOnUpdate"); end,
									set = function(_,v) _set(nil,"alertMotDOnUpdate",v); end
								}
							}
						},
						repeater = {
							type = "group", order = 2,
							name = L["Repeater / Changer"],
							args = {
								desc = {
									type = "group", order = 9,
									name = C("orange",L["Missing permission to change guild message of the day in current guild..."]),
									guiInline = true,
									hidden = function() return CanEditMOTD() end,
									args = {
										info = {
											type = "description",
											name = L["You can adjust all settings and it will be save for later use."],
											fontSize = "medium"
										}
									}
								},
								mode = {
									type = "select", order = 1, width = "double",
									name = L["Repeater mode"],
									values = {
										["0"] = ADDON_DISABLED,
										["1"] = L["Repeat current message"],
										["2"] = L["Change message by list (normal mode)"],
										["3"] = L["Change message by list (random mode)"]
									},
									get = function() return _get(nil,"repeater_mode") end,
									set = function(_,v)
										_set(nil,"repeater_mode",v);
										repeater(repeater_ticker,"start");
									end,
								},
								dontAlertMotD = {
									type = "toggle", order = 2,
									name = L["Don't alert MotD"], desc = L["MotD alert ignore changes made by Repeater/Changer"],
									get = function() return _get(nil,"repeater_dontAlertMotD"); end,
									set = function(_,v) _set(nil,"repeater_dontAlertMotD",v); end,
								},
								interval = {
									type = "range", order = 3, width = "double",
									name = L["Interval"], desc = nil,
									min = 1, softMin = 1,
									max = 3600, softMax = 3600,
									step = 1,
									get = function() return _get(nil,"repeater_interval"); end,
									set = function(_,v)
										_set(nil,"repeater_interval",v);
										repeater(repeater_ticker,"start");
									end,
								},
								interval_size = {
									type = "select", order = 4,
									name = L["Interval size"],
									values = {
										["1"] = SECONDS,
										["2"] = MINUTES,
										["3"] = HOURS
									},
									get = function() return _get(nil,"repeater_interval_type"); end,
									set = function(_,v)
										_set(nil,"repeater_interval_type",v);
										repeater(repeater_ticker,"start");
									end,
								}
							}
						},
						knownGuilds = {
							type = "group",
							name = L["Guild options"],
							args = {
							}
						}
					}
				},
			}
		},
		--[[
		misc = {
			hidden = true,
			type = "group", order = 3,
			name = L["Misc. options"],
			args = {
				favpage = {
					type = "group", order = 1,
					name = C("dkyellow",L["Favorite guild page"]),
					guiInline = true,
					disabled = function() return not IsInGuild(); end,
					args = {
						desc = {
							type = "description", order = 2,
							name = L["Blizzards guild window has some page and opens News on any new session. This option gives you the choice to change this. Choose your favorite page which displayed on opening guild window first time after login or any time you open the guild window"]
						},
						choose = {
							type = "select", order = 3,
							name = "",
							values = {
								["1"] = GUILD_TAB_NEWS.." ("..DEFAULT..")",
								["2"] = GUILD_TAB_ROSTER,
								["3"] = GUILD_TAB_PERKS,
								["4"] = GUILD_TAB_REWARDS,
								["5"] = GUILD_TAB_INFO
							},
							get = function() return ns.get(modName,"favpageFirstTime"); end,
							set = function(_,v) ns.set(modName,"favpageFirstTime",v); end
						},
						anytime = {
							type = "toggle", order = 4,
							name = L["Any time"],
							get = function() return ns.get(modName,"favpageAnyTime"); end,
							set = function(_,v) ns.set(modName,"favpageAnyTime",v); end
						}
					}
				},
				roster = {
					type = "group", order = 2,
					name = C("dkyellow",L["Guild roster options"]),
					guiInline = true,
					disabled = function() return not IsInGuild(); end,
					args = {
						desc = {
							type = "description", order = 1,
							name = L["You don't like blizzards select field for"]
						},
						replace = {
							type = "select", order = 2,
							name = L["Replace select element"],
							values = {
								["0"] = DEFAULT,
								["1"] = L["Icon buttons"],
								["2"] = L["Text buttons"]
							},
							get = function() return ns.get(modName,"rosterSelectStyle"); end,
							set = function(_,v) ns.set(modName,"rosterSelectStyle",v); end
						},
						favorite = {
							type = "select", order = 3,
							name = L["Favorite roster page"],
							values = {
								["1"] = "1",
								["2"] = "2",
								["3"] = "3",
								["4"] = "4",
								["5"] = "5",
								["6"] = "6",
							},
							get = function() return ns.get(modName,"rosterFavPage"); end,
							set = function(_,v) ns.set(modName,"rosterFavPage",v); end
						}
					}
				}
			}
		}
		--]]
	}
}
ns.modules[modName] = module;

StaticPopupDialogs["HTB_GUILDMOTD"] = {
	text = "",
	button1 = OKAY,
	OnShow = function(self) self.text:SetText(GUILD_MOTD.."\n\n"..C("ltgreen",GetGuildRosterMOTD())) end,
	OnAccept = function(self) end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};

-----

function _get(guild,key,chkUseGlobal)
	if guild and not (chkUseGlobal~=nil and ns.profile[modName].guilds[guild][chkUseGlobal]) then
		return ns.profile[modName].guilds[guild][key];
	end
	return ns.profile[modName].globals[key];
end

function _set(guild,key,value)
	local t = ns.profile[modName].globals;
	if guild then t = ns.profile[modName].guilds[guild]; end
	t[key] = value;
end

local function addKnownGuild(num,data,color,gName)
	module.options.gmotd.args.globals.args.knownGuilds.args["guild"..num] = {
		type = "group", order = num+1,
		name = C("ltgreen",data.name).." - "..C("dkyellow",data.realm)..", "..C(color,_G["FACTION_"..data.faction]),
		guiInline = true,
		args = {
			hide = {
				type = "toggle", order = 1,
				name = L["Hide"],
				get = function() return ns.data[modName].gmotd[gName].ignore; end,
				set = function(_,v) ns.data[modName].gmotd[gName].ignore = v; updateOptions(); end
			},
			delete = {
				type = "execute", order = 1,
				name = function()
					if gName==current then
						return RESET;
					end
					return DELETE;
				end,
				desc = function()
					if gName==current then
						return L["Resets all data (settings & messages) from current guild"];
					end
					return L["Delete all data (settings & messages) from this guild"]; 
				end,
				func = function()
					ns.data[modName].gmotd[gName] = {};
					ns.profile[modName].guilds[gName] = {};
					if gName == current then
						updateGuildStatus();
					end
					updateOptions();
				end
			}
		}
	}
end

function updateOptions(gName,num)
	if gName==nil then
		local count=2;
		for k,v in ns.pairsByKeys(ns.data[modName].gmotd)do
			updateOptions(k,count);
			count=count+1;
			if current==k then
				wipe(motd);
				if v.list then
					for _,entry in ipairs(v.list)do
						if not entry.ignore and strlen(entry.text)>0 then
							tinsert(motd,entry.text);
						end
					end
				end
			end
		end
		module.options.gmotd.args.globals.args.knownGuilds.order = count + 1;
		LibStub("AceConfigRegistry-3.0"):NotifyChange(modName);
		return;
	end
	if tostring(gName)~="" then
		local data = ns.data[modName].gmotd[gName];
		local color = PLAYER_FACTION_COLORS[data.faction:lower()=="alliance" and 1 or 0];
		local desc = C("dkyellow",data.realm)..", "..C(color,_G["FACTION_"..data.faction]);

		-- check guild settings
		if ns.profile[modName].guilds[gName]==nil then
			ns.profile[modName].guilds[gName] = CopyTable(config_defaults);
			ns.profile[modName].guilds[gName].alertUseGlobal = true;
			ns.profile[modName].guilds[gName].repeaterUseGlobal = false;
		end

		if not ns.data[modName].gmotd[gName].ignore then
			module.options.gmotd.args["guild"..num] = {
				type = "group", order = num+1,
				name = current==gName and C("green",data.name) or data.name,
				desc = desc,
				childGroups = "tab",
				args = {
					alert = {
						type = "group", order = 1,
						name = L["MotD alert"],
						args = {
							useGlobal = {
								type = "toggle", order = 1, width = "full",
								name = L["Use global settings"],
								get = function() return _get(gName,"alertUseGlobal"); end,
								set = function(_,v) _set(gName,"alertUseGlobal",v); end
							},
							atloginchanged = {
								type = "select", order = 2,
								name = L["At login (if changed)"],
								values = alertMotD_values,
								get = function() return _get(gName,"alertMotDAtLoginChanged"); end,
								set = function(_,v) _set(gName,"alertMotDAtLoginChanged",v); end
							},
							atanylogin = {
								type = "toggle", order = 3, width = "double",
								name = L["Anytime"],
								get = function() return _get(gName,"alertMotDAtAnyLogin"); end,
								set = function(_,v) _set(gName,"alertMotDAtAnyLogin",v); end
							},
							onchanges = {
								type = "select", order = 4,
								name = L["In case of changes"], desc = L["In case of changes during the session"],
								values = alertMotD_values,
								get = function() return _get(gName,"alertMotDOnChange"); end,
								set = function(_,v) _set(gName,"alertMotDOnChange",v); end
							},
							onupdate = {
								type = "toggle", order = 5, width = "double",
								name = L["On update (without changes)"], desc = L["Show motd alert if text unchanged but forced to display in guild chat"],
								get = function() return _get(gName,"alertMotDOnUpdate"); end,
								set = function(_,v) _set(gName,"alertMotDOnUpdate",v); end
							}
						}
					},
					repeater = {
						type = "group", order = 2,
						name = L["Repeater / Changer"],
						args = {
							desc = {
								type = "group", order = 99,
								name = C("orange",L["Missing permission to change guild message of the day..."]),
								guiInline = true,
								hidden = function() return gName~=current or CanEditMOTD() end,
								args = {
									info = {
										type = "description",
										name = L["You can adjust all settings and it will be save for later use."],
										fontSize = "medium"
									}
								}
							},
							useGlobal = {
								type = "toggle", order = 1, width = "full",
								name = L["Use global settings"],
								get = function() return _get(gName,"repeaterUseGlobal"); end,
								set = function(_,v) _set(gName,"repeaterUseGlobal",v); end
							},
							mode = {
								type = "select", order = 2, width = "double",
								name = L["Repeater mode"],
								values = {
									["0"] = ADDON_DISABLED,
									["1"] = L["Repeat current message"],
									["2"] = L["Change message by list (normal mode)"],
									["3"] = L["Change message by list (random mode)"]
								},
								get = function() return _get(gName,"repeater_mode"); end,
								set = function(_,v) _set(gName,"repeater_mode",v); if gName==current then repeater(repeater_ticker,"start"); end end,
							},
							dontAlertMotD = {
								type = "toggle", order = 3,
								name = L["Don't alert MotD"], desc = L["MotD alert ignore changes made by Repeater/Changer"],
								get = function() return _get(gName,"repeater_dontAlertMotD"); end,
								set = function(_,v) _set(gName,"repeater_dontAlertMotD",v); end,
							},
							interval = {
								type = "range", order = 4, width = "double",
								name = L["Interval"], desc = nil,
								min = 1, softMin = 1,
								max = 3600, softMax = 3600,
								step = 1,
								get = function() return _get(gName,"repeater_interval"); end,
								set = function(_,v) _set(gName,"repeater_interval",v); if gName==current then repeater(repeater_ticker,"start"); end end,
							},
							interval_size = {
								type = "select", order = 5,
								name = L["Interval size"],
								values = {
									["1"] = SECONDS,
									["2"] = MINUTES,
									["3"] = HOURS
								},
								get = function() return _get(gName,"repeater_interval_type"); end,
								set = function(_,v) _set(gName,"repeater_interval_type",v); if gName==current then repeater(repeater_ticker,"start"); end end,
							}
						}
					},
					messages = {
						type = "group", order = 3,
						name = L["Stored messages"],
						args = {
							addtext = {
								type = "execute", order = 0,
								name = ADD,
								func = function()
									tinsert(data.list,{text="",ignore=false});
									updateOptions();
								end
							}
						}
					}
				}
			};

			-- add stored messages
			for i,value in ipairs(data.list)do
				module.options.gmotd.args["guild"..num].args.messages.args["motd"..i] = {
					type = "group", order = i,
					name = function()
						local str = i..". "
						if data.list[i].text~="" then
							str = str..strsub(data.list[i].text,0,20).."...";
							if IsInGuild() and data.list[i].text == GetGuildRosterMOTD() then
								return C("ltblue",str);
							end
						else
							str = C("gray",str.."("..EMPTY..")");
						end
						return str;
					end,
					desc = data.list[i].text,
					args = {
						txt = {
							type = "input", order = 1, width = "full",
							name = "",
							get = function() return data.list[i].text; end,
							set = function(_,v) data.list[i].text = v; updateOptions(); end
						},
						--------
						up = {
							type = "execute", order = 2, width = "half",
							name = L["Up"], desc = L["Move this entry up in list order"],
							func = function()
								tinsert(data.list,i-1,CopyTable(data.list[i]));
								tremove(data.list,i+1);
							end,
							disabled = i==1
						},
						get = {
							type = "execute", order = 3, width = "half",
							name = L["Get"], desc = L["Get current message of the day and save it here"],
							func = function()
								data.list[i].text = GetGuildRosterMOTD();
								updateOptions();
							end,
							disabled = function() if not IsInGuild() then return true; end return data.list[i].text == GetGuildRosterMOTD(); end
						},
						ignore = {
							type = "toggle", order = 4, 
							name = L["Ignore"], desc = L["Ignore this message in repeater modes ordered and random"],
							get = function() return data.list[i].ignore; end,
							set = function(_,v) data.list[i].ignore = v; updateOptions(); end
						},
						--------
						down = {
							type = "execute", order = 5, width = "half",
							name = L["Down"], desc = L["Move this entry down in list order"],
							func = function()
								tinsert(data.list,i,CopyTable(data.list[i+1]));
								tremove(data.list,i+2);
							end,
							disabled = i==#data.list
						},
						set = {
							type = "execute", order = 6, width = "half",
							name = L["Set"], desc = L["Set this text manually as message of the day"],
							func = function()
								if _get(current,"repeater_dontAlertMotD","repeaterUseGlobal") then
									noAlert = true;
								end
								GuildSetMOTD(data.list[i].text);
							end,
							disabled = function() return not (IsInGuild() and CanEditMOTD()); end
						},
						del = {
							type = "execute", order = 7,
							name = DELETE, desc = L["Delete this entry"],
							func = function()
								tremove(data.list,i);
								updateOptions();
							end
						},
					}
				};
			end
		end

		-- known guilds entry
		module.options.gmotd.args.globals.args.knownGuilds.args["guild"..num] = {
			type = "group", order = num+1,
			name = C("ltgreen",data.name).." - "..C("dkyellow",data.realm)..", "..C(color,_G["FACTION_"..data.faction]),
			guiInline = true,
			args = {
				hide = {
					type = "toggle", order = 1,
					name = L["Hide"],
					get = function() return ns.data[modName].gmotd[gName].ignore; end,
					set = function(_,v) ns.data[modName].gmotd[gName].ignore = v; updateOptions(); end
				},
				delete = {
					type = "execute", order = 1,
					name = function() if gName==current then return RESET; end return DELETE; end,
					desc = function() if gName==current then return L["Resets all data (settings & messages) from current guild"]; end return L["Delete all data (settings & messages) from this guild"]; end,
					func = function()
						ns.data[modName].gmotd[gName] = {};
						ns.profile[modName].guilds[gName] = {};
						if gName == current then
							updateGuildStatus();
						end
						updateOptions();
					end
				}
			}
		}
	end
end

function updateGuildStatus()
	if IsInGuild() then
		local guildName = GetGuildInfo("player");
		if not guildName then
			return; -- Oops... to early to queried guild name?
		end
		local faction = UnitFactionGroup("player"):upper();
		local realm = GetRealmName();
		current = guildName.."::"..realm.."::"..faction;
		state = "true"..tostring(CanEditMOTD());
		if ns.data[modName].gmotd[current]==nil then
			ns.data[modName].gmotd[current] = {};
		end
		if ns.data[modName].gmotd[current].name==nil then
			ns.data[modName].gmotd[current].name=guildName;
		end
		if ns.data[modName].gmotd[current].realm==nil then
			ns.data[modName].gmotd[current].realm=realm;
		end
		if ns.data[modName].gmotd[current].faction==nil then
			ns.data[modName].gmotd[current].faction=faction;
		end
		if ns.data[modName].gmotd[current].list==nil then
			ns.data[modName].gmotd[current].list={};
		end
	else
		state = "falsefalse";
	end
	if state~=lastState then
		lastState=state;
		updateOptions();
	end
end

-----

module.onevent = function(self,event,arg1,...)
	if event=="ADDON_LOADED" then
		if arg1==addon then
			if ns.data[modName]==nil then
				ns.data[modName] = {};
			end
			if ns.data[modName].gmotd == nil then
				ns.data[modName].gmotd = {};
			end
		--elseif arg1=="Blizzard_GuildUI" then
			--?
		end
	elseif event=="PLAYER_ENTERING_WORLD" then
		PEW = true;
		updateGuildStatus();
		C_Timer.After(9.3,function()
			alertMotD("pew");
			repeater(repeater_ticker,"start");
		end);
		self:UnregisterEvent(event);
	elseif PEW and event:match("^GUILD") then
		updateGuildStatus();
		if event=="GUILD_MOTD" then
			C_Timer.After(0.5,function()
				-- very funny... event is faster than GetGuildRosterMOTD to return new motd.
				if not noAlert then
					alertMotD("update");
				end
				noAlert=false;
				updateOptions();
				repeater(repeater_ticker,"start");
				repeater_resetlock = false;
			end);
		end
	end
end

-----

function alertMotD(state)
	if not IsInGuild() then return end
	local changed,style,currentMotD = false,false,GetGuildRosterMOTD();
	if currentMotD=="" then return; end -- no motd, no alert
	changed = ns.data[modName].gmotd[current].lastSeenMotD~=currentMotD;
	if state=="pew" then
		style = _get(current,"alertMotDAtLoginChanged","alertUseGlobal");
		if _get(current,"alertMotDAtAnyLogin","alertUseGlobal") then
			changed = true;
		end
	elseif state=="update" then
		style = _get(current,"alertMotDOnChange","alertUseGlobal");
		if _get(current,"alertMotDOnUpdate","alertUseGlobal") then
			changed = true;
		end
	end
	--ns.print(tostring(style),tostring(changed));
	if not changed or style=="_none" then
		return; -- do nothing
	end
	if style=="popup" then
		StaticPopup_Show("HTB_GUILDMOTD");
	elseif style=="raidwarn" then
		RaidNotice_AddMessage(RaidBossEmoteFrame,C("ltgray",GUILD_MOTD).."\n"..C("ltgreen",GetGuildRosterMOTD()),ChatTypeInfo["RAID_BOSS_EMOTE"], 10);
	elseif style=="alertframe" then
		GuildMotDAlertSystem:AddAlert();
	elseif style=="talkinghead" then
		
	end
	ns.data[modName].gmotd[current].lastSeenMotD = currentMotD;
end

function repeater(self,action)
	if not IsInGuild() then return end
	local mode,length = _get(current,"repeater_mode","repeaterUseGlobal"),strlen(GetGuildRosterMOTD());
	if not CanEditMOTD() or mode=="0" or action=="stop" then
		if not repeater_resetlock and self.Cancel then
			repeater_ticker:Cancel();
			repeater_ticker = {};
		end
		return;
	end
	ns.print(action);
	if action=="start" then
		repeater(repeater_ticker,"stop");
		repeater_ticker = C_Timer.NewTimer(_get(current,"repeater_interval","repeaterUseGlobal") * multiplier[_get(current,"repeater_interval_type","repeaterUseGlobal")],repeater);
	elseif self.Cancel then
		if mode=="1" and length>0 then
			repeater_resetlock = true;
			if _get(current,"repeater_dontAlertMotD","repeaterUseGlobal") then
				noAlert = true;
			end
			GuildSetMOTD(GetGuildRosterMOTD());
		elseif #motd>0 then
			local next = 1;
			if #motd>1 and mode=="2" then
				next = repeater_last+1;
				if next>#motd then next=1; end
				repeater_last = next;
			elseif #motd>1 and mode=="3" then
				if #motd==2 then
					next = (repeater_lastRandom[1]) + 1;
					if #motd>next then
						next = 1;
					end
				else
					next = random(1,#motd);
					if repeater_lastRandom[1]==next or (#motd>3 and repeater_lastRandom[2]==next) then
						repeat
							next = random(1,#motd);
						until not (repeater_lastRandom[1]==next or (#motd>3 and repeater_lastRandom[2]==next));
					end
				end
				tinsert(repeater_lastRandom,1,next);
				if #repeater_lastRandom==3 then
					tremove(repeater_lastRandom,3);
				end
			end
			repeater_resetlock = true;
			if _get(current,"repeater_dontAlertMotD","repeaterUseGlobal") then
				noAlert = true;
			end
			GuildSetMOTD(motd[next]);
		end
	end
end

function rosterButtons()
end

