------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Maexxna")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "maexxna",
	
	spray_cmd = "spray",
	spray_name = "Web Spray Alert",
	spray_desc = "Warn for webspray and spiders",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",

	webwraptrigger = "(.*) (.*) afflicted by Web Wrap.",
	webspraytrigger = "is afflicted by Web Spray.",

	enragetrigger = "becomes enraged.",

	webspraywarn30sec = "Wall Cocoons in 10 seconds",
	webspraywarn20sec = "Wall Cocoons! 10 seconds until Spiders spawn!",
	webspraywarn10sec = "Spiders Spawn. 10 seconds until Web Spray!",
	webspraywarn5sec = "WEB SPRAY 5 seconds!",
	webspraywarn = "Web Spray! 40 seconds until next!",
	enragewarn = "Enrage - Give it all you got!",
	enragesoonwarn = "Enrage Soon - Get Ready!",

	webspraybar = "Web Spray",

	you = "You",
	are = "are",
} end )

L:RegisterTranslations("deDE", function() return {
	webwraptrigger = "(.*) (.*) ist von Fangnetz betroffen.",
	webspraytrigger = "ist von Gespinstschauer betroffen.",

	enragetrigger = "wird w\195\188tend.",

	webspraywarn30sec = "Fangnetze in 10 Sekunden",
	webspraywarn20sec = "Fangnetze! 10 Sekunden bis Gespinst!",
	webspraywarn10sec = "Spinnen! 10 Sekunden bis Kokons!",
	webspraywarn5sec = "GESPINST in 5 Sekunden!",
	webspraywarn = "GESPINST! N\195\164chstes in 40 Sekunden!",
	enragewarn = "Enrage - Gebt alles!",
	enragesoonwarn = "Enrage in K\195\188rze - ACHTUNG!",

	webspraybar = "Web Spray",

	you = "Ihr",
	are = "seid",
} end )

L:RegisterTranslations("koKR", function() return {
	webwraptrigger = "(.*) (.*) afflicted by Web Wrap.", -- "(.*)|1이;가; 거미줄 감싸기에 걸렸습니다."
	webspraytrigger = "거미줄 뿌리기에 걸렸습니다.",		

	enragetrigger = "맥스나|1이;가; 분노에 휩싸입니다!",

	webspraywarn30sec = "10초후 거미줄 감싸기",
	webspraywarn20sec = "거미줄 감싸기. 10초후 거미 소환!",
	webspraywarn10sec = "거미 소환. 10초후 거미줄 뿌리기!",
	webspraywarn5sec = "5초! HOTS/ABOLISH/GOGO",
	webspraywarn = "거미줄 감싸기! 다음 번은 40초후!",
	enragewarn = "분노 - 무한 공격!",
	enragesoonwarn = "분노 예고 - 준비!",

	webspraybar = "거미줄 뿌리기",

	you = "You",
	are = "are",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMaexxna = BigWigs:NewModule(boss)
BigWigsMaexxna.zonename = AceLibrary("Babble-Zone-2.0")("Naxxramas")
BigWigsMaexxna.enabletrigger = boss
BigWigsMaexxna.toggleoptions = {"spray", "enrage", "bosskill"}
BigWigsMaexxna.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMaexxna:OnEnable()
	self.enrageannounced = nil

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "SprayEvent")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MaexxnaWebspray", 8)
end

function BigWigsMaexxna:SprayEvent( msg )
	-- web spray warning
	if string.find(msg, L"webspraytrigger") then
		self:TriggerEvent("BigWigs_SendSync", "MaexxnaWebspray")
	end
end


function BigWigsMaexxna:BigWigs_RecvSync( sync )
	if sync ~= "MaexxnaWebspray" then return end

	self:TriggerEvent("BigWigs_Message", L"webspraywarn", "Red")
	self:ScheduleEvent("BigWigs_Message", 10, L"webspraywarn30sec", "Yellow")
	self:ScheduleEvent("BigWigs_Message", 20, L"webspraywarn20sec", "Yellow")
	self:ScheduleEvent("BigWigs_Message", 30, L"webspraywarn10sec", "Yellow")
	self:ScheduleEvent("BigWigs_Message", 35, L"webspraywarn5sec", "Yellow")
	self:TriggerEvent("BigWigs_StartBar", self, L"webspraybar", 40, 1, "Interface\\Icons\\Ability_Ensnare", "Green", "Yellow", "Orange", "Red")
end



function BigWigsMaexxna:Scan()
	if UnitName("target") == boss and UnitAffectingCombat("target") then
		return true
	elseif UnitName("playertarget") == boss and UnitAffectingCombat("playertarget") then
		return true
	else
		local i
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("raid"..i.."target") == bossname and UnitAffectingCombat("raid"..i.."target") then
				return true
			end
		end
	end
	return false
end

function BigWigsMaexxna:PLAYER_REGEN_DISABLED()
	local go = self:Scan()
	if (go) then
		self:TriggerEvent("BigWigs_SendSync", "MaexxnaWebspray") 
	end
end

function BigWigsMaexxna:PLAYER_REGEN_ENABLED()
	local go = self:Scan()
	local running = self:IsEventScheduled("Maexxna_CheckWipe")
	if (not go) then
		self:TriggerEvent("BigWigs_RebootModule", self)
	elseif (not running) then
		self:ScheduleRepeatingEvent("Maexxna_CheckWipe", self.PLAYER_REGEN_ENABLED, 2, self)
	end
end

function BigWigsMaexxna:CHAT_MSG_MONSTER_EMOTE( msg )
	if self.db.profile.enrage and msg == L"enragetrigger" then 
		self:TriggerEvent("BigWigs_Message", L"enragewarn", "Red")
	end
end

function BigWigsMaexxna:UNIT_HEALTH( msg )
	if UnitName(msg) == boss then
		local health = UnitHealth(msg)
		if (health > 30 and health <= 33) then
			if self.db.profile.enrage then self:TriggerEvent("BigWigs_Message", L"enragesoonwarn", "Red") end
			self.enrageannounced = true
		elseif (health > 40 and self.enrageannounced) then
			self.enrageannounced = nil
		end
	end
end
