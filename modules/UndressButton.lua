
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "UndressButtons";
local updateButtons;
local buttons = {};
local module = {
	label = "Undress buttons",
	desc = L["You have a problem to show some items in your dressing room because it is overlayed by another item like pants under robes? A click on this button will be undress your character and you can dress a single item to see it."],
	events = nil, --{},
	config = {
		showUndressButtons = true,
		showFreezeButtons = true
	},
	options = {
		showUndress = {
			type = "toggle", order = 1,
			name = L["Show Undress buttons"],
			desc = L["Display Undress buttons on DressUp frames"],
			get = function() return ns.get(modName,"showUndressButtons"); end,
			set = function(_,v) ns.set(modName,"showUndressButtons",v); updateButtons(); end,
		},
		showFreeze = {
			type = "toggle", order = 2,
			name = L["Show freeze buttons"],
			desc = L["Display Freeze buttons on DressUp frames to stop motion"],
			get = function() return ns.get(modName,"showFreezeButtons"); end,
			set = function(_,v) ns.set(modName,"showFreezeButtons",v); updateButtons(); end
		},
		example_header = {
			type = "description", order = 3,
			name = " |n"..C("dkyellow",L["Examples"]),
			fontSize = "large"
		},
		example = {
			type = "description", order = 4,
			name = "", 
			image = ns.media.."example_dressup.tga",
			imageCoords = {0,490/512,0,380/512},
			imageWidth = 490, -- 512
			imageHeight = 380, -- 512
		},
	}
}
ns.modules[modName] = module;

function updateButtons()
	for i=1, #buttons do
		buttons[i]:SetShown(ns.get(modName,buttons[i].cfgName));
	end
end

local function Undress(self,button)
	local m=_G[self.model];
	--if button=="LeftButton" then
		m:Undress();
	--elseif button=="RightButton" then
		-- menu
		-- m:UndressSlot(slotId)
	--end
end

local function Freeze(self)
	local m = _G[self.model];
	if not m.freezed then
		m:FreezeAnimation(0);
		m.freezed = true;
	else
		m:SetSequence(0);
		m.freezed = false;
	end
	if not m.UnfreezeHook then
		m:HookScript("OnHide",function()
			if m.freezed then
				m:SetSequence(0);
			end
		end);
		m.UnfreezeHook = true;
	end
end

local function addButton(parent,model,name,cfgName,func,point,pointLevel)
	local button = CreateFrame("Button",parent.."_HTB"..name.."Button",_G[parent],"UIPanelButtonTemplate");
	button:Hide();
	button:SetWidth(80);
	button:SetText(L[name]);
	button:SetPoint(unpack(point));
	button:SetScript("OnClick",func);
	button.model = model;
	button.cfgName = cfgName;
	if pointLevel then button:SetFrameLevel(point[2]:GetFrameLevel()); end
	tinsert(buttons,button);
end

module.onload = function()
	if DressUpFrame and not DressUpFrameUndressButton then
		addButton(
			"DressUpFrame",
			"DressUpModel",
			"Undress", -- L . ["Undress"]
			"showUndressButtons",
			Undress,
			{"TOPLEFT",DressUpModel,"BOTTOMLEFT",-4,-4}
		);
		addButton(
			"DressUpFrame",
			"DressUpModel",
			"Freeze", -- L . ["Freeze"]
			"showFreezeButtons",
			Freeze,
			{"TOPLEFT",DressUpModel,"BOTTOMLEFT",78,-4}
		);
	end
	if SideDressUpFrame and not SideDressUpFrameUndressButton then
		-- Undress button for smaller dress up frame (auction house and void storage)
		addButton(
			"SideDressUpFrame",
			"SideDressUpModel",
			"Undress",
			"showUndressButtons",
			Undress,
			{"TOPRIGHT",SideDressUpModelResetButton,"BOTTOM",0,-4},
			true
		);
		addButton(
			"SideDressUpFrame",
			"SideDressUpModel",
			"Freeze",
			"showFreezeButtons",
			Freeze,
			{"TOPLEFT",SideDressUpModelResetButton,"BOTTOM",0,-4},
			true
		);
	end
	updateButtons();
end

--[[

next idea:
	right click on button [little menu] to choose which part you want to undress...
		UndressSlot(slotId)

--]]