/*

                   _____  _____
             /\   |  __ \|_   _|
            /  \  | |__) | | |
           / /\ \ |  _  /  | |
          / ____ \| | \ \ _| |_
         /_/    \_\_|  \_\_____|


    > NEAF Submarine Filterscript
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


    > /enter point and interior
    > Ability to drive, dive in the submarine for whoever is driving
    > Ability to deploy boats from the submarine
    > Ability to fire rockets/missiles (tragectory, or just fire rocket into sky then delete it and respawn it at the location)
    > Add "NEAF" or something to the sides + some spooky objects using the 0.00, 0.00, 0.00 map editor trick
    > SetObjectRotation when diving etc
    > Periscope??
    > Need materials to use rockets? 
    > Surfacing is done via command or keybind, and is automated so people cant fly the submarine
    
    >Shift to boost speed
    >Health so people can damage it
    >Drop mines to stop pursuit / enemy boats approaching when stationary

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

new                         _submarineObject;
new                         _camTimer[MAX_PLAYERS];


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

    _submarineObject = CreateDynamicObject(9958, 2658.7402, 3009.6284, 5.6771, 0.00, 0.00, 90.0000, 0, 0);

    return 1;
}

main()
{
    print("[DEBUG] main()");
}

public OnFilterScriptExit()
{
    print("[DEBUG] OnFilterScriptExit");
    DestroyAllDynamicObjects();


    return 1;
}

public OnPlayerConnect(playerid)
{
    printf("[DEBUG] OnPlayerConnect (%s)", ReturnPlayerName(playerid));


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

    if(GetPVarInt(playerid, "_subDriver"))
    {
        new iKeys, iUD, iLR;
        GetPlayerKeys(playerid, iKeys, iUD, iLR);

        if(iUD > 0) // Pressing DOWN
        {
            new Float:fObjPos[3];
            GetDynamicObjectPos(_submarineObject, posArr{fObjPos});

            MoveDynamicObject(_submarineObject, fObjPos[0]-100, fObjPos[1], fObjPos[2], 50);
            print("SRV: The Submarine is moving BACKWARDS");
        }
        else if(iUD < 0) // Pressing UP
        {
            new Float:fObjPos[3];
            GetDynamicObjectPos(_submarineObject, posArr{fObjPos});

            MoveDynamicObject(_submarineObject, fObjPos[0]+100, fObjPos[1], fObjPos[2], 50);
            print("SRV: The Submarine is moving FORWARD");
        }

        if(iLR > 0) // Pressing LEFT    
        {
            new Float:fObjPos[3];
            GetDynamicObjectPos(_submarineObject, posArr{fObjPos});

            MoveDynamicObject(_submarineObject, fObjPos[0], fObjPos[1]-100, fObjPos[2], 50);
            print("SRV: The Submarine is moving LEFT");
        }
        else if(iLR < 0) // Pressing RIGHT
        {
            new Float:fObjPos[3];
            GetDynamicObjectPos(_submarineObject, posArr{fObjPos});

            MoveDynamicObject(_submarineObject, fObjPos[0], fObjPos[1]+100, fObjPos[2], 50);
            print("SRV: The Submarine is moving RIGHT");
        }
    }

    return 1;
}


/* ------------------------------------------------------------- */
/*                          COMMANDS                             */

CMD:gotosub(playerid, params[])
{
    new Float:fObjPos[3];

    GetDynamicObjectPos(_submarineObject, posArr{fObjPos});
    SetPlayerPos(playerid, posArr{fObjPos});
    return 1;
}

CMD:pilotsubmarine(playerid, params[])
{
    if(GetSVarInt("_subDriving")) return SendClientMessage(playerid, COL_GREY, "SRV: Someone is already driving the submarine!");

    // Eventually add restrictions, need to be near entrance or inside at wheel.
    if(GetPVarInt(playerid, "_subDriver")) // They are driving, stop them driving
    {
        SetSVarInt("_subDriving", 0);
        DeletePVar(playerid, "_subDriver");

        TogglePlayerControllable(playerid, true);
        SetCameraBehindPlayer(playerid);
        KillTimer(_camTimer[playerid]);
        SendClientMessage(playerid, COL_GREY, "SRV: You are no longer driving the submarine!");

        new Float:fObjPos[3];

        GetDynamicObjectPos(_submarineObject, posArr{fObjPos});
        SetPlayerPos(playerid, posArr{fObjPos});
    }
    else // They start Driving
    {
        SetSVarInt("_subDriving", 1);
        SetPVarInt(playerid, "_subDriver", 1);

        new 
            Float:fobjPos[3];

        GetDynamicObjectPos(_submarineObject, posArr{fobjPos});
        SetPlayerCameraLookAt(playerid, posArr{fobjPos});
        TogglePlayerControllable(playerid, false);


        SendClientMessage(playerid, COL_GREY, "SRV: You are now driving the submarine!");

        _camTimer[playerid] = SetTimerEx("cameraTimer", 100, true, "d", playerid);

    }
    return 1;
}

CMD:dive(playerid, params[]) // this doesnt work
{
    if(GetPVarInt(playerid, "_subDriver")) 
    {
        new submarineState; // 0 At water level, 1 underwater
        if(submarineState < 1)
        {
            new 
                Float:fobjPos[3];

            GetDynamicObjectPos(_submarineObject, posArr{fobjPos});
            MoveDynamicObject(_submarineObject, fobjPos[0], fobjPos[1], fobjPos[2]-10, 10);
            submarineState = 1;
        }
        else if(submarineState > 0)
        {
            new 
                Float:fobjPos[3];

            GetDynamicObjectPos(_submarineObject, posArr{fobjPos});
            MoveDynamicObject(_submarineObject, fobjPos[0], fobjPos[1], fobjPos[2]+10, 10);
            submarineState = 0;
        }
    }
    else SendClientMessage(playerid, COL_GREY, "ERR: You're not piloting the submarine!");
    return 1;
}

CMD:rotatesubmarine(playerid, params[]) // Eventually turn into a key press
{
    if(GetPVarInt(playerid, "_subDriver"))
    {
        MoveDynamicObject(_submarineObject, 0.00, 0.00, 0.0001, 0.0001, 0.00, 0.00, 90.0);

        new 
            Float:fobjPos[3];

        GetDynamicObjectPos(_submarineObject, posArr{fobjPos});
        SetPlayerCameraLookAt(playerid, posArr{fobjPos});
        TogglePlayerControllable(playerid, false);
    }
    else SendClientMessage(playerid, COL_GREY, "ERR: You're not piloting the submarine!");
    return 1;
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
        //PutPlayerInVehicle(playerid, iVehicleID, 1);
    }
    return 1;
}

CMD:v(playerid, params[])
{
    return cmd_vehicle(playerid, params);
}


/* ------------------------------------------------------------- */
/*                          FUNCTIONS                            */

forward cameraTimer(playerid);
public cameraTimer(playerid)
{
    new
        Float:fsubPos[3];

    GetDynamicObjectPos(_submarineObject, posArr{fsubPos});

    SetPlayerCameraPos(playerid, fsubPos[0]-50, fsubPos[1], fsubPos[2]+20);
    SetPlayerCameraLookAt(playerid, posArr{fsubPos});
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
