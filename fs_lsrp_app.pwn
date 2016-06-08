/*

                   _____  _____
             /\   |  __ \|_   _|
            /  \  | |__) | | |
           / /\ \ |  _  /  | |
          / ____ \| | \ \ _| |_
         /_/    \_\_|  \_\_____|


    > LS-RP Development Application Code
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
               

               > FUS RO DAH with particals?
               > add particles to shark?
               > make shark bobble/go side to side?


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

new                         _sharkObject;
new                         _sharkTimer;
new                         _swimTime;

#define                     SHARK_OBJ_ID                1608
#define                     SHARK_SPAWN_POS             249.8585, -2020.7483, 0.3944

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

    _sharkObject = CreateObject(1608, SHARK_SPAWN_POS, 0.00, 0.00, 0.00);


    return 1;
}

main()
{
    print("[DEBUG] main()");
}

public OnFilterScriptExit()
{
    print("[DEBUG] OnFilterScriptExit");

    DestroyObject(_sharkObject);
    KillTimer(_sharkTimer);

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

public OnPlayerDeath(playerid)
{
    if(GetPVarInt(playerid, "_swimFlag"))
    {
        DeletePVar(playerid, "_swimFlag");
        KillTimer(_swimTime);
    }
    return 1;
}

public OnPlayerUpdate(playerid)
{

    if(IsPlayerInRangeOfPoint(playerid, 40.0, SHARK_SPAWN_POS)) // Should add a check to save CPU
    {
        _sharkTimer = SetTimerEx("_sharkTimer1", seconds(1), 1, "d", playerid);
    }


    if(GetPlayerAnimationIndex(playerid))
    {
        // store current anim, compare anim to stored anim, if they're not the same, store new one and send to function
        new szOldAnim = GetPlayerAnimationIndex(playerid);
        SetTimerEx("_animCheck", 100, 0, "di", playerid, szOldAnim);
    }
    return 1;
}

forward _animCheck(playerid, szOldAnim);
public _animCheck(playerid, szOldAnim)
{
    new szNewAnim = GetPlayerAnimationIndex(playerid);
    if(szOldAnim != szNewAnim)
    {
        CallRemoteFunction("OnPlayerChangeAnim", "dii", playerid, szNewAnim, szOldAnim);
    }
    return 1;
}

forward OnPlayerChangeAnim( playerid, newanimid, oldanimid);
public OnPlayerChangeAnim( playerid, newanimid, oldanimid)
{
    printf("Player: %s | new anim %s | old anim %s |", ReturnPlayerName(playerid), ReturnAnimName(newanimid), ReturnAnimName(oldanimid));

    new 
        szAnimLib[32], szAnimName[32];

    GetAnimationName(newanimid, szAnimLib, sizeof(szAnimLib), szAnimName, sizeof(szAnimName));

    if(GetPVarInt(playerid, "_swim"))
    {
        if(strfind(szAnimName, "SWIM", true) != -1)
        {
            // If the animation name contains "SWIM" they're swimming, easier than checking various ID's or names.
            _swimTime = SetTimerEx("_swimTimer", seconds(20), 0, "d", playerid);
            SetPVarInt(playerid, "_swimFlag", 1); // Flag that the player has the swim timer
        }
    }   
    return 1;
}

forward _swimTimer(playerid);
public _swimTimer(playerid)
{
    // THIS WORKS
    if(GetPVarInt(playerid, "_swimFlag"))
    {
        SetPlayerHealth(playerid, -150.0); // -150 to ensure that the player is killed
        SendClientMessage(playerid, COL_GREY, "SRV: You swam for too long and became exhausted and died!");
        KillTimer(_swimTime);
    }
    
    return 1;
}

forward _sharkTimer1(playerid);
public _sharkTimer1(playerid)
{
    new
        Float:fPos[3], Float:fObj[3];

    if(IsPlayerSwimming(playerid))
    {
        GetPlayerPos(playerid, posArr{fPos});
        GetObjectPos(_sharkObject, posArr{fObj});
        new 
            Float:fDistance = GetPlayerDistanceFromPoint(playerid, posArr{fObj});

        if(fDistance <= 40.0 && fDistance > 10.0) // Player Near! Follow the player!
        {
            // THIS WORKS
            GetPlayerPos(playerid, posArr{fPos});
            SetObjectToFaceCords(_sharkObject, posArr{fPos});
            MoveObject(_sharkObject, posArr{fPos}, 4.0);
        }
        else if(fDistance > 40.0) // They got away, swim home!
        {
            // THIS WORKS
            MoveObject(_sharkObject, SHARK_SPAWN_POS, 15.0);
            SetObjectToFaceCords(_sharkObject, SHARK_SPAWN_POS);
            KillTimer(_sharkTimer);
        }
        else if(fDistance < 10.0) // Shark is close enough to attack! Don't get any closer!
        {
            // Follow at 10.0 distance - Had to double to account for size of the Shark Object
            GetPlayerPos(playerid, fPos[0], fPos[1], fPos[2]);

            SetObjectToFaceCords(_sharkObject, posArr{fPos});
            //MoveObject(_sharkObject, posArr{fPos}, 4.0);
            StopObject(_sharkObject);
            KillTimer(_sharkTimer);

            new Float:fHealth;
            GetPlayerHealth(playerid, fHealth);
            SetPlayerHealth(playerid, fHealth-0.5); // Each Shark bite is 0.5

        }
    }
    else // If the player gets out of the water, the shark swims off.
    {
        MoveObject(_sharkObject, SHARK_SPAWN_POS, 15.0);
        SetObjectToFaceCords(_sharkObject, SHARK_SPAWN_POS);
        KillTimer(_sharkTimer);
    }
}

/*
>Shark Attack
Find the shark object on the sa-mp wiki, forums, or however you choose to find objects. Once found place it any part of the water.
Once a player is near a shark(40.0 radius) I want the shark to not only face them but swim towards them at 4.0 speed.
You will need this function to make the shark face a person.
The shark should not follow them out of the water.

Once a player is near a shark(5.0 radius) I want the shark to pause and just stay on them.

Extra
I want the shark to bite the player when near them so make them lose health. Time between each bite and how much health you want to take off is up to you.
When the player escapes the 40.0 radius of the shark it should swim back to it's original place.

SHARK ID: 1608

> Create Blood particles when bitten etc
> OnPlayerWeaponShoot - Shoot the shark to death?
> Country rifle + RPG = Harpoon gun to kill the shark
--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
>OnPlayerChangeAnim( playerid, newanimid, oldanimid)
First thing first you got to create the callback lol.
Once created I want you to create the actions laid out below, I also want you to come up with some funky stuff of your own with it.
This .inc should be helpful for you http://spelsajten.net/animation_names.inc 

After 20 seconds of swimming I want you to set the player's health to 0.
---When a player is shooting I want a text above their head to say "Name is shooting"
I want a print message everytime the animation changes. - "Name is now performing anim: %s animid: %d"


I didn't do the shooting animations, I felt that the ability to do this with OnPlayerWeaponShot would basically defunct the work. 
I've decided to do some extra animation work instead

> When player is falling with parachute, make some partical effects
>
--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
>String Scrambler
A nice ScrambleString( "string" ); function. It should be able to transform "apple" into "plape" or something of the sorts.

>This code is easily created, however there are snippets and copies all over the internet so I don't think this is much of a task or can show any creativeness with it.

--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
>Particles / Attached Objects
http://wiki.sa-mp.com/wiki/Objects_0.3c#Particle_Effects

I want something creative done with them. Let your mind wonder. I want to see the type of imaginations you can script up with something as visually nice as 
particles or any of the attachable objects.

>Have guns and rockets come out of a car, james bond style
>/fusrohdah command like Skyrim, uses SetPlayerVelocity
>Blood pools when bitten by the shark, not a good way to do this without causing a lot of CPU strain or lag. Will need to come up with a hacky method

--------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/* ------------------------------------------------------------- */
/*                          COMMANDS                             */

CMD:gotoshark(playerid, params[])
{
    new 
          Float:fSharkPos[3];

    GetObjectPos(_sharkObject, posArr{fSharkPos});
    SetPlayerPos(playerid, fSharkPos[0], fSharkPos[1]+50, fSharkPos[2]);  // TP The player to the shark, but 50 units away so we don't disturb it.
    return 1;
}

CMD:swimtimer(playerid, params[])
{
    SetPVarInt(playerid, "_swim", 1);
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

stock ReturnAnimName(iAnimID)
{
    new 
        szAnimLib[32], szAnimName[32];

    GetAnimationName(iAnimID, szAnimLib, sizeof(szAnimLib), szAnimName, sizeof(szAnimName));
    return szAnimName;
}

SetObjectToFaceCords(objectid, Float:x1,Float:y1,Float:z1)
{
    //   SetObjectToFaceCords() By LucifeR   //
    //                LucifeR@vgames.co.il   //

    // setting the objects cords
    new Float:x2,Float:y2,Float:z2;
    GetObjectPos(objectid, x2,y2,z2);

    // setting the distance values
    new Float:DX = floatabs(x2-x1);
    new Float:DY = floatabs(y2-y1);
    new Float:DZ = floatabs(z2-z1);

    // defining the angles and setting them to 0
    new Float:yaw = 0;
    new Float:pitch = 0;

        // check that there isnt any 0 in one of the distances,
    // if there is any  use the given parameters:
    if(DY == 0 || DX == 0)
    {
        if(DY == 0 && DX > 0)
        {
            yaw = 0;
            pitch = 0;
        }
        else if(DY == 0 && DX < 0)
        {
            yaw = 180;
            pitch = 180;
        }
        else if(DY > 0 && DX == 0)
        {
            yaw = 90;
            pitch = 90;
        }
        else if(DY < 0 && DX == 0)
        {
            yaw = 270;
            pitch = 270;
        }
        else if(DY == 0 && DX == 0)
        {
            yaw = 0;
            pitch = 0;
        }
    }
    // calculating the angale using atan
    else // non of the distances is 0.
    {
            // calculatin the angles
        yaw = atan(DX/DY);
        pitch = atan(floatsqroot(DX*DX + DZ*DZ) / DY);

        // there are three quarters in a circle, now i will
        // check wich circle this is and change the angles
        // according to it.
        if(x1 > x2 && y1 <= y2)
        {
            yaw = yaw + 90;
            pitch = pitch - 45;
        }
        else if(x1 <= x2 && y1 < y2)
        {
            yaw = 90 - yaw;
            pitch = pitch - 45;
        }
        else if(x1 < x2 && y1 >= y2)
        {
            yaw = yaw - 90;
            pitch = pitch - 45;
        }
        else if(x1 >= x2 && y1 > y2)
        {
            yaw = 270 - yaw;
            pitch = pitch + 315;
        }

        if(z1 < z2)
            pitch = 360-pitch;
    }

    // setting the object rotation (should be twice cuz of lame GTA rotation system)
    SetObjectRot(objectid, 0, 0, yaw);
    SetObjectRot(objectid, 0, pitch, yaw+90.0); // Add 90.0 degrees of rotation since for some reason the shark model is out
    return 1;
}

/*
stock Float:GetAngleToPoint(Float:fDestX, Float:fDestY, Float:fPointX, Float:fPointY)
    return atan2((fDestY - fPointY), (fDestX - fPointX)) + 90.0;
*/

stock IsPlayerSwimming(playerid)
{
    if(IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 0;
    new animlib[32], animname[32];

    GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);

    if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_GLIDE", true))     return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_BREAST", true)) return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_CRAWL", true)) return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_DIVE_UNDER", true)) return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_DIVE_GLIDE", true)) return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_UNDER", true)) return 1;
    else if(!strcmp(animlib, "SWIM", true) && !strcmp(animname, "SWIM_TREAD", true)) return 1;
    return 0;
}

stock ReturnSharkPos()
{
    new
          Float:fSharkPos[3];

    GetObjectPos(_sharkObject, posArr{fSharkPos});
    return fSharkPos;
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
