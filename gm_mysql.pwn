/*
		 ▄▄▄       ██▀███   ██▓
		▒████▄    ▓██ ▒ ██▒▓██▒
		▒██  ▀█▄  ▓██ ░▄█ ▒▒██▒
		░██▄▄▄▄██ ▒██▀▀█▄  ░██░
		 ▓█   ▓██▒░██▓ ▒██▒░██░
		 ▒▒   ▓▒█░░ ▒▓ ░▒▓░░▓  
		  ▒   ▒▒ ░  ░▒ ░ ▒░ ▒ ░
		  ░   ▒     ░░   ░  ▒ ░
		      ░  ░   ░      ░  
		                       



	> Ari's MySQL Base
	> Copyright 	© 	2016 		Ari

	> SA-MP Forums: 				http://forum.sa-mp.com/member.php?u=194384

	> Authors:					
									Ari

	> Developers:					
									Ari



	Additional Credits:


	SA-MP (Grand Theft Auto Multiplayer Modification) is a copyright of the SA-MP Team.
	http://www.sa-mp.com/



	Notepad:

	*Move all MySQL to it's own file "mysql.pwn"
	> Add SavePlayerInt, SavePlayerString, SavePlayerFloat and SavePlayerData functions to make it easier to add new MySQL data (from exodus)
	> New table for storing "SERVER NAME" "SERVER MODE" "SERVER MAP" "FREE PREMIUM WEEKEND" etc

*/

/* ------------------------------------------------------------- */
/*							LIBRARIES							 */

#include					<a_samp>			// SA-MP Include
#include 					<a_mysql>			// MySQL Include

#include					<zcmd>				// ZCMD Comamnd processor
#include					<sscanf2>			// SSCANF Include
#include					<streamer>			// Incognito's Object Streamer

/* ------------------------------------------------------------- */
/*							PRECONFIG							 */



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

#define 					SPAWN_X 					1660.0837
#define 					SPAWN_Y 					-1429.3831
#define 					SPAWN_Z 					12.5338
#define 					SPAWN_A 					0.00

enum
{
	DIALOG_LOGIN,
	DIALOG_REGISTER,
	DIALOG_QUERY,
	DIALOG_QUERY2
};


/* ------------------------------------------------------------- */
/*							MACROS								 */

#define  					posArr{%0}  				%0[0], %0[1], %0[2]
#define  					posArrEx{%0} 				%0[0], %0[1], %0[2], %0[3]


#define     				seconds(%0)     			%0 * 1000
#define     				minutes(%0)     			%0 * seconds(60)
#define     				hours(%0)       			%0 * minutes(60)
#define     				days(%0)        			%0 * hours(24)


/* -------------------------------------------------------------*/
/*							NATIVES								*/

native 						gpci(playerid, serial[], maxlen);

/* ------------------------------------------------------------- */
/*                          ARRAYS                               */


/* ------------------------------------------------------------- */
/*							MYSQL 								 */

new 						g_ConnectionHandle=			-1;

#define 					MYSQL_HOST					"localhost"
#define 					MYSQL_NAME					"root"
#define 					MYSQL_DB					"samp"
#define 					MYSQL_PASS					""

enum E_PLAYER
{
	ID,

	Name[MAX_PLAYER_NAME],
	Password[65], // SHA-256 creates a string with a length of 64
	SALT[11],  // The SALT has a length of 10

	IP[16],
	Admin,
	Premium,
	Money,
	Level,
	Skin,

	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosA 
};
new AccountData[MAX_PLAYERS][E_PLAYER];


/* ------------------------------------------------------------- */
/*							ENUMERATIONS						 */



/* ------------------------------------------------------------- */
/*							GLOBAL VARS							 */



/* ------------------------------------------------------------- */
/*							PUBLIC/CALLBACK						 */

public OnGameModeInit()
{
	print("[DEBUG] OnGameModeInit");
	Server_AntiDeAMX();

	print("		                                           <ari/SAMP/>");



	/*						mysql 								 */
	mysql_log(LOG_ALL);
	g_ConnectionHandle = mysql_connect(MYSQL_HOST, MYSQL_NAME, MYSQL_DB, MYSQL_PASS);

	if(mysql_errno() != 0) printf("[MYSQL:ERR] I couldn't connect to database: '%s' at host: '%s' (with the username: '%s')", MYSQL_DB, MYSQL_HOST, MYSQL_NAME);

	else printf("[MYSQL:LOG] I successfully connected to database: '%s' at host: '%s' (with username: '%s')", MYSQL_DB, MYSQL_HOST, MYSQL_NAME);

	return 1;
}

main()
{
	print("[DEBUG] main()");
}

public OnGameModeExit()
{
	print("[DEBUG] OnGameModeExit");


	printf("MySQL unfinished queries: %d!", mysql_unprocessed_queries());
	mysql_close(g_ConnectionHandle);

	return 1;
}

public OnPlayerConnect(playerid)
{
	printf("[DEBUG] OnPlayerConnect (%s)", ReturnPlayerName(playerid));

	TogglePlayerSpectating(playerid, true); 
	//InterpolateCamera over a location for login screen

	new szQuery[128];

	mysql_format(g_ConnectionHandle, szQuery, sizeof(szQuery), "SELECT `Password`, `SALT`, `ID` FROM `players` WHERE `Name` = '%e' LIMIT 1", ReturnPlayerName(playerid)); 
    mysql_tquery(g_ConnectionHandle, szQuery, "OnPlayerDataLoad", "i", playerid); 

	return 1;
}


forward OnPlayerDataLoad(playerid);
public OnPlayerDataLoad(playerid)
{
	printf("[DEBUG] OnPlayerDataLoad (%s)", ReturnPlayerName(playerid));

	new szRows, szFields;
	cache_get_data(szRows, szFields, g_ConnectionHandle);

	if(szRows)
	{
		new szString[128], szTitleString[128];

		cache_get_field_content(0, "Password", AccountData[playerid][Password], g_ConnectionHandle, 65);
		cache_get_field_content(0, "SALT", AccountData[playerid][SALT], g_ConnectionHandle, 11);
		AccountData[playerid][ID] = cache_get_field_content_int(0, "ID");

		format(szString, sizeof(szString), "Welcome %s! (IP: %s) \nYour account has been found in our database, please enter your password!", ReturnPlayerName(playerid), ReturnIP(playerid));
		format(szTitleString, sizeof(szTitleString), "LOGIN: %s", ReturnPlayerName(playerid));

		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, szTitleString, szString, "Login", "Quit");

	}
	else
	{
		new szString[128], szTitleString[128];

		format(szString, sizeof(szString), "Welcome %s! (IP: %s) \nIt appears you don't have an account! No worries, enter your desired password to get started!", ReturnPlayerName(playerid), ReturnIP(playerid));
		format(szTitleString, sizeof(szTitleString), "REGISTER: %s", ReturnPlayerName(playerid));

		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, szTitleString, szString, "Register", "Quit");
	}

	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	AccountData[playerid][ID] = cache_insert_id(g_ConnectionHandle);

	printf("SRV: Player %s signed up and their ID value is %d.", ReturnPlayerName(playerid), AccountData[playerid][ID]);


    TogglePlayerSpectating(playerid, false); 

    SetSpawnInfo(playerid, 0, 94, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0); 
    SpawnPlayer(playerid); 
    return 1;  
}

forward OnAccountLoad(playerid); 
public OnAccountLoad(playerid) 
{ 
	AccountData[playerid][IP] = cache_get_field_content_int(0, "IP");
	AccountData[playerid][Admin] = cache_get_field_content_int(0, "Admin");
	AccountData[playerid][Premium] = cache_get_field_content_int(0, "Premium"); 
	AccountData[playerid][Money] = cache_get_field_content_int(0, "Money"); 
	AccountData[playerid][Skin] = cache_get_field_content_int(0, "Skin"); 


	AccountData[playerid][PosX] = cache_get_field_content_float(0, "PosX"); 
	AccountData[playerid][PosY] = cache_get_field_content_float(0, "PosY"); 
	AccountData[playerid][PosZ] = cache_get_field_content_float(0, "PosZ"); 
	AccountData[playerid][PosA] = cache_get_field_content_float(0, "PosA"); 

  
    TogglePlayerSpectating(playerid, false); 
    //Stop interpolating the camera, too

    GivePlayerMoney(playerid, AccountData[playerid][Money]); 

    SetSpawnInfo(playerid, 0, AccountData[playerid][Skin], AccountData[playerid][PosX], AccountData[playerid][PosY], AccountData[playerid][PosZ], AccountData[playerid][PosA], 0, 0, 0, 0 ,0, 0);
    SpawnPlayer(playerid); 

    SendClientMessage(playerid, COL_GREY, "SRV: You have successfully logged in."); // change this later
    printf("SRV: %s has successfully logged in! (ID: %d)", ReturnPlayerName(playerid), playerid);
    return 1; 
}  

public OnPlayerDisconnect(playerid, reason) 
{
	// fix the query cell size
	new szQuery[2048], Float:fPos[4];
	GetPlayerPos(playerid, posArr{fPos});
	GetPlayerFacingAngle(playerid, fPos[3]);

	// Don't leave a comma trailing the last entry otherwise it will throw a MySQL error (ID: #1064)
	mysql_format(g_ConnectionHandle, szQuery, sizeof(szQuery), 
	"UPDATE `players` SET `Name` = '%s', `IP` = '%s', `Admin` = '%i', `Premium` = '%i', `Money` = '%i', `Skin` = '%i', `PosX` = '%f', `PosY` = '%f', `PosZ` = '%f', `PosA` = '%f' WHERE `ID` = '%d'",
	ReturnPlayerName(playerid), ReturnIP(playerid), AccountData[playerid][Admin], AccountData[playerid][Premium], AccountData[playerid][Money], AccountData[playerid][Skin], posArr{fPos}, fPos[3], AccountData[playerid][ID]);

	mysql_tquery(g_ConnectionHandle, szQuery, "", ""); 
     
	return 1;
}

public OnPlayerSpawn(playerid) 
{ 
	SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
	SetPlayerSkin(playerid, AccountData[playerid][Skin]);
    return 1; 
}  

public OnPlayerDeath(playerid, killerid, reason)
{ 

    SendDeathMessage(killerid, playerid, reason);
    return 1; 
}  

public OnVehicleDeath(vehicleid, killerid)
{
	DestroyVehicle(vehicleid);
	return 1;
}

public OnPlayerUpdate(playerid)
{

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{ 

	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response) Kick(playerid); // make this more informative, later

			new szSALT[11], szQuery[1028];

			for(new i; i < 10; ++i)
			{
				szSALT[i] = random(79) + 47;
			} 
			/*  Generating a random string of characters with a length of 10 for our SALT plus null terminator	*/

			szSALT[10] = 0;
			SHA256_PassHash(inputtext, szSALT, AccountData[playerid][Password], 65);

			mysql_format(g_ConnectionHandle, szQuery, sizeof(szQuery), "INSERT INTO `players` (`Name`, `Password`, `SALT`, `IP`, `Admin`, `Premium`, `Money`, `Skin`, `PosX`, `PosY`, `PosZ`, `PosA`) VALUES ('%s', '%e', '%e', '%s', 0, 0, 0, 94,'%f', '%f', '%f', '%f')",
			ReturnPlayerName(playerid), AccountData[playerid][Password], szSALT, ReturnIP(playerid), SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A);

			//mysql_tquery(g_ConnectionHandle, szQuery, "", "");

			mysql_tquery(g_ConnectionHandle, szQuery, "OnPlayerRegister", "d", playerid); 
		}
		case DIALOG_LOGIN:
		{
			new szHash[65];
			SHA256_PassHash(inputtext, AccountData[playerid][SALT], szHash, sizeof(szHash));

			if(strcmp(szHash, AccountData[playerid][Password]))
			{
				new szQuery[258];
				mysql_format(g_ConnectionHandle, szQuery, sizeof(szQuery), "SELECT * FROM `players` WHERE `Name` = '%e' LIMIT 1", ReturnPlayerName(playerid)); 
                mysql_tquery(g_ConnectionHandle, szQuery, "OnAccountLoad", "i", playerid); 
			}
			else 
			{
				new szString[128], szTitleString[128];

				SendClientMessage(playerid, COL_RED, "SRV: You have entered a wrong password!");
				format(szString, sizeof(szString), "Welcome %s! (IP: %s) \nYour account has been found in our database, please enter your password!", ReturnPlayerName(playerid), ReturnIP(playerid));
				format(szTitleString, sizeof(szTitleString), "LOGIN: %s", ReturnPlayerName(playerid));

				return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, szTitleString, szString, "Login", "Quit");
			}
		}
		case DIALOG_QUERY:
		{
			new szString[128];
			mysql_tquery(g_ConnectionHandle, inputtext, "", "");

			format(szString, sizeof(szString), "Submitted the Query: %s", inputtext);
			ShowPlayerDialog(playerid, DIALOG_QUERY2, DIALOG_STYLE_MSGBOX, "MySQL Query Submitted!", szString, "Okay", "");
		}
	}

    return 0;
}  

forward OnQueryFinish(query[], resultid, extraid, connectionHandle);
public OnQueryFinish(query[], resultid, extraid, connectionHandle)
{
	/*
	switch(resultid)
	{
		case THREAD_LOADPLAYER:
		{
			mysql_store_result();
			if(IsPlayerConnected(extraid))
			{
				//Execute your code
			}
			mysql_free_result();
		}
	}
	*/
	return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case CR_SERVER_GONE_ERROR:
		{
			printf("Lost connection to server, trying reconnect...");
			mysql_reconnect(connectionHandle);
		}
	}

	printf("[MYSQL:ERR] I en-counted an error! (ERR:ID: %i) ERROR: %s (Callback: %s) (Query: %s)", errorid, error, callback, query);
	return 1;
}

/* ------------------------------------------------------------- */
/*							COMMANDS							 */

CMD:ahelp(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) return SendClientMessage(playerid, COL_RED, "SRV: You must be an admin to use this command!");

	//should show, all ranks up until your current rank, and denote ranks in their respective colours
	SendClientMessage(playerid, COL_GREY, "SRV: /(w)eapon /(v)ehicle /a /ahelp /sendquery /setadmin /goto /gethere /kill /cleanup");
	return 1;
}

CMD:setadmin(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	new iTargetID, iAdminLevel;

	if(sscanf(params, "ui", iTargetID, iAdminLevel)) SendClientMessage(playerid, COL_GREY, "USAGE: /setadmin [ID] [Level]");
	else
	{
		new szString[128];
		AccountData[iTargetID][Admin] = iAdminLevel;

		format(szString, sizeof(szString), "## %s has made you a level %i admin!", ReturnPlayerName(playerid), iAdminLevel);
		SendClientMessage(iTargetID, COL_GREY, szString);

		format(szString, sizeof(szString), "## %s has made %s a level %i admin!", ReturnPlayerName(playerid), ReturnPlayerName(iTargetID), iAdminLevel);

		for(new i = 0; i < MAX_PLAYERS; ++i)
		{
			if(GetAdminLevel(i) > 0)
			{
				SendClientMessage(i, COL_YELLOW, szString);
			}
		}
	}
	return 1;
}

CMD:a(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) return SendClientMessage(playerid, COL_RED, "SRV: You must be an admin to use this command!");

	new szString[128];
	format(szString, sizeof(szString), "## %s {CECECE}%s {FFFF00}says: %s", GetAdminRank(playerid), ReturnPlayerName(playerid), params);

	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
		if(GetAdminLevel(i) > 0)
		{
			SendClientMessage(i, COL_YELLOW, szString);
		}
	}
	return 1;
}

CMD:sendquery(playerid, params[])
{
	if(GetAdminLevel(playerid) < 5) return 0;

	ShowPlayerDialog(playerid, DIALOG_QUERY, DIALOG_STYLE_INPUT, "MySQL - Submit Query", "Enter a valid MySQL Query to be submitted to the database", "Execute", "Cancel");
	return 1;
}

CMD:reloadme(playerid, params[])
{
	new 
		i = 0;

	while (i < 256) if(CallRemoteFunction("OnQueryFinish", "iii", 4, playerid, ++i))
		return SendClientMessage(playerid, COL_WHITE, "Reload successful!");
	return 1;
}

CMD:weapon(playerid, params[])
{
	new iWepID, iAmmo;

	if(GetAdminLevel(playerid) < 1) return 0;

	if(sscanf(params, "iI(600)", iWepID, iAmmo)) SendClientMessage(playerid, COL_GREY, "USAGE: /(w)eapon [ID] [AMMO]");
	else
	{
		GivePlayerWeapon(playerid, iWepID, iAmmo);
	}
	return 1;
}

CMD:w(playerid, params[])
{
	return cmd_weapon(playerid, params);
}

CMD:vehicle(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) return 0;

	new iVehicleID, iColour[2], Float:fPos[3];
	if(sscanf(params, "iI(0)I(0)", iVehicleID, iColour[0], iColour[1])) SendClientMessage(playerid, COL_GREY, "USAGE: /(v)ehicle [ID] [COLOUR 1] [COLOUR 2]");
	else
	{
		GetPlayerPos(playerid, posArr{fPos});
		CreateVehicle(iVehicleID, posArr{fPos}, 0.00, iColour[0], iColour[1], -1, 0);
		PutPlayerInVehicle(playerid, iVehicleID, 1);
	}
	return 1;
}

CMD:v(playerid, params[])
{
	return cmd_vehicle(playerid, params);
}

CMD:goto(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) return 0;

	new iTargetID, Float:fPos[3];
	if(sscanf(params, "u", iTargetID)) SendClientMessage(playerid, COL_GREY, "USAGE: /goto [ID]");
	else
	{
		GetPlayerPos(iTargetID, posArr{fPos});
		SetPlayerPos(playerid, posArr{fPos});
	}
	return 1;
}

CMD:gethere(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) return 0;

	new iTargetID, Float:fPos[3];
	if(sscanf(params, "u", iTargetID)) SendClientMessage(playerid, COL_GREY, "USAGE: /gethere [ID]");
	else
	{
		GetPlayerPos(playerid, posArr{fPos});
		SetPlayerPos(iTargetID, posArr{fPos});
	}
	return 1;
}

CMD:kill(playerid, params[])
{
	if(GetAdminLevel(playerid) < 1) SetPlayerHealth(playerid, -150.0);

	new iTargetID;
	if(sscanf(params, "u", iTargetID)) SendClientMessage(playerid, COL_GREY, "USAGE: /kill [ID]");
	else
	{
		SetPlayerHealth(iTargetID, -150.0);
	}
	return 1;
}

CMD:cleanup(playerid, params[])
{
	if(GetAdminLevel(playerid) < 4) return 0;

	for(new i = 0; i<MAX_VEHICLES; ++i)
    {
    	DestroyVehicle(i);
    }
	return 1;
}

/* ------------------------------------------------------------- */
/*							FUNCTIONS							 */

stock GetAdminLevel(iPlayerID)
{
	new 
		iAdminLevel = AccountData[iPlayerID][Admin];

	return iAdminLevel;
}

stock GetAdminRank(iPlayerID)
{
	new 
		szRankName[30];

	switch(GetAdminLevel(iPlayerID))
	{
		case 1: szRankName = "{8000BF}Level 1 Admin";
		case 2: szRankName = "{0080FF}Level 2 Admin";
		case 3: szRankName = "{679D47}Level 3 Admin";
		case 4: szRankName = "{679D47}Level 4 Admin";
		case 5: szRankName = "{AA000E}Level 5 Admin";
		case 6: szRankName = "{000066}Developer";
		default: szRankName = "{00CB69}Unknown Rank";
	}
	return szRankName;
}

stock ReturnPlayerName(iPlayerID)
{
	new
		szName[MAX_PLAYER_NAME];

	GetPlayerName(iPlayerID, szName, sizeof(szName));
	return szName;
}

stock ReturnGPCI(iPlayerID)
{
	new 
		szSerial[64];

	gpci(iPlayerID, szSerial, sizeof(szSerial));
	return szSerial;
}

stock ReturnIP(iPlayerID)
{
	new 
		szIP[16];

	GetPlayerIp(iPlayerID, szIP, sizeof(szIP));
	return szIP;
}

stock randEx(min, max) 
{
	/*
		Thank you Alex Cole (Y_LESS)
	*/
	return random(max - min) + min;
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
/*
  █████▒█    ██  ▄████▄   ██ ▄█▀    ▄████▄   ██░ ██  ▄▄▄       ██▓███   ███▄ ▄███▓ ▄▄▄       ███▄    █ 
▓██   ▒ ██  ▓██▒▒██▀ ▀█   ██▄█▒    ▒██▀ ▀█  ▓██░ ██▒▒████▄    ▓██░  ██▒▓██▒▀█▀ ██▒▒████▄     ██ ▀█   █ 
▒████ ░▓██  ▒██░▒▓█    ▄ ▓███▄░    ▒▓█    ▄ ▒██▀▀██░▒██  ▀█▄  ▓██░ ██▓▒▓██    ▓██░▒██  ▀█▄  ▓██  ▀█ ██▒
░▓█▒  ░▓▓█  ░██░▒▓▓▄ ▄██▒▓██ █▄    ▒▓▓▄ ▄██▒░▓█ ░██ ░██▄▄▄▄██ ▒██▄█▓▒ ▒▒██    ▒██ ░██▄▄▄▄██ ▓██▒  ▐▌██▒
░▒█░   ▒▒█████▓ ▒ ▓███▀ ░▒██▒ █▄   ▒ ▓███▀ ░░▓█▒░██▓ ▓█   ▓██▒▒██▒ ░  ░▒██▒   ░██▒ ▓█   ▓██▒▒██░   ▓██░
 ▒ ░   ░▒▓▒ ▒ ▒ ░ ░▒ ▒  ░▒ ▒▒ ▓▒   ░ ░▒ ▒  ░ ▒ ░░▒░▒ ▒▒   ▓▒█░▒▓▒░ ░  ░░ ▒░   ░  ░ ▒▒   ▓▒█░░ ▒░   ▒ ▒ 
 ░     ░░▒░ ░ ░   ░  ▒   ░ ░▒ ▒░     ░  ▒    ▒ ░▒░ ░  ▒   ▒▒ ░░▒ ░     ░  ░      ░  ▒   ▒▒ ░░ ░░   ░ ▒░
 ░ ░    ░░░ ░ ░ ░        ░ ░░ ░    ░         ░  ░░ ░  ░   ▒   ░░       ░      ░     ░   ▒      ░   ░ ░ 
          ░     ░ ░      ░  ░      ░ ░       ░  ░  ░      ░  ░                ░         ░  ░         ░ 
                ░                  ░                                                                   
*/
