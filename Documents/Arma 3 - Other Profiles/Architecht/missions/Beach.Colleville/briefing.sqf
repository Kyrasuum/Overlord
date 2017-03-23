switch (side player) do {
	player createDiaryRecord ["Diary", ["Gamemode","
		Welcome to the battlefield soldier, <br/><br/>
		Both sides get a set amount of 'tickets' at the start of the match.  <br/>
		The United States can win by removing all resistance or pushing the Germans off the beach.  <br/>
		The Germans can only win by exhausting allied reinforcements.   <br/>
		Both sides are able to recruit AI soldiers to assist them at the cost of tickets.  <br/>
		"]];

	case West:
	{
		player createDiaryRecord ["Diary", ["SitRep","
			Welcome to the Omaha <br/><br/>
			The Americans think they can take these beaches from us using manpower alone.<br/>
			We will show them why the fatherland is superior.  Make an example so they never have the guts to try this again. <br/>
			<br/>
			The allies have a large amount of landing craft and the ability to overwhelm us in the skies.<br/>
			Unfortunately for them, their bombers failed to cause any real damage and their tanks will have a hard time scaling these beaches.<br/>
			Our strength lies in our powerful gun emplacements scattered over the island and our well prepared defenses.<br/>
			Use our men and ammo wisely, reinforcements are far away and limited.<br/>
			Our long supply lines make us vulnerable to guerilla tactics or centrated insertions by the allies.<br/>
			To win, protect our machine gun bunkers long enough to deplete their resources.<br/>
			"]];  
	};
	case east:
	{
		player createDiaryRecord ["Diary", ["SitRep","
			I dont know how you got on this team... but I salute your bravery. <br/>
			Fight for the motherland with honer. <br/><br/>
			Architecht"]]; 
	};
	case independent:
	{
		player createDiaryRecord ["Diary", ["SitRep","
			Welcome to the frontlines... I hope you last. <br/><br/>
			The Germans have deployed fierce resistance on these beaches. <br/>
			They think they can stop us from gaining even an inch here, prove them wrong. <br/>  <br/>
			An aerial paradrop insertion might be the ideal way of softening up German defenses but be wary of flak fire. <br/> 
			German AA encampments are scattered across these fields but can be disabled if hit with enough firepower. <br/>
			German artillery is will be dug in and will continue to fire on our friendlies until disabled. <br/>
			"]]; 
	};
	case civilian:
	{
		player createDiaryRecord ["Diary", ["SitRep","
			You actually expected some orders here? <br/>
			Sit pretty and watch the bombs drop... hopefully on your neighbor. <br/><br/>
			Architecht"]]; 
	};
	default
	{
		player createDiaryRecord ["Diary", ["SitRep","
			How did you even manage to create a new side?<br/>
			Seriously I want to know, send me a message or something.<br/><br/>
			Architecht"]]; 
	};
};