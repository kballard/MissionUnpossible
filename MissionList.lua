
local myname, ns = ...


ns.inactive_statii = {
	[GARRISON_FOLLOWER_ON_MISSION] = true,
	[GARRISON_FOLLOWER_INACTIVE] = true,
	[GARRISON_FOLLOWER_WORKING] = true,
	[GARRISON_FOLLOWER_IN_PARTY] = true,
}
local function GetCounterText(trait, mission)
	local available, total, levelmatch, overlevel = 0, 0, false, false
	local missionid = mission.missionID
	local missionlevel = mission.level

	local buffed = C_Garrison.GetBuffedFollowersForMission(mission.missionID)
	for guid,buffs in pairs(buffed) do
		for i,buff in pairs(buffs) do
			if buff.name == trait then
				total = total + 1

				local status = C_Garrison.GetFollowerStatus(guid)
				if not ns.inactive_statii[status] then
					available = available + 1

					local level = C_Garrison.GetFollowerLevel(guid)
					if mission.level == 100 and mission.iLevel > 0 then
						local ilvl = C_Garrison.GetFollowerItemLevelAverage(guid)
						if ilvl >= mission.iLevel then levelmatch = true end
					else
						if level == mission.level then levelmatch = true end
						if level > mission.level then overlevel = true end
					end
				end
			end
		end
	end

	if total == 0 then
		return GRAY_FONT_COLOR_CODE.. "--"
	else
		local color = ORANGE_FONT_COLOR_CODE
		if available == 0 then
			color = GRAY_FONT_COLOR_CODE
		elseif levelmatch then
			color = HIGHLIGHT_FONT_COLOR_CODE
		elseif overlevel then
			color = BATTLENET_FONT_COLOR_CODE
		end

		return color.. available.. "/".. total
	end
end


local function UpdateMission(frame)
	local mission = frame.info
	if not mission then return end
	local missionID = mission.missionID

	frame.Level:SetText(mission.level.. "\nx".. mission.numFollowers)

	local _, _, _, _, _, _, _, missionbosses = C_Garrison.GetMissionInfo(missionID)
	if not missionbosses then return end

	local anchor = frame.Rewards[mission.numRewards]
	local lastframe
	for _,boss in pairs(missionbosses) do
		for _,mechanic in pairs(boss.mechanics) do
			local mech = ns.GetBossMechanicFrame()

			mech.label:SetText(GetCounterText(mechanic.name, mission))
			mech.Icon:SetTexture(mechanic.icon)

			mech:SetParent(frame)
			mech:SetPoint("RIGHT", anchor, "LEFT", -12, 0)
			mech:Show()

			if lastframe then
				lastframe:SetPoint("RIGHT", mech, "LEFT", -12, 0)
			end

			lastframe = mech
		end
	end
end


local MissionList = GarrisonMissionFrame.MissionTab.MissionList
local function GarrisonMissionList_Update()
	ns.HideBossMechanicFrames()

	if MissionList.showInProgress then return end

	for i,button in pairs(MissionList.listScroll.buttons) do
		UpdateMission(button)
	end
end


hooksecurefunc("GarrisonMissionList_Update", GarrisonMissionList_Update)
hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", GarrisonMissionList_Update)


for _,butt in pairs(MissionList.listScroll.buttons) do
	butt:SetScript("OnEnter", nil)
end
