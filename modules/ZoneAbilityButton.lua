
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "ZoneAbilityButton";
local updateButtons;
local buttons = {};
local module = {
	label = "Zone Ability Button",
	desc = L["Do you have a problem to find blizzards zone ability button on your action bars?"],
	events = nil, --{},
	config = {},
	options = {
		getFromActionBar = {
			type = "execute",
			name = L["Find and pull it"],
			desc = L["Push this button and this script pull the button from your action bars to your mouse."],
			func = function()
				local _,SpellID;
				local frame = DraenorZoneAbilityFrame or ZoneAbilityFrame; -- wod and legion frame name.
				if frame and frame.baseName then
					_,_,_,_,_,_,SpellID = GetSpellInfo(frame.baseName);
				end
				if SpellID then
					for ActionSlot=1, 120 do
						local ActionType,ActionID=GetActionInfo(ActionSlot);
						if ActionType=="spell" and ActionID==SpellID then
							PickupAction(ActionSlot);
						end
					end
				end
			end
		}
	}
}
ns.modules[modName] = module;

-- MakeMoreDraenorZoneAbilityButtons()
-- PickupSpellBookItem("")
-- http://eu.battle.net/wow/de/forum/topic/15161820849#5

