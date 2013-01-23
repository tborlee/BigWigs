local L = BigWigs:NewBossLocale("Imperial Vizier Zor'lok", "esES") or BigWigs:NewBossLocale("Imperial Vizier Zor'lok", "esMX")
if not L then return end
if L then
	L.engage_yell = "La Divina nos ha elegido para dar voz mortal a Su pensamiento eterno. Solo somos el brazo que ejecuta Su voluntad."

	L.force_message = "Pulso AoE"

	L.attenuation = EJ_GetSectionInfo(6426) .. " (Discos)"
	L.attenuation_bar = "¡Discos... baila!"
	L.attenuation_message = "%s Baile %s"
	L.echo = "|c001cc986Echo|r"
	L.zorlok = "|c00ed1ffaZor'lok|r"
	L.left = "|c00008000<- Izquierda <-|r"
	L.right = "|c00FF0000-> Derecha ->|r"

	L.platform_emote = "¡El visir imperial Zor'lok vuela hacia una de las plataformas!" -- Imperial Vizier Zor'lok flies to one of his platforms!
	L.platform_emote_final = "¡El visir imperial Zor'lok inhala las feromonas de celo!"-- Imperial Vizier Zor'lok inhales the Pheromones of Zeal!
	L.platform_message = "Cambio de plataforma"
end

L = BigWigs:NewBossLocale("Blade Lord Ta'yak", "esES") or BigWigs:NewBossLocale("Blade Lord Ta'yak", "esMX")
if L then
	L.engage_yell = "¡En guardia, invasores! Yo, Ta'yak, Señor de las Espadas, seré vuestro contrincante."

	L.unseenstrike_inc = "¡Golpe inminente!"
	L.unseenstrike_soon = "¡Golpe en ~5-10 seg!"

	L.assault_message = "Asalto"
	L.side_swap = "Cambia de lado"
end

L = BigWigs:NewBossLocale("Garalon", "esES") or BigWigs:NewBossLocale("Garalon", "esMX")
if L then
	L.phase2_trigger = "Garalon's massive armor plating begins to crack and split!"

	L.removed = "¡%s eliminado!"
end

L = BigWigs:NewBossLocale("Wind Lord Mel'jarak", "esES") or BigWigs:NewBossLocale("Wind Lord Mel'jarak", "esMX")
if L then
	L.spear_removed = "¡Tu Lanza empaladora fue eliminada!"
	L.residue_removed = "¡%s eliminado!"

	L.mending_desc = "|cFFFF0000WARNING: Solo se mostrará el temporizador para tu 'focus' porque todos los Ensalmador de batalla Zar'thik tienen diferentes CDs de sanación.|r "
	L.mending_warning = "¡Tu focus está casteando Aliviar!"
	L.mending_bar = "Focus: Aliviar"
end

L = BigWigs:NewBossLocale("Amber-Shaper Un'sok", "esES") or BigWigs:NewBossLocale("Amber-Shaper Un'sok", "esMX")
if L then
	L.explosion_by_other = "Deflagración de ámbar en otros"
	L.explosion_by_other_desc = "Deflagración de ámbar lanzado por Monstruosidad de ámbar o tu foco si lo tienes marcado."

	L.explosion_casting_by_other = "Deflagración de ámbar lanzado por otros"
	L.explosion_casting_by_other_desc = "Deflagración de ámbar empezados por Monstruosidad de ámbar o tu foco si lo tienes marcado. ¡Es altamente recomendable enfatizar esto!"

	L.explosion_by_you = "Deflagración de ámbar en ti"
	L.explosion_by_you_bar = "Empiezas a castear..."
	L.explosion_by_you_desc = "Deflagración de ámbar propia."

	L.explosion_casting_by_you = "Deflagración de ámbar lanzado por ti"
	L.explosion_casting_by_you_desc = "Deflagración de ámbar empezados por ti. ¡Es altamente recomendable enfatizar esto!"

	L.willpower = "Voluntad"
	L.willpower_message = "¡Voluntad al %d!"

	L.break_free_message = "¡Vida al %d%%!"
	L.fling_message = "¡Vas a ser lanzado!"
	L.parasite = "Parásito"

	L.monstrosity_is_casting = "Monstruosidad: Explosión"
	L.you_are_casting = "¡ESTÁS casteando!"

	L.unsok_short = "|cFFF20056Boss|r" -- Light Red
	L.monstrosity_short = "|cFFFFBE00Add|r" -- Amber
end

L = BigWigs:NewBossLocale("Grand Empress Shek'zeer", "esES") or BigWigs:NewBossLocale("Grand Empress Shek'zeer", "esMX")
if L then
	L.engage_trigger = "¡Muerte a todo aquel que desafíe a mi imperio!"
	L.phases = "Fases"
	L.phases_desc = "Cambios de fase."

	L.eyes = "Ojos de la Emperatriz"
	L.eyes_desc = "Muestra stacks y barra de duración para Ojos de la Emperatriz."
	L.eyes_message = "%2$dx Ojos en %1$s"

	L.fumes_bar = "Tu beneficio de Vapores"
end

