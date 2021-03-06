/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "author"

//new bool:bWallClimb[ 33 ] = true;

new Float:flWallOrigin[ 33 ][ 3 ];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward( FM_Touch, "forward_Touch" );
	register_forward( FM_PlayerPreThink, "forward_PreThink" ); 
}

public forward_Touch( id, iWorld )
{ 
	if( !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}
	
	pev( id, pev_origin, flWallOrigin[ id ] );
	
	return FMRES_IGNORED;
} 

public forward_PreThink( id )
{
	if( !is_user_alive( id ) )
	{
		return FMRES_IGNORED;
	}
	
	new iButton = pev( id, pev_button );
	
	if( iButton & IN_USE )
	{
		new Float:flVelocity[ 3 ] = { 0.0, 0.0, 0.0 };
		set_pev( id, pev_velocity, flVelocity );

		WallClimb( id );
	}
	
	return FMRES_IGNORED;
}

public WallClimb( id )
{
	new Float:flOrigin[ 3 ];
	new Float:flVelocity[ 3 ];

	pev( id, pev_origin, flOrigin );
	
	if( get_distance_f( flOrigin, flWallOrigin[ id ] ) > 25.0 )
	{
		return PLUGIN_HANDLED;
	}
	
	if( pev( id, pev_flags ) & FL_ONGROUND )
	{
		return PLUGIN_HANDLED;
	}
	
	new iButton = pev( id, pev_button );

	if( iButton & IN_FORWARD )
	{
		velocity_by_aim( id, 125, flVelocity );
			
		set_pev( id, pev_velocity, flVelocity );
	}
		
	else if( iButton & IN_BACK )
	{
		velocity_by_aim( id, -125, flVelocity );
			
		set_pev( id, pev_velocity, flVelocity );
	}
	
	
	return PLUGIN_HANDLED;
}
