/*

                   _____  _____
             /\   |  __ \|_   _|
            /  \  | |__) | | |
           / /\ \ |  _  /  | |
          / ____ \| | \ \ _| |_
         /_/    \_\_|  \_\_____|


    > Flashbang Filterscript
    > Copyright     ©   2016        Ari

    > SA-MP Forums:                 http://forum.sa-mp.com/member.php?u=194384

    > Website:                      

    > Authors:                  
                                    Ari

    > Developers:                   
                                    Ari



    Additional Credits:


    SA-MP (Grand Theft Auto Multiplayer Modification) is a copyright of the SA-MP Team.
    http://www.sa-mp.com/



    Notepad:
        >"A Flashbang landed here %i seconds ago!" -- use GetTickCount(); -- probably won't do this if 3dTextLabel is removed
        
        >"Flashed!" above peoples head that are flashed
        
        >Let you load a specific amount of flashbang shells before it toggles off, /tfs 3 would let you 
            shoot three flashs before it swapped back to normal 12GA
        
        >Auto-RP line for when /tfs for the amount of shells loaded ex (has loaded 3 flashbang shells, or, has loaded a flashbang shell)

        >Convert 3dTextLabels to Dynamic ones from Incognito's streamer, easier removeable
        
        >Player was blinded by _'s Flashbang!


*/

/* ------------------------------------------------------------- */
/*                          LIBRARIES                            */

#include                    <a_samp>            // SA-MP Include

#include                    <zcmd>              // ZCMD Comamnd processor
#include                    <sscanf2>           // SSCANF Include
#include                    <streamer>          // Incognito's Object Streamer


/* ------------------------------------------------------------- */
/*                          MACROS                               */

#define                     posArr{%0}                  %0[0], %0[1], %0[2]
#define                     posArrEx{%0}                %0[0], %0[1], %0[2], %0[3]


#define                     seconds(%0)                 %0 * 1000
#define                     minutes(%0)                 %0 * seconds(60)
#define                     hours(%0)                   %0 * minutes(60)
#define                     days(%0)                    %0 * hours(24)


/* ------------------------------------------------------------- */
/*                          PRECONFIG                            */



/* ------------------------------------------------------------- */
/*                          COLOURS                              */

//                          COL_NAME                    0xRRGGBBAA
//                          EMBED_NAME                  "{RRGGBB}"

#define                     COL_WHITE                   0xFFFFFFFF
#define                     COL_GREY                    0xCECECEFF
#define                     COL_ORANGE                  0xFFA800CC
#define                     COL_RED                     0xFF0000AA
#define                     COL_GREEN                   0x00FF00AA
#define                     COL_PURPLE                  0xC2A2DAAA
#define                     COL_YELLOW                  0xFFFF00AA
#define                     COL_DPURPLE                 0x6A15EAC8
#define                     COL_PURPLE                  0xC2A2DAAA
#define                     COL_PINK                    0xFF1580EA

#define                     EMBED_PURPLE                "{BF15EA}"
#define                     EMBED_GREY                  "{CECECE}"
#define                     EMBED_BLUE                  "{1580EA}"


/* ------------------------------------------------------------- */
/*                          DEFINITIONS                          */

new PlayerText:_flashbangEffect[MAX_PLAYERS];
new Text3D:_flashbangTag;

/* -------------------------------------------------------------*/
/*                          NATIVES                             */

native                      gpci(playerid, serial[], maxlen);

/* ------------------------------------------------------------- */
/*                          ARRAYS                               */



/* ------------------------------------------------------------- */
/*                          MYSQL                                */



/* ------------------------------------------------------------- */
/*                          ENUMERATIONS                         */



/* ------------------------------------------------------------- */
/*                          GLOBAL VARS                          */



/* ------------------------------------------------------------- */
/*                          PUBLIC/CALLBACK                      */

public OnFilterScriptInit()
{
    print("[DEBUG] OnFilterScriptInit");
    Server_AntiDeAMX();

    print("                                                <ari/SAMP/>");
    return 1;
}

main()
{
    print("[DEBUG] main()");
}

public OnFilterScriptExit()
{
    print("[DEBUG] OnFilterScriptExit");


    return 1;
}

public OnPlayerConnect(playerid)
{
    printf("[DEBUG] OnPlayerConnect (%s)", ReturnPlayerName(playerid));


    _flashbangEffect[playerid] = CreatePlayerTextDraw(playerid, -20.000000, 2.000000, "|");

    PlayerTextDrawUseBox(playerid, _flashbangEffect[playerid], 1);
    PlayerTextDrawBoxColor(playerid, _flashbangEffect[playerid], 0xffffffFF); // 0xffffff55 -- make this solid white again

    PlayerTextDrawTextSize(playerid, _flashbangEffect[playerid], 660.000000, 22.000000);
    PlayerTextDrawLetterSize(playerid, _flashbangEffect[playerid], 1.000000, 52.200000);
    PlayerTextDrawAlignment(playerid, _flashbangEffect[playerid], 0);

    PlayerTextDrawBackgroundColor(playerid, _flashbangEffect[playerid], 0xffffffFF); // 0x000000ff -- make this solid white again
    PlayerTextDrawFont(playerid, _flashbangEffect[playerid], 3);

    
    PlayerTextDrawColor(playerid, _flashbangEffect[playerid], 0xffffffFF); // 0x000000ff -- make this solid white again

    PlayerTextDrawSetOutline(playerid, _flashbangEffect[playerid], 1);
    PlayerTextDrawSetProportional(playerid, _flashbangEffect[playerid], 1);
    PlayerTextDrawSetShadow(playerid, _flashbangEffect[playerid], 1);

    return 1;
}

public OnPlayerDisconnect(playerid, reason) 
{

    return 1;
}

public OnPlayerSpawn(playerid) 
{ 
    return 1; 
}  

public OnPlayerUpdate(playerid)
{

    return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{

    /*new szString[144];

    format(szString, sizeof(szString), "[DEBUG]: Weapon %i fired. hittype: %i   hitid: %i   pos: %f, %f, %f", weaponid, hittype, hitid, fX, fY, fZ);
    SendClientMessage(playerid, -1, szString);*/

    if(GetPVarInt(playerid, "_flashShells"))
    {
        if(weaponid == 25)
        {
            // Not the fastest loop, but will do for testing.
             for(new i = 0; i<GetMaxPlayers(); ++i)
            {
                if(IsPlayerInRangeOfPoint(i, 15.0, fX, fY, fZ))
                {
                    new
                        Float:iPos[3];
        
                    GetPlayerPos(i, posArr{iPos});
                    PlayerPlaySound(i, 1159, posArr{iPos});

                    PlayerTextDrawShow(i, _flashbangEffect[i]); // Flash textdraw to flash the player
                    SetTimerEx("toggleFlashEffect", seconds(2), 0, "i", i); // Timer to destroy the textdraw

                    SendClientMessage(i, COL_RED, "SRV: You have been blinded by a flashbang!");

                    _flashbangTag = Create3DTextLabel("FLASHED!", 0x008080FF, posArr{iPos}, 25.0, 0, 1);
                    Attach3DTextLabelToPlayer(_flashbangTag, i, 0.0, 0.0, 1.5);
                }
            }
            //Create3DTextLabel("A Flashbang landed here!", COL_RED, fX, fY, fZ, 40.0, 0, 0); // This can be revised or removed

            //Toggle the flash shells once the amount loaded in has been completed.
        }
        
    }
    return 1;
}

forward toggleFlashEffect(playerid);
public toggleFlashEffect(playerid)
{
    PlayerTextDrawHide(playerid, _flashbangEffect[playerid]);
    return 1;
}


/* ------------------------------------------------------------- */
/*                          COMMANDS                             */

CMD:toggleflashshells(playerid, params[])
{
    if(GetPVarInt(playerid, "_flashShells"))
    {
        SendClientMessage(playerid, COL_GREY, "SRV: You have toggled off Flashbang Shells!");
        DeletePVar(playerid, "_flashShells");
    }
    else
    {
        SendClientMessage(playerid, COL_GREY, "SRV: You have toggled on Flashbang Shells!");
        SetPVarInt(playerid, "_flashShells", 1);
    }
    return 1;
}

CMD:tfs(playerid, params[])
{
    return cmd_toggleflashshells(playerid, params);
}

CMD:weapon(playerid, params[])
{
    new 
        iWepID, iAmmo;


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
    new 
        iVehicleID, iColour[2], iSiren, Float:fPos[3];

    if(sscanf(params, "iI(0)I(0)I(0)", iVehicleID, iColour[0], iColour[1], iSiren)) SendClientMessage(playerid, COL_GREY, "USAGE: /(v)ehicle [ID] [COLOUR 1] [COLOUR 2] [SIREN?]");
    else
    {
        GetPlayerPos(playerid, posArr{fPos});
        iVehicleID = CreateVehicle(iVehicleID, posArr{fPos}, 0.00, iColour[0], iColour[1], -1, iSiren);
        PutPlayerInVehicle(playerid, iVehicleID, 1);
    }
    return 1;
}

CMD:v(playerid, params[])
{
    return cmd_vehicle(playerid, params);
}


/* ------------------------------------------------------------- */
/*                          FUNCTIONS                            */

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
