;###########################
;#  by rheek               #
;#  modified by mhaendler  #
;###########################
; v 1.5 (https://github.com/rheek123/GwBotApiPatcher), many headers taken from: https://github.com/tjubutsi/gwa2
; 
; This file contains all headers that gwa2 uses to communicate with the gameservers directly.
; The headers are named variables. The names should indicate what the header is about.
; The comments give a litte more detail about what the header does.
;
; This makes the source code of gwa2 a little better readable. Also it allows to update headers more easily, as they
; are all now in a small separate place as a list to work yourself through.
; If you need to update the headers, the comments give hints about what action to trigger while recording CtoGS packets.

#include-once
;=QUEST=
Global Const $HEADER_QUEST_ACCEPT				= 0x3F	;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD				= 0x3F	;Retrieves Quest reward from NPC
Global Const $HEADER_QUEST_ABANDON				= 0x12	 ;Abandons the quest

;=HERO=
Global Const $HEADER_HERO_AGGRESSION			= 0x17	;Sets the heroes aggression level
Global Const $HEADER_HERO_LOCK					= 0x18	;Locks the heroes target
Global Const $HEADER_HERO_TOGGLE_SKILL			= 0x1C	;Enables or disables the heroes skill
Global Const $HEADER_HERO_CLEAR_FLAG			= 0x1E	;Clears the heroes position flag
Global Const $HEADER_HERO_PLACE_FLAG 			= 0x1E	;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_ADD					= 0x22	;Adds hero to party
Global Const $HEADER_HERO_KICK					= 0x23	;Kicks hero from party
Global Const $HEADER_HEROES_KICK				= 0x23	;Kicks ALL heroes from party

;=PARTY=
Global Const $HEADER_PARTY_PLACE_FLAG 			= 0x1F	;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG 			= 0x1F	;Clears the party position flag
Global Const $HEADER_HENCHMAN_ADD				= 0xA3	;Adds henchman to party
Global Const $HEADER_PARTY_LEAVE				= 0xA6	;Leaves the party
Global Const $HEADER_HENCHMAN_KICK				= 0xAC	;Kicks a henchman from party
Global Const $HEADER_INVITE_TARGET				= 0xA4	;Invite target player to party
Global Const $HEADER_INVITE_CANCEL				= 0xA1	;Cancel invitation of player
Global Const $HEADER_INVITE_ACCEPT				= 0xA0	;Accept invitation to party

;=TARGET (Enemies or NPC)=
Global Const $HEADER_CALL_TARGET				= 0x27	;Calls the target without attacking (Ctrl+Shift+Space)
Global Const $HEADER_ATTACK_AGENT				= 0x2A	;Attacks agent (Space IIRC)
Global Const $HEADER_CANCEL_ACTION				= 0x2C	;Cancels the current action
Global Const $HEADER_AGENT_FOLLOW				= 0x37	;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
Global Const $HEADER_NPC_TALK					= 0x3D	;talks/goes to npc
Global Const $HEADER_SIGNPOST_RUN				= 0x55	;Runs to signpost

;=DROP=
Global Const $HEADER_ITEM_DROP					= 0x30	;Drops item from inventory to ground
Global Const $HEADER_GOLD_DROP					= 0x33	;Drops gold from inventory to ground

;=BUFFS=
Global Const $HEADER_STOP_MAINTAIN_ENCH			= 0x2D	;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
Global Const $HEADER_ITEM_EQUIP					= 0x34	;Equips item from inventory/chest/no idea
Global Const $HEADER_ITEM_PICKUP				= 0x43	;Picks up an item from ground
Global Const $HEADER_ITEM_DESTROY				= 0x6C	;Destroys the item
Global Const $HEADER_ITEM_ID					= 0x6F	;Identifies item in inventory
Global Const $HEADER_ITEM_MOVE					= 0x75	;Moves item in inventory
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED		= 0x76	;Accepts ITEMS not picked up in missions
Global Const $HEADER_ITEM_MOVE_EX				= 0x78	;Moves an item, with amount to be moved.
Global Const $HEADER_SALVAGE_MATS				= 0x7D	;Salvages materials from item
Global Const $HEADER_SALVAGE_MODS				= 0x7E	;Salvages mods from item
Global Const $HEADER_ITEM_USE					= 0x81	;Uses item from inventory/chest
Global Const $HEADER_ITEM_UNEQUIP				= 0x53	;Unequip item
Global Const $HEADER_UPGRADE					= 0x85	;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_1			= 0x82	;used by gwapi. is it even useful? NOT TESTED
Global Const $HEADER_UPGRADE_ARMOR_2			= 0x85	;used by gwapi. is it even useful? NOT TESTED

;=TRADE=
Global Const $HEADER_TRADE_PLAYER				= 0x4D	;Send trade request to player
Global Const $HEADER_TRADE_OFFER_ITEM			= 0x02	;Add item to trade window
Global Const $HEADER_TRADE_SUBMIT_OFFER			= 0x03	;Submit offer
Global Const $HEADER_TRADE_CHANGE_OFFER			= 0x06	;Change offer
Global Const $HEADER_TRADE_CANCEL				= 0x01	;Cancel trade
Global Const $HEADER_TRADE_ACCEPT				= 0x07	;Accept trade

;=TRAVEL=
Global Const $HEADER_MAP_TRAVEL					= 0xB5	;Travels to outpost via worldmap
Global Const $HEADER_GUILDHALL_TRAVEL			= 0xB4	;Travels to guild hall
Global Const $HEADER_GUILDHALL_LEAVE			= 0xB6	;Leaves Guildhall

;=FACTION=
Global Const $HEADER_FACTION_DONATE				= 0x39	;Donates kurzick/luxon faction to ally

;=TITLE=
Global Const $HEADER_TITLE_DISPLAY				= 0x5B	;Displays title (from Gigis Vaettir Bot)
Global Const $HEADER_TITLE_CLEAR				= 0x5C	;Hides title (from Gigis Vaettir Bot)

;=DIALOG=
Global Const $HEADER_DIALOG						= 0x3F	;Sends a dialog to NPC
Global Const $HEADER_CINEMATIC_SKIP				= 0x66	;Skips the cinematic

;=SKILL / BUILD=
Global Const $HEADER_SKILL_CHANGE				= 0x5F	;Changes a skill on the skillbar
Global Const $HEADER_BUILD_LOAD					= 0x60	;Loads a complete build
Global Const $HEADER_CHANGE_SECONDARY			= 0x45	;Changes Secondary class (from Build window, not class changer)
Global Const $HEADER_SKILL_USE_ALLY				= 0x4A	;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_FOE				= 0x4A	;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_ID				= 0x4A	;
Global Const $HEADER_SET_ATTRIBUTES				= 0x10	;hidden in init stuff like sendchat

;=CHEST=
Global Const $HEADER_CHEST_OPEN					= 0x57	;Opens a chest (with key AFAIK)
Global Const $HEADER_GOLD_MOVE					= 0x7F	;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
Global Const $HEADER_MODE_SWITCH				= 0x9F	;Toggles hard- and normal mode
Global Const $HEADER_MISSION_ENTER				= 0xA9	;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER		= 0xA9	;Enters a foreign mission/challenge (no idea honestly)
Global Const $HEADER_OUTPOST_RETURN 			= 0xAB	;Returns to outpost after /resign

;=CHAT=
Global Const $HEADER_SEND_CHAT      			= 0x67	;Needed for sending messages in chat

;=OTHER CONSTANTS=
Global Const $HEADER_MAX_ATTRIBUTES_CONST_5		= 0x04	;constant at word 5 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_MAX_ATTRIBUTES_CONST_22	= 0x04	;constant at word 22 of max attrib packet. Changed from 3 to four in most recent update
