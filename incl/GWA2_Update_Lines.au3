
Global $gwa2_old_line 	= 0			;first entry of list, the left part of the old line
Global $gwa2_new_line	= 1			;second entry of list, the complete new line

Global $gwa2_lines[][2] = [ _
   ["Local $lItemStruct = DllStructCreate('long id;long agentId;byte unknown1[4];ptr bag;ptr modstruct;long modstructsize;ptr customized;byte unknown2[4];byte type;byte unknown3;short extraId;short value;byte unknown4[2];short interaction;long modelId;ptr modString;byte unknown5[4];ptr NameString;byte unknown6[15];byte quantity;byte equipped;byte unknown7[1];byte slot')", "Local $lItemStruct = DllStructCreate('long Id;long AgentId;byte Unknown1[4];ptr Bag;ptr ModStruct;long ModStructSize;ptr Customized;byte unknown2[4];byte Type;byte unknown4;short ExtraId;short Value;byte unknown4[2];short Interaction;long ModelId;ptr ModString;byte unknown5[4];ptr NameString;ptr SingleItemName;byte Unknown4[10];byte IsSalvageable;byte Unknown6;word Quantity;byte Equiped;byte Profession;byte Type2;byte Slot')"], _						;Storage update changed item structs
   ["Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x80]", "Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x94]"], _
   ["Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x7C]", "Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x90]"], _
   ["", ""]]

