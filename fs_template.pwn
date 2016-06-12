/*
		  _____  _____
	    /\   |  __ \|_   _|
	   /  \  | |__) | | |
	  / /\ \ |  _  /  | |
	 / ____ \| | \ \ _| |_
	/_/    \_\_|  \_\_____|

	+----------------------------------------------------------+

	Ari's Script Template
	Copyright © 2014 Ari

	SA-MP Forums: http://forum.sa-mp.com/member.php?u=194384

	Authors:		Ari

	Developers:		Ari


	Additional Credits:


	SA-MP (Grand Theft Auto Multiplayer Modification) is a copyright of the SA-MP Team.
	http://www.sa-mp.com/

	+----------------------------------------------------------+

	Notepad:

*/

/* ------------------------------------------------------------- */
/*							LIBRARIES							 */

#include					<a_samp>			// SA-MP Include
#include					<zcmd>				// ZCMD Comamnd processor
#include					<sscanf2>			// SSCANF Include

/* ------------------------------------------------------------- */
/*							MACROS								 */

#define  					posArr{%0}  				%0[0], %0[1], %0[2]
#define  					posArrEx{%0} 				%0[0], %0[1], %0[2], %0[3]


#define     				seconds(%0)     			%0 * 1000
#define     				minutes(%0)     			%0 * seconds(60)
#define     				hours(%0)       			%0 * minutes(60)
#define     				days(%0)        			%0 * hours(24)

/* ------------------------------------------------------------- */
/*							PRECONFIG							 */


/* ------------------------------------------------------------- */
/*							MYSQL								 */

/* ------------------------------------------------------------- */
/*							COLOURS								 */

//             				COL_NAME                 	0xRRGGBBAA
//             				EMBED_NAME               	"{RRGGBB}"

#define 					COL_WHITE 					0xFFFFFFFF
#define 					COL_GREY 					0xCECECEFF
#define						COL_ORANGE					0xFFA800CC
#define 					COL_RED		 				0xFF0000AA
#define 					COL_GREEN		 			0x00FF00AA
#define 					COL_PURPLE 					0xC2A2DAAA
#define 					COL_YELLOW 					0xFFFF00AA
#define 					COL_DPURPLE 				0x6A15EAC8
#define 					COL_PURPLE 					0xC2A2DAAA
#define						COL_PINK					0xFF1580EA

#define						EMBED_PURPLE				"{BF15EA}"
#define						EMBED_GREY					"{CECECE}"
#define						EMBED_BLUE					"{1580EA}"

/* ------------------------------------------------------------- */
/*							DEFINITIONS							 */


/* -------------------------------------------------------------*/
/*							NATIVES								*/

native 						gpci(playerid, serial[], maxlen);

/* ------------------------------------------------------------- */
/*                          ARRAYS                               */


/* ------------------------------------------------------------- */
/*							ENUMERATIONS						 */


/* ------------------------------------------------------------- */
/*							GLOBAL VARS							 */


/* ------------------------------------------------------------- */
/*							PUBLIC/CALLBACK						 */

public OnFilterScriptInit()
{
	print("[DEBUG] OnFilterScriptInit");
	Server_AntiDeAMX();

	return 1;
}

main()
{
	print("[DEBUG] main()");
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{

	return 1;
}

public OnPlayerUpdate(playerid)
{

	return 1;
}

/* ------------------------------------------------------------- */
/*							COMMANDS							 */

CMD:w(playerid, params[])
{
	new iWepID, iAmmo;

	if(sscanf(params, "iI(600)", iWepID, iAmmo)) SendClientMessage(playerid, COL_GREY, "USAGE: /(w)eapon [ID] [AMMO]");
	else
	{
		GivePlayerWeapon(playerid, iWepID, iAmmo);
	}
	return 1;
}

CMD:v(playerid, params[])
{
	new iVehID, iColour[2];

	if(sscanf(params, "ii", iVehID, iColour[0], iColour[1])) SendClientMessage(playerid, COL_GREY, "USAGE: /v [ID] [COLOUR 1] [COLOUR 2]");
	else
	{
		new Float:iPos[3];
		GetPlayerPos(playerid, posArr{iPos});
		CreateVehicle(iVehID, posArr{iPos}, iColour[0], iColour[1], 50, 0);
	}
	return 1;
}

/* ------------------------------------------------------------- */
/*							FUNCTIONS							 */

stock ReturnPlayerName(iPlayerID)
{
	new
		szName[MAX_PLAYER_NAME];

	GetPlayerName(iPlayerID, szName, sizeof(szName));
	return szName;
}

stock ReturnGPCI(iPlayerID)
{
	new szSerial[64];
	gpci(iPlayerID, szSerial, sizeof(szSerial));
	return szSerial;
}

stock ReturnIP(iPlayerID)
{
	new szIP[16];
	GetPlayerIp(iPlayerID, szIP, sizeof(szIP));
	return szIP;
}

Server_AntiDeAMX()
{
	new
		a[][] = {
			"Unarmed (Fist)",
			"Brass K"
		},
		b;

	#emit load.pri b
	#emit stor.pri b

	#pragma unused a
}
