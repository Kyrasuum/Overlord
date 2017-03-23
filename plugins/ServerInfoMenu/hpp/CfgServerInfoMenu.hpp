class CfgServerInfoMenu
{
   createdBy = "Architecht";
   hostedBy = "Omaha Beach";
   ipPort = "F1 to open this menu";
   restart = "ESCAPE"; // Amount of hours before server automatically restarts
   serverName = "Dread Tavern";
   class menuItems
   {
      class Story
      {
         title = "Background";
         content[] = 
         {
            "<t size='1.5'>Operation Overlord</t>",
            "<br />",
            "In June 1940, Germany's leader Adolf Hitler had triumphed in what he called 'the most famous victory in history'—the fall of France.",
            "<br />",
            "The defending British Expeditionary Force (BEF), trapped along the northern coast of France, was able to evacuate over 338,000 troops to England in the Dunkirk evacuation",
            "<br />",
            "<br />",
            "After the Germans invaded the Soviet Union in June 1941, Soviet leader Joseph Stalin began pressing for the creation of a second front in Western Europe.",
            "<br />",
            "Instead, the Allies launched the invasion of French North Africa in November 1942, the invasion of Sicily in July 1943, and invaded Italy in September.",
            "<br />",
            "These operations provided the troops with valuable experience in amphibious warfare.",
            "<br />",
            "<br />",
            "landings on a broad front in Normandy would permit simultaneous threats against the port of Cherbourg, coastal ports further west in Brittany, and an overland attack towards Paris and eventually into Germany.",
            "<br />",
            "Normandy was hence chosen as the landing site. Under the Transport Plan, communications infrastructure and road and rail links were bombed to cut off the north of France and make it more difficult to bring up reinforcements.",
            "<br />",
            "The coastline of Normandy was divided into seventeen sectors, with codenames using a spelling alphabet—from Able, west of Omaha, to Roger on the east flank of Sword.",
            "<br />",
            "<br />",
            "The landings were to be preceded by airborne drops near Caen on the eastern flank to secure the Orne River bridges, and north of Carentan on the western flank.",
            "<br />",
            "The Americans, assigned to land at Utah and Omaha, were to cut off the Cotentin Peninsula and capture the port facilities at Cherbourg.",
            "<br />",
            "The British at Sword and Gold, and the Canadians at Juno, were to capture Caen and form a front line from Caumont-l'Éventé to the south-east of Caen in order to protect the American flank, while establishing airfields near Caen.",
            "<br />",
            "<br />",
            "The operation was launched on 6 June 1944 with the Normandy landings. A 1,200-plane airborne assault preceded an amphibious assault involving more than 5,000 vessels. Nearly 160,000 troops crossed the English Channel on 6 June, and more than two million Allied troops were in France by the end of August.",
            "<br />",
            "<br />",
            "<br />",
            "<br />"
         };
      };
      class Info
      {
         title = "Mission Info"; 
         content[] = 
         {
            "Germany starts out with a more secure position but has less resources to spend on resupplying ammo, vehicles, and manpower.  Thankfully, Germany recieves a small trickle of resources.",
            "<br />",
            "The Allies however have very little territory but large reserves of resources at their disposal.  These resources however can run out.",
            "<br />",
            "<br />",
            "The goal of both sides is to dominate the battlefield through capturing the majority of the cities or majority of territory.",
            "<br />",
            "The defending side, in this case the Germans, cannot win through territory but rather they win by bleeding the attackers dry of reinforcements.",
            "<br />",
            "<br />",
            "The defenses and towns will always be constant every playthrough but how the AI/Players use them will decide who wins and who dies.",
            "<br />",
            "There are two major draws from the beaches one going into a heavily fortified town and the other leading into a deep network of trenches and enfilading fire.",
            "<br />",
            "<br />",
            "<br />",
            "<br />"
         };
      };
      class Keybinds
      {
         title = "Custom Keys";
         content[] = 
         {
            "F1->Brings up this information menu",
            "<br />",
            "F2->Throws a magazine (uses the stone grenade ammo)",
            "<br />",
            "F4->Uses the context sensitive medic action (heal self, heal others, revive others)",
            "<br />",
            "F4->Toggles your Earplugs",
            "<br />",
            "F5->Does a sit down animation",
            "<br />",
            "<br />",
            "<br />",
            "<br />"
         };
      };
      class Mechanics
      {
         title = "GAME MECHANICS";
         content[] = 
         {
            "The game is covered in a hex grid, take territory to dominate the map.",
            "<br />",
            "<br />",
            "There is a virtual AI commander who will assign tasks to squads based upon the battlefield situation.",
            "<br />",
            "<br />",
            "AI squad leaders will assign sub tasks to their squad members in order to best accomplish their goals.",
            "<br />",
            "<br />",
            "There are AA and Artillery emplacements scattered across the map.  The corresponding Tasks will tell you whether any targets still remain.",
            "<br />",
            "<br />",
            "All vehicles will respawn in this mission and have a corresponding reinforcement cost attributed to it.  Some vehicles are made to be free like the essential boats for the allies.",
            "<br />",
            "<br />",
            "There is a suppression mechanic included in this mission it works by attempting to blur the player's aim.  Suppression increases from any and all gunshots fired nearby you and lessens overtime or from returning fire yourself.",
            "<br />",
            "<br />",
            "Ammo is this mission is partially virtual.  You will periodically recieve an increase to your ammo reserves while in friendly territory.  This number is decreased everytime you have emptied your previous magazine.  You can observe this number by the red floating number on your characters left hand.",
            "<br />",
            "<br />",
            "MORE TO BE ADDED",
            "<br />",
            "<br />",
            "<br />",
            "<br />"
         };
      };
      class Credits
      {
         title = "CREDITS AND THANKS";
         content[] = 
         {
			"<t size='1.5'>Credit to:</t>",
			"<br />",
            "<t size='1.25'>IT07:</t> original coder/creator of this menu",
         "<br />",
            "<t size='1.25'>Squeeze:</t> Hex Warfare",
			"<br />",
            "<t size='1.25'>kamikaz333:</t> Plank, a lightweight fortification plugin",
         "<br />",
            "<t size='1.25'>Demon Cleaner:</t> Author of the Spawn Air Patrol script",
         "<br />",
            "<t size='1.25'>Larrow:</t> Author of the Virtual Arsenal Override",
         "<br />",
            "<t size='1.25'>Duda w/ custom animations by Mcruppert:</t> Rappelling",
         "<br />",
            "<t size='1.25'>Psycho:</t> AIS injury system",
         "<br />",
            "<t size='1.25'>Wyqer:</t> Author of KP Fuel Consumption Script",
         "<br />",
            "<t size='1.25'>Arma 3 Community:</t> because it would not be possible without all of you",
         "<br />",
         "<br />",
         "<br />",
         "<br />"
         };
      };
      class Changelog
      {
         title = "Changelog"; 
         content[] = 
         {
            "<t size='2.00'>1/30/2017</t><br />",
            "<t size='1.25'>Changes:</t> First release",
            "<br />",
            "<br />",
            "<br />",
            "<br />"
         };
      };
   };
};


