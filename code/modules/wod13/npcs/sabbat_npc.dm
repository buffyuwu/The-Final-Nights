/mob/living/carbon/human/npc/sabbat/shovelhead
	name = "Loh ebanii"
	a_intent = INTENT_HARM
	hostile = TRUE
	fights_anyway = TRUE
	old_movement = TRUE //dont start pathing down the sidewalk
	var/datum/action/blood_heal_action

/mob/living/carbon/human/npc/sabbat/shovelhead/LateInitialize()
	. = ..()

	//assign their special stuff. species, clane, etc
	roundstart_vampire = FALSE
	set_species(/datum/species/kindred)
	clane = new /datum/vampireclane/caitiff()
	generation = 12
	ADD_TRAIT(src, TRAIT_MESSY_EATER, "sabbat_shovelhead")
	is_criminal = TRUE

	//dress them, name them
	AssignSocialRole(pick(/datum/socialrole/usualmale, /datum/socialrole/usualfemale))

	//store actions to use later based on what we rolled for disciplines
	//TODO: add randomly rolled disciplines
	for(var/datum/action/discipline/action in actions)
		if(action.discipline.name == "Bloodheal")
			blood_heal_action = action

	//bloody their clothes
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
		else
			hairstyle = pick(socialrole.female_hair)
			facial_hairstyle = "Shaved"
		real_name = pick("Shovelhead","Mass-embraced Lunatic", "Reanimated Psycho")
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
	if(attacker)
		for(var/mob/living/carbon/human/npc/sabbat/shovelhead/NEPIC in oviewers(7, src))
			NEPIC.Aggro(attacker)
		Aggro(attacker, TRUE)
	..()

/mob/living/carbon/human/npc/sabbat/shovelhead/on_hit(obj/projectile/P)
	. = ..()
	if(P)
		if(P.firer)
			for(var/mob/living/carbon/human/npc/sabbat/shovelhead/NEPIC in oviewers(7, src))
				NEPIC.Aggro(P.firer)
			Aggro(P.firer, TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	. = ..()
	if(throwingdatum?.thrower && (AM.throwforce > 5 || (AM.throwforce && src.health < src.maxHealth)))
		Aggro(throwingdatum.thrower, TRUE)

/mob/living/carbon/human/npc/sabbat/shovelhead/attackby(obj/item/W, mob/living/attacker, params)
	. = ..()
	if(attacker)
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

var/list/shovelhead_idle_phrases = list(
	"So... cold...",
	"Please...",
	"Help me...",
	"Help me... please...",
	"I don't... want to die...",
	"Everything... hurts...",
)

var/list/shovelhead_attack_phrases = list(
	"So... HUNGRY!!",
	"Blood... I need blood!",
	"Give me... your blood!",
	"Blood...",
	"Warm...",
	"Ow...",
	"Why...?",
	"Why me...?",
	"It... hurts...",
)

/mob/living/carbon/human/npc/sabbat/shovelhead/Annoy(atom/source)
	return

/mob/living/carbon/human/npc/sabbat/shovelhead/Aggro(mob/victim, attacked = FALSE)
	if(CheckMove())
		return
	if (istype(victim, /mob/living/carbon/human/npc/sabbat))
		return
	if(frenzy_target != victim)
		frenzy_target = victim
		RealisticSay(pick(shovelhead_attack_phrases)) //dialogue when we switch targets

/mob/living/carbon/human/npc/sabbat/shovelhead/handle_automated_movement()
	if(CheckMove())
		return
	if(isturf(loc))
		if(!in_frenzy)
			bloodpool = 5
			enter_frenzymod()
		if(prob(50) && (getBruteLoss() + getFireLoss() >= 40) && (bloodpool > 2)) //we are wounded, heal ourselves if we can
			blood_heal_action.Trigger()
			visible_message(
			span_warning("[src]'s wounds heal with unnatural speed!"),
			span_warning("Your wounds visibly heal with unnatural speed!")
			)
/mob/living/carbon/human/npc/sabbat/shovelhead/ChoosePath()
	return

/mob/living/carbon/human/npc/sabbat/shovelhead/Life()
	if(stat == DEAD)
		return
	..()
	if(CheckMove())
		return
	if(!frenzy_target) //no opps, wander around
		if(prob(15))
			var/turf/T = get_step(src, pick(NORTH, SOUTH, WEST, EAST))
			face_atom(T)
			step_to(src,T,0)
		if(prob(1))
			RealisticSay(pick(shovelhead_idle_phrases))
