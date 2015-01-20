-------------------------------------------------------------------------------
-- Module Declaration
--

local plugin = BigWigs:NewPlugin("BossBlock")
if not plugin then return end

-------------------------------------------------------------------------------
-- Database
--

plugin.defaultDB = {
	blockEmotes = true,
	blockMovies = true,
	blockGarrison = true,
	blockGuildChallenge = true,
	blockSpellErrors = true,
}

--------------------------------------------------------------------------------
-- Locals
--

local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Plugins")
plugin.displayName = L.bossBlock

-------------------------------------------------------------------------------
-- Options
--

plugin.pluginOptions = {
	name = L.bossBlock,
	desc = L.bossBlockDesc,
	type = "group",
	get = function(info)
		return plugin.db.profile[info[#info]]
	end,
	set = function(info, value)
		if IsEncounterInProgress() then return end -- Don't allow toggling during an encounter.
		local entry = info[#info]
		plugin.db.profile[entry] = value
	end,
	args = {
		heading = {
			type = "description",
			name = L.bossBlockDesc.. "\n\n",
			order = 0,
			width = "full",
			fontSize = "medium",
		},
		blockEmotes = {
			type = "toggle",
			name = "Block middle-screen emotes",
			desc = "Some bosses show emotes for certain abilities, these messages are both way too long and descriptive. We try to produce smaller, more fitting messages that do not interfere with the gameplay, and don't tell you specifically what to do.\n\n|cffff4411When on, emote warnings will not be shown in the middle of the screen, but they will still show in your chat frame.|r",
			width = "full",
			order = 1,
		},
		blockMovies = {
			type = "toggle",
			name = "Block repeated movies",
			desc = "Encounter movies will only be allowed to play once (so you can watch each one) and will then be blocked.",
			width = "full",
			order = 2,
		},
		blockGarrison = {
			type = "toggle",
			name = "Block garrison popups",
			desc = "Garrison popups show for a few things, mainly when a follower mission is completed. These popups can cover up critical parts of your UI during a boss fight, so we recommend blocking them.",
			width = "full",
			order = 3,
		},
		blockGuildChallenge = {
			type = "toggle",
			name = "Block guild challenge popups",
			desc = "Guild challenge popups show for a few things, mainly when a group in your guild completes a dungeon or challenge mode. These popups can cover up critical parts of your UI during a boss fight, so we recommend blocking them.",
			width = "full",
			order = 4,
		},
		blockSpellErrors = {
			type = "toggle",
			name = "Block spell failed messages",
			desc = "Messages such as \"Spell is not ready yet\" and \"There is nothing to attack\" that usually show at the top of the screen will be blocked.",
			width = "full",
			order = 5,
		},
	},
}

--------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_OnBossEngage")
	self:RegisterMessage("BigWigs_OnBossWin")
	self:RegisterMessage("BigWigs_OnBossWipe", "BigWigs_OnBossWin")

	if IsEncounterInProgress() then -- Just assume we logged into an encounter after a DC
		self:BigWigs_OnBossEngage()
	end

	self:RegisterEvent("CINEMATIC_START")
	self:RegisterEvent("PLAY_MOVIE")
	self:SiegeOfOrgrimmarCinematics() -- XXX need to do something about this
end

-------------------------------------------------------------------------------
-- Event Handlers
--

function plugin:BigWigs_OnBossEngage()
	if self.db.profile.blockEmotes then
		RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_WHISPER")
	end
	if self.db.profile.blockGarrison then
		AlertFrame:UnregisterEvent("GARRISON_MISSION_FINISHED")
	end
	if self.db.profile.blockGuildChallenge then
		AlertFrame:UnregisterEvent("GUILD_CHALLENGE_COMPLETED")
	end
	if self.db.profile.blockSpellErrors then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	end
end

function plugin:BigWigs_OnBossWin()
	if self.db.profile.blockEmotes then
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
	end
	if self.db.profile.blockGarrison then
		AlertFrame:RegisterEvent("GARRISON_MISSION_FINISHED")
	end
	if self.db.profile.blockGuildChallenge then
		AlertFrame:RegisterEvent("GUILD_CHALLENGE_COMPLETED")
	end
	if self.db.profile.blockSpellErrors then
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end
end

-------------------------------------------------------------------------------
-- Movie Blocking
--

do
	-- Movie handling
	local knownMovies = {
		[16] = true, -- Lich King death
		[73] = true, -- Ultraxion death
		[74] = true, -- DeathwingSpine engage
		[75] = true, -- DeathwingSpine death
		[76] = true, -- DeathwingMadness death
		[152] = true, -- Garrosh defeat
	}

	function plugin:PLAY_MOVIE(_, id)
		if knownMovies[id] and self.db.profile.blockMovies then
			if BigWigs.db.global.watchedMovies[id] then
				BigWigs:Print(L.movieBlocked)
				MovieFrame:Hide()
			else
				BigWigs.db.global.watchedMovies[id] = true
			end
		end
	end
end

do
	-- Cinematic handling
	local cinematicZones = {
		["800:1"] = true, -- Firelands bridge lowering
		["875:1"] = true, -- Gate of the Setting Sun gate breach
		["930:3"] = true, -- Tortos cave entry -- Doesn't work, apparently Blizzard don't want us to skip this..?
		["930:7"] = true, -- Ra-Den room opening
		["953:2"] = true, -- After Immerseus, entry to Fallen Protectors
		["953:8"] = true, -- Blackfuse room opening, just outside the door
		["953:9"] = true, -- Blackfuse room opening, in Thok area
		["953:12"] = true, -- Mythic Garrosh Phase 4
		["964:1"] = true, -- Bloodmaul Slag Mines, activating bridge to Roltall
		["969:2"] = true, -- Shadowmoon Burial Grounds, final boss introduction
		-- 984:1 is Auchindoun, but it unfortunately has 2 cinematics. 1 before the first boss and 1 before the last boss. Workaround?
		["993:2"] = true, -- Grimrail Depot, boarding the train
		["993:4"] = true, -- Grimrail Depot, destroying the train
		["994:3"] = true, -- Highmaul, Kargath Death
	}

	-- Cinematic skipping hack to workaround an item (Vision of Time) that creates cinematics in Siege of Orgrimmar.
	function plugin:SiegeOfOrgrimmarCinematics()
		local hasItem
		for i = 105930, 105935 do -- Vision of Time items
			local _, _, cd = GetItemCooldown(i)
			if cd > 0 then hasItem = true end -- Item is found in our inventory
		end
		if hasItem and not self.SiegeOfOrgrimmarCinematicsFrame then
			local tbl = {[149370] = true, [149371] = true, [149372] = true, [149373] = true, [149374] = true, [149375] = true}
			self.SiegeOfOrgrimmarCinematicsFrame = CreateFrame("Frame")
			-- frame:UNIT_SPELLCAST_SUCCEEDED:player:Vision of Time Scene 2::227:149371:
			self.SiegeOfOrgrimmarCinematicsFrame:SetScript("OnEvent", function(_, _, _, _, _, _, spellId)
				if tbl[spellId] then
					plugin:UnregisterEvent("CINEMATIC_START")
					plugin:ScheduleTimer("RegisterEvent", 10, "CINEMATIC_START")
				end
			end)
			self.SiegeOfOrgrimmarCinematicsFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
		end
	end

	function plugin:CINEMATIC_START()
		if self.db.profile.blockMovies then
			SetMapToCurrentZone()
			local areaId = GetCurrentMapAreaID() or 0
			local areaLevel = GetCurrentMapDungeonLevel() or 0
			local id = ("%d:%d"):format(areaId, areaLevel)

			if cinematicZones[id] then
				if BigWigs.db.global.watchedMovies[id] then
					BigWigs:Print(L.movieBlocked)
					CinematicFrame_CancelCinematic()
				else
					BigWigs.db.global.watchedMovies[id] = true
				end
			end
		end
	end
end

