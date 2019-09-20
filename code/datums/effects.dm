/*
	What does it do?
	This is used to apply effects to living/carbon mobs or objects. Effects are intended to be things such as fire, acid, slow or even stun.

	How does it work?
	Atom has a var/list/effects_list which is used to hold all the active effects on that atom.
	A subystem called "Effects" is used to process() every effect every second. 

	How to create one?
	Make a new /datum/effects/name in the folder effects
	Overwrite existing procs to fit the wanted behaviour

	How to apply one?
	Create a new /datum/effects/whatever with the object inside the arguments
	Done
*/

/*
	FLAGS FOR EFFECTS
	They determine when an effect should be processed or deleted
*/
#define DEL_ON_DEATH	1	//Delete the effect when something dies
#define DEL_ON_LIVING	2	//Delete the effect when something is alive
#define DEL_ON_DURATION	4	//Only delete the effect when the duration ends

/datum/effects
	var/effect_name = "standard"				//Name of the effect
	var/duration = 0							//How long it lasts
	var/flags = DEL_ON_DEATH					//Flags for the effect
	var/atom/affected_atom = null				//The affected atom
	var/def_zone = "chest"						//The area affected if its a mob
	var/icon_path = null						//The icon path if the effect should apply an overlay to things
	var/obj_icon_state_path = null				//The icon_state path for objs
	var/mob_icon_state_path = null				//The icon_state path for mobs
	var/source_mob = null						//Source mob for statistics
	var/source = null							//Damage source for statistics

/datum/effects/New(var/atom/A, var/mob/from = null, var/last_dmg_source = null, var/zone = "chest")
	if(!validate_atom(A))
		qdel(src)
		return

	active_effects += src
	affected_atom = A
	affected_atom.effects_list += src
	def_zone = zone
	if(from && istype(from))
		source_mob = from
	if(last_dmg_source)
		source = last_dmg_source

/datum/effects/proc/validate_atom(var/atom/A)
	if(iscarbon(A) || isobj(A))
		return TRUE

	return FALSE

/datum/effects/proc/process()
	if(!affected_atom || duration <= 0)
		qdel(src)
		return
	
	duration--

	if(iscarbon(affected_atom))
		process_mob()
	else if (isobj(affected_atom))
		process_obj()

/datum/effects/proc/process_mob()
	var/mob/living/carbon/affected_mob = affected_atom
	if((flags & DEL_ON_DEATH) && affected_mob.stat == DEAD && !(flags & DEL_ON_DURATION))
		qdel(src)
		return

	if((flags & DEL_ON_LIVING) && affected_mob.stat != DEAD && !(flags & DEL_ON_DURATION))
		qdel(src)
		return

/datum/effects/proc/process_obj()
	var/obj/affected_obj = affected_atom
	if((flags & DEL_ON_DEATH) && affected_obj.health <= 0 && !(flags & DEL_ON_DURATION))
		qdel(src)
		return

	if((flags & DEL_ON_LIVING) && affected_obj.health > 0 && !(flags & DEL_ON_DURATION))
		qdel(src)
		return

/datum/effects/Dispose()
	if(affected_atom)
		affected_atom.effects_list -= src
		affected_atom = null
	active_effects -= src
	. = ..()
	


