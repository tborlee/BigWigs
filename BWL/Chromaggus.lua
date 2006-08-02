﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Chromaggus")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

local breath1 = nil
local breath2 = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Chromaggus",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",
	
	breath_cmd = "breath",
	breath_name = "Breath Alerts",
	breath_desc = "Warn for Breaths",
	
	vulnerability_cmd = "vulnerability",
	vulnerability_name = "Vulnerability Alerts",
	vulnerability_desc = "Warn for Vulnerability changes",
	
	trigger1 = "^Chromaggus begins to cast ([%w ]+)\.",
	trigger2 = "^[%w']+ [%w' ]+ ([%w]+) Chromaggus for ([%d]+) ([%w ]+) damage%..*",
	trigger3 = "Chromaggus's Time Lapse was resisted by ([%w]+)%.",
	trigger4 = "goes into a killing frenzy!",
	trigger5 = "flinches as its skin shimmers.",

	hit = "hits",
	crit = "crits",

	warn1 = "%s in 10 seconds!",
	warn2 = "%s is casting!",
	warn3 = "New spell vulnerability: %s",
	warn4 = "Spell vulnerability changed!",
	warn5 = "Frenzy Alert!",

	breath1 = "Time Lapse",
	breath2 = "Corrosive Acid",
	breath3 = "Ignire Flesh",
	breath4 = "Incinerate",
	breath5 = "Frost Burn",

	icon1 = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar",
	icon2 = "Interface\\Icons\\Spell_Nature_Acid_01",
	icon3 = "Interface\\Icons\\Spell_Fire_Fire",
	icon4 = "Interface\\Icons\\Spell_Shadow_ChillTouch",
	icon5 = "Interface\\Icons\\Spell_Frost_ChillingBlast",

} end )

L:RegisterTranslations("deDE", function() return {
	trigger1 = "^Chromaggus beginnt ([%w ]+)\ zu wirken.",
	trigger2 = "^[%w']+ [%w' ]+ ([%w]+) Chromaggus f\195\188r ([%d]+) ([%w ]+)schaden%..*",
	trigger3 = "Chromaggus's Zeitraffer wurde von ([%w]+)% widerstanden.",
	trigger4 = "ger\195\164t in t\195\182dliche Raserei!",
	trigger5 = "als die Haut schimmert",

	hit = "trifft",
	crit = "trifft kritisch",

	warn1 = "%s in 10 Sekunden!",
	warn2 = "Chromaggus wirkt %s!",
	warn3 = "Neue Verwundbarkeit: %s",
	warn4 = "Verwundbarkeit ge\195\164ndert!",
	warn5 = "RASEREI!",

	breath1 = "Zeitraffer",
	breath2 = "Corrosive Acid",
	breath3 = "Fleisch entz\195\188nden",
	breath4 = "Verbrennen",
	breath5 = "Frostbeulen",
} end )

L:RegisterTranslations("zhCN", function() return {
	trigger1 = "^克洛玛古斯开始施放(.+)。",
	trigger2 = "^.+的(.+)克洛玛古斯造成(%d+)点(.+)伤害。",
	trigger3 = "^克洛玛古斯的时间流逝被(.+)抵抗了。",
	trigger4 = "变得极为狂暴！",
	trigger5 = "的皮肤闪着光芒",

	hit = "击中",
	crit = "致命一击",

	warn1 = "%s - 10秒后施放！",
	warn2 = "正在施放 %s！",
	warn3 = "新法术弱点：%s",
	warn4 = "法术弱点已改变！",
	warn5 = "狂暴警报 - 猎人立刻使用宁神射击！",

	breath1 = "时间流逝",
	breath2 = "腐蚀酸液",
	breath3 = "Ignite Flesh",
	breath4 = "Incinerate",
	breath5 = "冰霜灼烧",
} end )

L:RegisterTranslations("koKR", function() return {
	trigger1 = "크로마구스|1이;가; (.+)|1을;를; 시전합니다.",
	trigger2 = "(.+)|1이;가; (.+)|1으로;로; 크로마구스에게 (%d+)의 (.+) 입혔습니다.",
	trigger3 = "크로마구스|1이;가; 시간의 쇠퇴|1으로;로; (.+)|1을;를; 공격했지만 저항했습니다.",		
	trigger4 = "광란의 상태에 빠집니다!",
	trigger5 = "가죽이 점점 빛나면서 물러서기 시작합니다.",

	hit = "피해를",
	crit = "치명상을",

	warn1 = "%s 10초전!",
	warn2 = "%s를 시전합니다!",
	warn3 = "새로운 취약 속성: %s",
	warn4 = "취약 속성이 변경되었습니다!",
	warn5 = "광폭화 - 평정 사격!",

	breath1 = "시간의 쇠퇴",
	breath2 = "부식성 산",
	breath3 = "살점 태우기",
	breath4 = "소각",
	breath5 = "동결",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsChromaggus = BigWigs:NewModule(boss)
BigWigsChromaggus.zonename = AceLibrary("Babble-Zone-2.0")("Blackwing Lair")
BigWigsChromaggus.enabletrigger = boss
BigWigsChromaggus.toggleoptions = { "frenzy", "breath", "vulnerability", "bosskill"}
BigWigsChromaggus.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsChromaggus:OnEnable()
	-- in the module itself for resetting via schedule
	self.vulnerability = nil
	-- locals
	breath1 = nil
	breath2 = nil

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "ChromaggusBreath", 10)

end

function BigWigsChromaggus:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	local _,_, SpellName = string.find(msg, L"trigger1")
	if SpellName then
		self:TriggerEvent("BigWigs_SendSync", "ChromaggusBreath "..SpellName)
	end
end

function BigWigsChromaggus:BigWigs_RecvSync(sync, SpellName)
	if sync ~= "ChromaggusBreath" then return end
	
	if SpellName then
		if not breath1 then
			breath1 = SpellName
		elseif not breath2 and not breath1 ~= SpellName then
			breath2 = SpellName
		end

		self:TriggerEvent("BigWigs_Message", format(L"warn2", SpellName), "Red")

		-- figure out the icon
		local breathnr = L:HasReverseTranslation(SpellName) and L:GetReverseTranslation(SpellName) or "breath1"
		breathnr = string.sub(breathnr, -1 )
		if tonumber( breathnr) < 1 or tonumber( breathnr ) > 5 then breathnr = 1 end
		local icon = "icon"..breathnr
		icon = L(icon)

		if breath1 == SpellName and not self.db.profile.breath then
			self:ScheduleEvent("bwchromaggusbreath1", "BigWigs_Message", 50, format(L"warn1", breath1), "Red")
			self:TriggerEvent("BigWigs_StartBar", self, breath1, 60, 1, icon, "Green", "Yellow", "Orange", "Red")
		elseif breath2 == SpellName and self.db.profile.breath then
			self:ScheduleEvent("bwchromaggusbreath2", "BigWigs_Message", 50, format(L"warn1", breath2), "Red")
			self:TriggerEvent("BigWigs_StartBar", self, breath2, 60, 2, icon, "Green", "Yellow", "Orange", "Red")
		end
	end
end

function BigWigsChromaggus:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L"trigger4" and self.db.profile.frenzy then
		self:TriggerEvent("BigWigs_Message", L"warn5", "Red")
	elseif msg == L"trigger5" and self.db.profile.vulnerability then
		self:TriggerEvent("BigWigs_Message", L"warn4", "White")
		self:ScheduleEvent(function() BigWigsChromaggus.vulnerability = nil end, 2.5 )
	end
end

if (GetLocale() == "koKR") then
	function BigWigsChromaggus:PlayerDamageEvents(msg)
		if (not self.vulnerability) then
			local _, _, _, school, dmg, type = string.find(msg, L"trigger2")
			if type == (L"hit" or L"crit") and tonumber(dmg or "") and school then
				if (tonumber(dmg) >= 550 and type == L"hit") or (tonumber(dmg) >= 1100 and type == L"crit") then
					self.vulnerability = school
					if self.db.profile.vulnerability then self:TriggerEvent("BigWigs_Message", format(L"warn3", school), "White") end
				end
			end
		end
	end
else
	function BigWigsChromaggus:PlayerDamageEvents(msg)
		if (not self.vulnerability) then
			local _,_, type, dmg, school = string.find(msg, L"trigger2")
			if type == (L"hit" or L"crit") and tonumber(dmg or "") and school then
				if (tonumber(dmg) >= 550 and type == L"hit") or (tonumber(dmg) >= 1100 and type == L"crit") then
					self.vulnerability = school
					if self.db.profile.vulnerability then self:TriggerEvent("BigWigs_Message", format(L"warn3", school), "White") end
				end
			end
		end
	end
end
