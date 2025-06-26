

/mob/living/simple_animal/revenant/auspex_demon
	name = "auspex demon"
	desc = "A malevolent spirit."
	var/mob/dead/observer/avatar/haunt_target
	COOLDOWN_DECLARE(revenant_auspex_demon_move)
	COOLDOWN_DECLARE(revenant_auspex_demon_attack)
	var/stalk_distance = 20 //the spirits distance from its target. gets lower overtime before it eventually reaches 0
	var/list/spooky_phrases = list("You don't belong here...",
	"Living one...",
	"She watches you...",
	"We watch you...",
	"Time to go...",
	"Why do you anger her...?",
	"She is coming...",
	"They make more... In the shadows, in the dirt...",
	"Gehenna...",
	"Find her...",
	"So cold...",
	"You are not welcome here..."
	)

/mob/living/simple_animal/revenant/Initialize()
	. = ..()
	AddElement(/datum/element/point_of_interest) // let observers know something entertaining is happening

/mob/living/simple_animal/revenant/auspex_demon/Life()
	. = ..()
	if(QDELETED(haunt_target) || !haunt_target)
		qdel(src)

	if(COOLDOWN_FINISHED(src, revenant_auspex_demon_attack))
		if(get_dist(src, haunt_target) < 2) //caught ya
			haunt_target?.reenter_corpse(TRUE)
		COOLDOWN_START(src, revenant_auspex_demon_attack, rand(1 SECONDS, 3 SECONDS))

	if(!COOLDOWN_FINISHED(src, revenant_auspex_demon_move))
		return

	COOLDOWN_START(src, revenant_auspex_demon_move, rand(12 SECONDS, 24 SECONDS))
	var/spooky_phrase = pick(spooky_phrases)
	for(var/letter in GLOB.malkavian_character_replacements)
		spooky_phrase = replacetextEx(spooky_phrase, letter, GLOB.malkavian_character_replacements[letter])
	if(prob(50)) //50% chance to say a spooky phrase every 12 to 24 seconds
		to_chat(haunt_target, span_cult(spooky_phrase))
	stalk_distance = max(0, stalk_distance - rand(1,3))
	z = haunt_target.z
	walk_towards(src, haunt_target, stalk_distance)
	if(get_dist(src, haunt_target) > 20) //they evaded the spirits... for now
		haunt_target.haunted = FALSE
		qdel(src)
