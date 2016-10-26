/*

    Authors:		Ari

    Additional Credits:

                    Brian - Debugging

    Q:What does this do?
    A: There's a CLEO that allows you to "leave your body" and this simply checks if the bullet origin is from an unlikely distance
        This doesn't mean it is 100% accurate, but through my testing it is almost always accurate.
        The code protects against the "AFK-Ghost.cs" but also works against "CAMHACK.cs" because of how I wrote it.
*/

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{

    new Float:fOrigin[3], Float:fHitPos[3];
 	GetPlayerLastShotVectors(playerid, fOrigin[0], fOrigin[1], fOrigin[2], fHitPos[0], fHitPos[1], fHitPos[2]);
	new Float: fDistance = GetPlayerDistanceFromPoint(playerid, fOrigin[0], fOrigin[1], fOrigin[2]);


	if(fDistance > 0.980) // this was the hardest part, finding an offset that doesn't give false-positive for the length of a gun.
	{
        new szString[220], szWepName[30];

        GetWeaponName(weaponid, szWepName, sizeof(szWepName));

        format(szString, sizeof(szString), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may POSSIBLY be using a Ghost CLEO. Shot %s (ID: %d) with %s from %0.1f meters.",
        ReturnPlayerName(playerid), playerid,ReturnPlayerName(damagedid), damagedid, szWepName, fDistance);


        // return 0; un-comment this if you want possible hackers to not do any damage.
	}

    return 1;
}
