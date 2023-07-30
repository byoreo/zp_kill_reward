
#include <amxmodx>
#include <amxmisc>

#include <fakemeta_util>
#include <zombieplague>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define PLUGIN "[ZP] Kill Rewards"
#define VERSION "1.0"
#define AUTHOR "byoreo"

enum cvar
{
	giveammo
}

new pcvar[cvar]

new const item_class_name[] = "ammo"

/* Here you can change the model */
new g_model[] = "models/zombie_plague/ammobox.mdl"

/* Here is the sound, when you take it */
new sound[]   =  { "zombie_plague/ammobox.wav" }

public plugin_precache()
{
	precache_model(g_model)	
	precache_sound(sound)
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_Touch, "fwd_Touch")

	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")

 	register_event("HLTV", "EVENT_round_start", "a", "1=0", "2=0")

	pcvar[giveammo] = register_cvar("zp_awards_give_ammo", "3")
}

public EVENT_round_start()
{	
	deleteAllItems()
}

public deleteAllItems()
{
	new ent = FM_NULLENT
	static string_class[] = "classname"
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, string_class, item_class_name))) 
		set_pev(ent, pev_flags, FL_KILLME)
}

public addItem(origin[3])
{
	new ent = fm_create_entity("info_target")
	set_pev(ent, pev_classname, item_class_name)
	
	engfunc(EngFunc_SetModel,ent, g_model)

	set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0})
	set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0})
	set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0})
	engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0})

	set_pev(ent,pev_solid,SOLID_BBOX)
	set_pev(ent,pev_movetype,MOVETYPE_TOSS)
	
	new Float:fOrigin[3]
	IVecFVec(origin, fOrigin)
	set_pev(ent, pev_origin, fOrigin)
	
	set_pev(ent,pev_renderfx,kRenderFxGlowShell)

	new Float:velocity[3];
	pev(ent,pev_velocity,velocity);
	velocity[2] = random_float(265.0,285.0);
	set_pev(ent,pev_velocity,velocity)

	switch(random_num(1,4))
	{
		case 1: set_pev(ent,pev_rendercolor,Float:{0.0,0.0,255.0})
		case 2: set_pev(ent,pev_rendercolor,Float:{0.0,255.0,0.0})
		case 3: set_pev(ent,pev_rendercolor,Float:{255.0,0.0,0.0})
		case 4: set_pev(ent,pev_rendercolor,Float:{255.0,255.0,255.0})
	}
}

public fwd_Touch(toucher, touched)
{
	if (!is_user_alive(toucher) || !pev_valid(touched))
		return FMRES_IGNORED
	
	new classname[32]	
	pev(touched, pev_classname, classname, 31)

	if (!equal(classname, item_class_name))
		return FMRES_IGNORED
	
	zp_set_user_ammo_packs(toucher, zp_get_user_ammo_packs(toucher) + get_pcvar_num(pcvar[giveammo]))
        emit_sound(toucher, CHAN_AUTO, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_pev(touched, pev_effects, EF_NODRAW)
	set_pev(touched, pev_solid, SOLID_NOT)
	
	return FMRES_IGNORED
	
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	new origin[3]
    	get_user_origin(victim , origin)
			
	addItem(origin)
}
