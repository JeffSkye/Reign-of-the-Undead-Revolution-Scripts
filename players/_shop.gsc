//
// vim: set ft=cpp:
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\hud;
#include scripts\include\useful;
#include scripts\include\weapons;

init()
{
	preCacheString( &"ZOMBIEUI_RESTORING_HEALTH" );	
	preCacheString( &"ZOMBIEUI_ALREADY_AT_FULL_HEALTH" );
	preCacheString( &"ZOMBIEUI_AMMO_RESTORED" );
	preCacheString( &"ZOMBIEUI_ALREADY_AT_MAX_AMMO" );
	preCacheString( &"ZOMBIEUI_N_IS_NO_LONGER_INFECTED" );
	preCacheString( &"ZOMBIEUI_YOU_HAVE_BEEN_CURED" );
	preCacheString( &"ZOMBIEUI_YOU_ARE_NOT_INFECTED" );
	preCacheString( &"ZOMBIEUI_MAXIMUM_OF_N_BARRELS" );
	preCacheString( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS_PER_PLAYER" );
	preCacheString( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS" );
}

playerSetupShop()
{
	self endon("disconnect");
	self.points = level.dvar["game_startpoints"];

	wait 0.1; // Security wait to ensure that not too many clientdvars are set
	self setClientDvars("ui_points", self.points, "ui_upgrade", 0, "ui_supupgrade", 0,
						
						"ui_buff_costs1", level.dvar["shop_item1_costs"],
						"ui_buff_costs2", level.dvar["shop_item2_costs"],
						"ui_buff_costs3", level.dvar["shop_item3_costs"],
						
						"ui_weapon_costs1", level.dvar["shop_weapon1_costs"],
						"ui_weapon_costs2", level.dvar["shop_weapon2_costs"],
						"ui_weapon_costs3", level.dvar["shop_weapon3_costs"],
						"ui_weapon_costs4", level.dvar["shop_weapon4_costs"],
						
						"ui_item_costs1", level.dvar["shop_defensive1_costs"],
						"ui_item_costs2", level.dvar["shop_defensive2_costs"],
						"ui_item_costs3", level.dvar["shop_defensive3_costs"],
						"ui_item_costs4", level.dvar["shop_defensive4_costs"]);
}

updateShopCosts()
{
	raiseCosts();
	for( i=0; i<level.players.size; i++ )
		level.players[i] thread updateCosts();
}

raiseCosts()
{
	for( i=1; i<7; i++ )
	{
		// not all the item categories have the same amount, thus the ifDefined
		if( isDefined(level.dvar["shop_item"+i+"_costs"]) )
			level.dvar["shop_item"+i+"_costs"] += int(level.dvar["shop_item"+i+"_costs"] * (level.dvar["shop_multiply_costs_amount"] / 100));
		
		if( isDefined(level.dvar["shop_weapon"+i+"_costs"]) )
			level.dvar["shop_weapon"+i+"_costs"] += int(level.dvar["shop_weapon"+i+"+_costs"] * (level.dvar["shop_multiply_costs_amount"] / 100));
		
		if( isDefined(level.dvar["shop_defensive"+i+"_costs"]) )
			level.dvar["shop_defensive"+i+"_costs"] += int(level.dvar["shop_defensive"+i+"_costs"] * (level.dvar["shop_multiply_costs_amount"] / 100));
		
		// if no more are defined we are done
		if( !isDefined(level.dvar["shop_item"+i+"_costs"]) && !isDefined(level.dvar["shop_weapon"+i+"_costs"]) && !isDefined(level.dvar["shop_defensive"+i+"_costs"]) )
			break;
	}
}

updateCosts()
{
	self endon( "disconnect" );
	self setClientDvars("ui_buff_costs1", level.dvar["shop_item1_costs"],
						"ui_buff_costs2", level.dvar["shop_item2_costs"],
						"ui_buff_costs3", level.dvar["shop_item3_costs"],
						// TODO: Change the dvars in the menu and here
						"ui_weapon_costs1", level.dvar["shop_weapon1_costs"],
						"ui_weapon_costs2", level.dvar["shop_weapon2_costs"],
						"ui_weapon_costs3", level.dvar["shop_weapon3_costs"],
						"ui_weapon_costs4", level.dvar["shop_weapon4_costs"],
						
						"ui_item_costs1", level.dvar["shop_defensive1_costs"],
						"ui_item_costs2", level.dvar["shop_defensive2_costs"],
						"ui_item_costs3", level.dvar["shop_defensive3_costs"],
						"ui_item_costs4", level.dvar["shop_defensive4_costs"]);
}

processResponse(response)
{
	switch( response )
	{
	case "item0":
		if (self.points >= level.dvar["shop_item1_costs"])
		{
			if(self.health < self.maxhealth){
				self thread scripts\players\_players::fullHeal(3);
				self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_item1_costs"] );
				self iPrintLnbold( &"ZOMBIEUI_RESTORING_HEALTH" );
				self playsound("buy_upgradebox");
			}
			else
				self iPrintLnBold( &"ZOMBIEUI_ALREADY_AT_FULL_HEALTH" );
		}
		break;
	case "item1":
		if (self.points >= level.dvar["shop_item2_costs"])
		{
			if(!self scripts\players\_players::hasFullAmmo()){
				self scripts\players\_players::restoreAmmo();
				self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_item2_costs"] );
				self iPrintLnBold( &"ZOMBIEUI_AMMO_RESTORED" );
				self playSound("buy_upgradebox");
			}
			else
				self iPrintLnBold( &"ZOMBIEUI_ALREADY_AT_MAX_AMMO" );
		}
		break;
	case "item2":
		if (self.points >= level.dvar["shop_item3_costs"])
		{
			if(self.infected){
				self scripts\players\_infection::cureInfection();
				self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_item3_costs"] );
				iPrintLn( &"ZOMBIEUI_N_IS_NO_LONGER_INFECTED", self );
				self iPrintLnBold( &"ZOMBIEUI_YOU_HAVE_BEEN_CURED" );
				self playSound( "buy_upgradebox" );
			}
			else
				self iPrintLnBold( &"ZOMBIEUI_YOU_ARE_NOT_INFECTED" );
		}
		break;
	case "item3":
		if (self.points >= level.dvar["shop_weapon1_costs"])
		{
			self scripts\players\_weapons::swapWeapons( "grenade", "frag_grenade_mp" );
			self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_weapon1_costs"] );
			self playsound("buy_upgradebox");
		}
		break;
	case "item4":
		if (self.points >= level.dvar["shop_weapon2_costs"])
		{
			self giveWeapon( "c4_mp" );
			self giveMaxAmmo( "c4_mp" );
			if( self.actionslotweapons.size == 0 )
				self setActionSlot( 4, "weapon", "c4_mp" );
			if( !self scripts\players\_weapons::isActionslotWeapon("c4_mp") )
				self.actionslotweapons[self.actionslotweapons.size] = "c4_mp";
			self switchToWeapon( "c4_mp" );
			self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_weapon2_costs"] );
			self playSound( "buy_upgradebox" );
		}
		break;
	case "item5":
		if (self.points >= level.dvar["shop_weapon3_costs"])
		{
			self giveWeapon( "claymore_mp" );
			self giveMaxAmmo( "claymore_mp" );
			if( self.actionslotweapons.size == 0 )
				self setActionSlot( 4, "weapon", "claymore_mp" );
			if( !self scripts\players\_weapons::isActionslotWeapon("claymore_mp") )
				self.actionslotweapons[self.actionslotweapons.size] = "claymore_mp";
			self switchToWeapon( "claymore_mp" );
			self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_weapon3_costs"] );
			self playSound( "buy_upgradebox" );
		}
		break;
	case "item6":
		if( self.points >= level.dvar["shop_weapon4_costs"] && self.unlock["extra"] == 0 )
		{
			self.extra = getDvar( "surv_extra_unlock1" );
			self.persData.extra = self.extra;
			
			self.unlock["extra"] ++;
			self.persData.unlock["extra"] ++;
			
			self giveWeap( self.extra );
			self giveWeapMaxAmmo( self.extra );
			self switchToWeap( self.extra );
			self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_weapon4_costs"] );
			self playSound( "buy_upgradebox" );
		}
		break;
	case "item10":
		if( self.points >= level.dvar["shop_defensive1_costs"] )
		{
			if( level.barrels[0] + level.barrels[1] < level.dvar["game_max_barrels"] )
			{
				self scripts\players\_barricades::giveBarrel();
				self scripts\players\_players::incUpgradePoints( -1 * level.dvar["shop_defensive1_costs"] );
				self playSound( "buy_upgradebox" );
			}
			else
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_BARRELS", level.dvar["game_max_barrels"] );
			}
		}
		break;
	case "item11":
		if( self.points >= level.dvar["shop_defensive2_costs"] )
		{
			if( level.barrels[0] + level.barrels[1] < level.dvar["game_max_barrels"] )
			{
				self scripts\players\_barricades::giveBarrel( 1 );
				self scripts\players\_players::incUpgradePoints( -1*level.dvar["shop_defensive2_costs"] );
				self playSound( "buy_upgradebox" );
			}
			else
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_BARRELS", level.dvar["game_max_barrels"] );
			}
		}
		break;
	case "item12":
		if (self.points >= level.dvar["shop_defensive3_costs"] && !level.turretsDisabled)
		{
			if( (level.turrets + level.turrets_held < level.dvar["game_max_turrets"]) && (self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self scripts\players\_turrets::giveTurret("minigun");
				self scripts\players\_players::incUpgradePoints(-1 * level.dvar["shop_defensive3_costs"]);
				self playsound("buy_upgradebox");
			}
			else if( !(self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS_PER_PLAYER", level.dvar["game_max_turrets_perplayer"] );
			}
			else
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS", level.dvar["game_max_turrets"] );
			}
		}
		break;
	case "item13":
		if (self.points >= level.dvar["shop_defensive4_costs"] && !level.turretsDisabled)
		{
			if (level.turrets + level.turrets_held < level.dvar["game_max_turrets"] && (self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) ){
			
				self scripts\players\_turrets::giveTurret("gl");
				self scripts\players\_players::incUpgradePoints(-1 * level.dvar["shop_defensive4_costs"]);
				self playsound("buy_upgradebox");
			}
			else if( !(self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS_PER_PLAYER", level.dvar["game_max_turrets_perplayer"] );
			}
			else
			{
				self iPrintLnBold( &"ZOMBIEUI_MAXIMUM_OF_N_TURRETS", level.dvar["game_max_turrets"] );
			}
		}
		break;
	case "item14":
		if( self.points >= level.dvar["shop_defensive5_costs"] )
		{
			// Barrel + MG was here
		}
		break;
	case "item15":
		if( self.points >= level.dvar["shop_defensive6_costs"] )
		{
			// Teleporter was here
		}
		break;
	}
}

disableTurrets(disable){
	for(i = 0; i < level.players.size; i++)
		level.players[i] setclientdvar("ui_turretsDisabled", disable);
	if(disable)
		level notify("turrets_disabled");
	else
		level notify("turrets_enabled");
}