# Guild Wars Botting API Patcher 1.5
modified version of gwa2_updater by testytest
RIP gamerevision :'(

https://github.com/rheek123/GwBotApiPatcher

I dont want to sound too harsh, but the trolls and lazy people start to eat too much of my time. So:
NO SUPPORT IF YOU DIDNT READ THIS README! YES I WILL KNOW!
NO SUPPORT OVER PM! ASK IN THE PATCHER THREAD FOR HELP! OR OPEN A TICKET ON GITHUB!
NO SUPPORT ON ANYTHING UNRELATED TO THE PATCHER!

		
# TL;DR
Double click and use this script on ALL FILES of any bot, copy the included header file from folder "incl" to your bot, and it should work again. If not clear, read section Patching.

Future header updates require a new/updated header file, which whill hopefully supplied soon after a new update.
READ the patching guide. If ANY PROBLEM occurs, read the ERROR HANDLING GUIDE below.
POST ONLY AFTER READING THE ERROR HANDLING GUIDE.


# Description		
This script will take any botting file, scan it for all functions that calls sendpacket that are known to me. sendpacket is the function inside botting APIs that uses headers, so any function calling it contains headers.

Other than just updating these values, this script will replace those fixed header values with variable names. This way we can outsource the header definitions and will not have to keep updating the botting api file itself.

This means, patch your botting files ONCE to use the variables and then only change the header files ever again. I hope that people that have experience with getting new headers will continue to push header updates fastly.
Hopefully in a way that is compatible with the variable naming this script uses. Else you'll have to copy the headers from an incompatible variable naming, or do the work yourself.


This github repo had very fast updates to address header updates in the past, but it's not compatible with my variable naming:

https://github.com/tjubutsi/gwa2
	
I tried my best to detect all functions that use sendpacket. The patcher will detect functions it does not know about and write them into a file. So if you get errors, check the Error handling section to solve them.

		
# Patching 
0. Make sure your patcher files are uptodate
1. Backup the bot you want to update
2. Double click "GWA2_Patcher.au3" and run -->ON EACH .au3 FILE<-- of the bot.
3. If you get an ERROR message, READ the section about ERROR HANDLING. 
    BOT IS UNSTABLE until you've done the error handling!
4. Copy the file "GWA2_Headers.au3" from the subfolder "incl" of this archive
    Yes, even if it is already there. The headers change...
5. Paste it into the bots folder, right where the "gwa2.au3", "gwapi.au3", ... is.
6. Run bot.

# Update after patching
0. Make sure your patcher files are uptodate
1. Fix headers or leech new "GWA2_Headers.au3" file
2. Replace "GWA2_Headers.au3" inside bots folder with new version.
    Yes, even if it is already there. The headers change...
3. Run bot.

# Error handling
If you get an error message, open the file "gwa_missing_headers.txt" inside your bot's folder. It will contain all functions that the patcher did not recognize.

Functions known to be unsupported so far are the cons crafting functions from some GwBibles or Addons. I couldnt replicate the packet layout they use, so I dont support them for now. If they get called from your bot, it may crash. 

If your bot uses different functions and you have no idea how to add those to the patcher files yourself, post on the patcher thread on epvp and pray for help. ATTACH the "gwa_missing_headers.txt", and preferebly the WHOLE BOT as a zip file. Also supply as much info about the crash as you can. Especially at what actions it appears to crash. This way we can check for hidden dependencies.
	
BEFORE POSTING MAKE SURE YOU DONT LEAK ANY INFORMATION LIKE WINDOWS USERNAME ("gwa_missing_headers.txt" contains full path to the bot), BOT CONFIG FILES WITH PATHS/CREDENTIALS/CHARACTERNAMES.
	
# Advanced error handling
  
This section is only for advanced programmers who can read, understand and edit sparsely commented code.

Check "incl\GWA2_Function_Header_Table.au3" for how to add new functions to the patcher. If your undetected function uses a header you dont find in "GWA2_Header.au3", you will have to find the correct value and declare a variable for it inside "GWA2_Header.au3".

Post your updates please! Prefebly as a working patcher, but please add a simple text file that contains the lines to add to "GWA2_Header.au3" and "GWA2_Function_Header_Table.au3". This will make it easier to join all changes into a new master version.

Or create a pull request on github.
