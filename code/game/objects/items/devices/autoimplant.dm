#define INFINITE -1

/obj/item/device/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	w_class = 2
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/uses = INFINITE
	var/starting_organ

/obj/item/device/autosurgeon/New()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/device/autosurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/device/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		user << "<span class='warning'>[src] has already been used. The tools are dull and won't reactivate.</span>"
		return
	else if(!storedorgan)
		user << "<span class='notice'>[src] currently has no implant stored.</span>"
		return
	var/obj/item/organ/internal/organtoimplant = storedorgan
	organtoimplant.Insert(user)//insert stored organ into the user
	user << "<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>"
	playsound(user.loc, 'sound/weapons/circsawhit.ogg', 50, 1, -1)
	qdel(storedorgan)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/device/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/device/autosurgeon/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			user << "<span class='notice'>[src] already has an implant stored.</span>"
			return
		else if(!uses)
			user << "<span class='notice'>[src] has already been used up.</span>"
			return
		storedorgan = I
		user << "<span class='notice'>You insert the [I] into [src].</span>"
	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!storedorgan)
			user << "<span class='notice'>There's no implant in [src] for you to remove.</span>"
		else
			user.put_in_hands(storedorgan)
			user << "<span class='notice'>You remove the [storedorgan] from [src].</span>"
			storedorgan = null
			if(uses != INFINITE)
				uses--
			if(!uses)
				desc = "[initial(desc)] Looks like it's been used up."