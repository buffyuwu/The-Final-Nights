/mob/living/carbon/human/npc/sabbat/shovelhead
	name = "Loh ebanii"
	a_intent = INTENT_HARM
	hostile = TRUE
	fights_anyway = TRUE
	old_movement = TRUE //dont start pathing down the sidewalk


/mob/living/carbon/human/npc/sabbat/shovelhead/LateInitialize()
	. = ..()
	if(role_weapons_chances.Find(type))
		for(var/weapon in role_weapons_chances[type])
			if(prob(role_weapons_chances[type][weapon]))
				my_weapon = new weapon(src)
				break
	if(!my_weapon && my_weapon_type)
		my_weapon = new my_weapon_type(src)



	if(my_weapon)
		has_weapon = TRUE
		equip_to_appropriate_slot(my_weapon)

	if(my_backup_weapon_type)
		my_backup_weapon = new my_backup_weapon_type(src)
		equip_to_appropriate_slot(my_backup_weapon)

	roundstart_vampire = FALSE
	set_species(/datum/species/kindred)
	clane = new /datum/vampireclane/caitiff()
	generation = 12
	ADD_TRAIT(src, TRAIT_MESSY_EATER, "sabbat_shovelhead")
	is_criminal = TRUE
	AssignSocialRole(pick(/datum/socialrole/usualmale, /datum/socialrole/usualfemale))
	if(wear_mask)
		wear_mask.add_mob_blood(src)
		update_inv_wear_mask()
	if(head)
		head.add_mob_blood(src)
		update_inv_head()
	if(wear_suit)
		wear_suit.add_mob_blood(src)
		update_inv_wear_suit()
	if(w_uniform)
		w_uniform.add_mob_blood(src)
		update_inv_w_uniform()

/mob/living/carbon/human/npc/sabbat/shovelhead/death(gibbed)
	..()
	dust(TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/torpor(source)
	..()
	dust(TRUE)

//If an npc's item has TRAIT_NODROP, we NEVER drop it, even if it is forced.
/mob/living/carbon/human/npc/sabbat/shovelhead/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(I && HAS_TRAIT(I, TRAIT_NODROP))
		return FALSE
	. = ..()
//============================================================



/mob/living/carbon/human/npc/sabbat/shovelhead/AssignSocialRole(datum/socialrole/S, var/dont_random = FALSE)
	if(!S)
		return
	physique = rand(1, max_stat)
	social = rand(1, max_stat)
	mentality = rand(1, max_stat)
	lockpicking = rand(1, max_stat)
	blood = rand(1, 2)
	maxHealth = round(initial(maxHealth)+(initial(maxHealth)/3)*(physique))
	health = round(initial(health)+(initial(health)/3)*(physique))
	last_health = health
	socialrole = new S()
	is_criminal = socialrole.is_criminal
	if(GLOB.winter && !length(socialrole.suits))
		socialrole.suits = list(/obj/item/clothing/suit/vampire/coat/winter, /obj/item/clothing/suit/vampire/coat/winter/alt)
	if(GLOB.winter && !length(socialrole.neck))
		if(prob(50))
			socialrole.neck = list(/obj/item/clothing/neck/vampire/scarf/red,
							/obj/item/clothing/neck/vampire/scarf,
							/obj/item/clothing/neck/vampire/scarf/blue,
							/obj/item/clothing/neck/vampire/scarf/green,
							/obj/item/clothing/neck/vampire/scarf/white)
	if(!dont_random)
		gender = pick(MALE, FEMALE)
		if(socialrole.preferedgender)
			gender = socialrole.preferedgender
		body_type = gender
		var/list/m_names = list()
		var/list/f_names = list()
		var/list/s_names = list()
		if(socialrole.male_names)
			m_names = socialrole.male_names
		else
			m_names = GLOB.first_names_male
		if(socialrole.female_names)
			f_names = socialrole.female_names
		else
			f_names = GLOB.first_names_female
		if(socialrole.surnames)
			s_names = socialrole.surnames
		else
			s_names = GLOB.last_names
		age = rand(socialrole.min_age, socialrole.max_age)
		skin_tone = pick(socialrole.s_tones)
		if(age >= 55)
			hair_color = "#a2a2a2"
			facial_hair_color = hair_color
		else
			hair_color = pick(socialrole.hair_colors)
			facial_hair_color = hair_color
		if(gender == MALE)
			hairstyle = pick(socialrole.male_hair)
			if(prob(25) || age >= 25)
				facial_hairstyle = pick(socialrole.male_facial)
			else
				facial_hairstyle = "Shaved"
			real_name = "[pick(m_names)] [pick(s_names)]"
		else
			hairstyle = pick(socialrole.female_hair)
			facial_hairstyle = "Shaved"
			real_name = "[pick(f_names)] [pick(s_names)]"
		name = real_name
		dna.real_name = real_name
		var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
		if(organ_eyes)
			organ_eyes.eye_color = random_eye_color()
		underwear = random_underwear(gender)
		if(prob(50))
			underwear_color = organ_eyes.eye_color
		if(prob(50) || gender == FEMALE)
			undershirt = random_undershirt(gender)
		if(prob(25))
			socks = random_socks()
		update_body()
		update_hair()
		update_body_parts()

	var/datum/outfit/O = new()
	if(length(socialrole.backpacks))
		O.back = pick(socialrole.backpacks)
	if(length(socialrole.uniforms))
		O.uniform = pick(socialrole.uniforms)
	if(length(socialrole.belts))
		O.belt = pick(socialrole.belts)
	if(length(socialrole.suits))
		O.suit = pick(socialrole.suits)
	if(length(socialrole.gloves))
		O.gloves = pick(socialrole.gloves)
	if(length(socialrole.shoes))
		O.shoes = pick(socialrole.shoes)
	if(length(socialrole.hats))
		O.head = pick(socialrole.hats)
	if(length(socialrole.masks))
		O.mask = pick(socialrole.masks)
	if(length(socialrole.neck))
		O.neck = pick(socialrole.neck)
	if(length(socialrole.ears))
		O.ears = pick(socialrole.ears)
	if(length(socialrole.glasses))
		O.glasses = pick(socialrole.glasses)
	if(length(socialrole.inhand_items))
		O.r_hand = pick(socialrole.inhand_items)
	if(socialrole.id_type)
		O.id = socialrole.id_type
	if(O.uniform && length(socialrole.pockets))
		O.l_pocket = pick(socialrole.pockets)
		if(length(socialrole.pockets) > 1 && prob(50))
			var/list/another_pocket = socialrole.pockets.Copy()
			another_pocket -= O.l_pocket
			O.r_pocket = pick(another_pocket)
	equipOutfit(O)
	qdel(O)

/mob/living/carbon/human/toggle_resting()
	..()
	update_shadow()

/mob/living/carbon/human/npc/sabbat/shovelhead/attack_hand(mob/living/attacker)
	if(attacker && !danger_source)
		for(var/mob/living/carbon/human/npc/sabbat/shovelhead/NEPIC in oviewers(7, src))
			NEPIC.Aggro(attacker)
		Aggro(attacker, TRUE)
	..()

/mob/living/carbon/human/npc/sabbat/shovelhead/on_hit(obj/projectile/P)
	. = ..()
	if(P)
		if(P.firer && !danger_source)
			for(var/mob/living/carbon/human/npc/sabbat/shovelhead/NEPIC in oviewers(7, src))
				NEPIC.Aggro(P.firer)
			Aggro(P.firer, TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	. = ..()
	if(throwingdatum?.thrower && (AM.throwforce > 5 || (AM.throwforce && src.health < src.maxHealth)))
		Aggro(throwingdatum.thrower, TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/attackby(obj/item/W, mob/living/attacker, params)
	. = ..()
	if(attacker && !danger_source)
		if(W.force > 5 || (W.force && src.health < src.maxHealth))
			for(var/mob/living/carbon/human/npc/sabbat/shovelhead/NEPIC in oviewers(7, src))
				NEPIC.Aggro(attacker)
			Aggro(attacker, TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	. = ..()

/mob/living/carbon/human/npc/sabbat/shovelhead/EmoteAction()
	return

/mob/living/carbon/human/npc/sabbat/shovelhead/StareAction()
	return

/mob/living/carbon/human/npc/sabbat/shovelhead/SpeechAction()
	return

/mob/living/carbon/human/npc/sabbat/shovelhead/ghoulificate(mob/owner)
	return FALSE

var/list/sabbat_shovelhead_phrases = list(
	"So... cold...",
	"Agh... My head...!",
	"I'm so sorry...",
	"Please...",
)

/mob/living/carbon/human/npc/sabbat/shovelhead/Aggro(mob/victim, attacked = FALSE)
	if(CheckMove())
		return
	if(danger_source != victim)
		src.Stun(5 SECONDS)
		danger_source = null
		if(!istype(victim, /mob/living/carbon/human/npc/sabbat/shovelhead))
			danger_source = victim
		if(prob(1))
			RealisticSay(pick(sabbat_shovelhead_phrases))

/mob/living/carbon/human/npc/sabbat/proc/tryDrinkBlood(mob/living/carbon/human/attacker, mob/living/victim)
	if(victim.stat == DEAD || attacker.pulling) //dont drag around corpses
		attacker.stop_pulling()
	if(get_dist(src, victim) <= 1)
		if(!attacker.in_frenzy)
			attacker.enter_frenzymod()

/mob/living/carbon/human/npc/sabbat/shovelhead/handle_automated_movement()
	if(CheckMove())
		return
	if(isturf(loc))
		if(danger_source)
			if(isliving(danger_source))
				if(danger_source.stat != DEAD)
					ClickOn(danger_source)
					tryDrinkBlood(src, danger_source)
					if(prob(50))
						face_atom(danger_source)
						var/reqsteps = round((SShumannpcpool.next_fire-world.time)/total_multiplicative_slowdown())
						set_glide_size(DELAY_TO_GLIDE_SIZE(total_multiplicative_slowdown()))
						walk_to(src, danger_source, reqsteps, total_multiplicative_slowdown())
				else
					danger_source = null
			if(last_danger_meet+300 <= world.time)
				danger_source = null
		else //find a victim
			src.stop_pulling() //stops them from pulling corpses around
			for(var/mob/living/carbon/human/victim in oviewers(7, src))
				if(victim.stat != DEAD)
					if(istype(victim, /mob/living/carbon/human/npc/sabbat)) //dont attack the homies
						continue
					else
						danger_source = victim
