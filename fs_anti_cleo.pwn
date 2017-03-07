public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
    
    // declare variables to store bullet origin and position where it lands (floats, notaded by 'f')
    new Float:fOrigin[3], Float:fHitPos[3]; 

    // fetch and parse player shot vectors to be compared with a global offset to assume ambigious bullet origins.
 	GetPlayerLastShotVectors(playerid, fOrigin[0], fOrigin[1], fOrigin[2], fHitPos[0], fHitPos[1], fHitPos[2]); 

    // declare a new float variable, the distance from the bullet origin and the player
	new Float: fDistance = GetPlayerDistanceFromPoint(playerid, fOrigin[0], fOrigin[1], fOrigin[2]);


    /* 
        .980 offset to account for weapon length (bullet origin will be at/near the end of the weapons barrel)
        this equation is used to check the distance from the player and the bullets origin, meaning: if a player is outside the bounds of 0.980
        this typically means that the player would be too far from the bullets origin that is otherwise realistic
        tl:dr: player is too far from where the bullet was shot from, likely floating above their target using CAM hack or Ghost Hack
    */
	
	if(fDistance > 0.980) // does the players distance from the bullets origin exceed 0.980?
	{
        new szString[220], szWepName[30];

        GetWeaponName(weaponid, szWepName, sizeof(szWepName));

        // It's important to remember that all anti-cheat can be problematic and might produce false-positives under extreme circumstances
        // this anti-cheat is suggestive and won't auto ban, it recommends that you spectate the suspect player to ultimately come to a verdict.
        
        format(szString, sizeof(szString), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may POSSIBLY be using a Ghost CLEO. Shot %s (ID: %d) with %s from %0.1f meters.",
        ReturnPlayerName(playerid), playerid,ReturnPlayerName(damagedid), damagedid, szWepName, fDistance);

        // return 0; un-comment this if you want possible hackers to not do any damage.
	}
    return 1;
}
