/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>

#include < fun >
#include < engine >
#include < fakemeta >
#include < colorchat >

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "author"

#define TASK_HEALING		2312131

#define MAX_PLAYERS		32 + 1

#define HEALING_DURATION	5

#define IS_PLAYER(%1)		(1 <= %1 <= gMaxPlayers)
#define FFADE_IN 		0x0000

new gMessageBarTime;
new gMessageScreenFade;
new gMaxPlayers;

new i;

new bool:bHealing[ MAX_PLAYERS ] = false;

new const gHealSounds[ ][ ] = 
{
	"items/medshot4.wav",
	"items/smallmedkit1.wav",
	"items/smallmedkit2.wav"
};

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

// Add your code here...
	gMaxPlayers = get_maxplayers( );
	gMessageBarTime = get_user_msgid( "BarTime" );
	gMessageScreenFade = get_user_msgid( "ScreenFade" );


	register_clcmd( "heal", "CommandHeal" );

	register_event( "DeathMsg", "Hook_Death", "a" );
}

public plugin_precache( )
{
	for( i = 0; i < sizeof gHealSounds; i++ )
	{
		precache_sound( gHealSounds[ i ] );
	}
	
	precache_model( "models/rpgrocket.mdl" );
}

public client_connect( id )
{
	bHealing[ id ] = false;
}

public client_disconnect( id )
{
	remove_task( id + TASK_HEALING );
	bHealing[ id ] = false;
}

public Hook_Death( )
{
	new iVictim = read_data( 2 );

	if( IS_PLAYER( iVictim ) )
	{
		remove_task( iVictim + TASK_HEALING );
		set_user_rendering( iVictim );
		
		set_pev( iVictim, pev_flags, pev( iVictim, pev_flags ) & ~FL_FROZEN );
		set_view( iVictim, CAMERA_NONE );
			
		bHealing[ iVictim ] = false;
		UTIL_BarTime( iVictim, 0 );
	}
}

public CommandHeal( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new iHealth = get_user_health( id );
	
	if( iHealth >= 80 )
	{
		ColorChat( id, GREEN, "^1You can't use the^4 First-Aid Kit^1 right now!" );
		
		return PLUGIN_HANDLED;
	}
	
	if( bHealing[ id ] == true )
	{
		ColorChat( id, GREEN, "^4First-Aid Kit^1 healing in progress!" );
		
		return PLUGIN_HANDLED;
	}
	
	new iFlags = pev( id, pev_flags );
	
	if( !( iFlags & FL_ONGROUND ) 
	|| iFlags & FL_INWATER
	|| iFlags & FL_WATERJUMP )
	{
		ColorChat( id, GREEN, "^1You can't use^4 First-Aid Kit^1 right now!" );
		
		return PLUGIN_HANDLED;
	}

	bHealing[ id ] = true;
	set_view( id, CAMERA_3RDPERSON );
	
	set_user_rendering( id, kRenderFxGlowShell, 255, 10, 10, kRenderNormal, 100 );
	UTIL_BarTime( id, HEALING_DURATION );
	
	set_task( float( HEALING_DURATION ), "HealPlayer", id + TASK_HEALING );
	set_pev( id, pev_flags, pev( id, pev_flags ) | FL_FROZEN );
	
	return PLUGIN_HANDLED;
}

public HealPlayer( iTask )
{
	new id = iTask - TASK_HEALING;
	
	if( IS_PLAYER( id ) )
	{
		if( is_user_alive( id ) )
		{
			remove_task( id + TASK_HEALING );
			
			set_user_health( id, 100 );
			set_user_rendering( id );
			
			set_pev( id, pev_flags, pev( id, pev_flags ) & ~FL_FROZEN );
			set_view( id, CAMERA_NONE );
			
			bHealing[ id ] = false;
			UTIL_BarTime( id, 0 );
			UTIL_Fade( id, 255, 10, 10, 70 );

			emit_sound( id, CHAN_BODY, gHealSounds[ random_num( 0, charsmax( gHealSounds ) ) ], VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			ColorChat( id, GREEN, "^1Successfuly used the^4 First-Aid Kit^1!" );
		}
	}
}

stock UTIL_BarTime( id, iDuration )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageBarTime, _, id );
	write_short( iDuration );
	message_end( );
}

stock UTIL_Fade( id, r, g, b, a )
{
	message_begin( MSG_ONE_UNRELIABLE, gMessageScreenFade , _, id );
	write_short( 1<<10 );
	write_short( 1<<10 );
	write_short( FFADE_IN );
	write_byte( r );
	write_byte( g );
	write_byte( b ); 
	write_byte( a );
	message_end( );
}
