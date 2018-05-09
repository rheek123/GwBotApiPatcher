
; The patcher tries to find calls to sendpacket inside functions.
; It matches the function name against the function names in the list below.
; If it matches, it replaces the whatever stored as the header parameter by the third element in the list below.
; The second parameter is used to distinguish between multiple calls inside the same function.
; If it is '0', all calls to sendpacket inside this function are set to the same variable
; If it is !='0', it will set the first/second/... (depending on the stored value) call to sendpacket to the variable specified.
;
;	Example:
;	In SetDisplayedTitle there are two different headers used. First $HEADER_TITLE_DISPLAY, then $HEADER_TITLE_CLEAR.
;	This is reflected by the occurance:
;
;			["SetDisplayedTitle",		1, "$HEADER_TITLE_DISPLAY"], _	;first sendpacket inside SetDisplayedTitle needs $HEADER_TITLE_DISPLAY
;			["SetDisplayedTitle",		2, "$HEADER_TITLE_CLEAR"], _	;second sendpacket inside SetDisplayedTitle needs $HEADER_TITLE_CLEAR
;
;	Another one:
;	Some versions of UseItem have one call to sendpacket, the gwapi version has three calls. They all use the same header, so you can set the occurance to 0
;	This way the same variable is going to be used for each call inside UseItem.
;
;  			["UseItem",					0, "$HEADER_ITEM_USE"], _		;Uses item from inventory/chest
;
;
;

Global $gwa2func_fname 		= 0		;first entry of list, the function name
Global $gwa2func_occurance	= 1		;second entry of list, the n-th call to sendpacket inside the function (0 for no difference of headers inside function)
Global $gwa2func_variable	= 2		;third entry of list, the variable name

Global $gwa2func_headers[][3] = [ _
   ["AbandonQuest", 				0, "$HEADER_QUEST_ABANDON"], _						;Abandons the quest
   ["SetHeroAggression", 			0, "$HEADER_HERO_AGGRESSION"], _					;Sets the heroes aggression level
   ["LockHeroTarget",				0, "$HEADER_HERO_LOCK"], _							;Locks the heroes target
   ["ChangeHeroSkillSlotState",		0, "$HEADER_HERO_TOGGLE_SKILL"], _					;Enables or disables the heroes skill
   ["CancelHero",					0, "$HEADER_HERO_CLEAR_FLAG"], _					;Clears the heroes position flag
   ["CommandHero",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero1",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero2",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero3",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero4",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero5",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero6",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandHero7",					0, "$HEADER_HERO_PLACE_FLAG"], _					;Sets the heroes position flag,	hero runs to position
   ["CommandAll",					0, "$HEADER_PARTY_PLACE_FLAG"], _					;Sets the party position flag, all party-npcs runs to position
   ["CancelAll",					0, "$HEADER_PARTY_CLEAR_FLAG"], _					;Clears the party position flag
   ["AddHero",						0, "$HEADER_HERO_ADD"], _							;Adds hero to party
   ["KickHero",						0, "$HEADER_HERO_KICK"], _							;Kicks hero from party
   ["KickAllHeroes",				0, "$HEADER_HEROES_KICK"], _						;Kicks ALL heroes from party
   ["CallTarget",					0, "$HEADER_CALL_TARGET"], _						;Calls the target without attacking (Ctrl+Shift+Space)
   ["Attack",						0, "$HEADER_ATTACK_AGENT"], _						;Attacks agent
   ["CallAttack",					0, "$HEADER_ATTACK_AGENT"], _						;Calls and Attacks agent
   ["CancelAction",					0, "$HEADER_CANCEL_ACTION"], _						;Cancels the current action
   ["DropBuff",						0, "$HEADER_STOP_MAINTAIN_ENCH"], _					;Drops buff, cancel enchantmant, whatever you call it
   ["DropAllBonds", 				0, "$HEADER_STOP_MAINTAIN_ENCH"], _					;Drops buff, cancel enchantmant, whatever you call it
   ["DropAllBuffs", 				0, "$HEADER_STOP_MAINTAIN_ENCH"], _					;Drops buff, cancel enchantmant, whatever you call it
   ["DropItem",						0, "$HEADER_ITEM_DROP"], _							;Drops item from inventory to ground
   ["DropGold",						0, "$HEADER_GOLD_DROP"], _							;Drops gold from inventory to ground
   ["EquipItem",					0, "$HEADER_ITEM_EQUIP"], _							;Equips item from inventory/chest/no idea
   ["GoPlayer",						0, "$HEADER_AGENT_FOLLOW"], _						;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
   ["DonateFaction",				0, "$HEADER_FACTION_DONATE"], _						;Donates kurzick/luxon faction to ally
   ["GoNPC",						0, "$HEADER_NPC_TALK"], _							;talks/goes to npc
   ["AcceptQuest",					0, "$HEADER_QUEST_ACCEPT"], _						;Accepts a quest from the NPC
   ["QuestReward",					0, "$HEADER_QUEST_REWARD"], _						;Retrieves Quest reward from NPC
   ["Dialog",						0, "$HEADER_DIALOG"], _								;Sends a dialog to NPC
   ["PickUpItem",					0, "$HEADER_ITEM_PICKUP"], _						;Picks up an item from ground
   ["PickUpItem_", 					0, "$HEADER_ITEM_PICKUP"], _						;Picks up an item from ground
   ["ChangeSecondProfession",		0, "$HEADER_CHANGE_SECONDARY"], _					;Changes Secondary class (from Build window, not class changer)
   ["GoSignpost",					0, "$HEADER_SIGNPOST_RUN"], _						;Goes to signpost
   ["OpenChest",					0, "$HEADER_CHEST_OPEN"], _							;Opens a chest (with key AFAIK)
   ["SetDisplayedTitle",			1, "$HEADER_TITLE_DISPLAY"], _						;Displays title (from Gigis Vaettir Bot)
   ["SetDisplayedTitle",			2, "$HEADER_TITLE_CLEAR"], _						;Hides title (from Gigis Vaettir Bot)
   ["AsuranRank",                0, "$HEADER_TITLE_DISPLAY"], _               ;Displays the asura title
   ["NornRank",                0, "$HEADER_TITLE_DISPLAY"], _               ;Displays the norn title
   ["VanguardRank",                0, "$HEADER_TITLE_DISPLAY"], _               ;Displays the vanguard title
   ["SetSkillbarSkill",				0, "$HEADER_SKILL_CHANGE"], _						;Changes a skill on the skillbar
   ["ReplaceSkill", 				0, "$HEADER_SKILL_CHANGE"], _						;Changes a skill on the skillbar
   ["LoadSkillBar",					0, "$HEADER_BUILD_LOAD"], _							;Loads a complete build
   ["SkipCinematic",				0, "$HEADER_CINEMATIC_SKIP"], _						;Skips the cinematic
   ["needed for sendchat",			0, "$HEADER_SEND_CHAT"], _							;Needed for sending messages in chat
   ["DestroyItem",					0, "$HEADER_ITEM_DESTROY"], _						;Destroys item in inventory
   ["IdentifyItem",					0, "$HEADER_ITEM_ID"], _							;Identifies item in inventory
   ["IdentifyItemExplorable",		0, "$HEADER_ITEM_ID"], _
   ["MoveItem",						0, "$HEADER_ITEM_MOVE"], _							;Moves item in inventory
   ["AcceptAllItems",				0, "$HEADER_ITEMS_ACCEPT_UNCLAIMED"], _				;Accepts items not picked up in missions
   ["SalvageMaterials",				0, "$HEADER_SALVAGE_MATS"], _						;Salvages materials from item
   ["SalvageMod",					0, "$HEADER_SALVAGE_MODS"], _						;Salvages mods from item
   ["ChangeGold",					0, "$HEADER_GOLD_MOVE"], _							;Moves Gold (from chest to inventory, and otherway around IIRC)
   ["UseItem",						0, "$HEADER_ITEM_USE"], _							;Uses item from inventory/chest
   ["UseItemBySlot", 				0, "$HEADER_ITEM_USE"], _							;Uses item from inventory/chest
   ["UseItembyModelID", 			0, "$HEADER_ITEM_USE"], _							;Uses item from inventory/chest
   ["SwitchMode",					0, "$HEADER_MODE_SWITCH"], _						;Toggles hard- and normal mode
   ["AddNpc", 						0, "$HEADER_HENCHMAN_ADD"], _						;Adds henchman to party
   ["LeaveGroup",					0, "$HEADER_PARTY_LEAVE"], _						;Leaves the party
   ["EnterChallenge",				0, "$HEADER_MISSION_ENTER"], _						;Enter a mission/challenge
   ["EnterChallengeForeign",		0, "$HEADER_MISSION_FOREIGN_ENTER"], _				;Enters a foreign mission/challenge (no idea honestly)
   ["ReturnToOutpost",				0, "$HEADER_OUTPOST_RETURN"], _						;Returns to outpost after /resign
   ["KickNpc",						0, "$HEADER_HENCHMAN_KICK"], _						;Kicks a henchman from party
   ["TravelGH",						0, "$HEADER_GUILDHALL_TRAVEL"], _					;Travels to guild hall
   ["MoveMap",						0, "$HEADER_MAP_TRAVEL"], _							;Travels to outpost via worldmap
   ["Travel", 						0, "$HEADER_MAP_TRAVEL"], _							;Travels to outpost via worldmap
   ["LeaveGH",						0, "$HEADER_GUILDHALL_LEAVE"], _					;Leaves Guildhall
   ["UseSkillBySkillID", 			1, "$HEADER_SKILL_USE_ALLY"], _
   ["UseSkillBySkillID", 			2, "$HEADER_SKILL_USE_FOE"], _
   ["UseSkillByID", 			   0, "$HEADER_SKILL_USE_ID"], _
   ["InviteTarget", 				0, "$HEADER_INVITE_TARGET"], _
   ["InvitePlayerByID", 			0, "$HEADER_INVITE_TARGET"], _
   ["InvitePlayerByPlayerNumber", 	0, "$HEADER_INVITE_TARGET"], _
   ["AcceptInvite", 				0, "$HEADER_INVITE_ACCEPT"], _
   ["SubmitOffer", 					0, "$HEADER_TRADE_SUBMIT_OFFER"], _
   ["ChangeOffer",					0, "$HEADER_TRADE_CHANGE_OFFER"], _
   ["CancelTrade", 					0, "$HEADER_TRADE_CANCEL"], _
   ["AcceptTrade", 					0, "$HEADER_TRADE_ACCEPT"], _
   ["OfferItem", 					0, "$HEADER_TRADE_OFFER_ITEM"], _
   ["TradePlayer", 					0, "$HEADER_TRADE_PLAYER"], _
   ["MoveItemEx", 					0, "$HEADER_ITEM_MOVE_EX"], _
   ["UnequipItem", 					0, "$HEADER_ITEM_UNEQUIP"], _
   ["Upgrade",	 					0, "$HEADER_UPGRADE"], _
   ["UpgradeArmor",	 				1, "$HEADER_UPGRADE_1"], _
   ["UpgradeArmor",	 				2, "$HEADER_UPGRADE_2"], _
   ["", 0, ""]]

