#define CANDLE_LUMINOSITY	2
/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	inhand_icon_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
	light_color = LIGHT_COLOR_FIRE
	heat = 1000
	/// How many seconds it burns for
	var/wax = 2000
	var/lit = FALSE
	var/infinite = FALSE
	var/start_lit = FALSE

/obj/item/candle/Initialize()
	. = ..()
	if(start_lit)
		light()

/obj/item/candle/update_icon_state()
	icon_state = "candle[(wax > 800) ? ((wax > 1500) ? 1 : 2) : 3][lit ? "_lit" : ""]"
	return ..()

/obj/item/candle/attackby(obj/item/W, mob/user, params)
	var/msg = W.ignition_effect(src, user)
	if(msg)
		light(msg)
	else
		return ..()

/obj/item/candle/fire_act(exposed_temperature, exposed_volume)
	if(!lit)
		light() //honk
	return ..()

/obj/item/candle/get_temperature()
	return lit * heat

/obj/item/candle/proc/light(show_message)
	if(!lit)
		lit = TRUE
		if(show_message)
			usr.visible_message(show_message)
		set_light(CANDLE_LUMINOSITY)
		START_PROCESSING(SSobj, src)
		update_appearance()

/obj/item/candle/proc/put_out_candle()
	if(!lit)
		return
	lit = FALSE
	update_appearance()
	set_light(0)
	return TRUE

/obj/item/candle/extinguish()
	put_out_candle()
	return ..()

/obj/item/candle/process(delta_time)
	if(!lit)
		return PROCESS_KILL
	if(!infinite)
		wax -= delta_time
	if(wax <= 0)
		new /obj/item/trash/candle(loc)
		qdel(src)
	update_appearance()
	open_flame()

/obj/item/candle/attack_self(mob/user)
	if(put_out_candle())
		user.visible_message("<span class='notice'>[user] snuffs [src].</span>")

/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

#undef CANDLE_LUMINOSITY
