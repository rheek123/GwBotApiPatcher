# Guild Wars Botting API Patcher 1.6
modified version of gwa2_updater by testytest
RIP gamerevision :'(

https://github.com/rheek123/GwBotApiPatcher

I dont want to sound too harsh, but the trolls and lazy people start to eat too much of my time. So:
NO SUPPORT IF YOU DIDNT READ THIS README! YES I WILL KNOW!
NO SUPPORT OVER PM! ASK IN THE PATCHER THREAD FOR HELP! OR OPEN A TICKET ON GITHUB!
NO SUPPORT ON ANYTHING UNRELATED TO THE PATCHER!

		
# TL;DR
Double click GWA2_Patcher.au3, select the main folder of your bot and it should work again. If not clear, read section Patching.

Future header updates require a new/updated header file, which whill hopefully supplied soon after a new update.
__Read__ the patching guide. If you get an error message occurs, read the guide on __Error Handling__ below.
Post only after reading the guide on __Error Handling__.


# Description		
This script will take any botting file, scan it for all functions that calls sendpacket that are known to me. sendpacket is the function inside botting APIs that uses headers, so any function calling it contains headers.

Other than just updating these values, this script will replace those fixed header values with variable names. This way we can outsource the header definitions and will not have to keep updating the botting api file itself.

This means, patch your botting files __once__ to use the variables and then only change the header files ever again. I hope that people that have experience with getting new headers will continue to push header updates fastly.
Hopefully in a way that is compatible with the variable naming this script uses. Else you'll have to copy the headers from an incompatible variable naming, or do the work yourself.


This github repo had very fast updates to address header updates in the past, but it's not compatible with my variable naming:

https://github.com/tjubutsi/gwa2
	
I tried my best to detect all functions that use sendpacket. The patcher will detect functions it does not know about and write them into a file. So if you get errors, check the Error handling section to solve them.

		
# Patching 
1. Make sure your patcher files are uptodate
2. Backup the bot you want to update
3. Double click "GWA2_Patcher.au3" and select your bot's main folder.
4. If you get an __error message__, read the section about __Error Handling__. __Bot is unstable__ until you've done the error handling!
5. Run bot.

# Update after patching
If I uploaded a new header file to this github, just follow the guide __Patching__.
Else:

1. Fix headers or leech new "GWA2_Headers.au3" file
2. Replace "GWA2_Headers.au3" inside bots folder with new version. 
3. Run bot.

# Error handling

If the bot still crashes make sure you used the newest header file and that you didnt get any error messages during patching.

If you get an error message, open the file "gwa_missing_headers.txt" inside your bot's folder. It will contain all functions that the patcher did not recognize.

Functions known to be unsupported so far are the cons crafting functions from some GwBibles or Addons. I couldnt replicate the packet layout they use, so I dont support them for now. If they get called from your bot, it may crash. 

If your bot uses different functions and you have no idea how to add those to the patcher files yourself, post on the patcher thread on epvp and pray for help. Attach the "gwa_missing_headers.txt", and preferebly the __whole bot__ as a zip file. Also supply as much info about the crash as you can. Especially at what actions it appears to crash. This way we can check for hidden dependencies.
	
BEFORE POSTING MAKE SURE YOU DONT LEAK ANY INFORMATION LIKE WINDOWS USERNAME ("gwa_missing_headers.txt" contains full path to the bot), BOT CONFIG FILES WITH PATHS/CREDENTIALS/CHARACTERNAMES.
	
# Advanced error handling
  
This section is only for advanced programmers who can read, understand and edit sparsely commented code.

Check "incl\GWA2_Function_Header_Table.au3" for how to add new functions to the patcher. If your undetected function uses a header you dont find in "GWA2_Header.au3", you will have to find the correct value and declare a variable for it inside "GWA2_Header.au3".

Post your updates please! Prefebly as a working patcher, but please add a simple text file that contains the lines to add to "GWA2_Header.au3" and "GWA2_Function_Header_Table.au3". This will make it easier to join all changes into a new master version.

Or create a pull request on github.
