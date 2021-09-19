*********************************************
*           TeknoParrot 1.0.0.140           *
*********************************************
-- www.teknogods.com --
---------------------------------------------
Changes in TeknoParrot 1.0.0.140 Release:
- [Reaver][TeknoParrot] Improved amAuth emulation accuracy, many RE2 games show online.
- [Reaver][TeknoParrot] Fixed coin issue with Golden Gun.
- [Reaver][TeknoParrot] GUILTY GEAR XX ACCENT CORE PLUS R test menu now saves properly.
- [Reaver][TeknoParrot] amAime is now emulated very simply to not crash but no card functionality.
- [Reaver][TeknoParrot] Fix amAuth in Under Defeat HD+.
- [Reaver][TeknoParrot] Fix amAuth in Arcade Love with Pengo.
- [Reaver][TeknoParrot] Accurate PCB emulation for RingEdge, RingEdge2 and RingWide respectively.
- [Reaver][TeknoParrot] Better game detection for non default imagebase games.
- [Reaver][TeknoParrot] EEPROM emulation accuracy is increased.
- [Reaver][TeknoParrot] House of the Dead 4 now has cursor hidden.
- [Reaver][TeknoParrot] House of the Dead 4 now throws grenades with mouse 3.
- [Reaver][BudgieLoader] Fixed Windows 10 compatibility issue where Budgie would not work at all.
- [Reaver][BudgieLoader] Added more output while booting so it is easier to figure out problems.
- [Reaver][TeknoParrotUi] Fixed UI crash with old userprofiles.
- [Reaver][TeknoParrotUi] Fixed issue where mouse hooks would still be present after game has been quit.
- [Boomslangnz][TeknoParrot] Mario Kart DX auto acceleration can now be disabled.
- [nzgamer41][TeknoParrotUi] Started fixing UI resize issues
- [nzgamer41][TeknoParrotUi] Made changes to updater to make it more reliable
- [nzgamer41][TeknoParrotUi] Temporary window fix setting minimum height to 740px

PATREON ONLY:
- [Reaver][TeknoParrot] 2Spicy no longer has 0.00001fps.
- [Reaver][TeknoParrot] 2Spicy now has cursor hidden.
- [Reaver][TeknoParrot] 2spicy now works properly with controller.
- [Reaver][TeknoParrot] 2spicy now works properly with mouse. Use left/right arrows movement.
- [Reaver/Nezarn][Lindbergh] Rambo (Debug elf RamboD.elf) is now playable.
NOTE: Videos only play properly in fullscreen mode!
NOTE: There is level select enabler in settings, use it for skipping levels/other fun.
NOTE: Audio issues still linger in Rambo.
---------------------------------------------
Changes in TeknoParrot 1.0.0.122 Release:
*STATEMENT BY REAVER*
Full open source is closing in on us. The more contributions and support we get from community developers, the more we will open source.

Do you understand the magnitude of what we can do with the ElfLoader?
Basically run ANY/ALL linux games on Windows like Wine does for Linux.
Especially now that our elfloader can emulate even libs(.so)!

The following months will tell us what will happen, if support is great and community is friendly. All source code will go public.



Special thanks to Nezarn, Boomslangnz, sTo0z, nibs and nzgamer41 for working on stuff tirelessly with me and keeping me motivated despite all the hate.

And remember, none of the Patreon funds come to me for personal use.
All of the money goes to developers and hardware to get more work done.
---------------------------------------------
- [Reaver/Nezarn][OpenParrot] Darius Burst Another Chronicle is now supported, open source ftw.
NOTE: You can play up to 4 players!
NOTE: 2nd screen is not inverted, truly epic achievement by Nezarn. Best things come first in TeknoParrot as always!
NOTE: Test Switch does not work right now, will log on real cabinet at some point to fix this issue.
NOTE: Copy folder b74e8ba0fff8b4f7b32099c84f9d1c23_000 to gamedir and rename to Db74e8ba0fff8b4f7b32099c84f9d1c23_000
NOTE: Copy folder EDData to gamedir and rename to DEDData
NOTE: NESYS is emulated, enjoy lots and lots of missions/modes!
NOTE: Here is proper config for init.ini:
2720
768
60
0
0
1
0
0
1
1
0
0

NOTE: 4th parameter is fullscreen.
Feel free to change resolution, best played on ultra wide monitor.
- [Reaver][OpenParrot] Fast I/O emulator now supports 3 and 4 player controls.
- [Reaver][OpenParrot] Fast I/O emulator improvements.
- [nzgamer41][TeknoParrotUi] fixed the patreon page
- [nzgamer41][TeknoParrotUi] fixed focus on the listbox
- [nzgamer41][TeknoParrotUi] fixed it so it'll remember what you clicked on when you go to settings
---------------------------------------------
Changes in TeknoParrot 1.0.0.118 Release:
- [Reaver][OpenParrot] Open source GRID and GTI Club 3.
- [Reaver][OpenParrot] Add missing emulated package to Fast I/O emulator. Groove Coaster 2 now boots and is playable.
- [Reaver][OpenParrot] Add missing reg query, used by USF4.
- [Reaver][TeknoParrotUi] Fixed issue where TeknoParrotUI would stay in background after closing.
- [Reaver][TeknoParrotUi] Groove Coaster 2 profile.
- [Poliwrath][TeknoParrotUi] Show EmulatorType in game info.
- [Poliwrath][TeknoParrotUi] Add (Patreon Only) to game names if they have the patreon bool.
- [Poliwrath][TeknoParrotUi] Add Patreon bool to 2Spicy.
- [Poliwrath][TeknoParrotUi] Check iDmacDrv64.dll legitimacy
- [Poliwrath][TeknoParrotUi] Add RequiresAdmin bool to GameProfile, add warning before launch if UI isn't running as admin
- [Poliwrath][TeknoParrotUi] Fix formatting/clean up GithubUpdates slightly
- [Poliwrath][TeknoParrotUi] Change GRID and GTI Club 3 emulator to OpenParrot
- [nzgamer41][TeknoParrotUi] Fix autoupdate issues.
---------------------------------------------
Changes in TeknoParrot 1.0.0.112 Release:
- New naming convention because we have now automatic builds coming from AppVeyor.
- This release needs to be completely separate from old version due to lot of changes, you may however copy UserProfiles to this new version.
- [nzgamer41][TeknoParrotUi] Automatic update of TeknoParrotUI, OpenSegaAPI, OpenParrot and OpenParrot64 from Github Releases.
NOTE:  This way any approved open source community change is instant to the end users. Such as: Fixes, improvements and more! No more waiting for a month to get community fixes!
- [Reaver][Lindbergh] Games now work again, sorry about that.
- [Reaver][TeknoParrot] TeknoParrot.dll, SteamChild.exe and BudgieLoader.exe are now signed with official COMODO certificate to get rid of false positives on virus scanners.
- [Poliwrath][TeknoParrotUI] Fix controls not working in GRID/Sega Rally/Europa-R games.
- [Poliwrath][TeknoParrotUI] Check if HookedWindows.txt exists before reading it.
- [Nezarn][OpenParrot] Fix OpenParrotLoader argument count
- [Nezarn][Lindbergh] Initial D4 Export SRAM fix.
- [Nezarn][Lindbergh] Virtua Fighter 5 Ver. C home/ram folder fix.
---------------------------------------------
Changes in TeknoParrot 1.94 Release:
- [Poliwrath][TeknoParrotUi] Fix Initial D8 / Mario Kart DX card errors (picodaemon/AMAuthd not running)
- [Poliwrath][TeknoParrotUi] Fix test menu for games that don't use seperate test executable 
- [Poliwrath][TeknoParrotUi] Fix the icon for the first game in the game list never loading (After Burner Climax)
- [Poliwrath][TeknoParrotUi] Added Back button to Emulator Settings, no need to restart UI to load new changes
- [Poliwrath][TeknoParrotUi] Reload game list when Add/Delete game is pressed, no need to restart UI for new games to appear
---------------------------------------------
Changes in TeknoParrot 1.93 Release:
- [Reaver][TeknoParrot] OpenParrotLoader now handles injecting of all OpenParrot/TeknoParrot files.
- [Reaver][TeknoParrot] TeknoParrot64 removed as all code is already in OpenParrot64
- [Reaver][TeknoParrot] Removed TeknoParrotLoader and TeknoParrotLoader64.
- [Reaver][TeknoParrot] Activation is now handled by BudgieLoader.
- [Reaver][OpenParrot/TeknoParrotUI] Added coins to Fast I/O emulator.
- [nzgamer41][TeknoParrotUi] Created new user interface and set it up.
- [nzgamer41][TeknoParrotOnline] Moved TeknoParrotOnline code to inside new UI
- [nzgamer41][TeknoParrotUi] Added ability to register and deregister Patreon key from inside UI
- [nzgamer41][TeknoParrotUi] Added a simple MD5 verification system so you can compare your game to a clean dump if it's completely not working
NOTE: If you've used patches like AMD Fix or English mods, or your game is more up to date, it will show invalid but in reality it may be fine.
- [nzgamer41][TeknoParrotUi] Icons have been moved to a download option, where the Icon will only be downloaded if you play that game.
- [nzgamer41][TeknoParrotUi] XInput/DirectInput can now be specified by game
- [Poliwrath][TeknoParrotUi] Using the mouse as a gun in gun games can now be specified by game
- [nzgamer41][TeknoParrotUi] Games now copy over your preferences when new profiles come out, so no more remapping controllers!
- [nzgamer41][TeknoParrotUi] There is now a description field where game information like AMD fixes required and such can be displayed
- [nzgamer41][TeknoParrotUi] Removed old force feedback stuff, replaced with button to download Boomslangnz's far superior FFB Plugin
- [BirdReport][TeknoParrotUi] Added invert buttons option for MaiMai GreeN
- [Nezarn][TeknoParrotUi] Fix console in new UI.
- [Nezarn][Lindbergh] Games now work on Windows 7, 8, 8.1 and 10, thanks to the cross-platform Faudio project https://github.com/FNA-XNA/FAudio
- [Nezarn][Lindbergh] House of the Dead 4 sound effects are now working.
- [Nezarn][RingEdge] Shining Force Cross Raid and Elysion now work windowed.
- [Nezarn][Lindbergh] VF5B home/ram folder fix.
- [Nezarn][TeknoParrot] Added missing game names in TeknoParrot Steam Integration.
- [Nezarn][Lindbergh] Initial D5 Crash issue fixed.
- [Nezarn][Lindbergh] Initial D4 Jap/EXP, Initial D5 resolution patch.

PATREON ONLY:
- [Reaver/Nezarn][Lindbergh] 2spicy is now playable.
---------------------------------------------
Changes in TeknoParrot 1.92 Release:
- Fixed non-patreon issues with Let's Go Jungle, Project Diva and Virtua Fighter 5 Ver. C.
---------------------------------------------
Changes in TeknoParrot 1.91 Release:
- [Nezarn][Lindbergh] Let's Go Jungle has now AMD Fix, requires fixed shaders from our discord.
NOTE: Characters and frog boss is broken but the game is playable.
- [Reaver][Lindbergh] Virtua Fighter 5 Ver. C no longer requires Patreon.
- [Reaver][Lindbergh] Let's Go Jungle no longer requires Patreon.
- [Reaver][RingEdge] Project Diva no longer requires Patreon.

PATREON ONLY:
- [NTAuthority][NAMCO N2] Counter-Strike NEO is now playable, first N2 emulated game!
NOTE: Dump file is called contents2.bin and file to load inside that is csneo2\linux\hlds_amd
NOTE: sha256 hash of engine_amd.so: fac2dc3e7966555e4848549655a5749251f55f420bf1fb2f147014c57bcf62c0 (from contents2)
NOTE: If you have AMD GPU copy N2\AMDFixByNezarn to N2\
NOTE: Requires some missing linux libs in \csneo2\linux\, you can download them from our discord: https://discord.gg/BcxQ46d
NOTE: console = ALT+F7 or ALTGR+F7 depending of keyboard layout.
NOTE: To play the game do the following:
- Wait for menu to load, move mouse so it asks for card.
- Write login [2 random digits that are card id] in console (Example login 12)
- Exit console and set some name.
- After setting name it takes some time to timeout, so be patient.
- Host via console: First write sv_lan 0 . Then map [mapname] to start server
- Join via console: connect <ip> to connect to listen server.
NOTE: ESC is disabled, open console and write quit to exit.
NOTE: Forward ports: 18243-18260 for online play.
NOTE: To have FreePlay Run game once and after that edit TeknoParrot\setting.ini
Add line FREEPLAY=1 under [COINSETTING]
---------------------------------------------
Changes in TeknoParrot 1.90 Release:
- [Reaver][Lindbergh] ID4 Export, ID4 Jap, ID5, Virtua Tennis 3 and Let's Go Jungle now have proper window titles.
- [Reaver][TEKNOPARROTUI] Let's Go Jungle mouse gameplay now works.
- [Reaver][RingEdge] Project Diva now has FullHD option.
---------------------------------------------
Changes in TeknoParrot 1.89 Release:
- Added missing icons, thanks to POOTERMAN. URL: https://www.deviantart.com/pooterman
---------------------------------------------
Changes in TeknoParrot 1.88 Release:
- Outrun 2 Special Tours Super Deluxe BlackscreenHack is now removed as NVIDIA shader fix can be found in our discord.
PATREON ONLY:
- Let's Go Jungle is now playable, some shader and sound issues remain.
---------------------------------------------
Changes in TeknoParrot 1.87 Release:
- [Reaver/Boomslangnz][EUROPA-R] GRID is now playable, including link play.
NOTE: Edit following file to point in the current game directory in case you don't want to run it from C:\Sega\:
debug\config.xml
->
    <sega_shell
        shell_path="c:\sega\Shell"
        shell_data_path="c:\sega\ShellData\"
        shell_data_ini_path="c:\sega\ShellData\ShellData.ini"
        shell_game_ini_filename="Game.ini"
        shell_game_settings_ini_path="c:\sega\ShellData\GameSettings.ini"
        shell_shutdown_time_limit="60"
    />

PATREON ONLY:
- [Reaver][Lindbergh] Virtua Fighter 5 Ver. C Japanese is now playable.
NOTE: Copy rom from disk1 to disk0.
NOTE: Copy file: gameid from /tmp/segaboot/ to disk0.
NOTE: Game only works properly with AMD graphics card, NVIDIA fix can be found in our discord.
NOTE: If you want to play in VGA, use VgaMode. Game boots 1280x768 by default.
NOTE: Game runs only windowed for now.
- [Reaver][Lindbergh] Sega Race TV now boots until stage select where it gets stuck. (help pls?)
NOTE: Remember to set your IP settings from TeknoParrot as this game uses network even in standalone play.
- [Reaver][Lindbergh] Let's Go Jungle boots but crashes after window creation.
- [Reaver][RINGEDGE] Project Diva is now playable.
NOTE: Only works with NVIDIA GPU and has some graphical issues.
NOTE: Touch emulation is not working but the game is playable regardless. Just use Square to change difficulty.
NOTE: No card emulation.
NOTE: Wait in the init screen for a while, takes some time for the game to boot.
---------------------------------------------
Changes in TeknoParrot 1.86 Release:
- SEGAAPI Audio emulation of Lindbergh is now separated from BudgieLoader to OpenParrot repository in project called Opensegaapi.
NOTE: Copy your compiled Opensegaapi.dll to teknoparrot directory for development, BudgieLoader will automatically load it and route the APIs.
---------------------------------------------
Changes in TeknoParrot 1.85 Release:
- [Reaver][RINGEDGE] Shining Force Cross Elysion 2.06 no longer requires Patreon for real. Oops
- [Reaver][LINDBERGH] Forgot one test code included in elf loader which caused instability in Lindbergh games.
---------------------------------------------
Changes in TeknoParrot 1.84 Release:
- [Reaver][RINGEDGE] Puyo Puyo Quest 1.00.04 no longer requires Patreon for real.
- [Reaver][RINGEDGE] Shining Force Cross Elysion 2.06 no longer requires Patreon for real.
- [Reaver][RINGEDGE] MaiMai GreeN no longer requires Patreon for real.
- [Reaver][RINGEDGE 2] Under Defeat HD+ no longer requires Patreon for real.
- [Reaver][RINGWIDE] Arcade Love with Pengo no longer requires Patreon for real.
- [Reaver][TEKNOPARROTUI] Removed Patreon texts on TeknoParrot Online.
---------------------------------------------
Changes in TeknoParrot 1.83 Release:
- [Reaver][LINDBERGH] Network code improvements, Outrun 2 SP DLX multiplayer should work again.
- [Reaver][LINDBERGH] Outrun 2 BlackTextureHack, this gets rid of black textures when playing from outside the car view.
NOTE: This does make the car invisible for brief moment during the level transition!
- [Reaver][RINGEDGE] Puyo Puyo Quest 1.00.04 no longer requires Patreon.
- [Reaver][RINGEDGE] Shining Force Cross Elysion 2.06 no longer requires Patreon.
- [Reaver][RINGEDGE] MaiMai GreeN no longer requires Patreon.
- [Reaver][RINGEDGE 2] Under Defeat HD+ no longer requires Patreon.
- [Reaver][RINGWIDE] Arcade Love with Pengo no longer requires Patreon.
- [Reaver][NAMCO ES3A] Mario Kart DX 1.10 TeknoParrot Online works.
- [Boomslangnz][LINDBERGH] Virtua Fighter 5 Ver. B now works again.
- [Boomslangnz][LINDBERGH] Added SunHeightValue hack to lower the sun in resolution hacked elfs.
NOTE: Use value of 15-50 or so to have nicer gameplay.
- [Boomslangnz][Namco ES3B] Fixed issue where Pokken Controls didn't work.
- [nzgamer41][NAMCO ES3X] WMMT5 now has event 2P and 4P mode option.
- [nzgamer41][TEKNOPARROTUI] Added a built in updater that will download and extract teknoparrot.
- [anonymous201712][NAMCO ES3X] Dome Hack for MachStorm, removing the dome curvature.

PATREON ONLY:
- [Reaver/Boomslangnz][EUROPA-R] GRID is now playable, including link play.
NOTE: Edit following file to point in the current game directory in case you don't want to run it from C:\Sega\:
debug\config.xml
->
    <sega_shell
        shell_path="c:\sega\Shell"
        shell_data_path="c:\sega\ShellData\"
        shell_data_ini_path="c:\sega\ShellData\ShellData.ini"
        shell_game_ini_filename="Game.ini"
        shell_game_settings_ini_path="c:\sega\ShellData\GameSettings.ini"
        shell_shutdown_time_limit="60"
    />
---------------------------------------------
Changes in TeknoParrot 1.82 Release:
- [nzgamer41][NAMCO ES3X] fixed crashing bug with wmmt5
- [Reaver][TEKNOPARROTUI] Fixed mistake by community developers where xml files would not be updated after recent big changes if extracted over old version.
---------------------------------------------
Changes in TeknoParrot 1.81 Release:
NOTE: Due to nature of multiple contributors, first field always describes the person who worked on the feature.

- [Reaver][NAMCO ES3A] Mario Kart DX no longer overwrites H:\ USB sticks.
  NOTE: This was due to Namco AMCUS default config, this has now been changed to save in chuck.img instead.
- [Reaver][RingWide] Sega Racing Classic LAN works again.
- [Reaver][LINDBERGH] Initial D5 no longer crashes on card entry.
- [Reaver][LINDBERGH] Virtua Tennis 3 no longer requires Patreon.
- [Reaver][LINDBERGH] Virtua Fighter 5 Ver. B no longer requires Patreon.
- [Reaver][LINDBERGH] House of the Dead 4 no longer requires Patreon.
- [Reaver][TEKNOPARROTUI] Nice christmas red color for title bar.
- [Poliwrath][TEKNOPARROTUI] Major code improvements.
- [Poliwrath][TEKNOPARROTUI] Discord RPC, you can now show others what you are playing with TeknoParrot, toggle on from Emulation Settings.
- [Boomslangnz][SEGA PC BASED] Daytona Usa 3 fixed XInput controller required to play.
- [Boomslangnz][SEGA PC BASED] Daytona Usa 3 Force Feedback is now working with FFB Arcade Plugin. Download: http://forum.arcadecontrols.com/index.php?topic=157734.0
- [Boomslangnz][SEGA PC BASED] Daytona Usa 3 MSAA 4x setting disable for people with slower GPUs.
- [Boomslangnz][SEGA PC BASED] Daytona Usa 3 no longer has reverse controls in championship mode.

PATREON ONLY:
- [Reaver][RINGEDGE] Puyo Puyo Quest 1.00.04 is now playable. (game exe is: bin\Pj24App.exe)
NOTE: Edit following fields from hod5.ini:
isNetwork = 1 -> 0
Auth = 1 -> 0
isUseAime = 1 -> 0
UseDownload = 1 -> 0
s_input = touch_panel -> mouse
Have fun testing other changes, maybe you can activate addional content!

- [Reaver][RINGEDGE] Shining Force Cross Elysion 2.06 is now playable including card saving.
NOTE: Like Raid, iccard.txt/iccard.bin need to be in C:\ root.
NOTE: You can also upgrade your Raid card save, note that you can no longer then use the card on raid. (Take backup before upgrade!)

- [Reaver][RINGEDGE] MaiMai GreeN is now playable.
NOTE: Touch is unemulated, this will need 3rd party plugin. You can find the touch struct at: 0x8DF9C0. By editing it you can get touch input (Use Test Menu).

- [Reaver][RINGEDGE 2] Under Defeat HD+ is now playable.
- [Reaver][RINGWIDE] Arcade Love with Pengo is now playable.
NOTE: 4 player mode is disabled due to insufficient JVS emulation (it crashes with VT4 profile). Feel free to fix, source is in github.
---------------------------------------------
Changes in TeknoParrot 1.80 Release:
- [LINDBERGH] Improved Linux emulation, many more supported APIs.
- [LINDBERGH] Initial D5 is now playable without Patreon.
- [LINDBERGH] Outrun 2 Special Tours Super Deluxe is now playable again.
- [LINDBERGH] Windowed/Fullscreen mode should now work for: House of the Dead 4, Virtua Tennis 3, After Burner Climax, Initial D4 JAP/EXP and Initial D5.
- [LINDBERGH] Improved gameid accuracy for all titles. (Overwriting patched elf gameids)
- [RINGEDGE] Guilty Gear XX Accent Core Plus R has now proper button set.
- [SEGA PC BASED] Daytona Usa 3 is now playable. (Thanks Boomslangnz)
- [TEKNOPARROTUI] Many many fixes by Poliwrath, thanks!
- [ES3A] Mario Kart DX online timeouts should now be fixed!
- [TEKNOPARROTUI] Daytona3, HOTD4, VF5 and VT3 icons added, made by POOTERMAN.

PATREON ONLY:
- [LINDBERGH] Virtua Tennis 3 is now playable with some minor graphical issues.
NOTE: If you want to play in VGA, use VgaMode. Game boots 1360x768 by default.
NOTE: FullHD hack obviously ignores VgaMode.
- [LINDBERGH] House of the Dead 4 is now playable with some sound and graphical issues.
NOTE: Fixed shaders are required! (Look at wiki) Special Special thanks to sqrt(-1) for the fixed shaders. "Shaders forever!"
NOTE: Please use offscreen reload mode for now, accelerometer will be added soon!
NOTE: If you want to play in VGA, use VgaMode. Game boots 1280x768 by default.
- [LINDBERGH] Virtua Fighter 5 Ver. B Export is now playable.
NOTE: Copy rom from disk1 to disk0.
NOTE: Copy file: gameid from /tmp/segaboot/ to disk0.
NOTE: Test menu is not tested and don't know if it saves or not.
NOTE: Game only works properly with AMD graphics card, NVIDIA fix will be coming soon!
NOTE: If you want to play in VGA, use VgaMode. Game boots 1280x768 by default.
NOTE: Game runs only windowed for now.
---------------------------------------------
Changes in TeknoParrot 1.69 Release:
- [NESiCA] D:\ file redirection should be complete now, no more crashes on init or non-saving test menu.
- [NESiCA] RFID emulator hooks rewritten.
- [NESiCA] Crimzon Clover is now playable.
- [NESiCA] Ikaruga is now playable.
- [NESiCA] Magical Beat in no longer stuck on Initializing.
- [NESiCA] Arcana Heart 2 is now playable.
- [NESiCA] Arcana Heart 3 - LOVE MAX SIX STARS!!!!!! is now playable.
- [NESiCA] Raiden III is now playable.
- [NESiCA] Raiden IV is now playable.
- [NESiCA] Senko no Ronde DUO is now playable.
- [NESiCA] Trouble Witches AC - Amalgam no Joutachi is now playable.
- [NESiCA] Groove Coaster 2 now boots but to a Fast I/O error due to wrong kind of emulation.
- [NAMCO ES3A] Fixed a bug in Mario Kart DX where amauthd would not run on launch and you could not connect to online server.
- [TEKNOPARROT UI] Update checker is now included and will prompt on launch in case of new updates.
---------------------------------------------
Changes in TeknoParrot 1.68 Release:
- [NAMCO ES3X] WMMT5 including 0-21 support and all save code for current dumped version moved to OpenParrot.
- [NESiCA] Fixed 2x Fast I/O hook missing that caused IO errors NESiCA games.
- [NESiCA] Nitroplus Blasterz (1.07 and 1.09) is now playable.
- [NESiCA] Goketsuji Ichzinoku - Matsuri Senzo Kuyo is now playable.
- [NESiCA] Also fixed a bug that caused hooks to be missing if game loaded iDmacDrv32.dll later than from Import Table.
- [NESiCA] Groove Coaster 2 now boots but gets stuck to a black screen.
- [NESiCA] Ultra Street Fighter (Dev exe) is now playable.
- [NESiCA] Space Invaders is now playable.
- [NESiCA] Strania - The Stella Machina is now playable.
- [NESiCA] Aquapazza Aquaplus Dream Match is now playable.
- [NESiCA] Do Not Fall - Run for Your Drink is now playable.
- [NESiCA] Elevator Action is now playable.
- [NESiCA] En-Eins Perfektewelt is now playable.
- [NESiCA] Rastan Saga is now playable.
- [NESiCA] Puzzle Bobble is now playable.
- [NESiCA] Homura is now playable.
- [NESiCA] Vampire Savior - The Lord Of Vampire is now playble.
- [NESiCA] Hyper Street Fighter II is now playable.
- [NESiCA] Street Fighter Zero 3 is now playable.
- [NESiCA] Sugoi! Arcana Heart 2 is now playable.
- [NESiCA] Street Fighter 3rd Strike is now playable.
- [TYPEX/NESiCA] Registry emulated for TYPE X and NESiCA titles, values settable via INI.
- [TEKNOPARROT UI] Other emulator blacklist now works properly, it no longer has false positives.
- [TYPEX] Battle Fantasia now playable.
- [EXBOARD] eX-Board is now emulated.
- [EXBOARD] Daemon Bride is now playable.
- [EXBOARD] Arcana Heart 3 boots but gets stuck.
- [EUROPA-R] Ford Racing now has windowed mode.

Thanks to super OpenParrot contributor Nezarn!
---------------------------------------------
Changes in TeknoParrot 1.67 Release:
- Pokken Tournament moved to OpenParrotLoader.
- Removed DEVMODE from OpenParrot so NESiCA titles work again.
---------------------------------------------
Changes in TeknoParrot 1.66 Release:
- OpenParrot is now included with TeknoParrot, freeing up code for public domain.
- OpenParrot is now released and source code available at: 
https://github.com/teknogods/TeknoParrotUI
and
https://github.com/teknogods/OpenParrot

If you wish to contribute in development or learn how things are done you are welcome to our discord.
https://discordapp.com/invite/A5SPc4x

Expect lot of new content available in near future as we are working on some cool stuff! :)
---------------------------------------------
Changes in TeknoParrot 1.65 Release:
- Mario Kart DX card should now work properly again.
- [KONAMI] GTI Club 3 is now playable, includes test menu saving and network play. More Konami coming soon! Use the japanese exe.
PATREON ONLY:
- [LINDBERGH] Initial D4 Japanese is now playable on LAN and TeknoParrot Online.
- [LINDBERGH] Initial D4 Export is now playable on TeknoParrot Online.
- [LINDBERGH] Initial D5 is now playable on TeknoParrot Online.
---------------------------------------------
Changes in TeknoParrot 1.64 Release:
- [TEKNOPARROT UI] Added Icons for ID4, ID5, ID8, School of Ragnarok, Mach Storm, USF4, LGI3D and GGXX by POOTERMAN. ( https://www.deviantart.com/pooterman/gallery/ )
- [LINDBERGH] AMDFix removed from ID4/ID5 since they are obsolete thanks to Nezarn.
https://github.com/Nezarn/IDShaderfix/tree/master/D5

PATREON ONLY:
- [LINDBERGH] Outrun 2 Special Tours Deluxe Network play now works with 2-4 players.
- [LINDBERGH] Partial Initial D5 network emulation, does not link yet. Coming soon!
- [LINDBERGH] Free play is now toggleable on and off properly.
---------------------------------------------
Changes in TeknoParrot 1.63 Release:
- [TEKNOPARROT CORE] Fixed JVS Wheel emulation for all games (borked in 1.62 without stooz)
- [TEKNOPARROT CORE] Initial D5/D6/D7/D8 wheel should now be as in the real cabinet, earlier values were wrong, sorry!
---------------------------------------------
Changes in TeknoParrot 1.62 Release:
- [TEKNOPARROT CORE] JVS Wheel is now properly emulated for Initial D4/D5/D6/D7/D8 and Sega Sonic All-Stars Racing (Only in non-sto0z mode!!!)

PATREON ONLY:
- [LINDBERGH] Initial D5 card crash fixed.
- [LINDBERGH] Initial D5 TeknoParrot Online enabled but does not function properly yet. Will be fixed soon.
---------------------------------------------
Changes in TeknoParrot 1.61 Hotfix Release:
- School of Ragnarok and Pokken Tournament now work without Patreon, sorry about that.
---------------------------------------------
Changes in TeknoParrot 1.61 Release:
- [TEKNOPARROT CORE] Separate Patreon releases are no more, now both are available same time but some modules are blocked to only patreon users.
  Simply if you have Patreon serial, use register_patreon.bat to register your serial.
- [TEKNOPARROT CORE] JVS Emulation improvements.

PATREON ONLY:
- [LINDBERGH] Initial D5 is playable with cards.
  NOTE: SOUNDS ARE BUGGED, NETWORK DOES NOT WORK YET!

PUBLIC:
- [LINDBERGH] Initial D4 Japanese is finally playable. Also supports cards but no network yet.
- [TYPE X3] School of Ragnarok is now playable.
- [ES3A] Mario Kart DX 1.10 now playable with saves (online only) and local multiplayer (or Hamachi).
- All previous Patreon changes included.

Please read previous 1.54a-1.60b patreon changes for more information!
---------------------------------------------
Changes in TeknoParrot 1.60b Patreon Release:
- Mario Kart DX 1.10 crash bug when changing items and various other crashes fixed.
- Mario Kart DX 1.10 no longer goes offline when playing mirror cup.
- Added missing Persona 4: The Ultimate in Mayonaka Arena profile.
- Added missing Persona 4: The Ultimax Ultra Suplex Hold profile.
- Reason for USF4 not working is that we only tested the very special developer exe and not the vanilla USF4 exe. This will be resolved soon.
---------------------------------------------
Changes in TeknoParrot 1.60a Patreon Release:
- More Nesica titles now playable:
* Blaz Blue Central Friction Supported.
* Blaz Blue Chrono Phantasma
* Magical Beat Supported.
* Persona 4: The Ultimate in Mayonaka Arena Supported.
* Persona 4: The Ultimax Ultra Suplex Hold Supported.
* Ultra Street Fighter IV Supported.
- Pokken Tournament Banapass Emulated, no functionality yet.
- Wangan Midnight 5 Banapass Emulated, no functionality yet.
- Mario Kart DX 1.00-1.10 Support.
* Network Play. TP Online coming soon.
* Banapass emulated, press F2 to insert card.
* ALL.NET and Online cloud emulated.
* Resolution selection (this breaks entire game, suggested not to use until better patch comes)
* Full save support including multiplayer stats:
1. Register+Login to https://teknoparrot.com
2. Generate your own MKDX PlayerId via https://teknoparrot.com/mkdx
3. Add PlayerId to Game Settings in TeknoParrotUI.
4. Play with full saves!

NOTE:
* Mario Kart DX Must be run as admin since emulation of Namco amAuth COM interface does not work otherwise. (You cannot get online)
* As gateway put your local area networks own gateway. (For example 192.168.1.1)
* Get PlayerId from https://teknoparrot.com/mkdx (after registration)
* Leave ServerAddress and ServerPort as is unless other servers come around.
* AmAuthPort leave it unchanged unless you have to use only certain port on your local machine for amAuth emulation.
* Full player statistics pages coming soon!

Thanks Peter Katt for the card dump.

100% more innovation than other es3 emulators.
Support the innovators, not the imitators!
---------------------------------------------
Changes in TeknoParrot 1.54a Patreon Release:
- Support Pokken Tournament all versions.
NOTE: Cards not working yet.
NOTE: Network versus works (Also VPN).
NOTE: If your ping with other player is higher than LAN (over 30ms), the game will be unplayable due to horrible lan code.
NOTE: Please enable free play from TEST MENU as coins are currently broken.
- Support School of Ragnarok
NOTE: This game has weirdest button configuration on planet, Button 8 start.
NOTE: Remember to set local area network ip settings from Game Settings.
NOTE: NESYS / Cards are emulated however online saves are not yet emulated.
NOTE: Game has known issues with PS4 controllers, we are investigating the issue.
- Added missing 6th button to Guilty Gear XX Accent Core Plus R.
- Added Pokken Tournament icon by POOTERMAN.
---------------------------------------------
Changes in TeknoParrot 1.53 Hotfix Release:
- Fixed problems with GGXX, LGI3D and SFCR105.
---------------------------------------------
Changes in TeknoParrot 1.53 Release:
- All 1.52x Patreon changes.
- AMDFix flag for Initial D4.
---------------------------------------------
Changes in TeknoParrot 1.52e Patreon Release:
- Melty Blood Actress Again Current Code and 1.07 now function properly.
- Let's Go Island 3D now saves test menu settings properly.
- Sega Sonic All-Stars Racing Arcade now saves test menu settings properly.
- Unresponsive Sega Racing Classic XInput controls fixed.
---------------------------------------------
Changes in TeknoParrot 1.52d Patreon Release:
- Outrun 2 and After Burner Climax are now working again, sorry about that!
- Ford Racing Brake now functions properly.
---------------------------------------------
Changes in TeknoParrot 1.52c Patreon Release:
- Virtua Tennis 4 is now playable with 4 players.
---------------------------------------------
Changes in TeknoParrot 1.52b Patreon Release:
- Support Let's Go Island 3D.
- Support Guilty Gear XX Accent Core Plus R
- Support Shining Force Cross Raid 1.05
- Test Mode can no longer be enabled from UI for games that have no separate test mode (Use test switch in game!)
---------------------------------------------
Changes in TeknoParrot 1.52a Patreon Release:
- Lindbergh:
* Initial D4 Export is now playable including card emulation, there are some sound emulation issues and also no link play yet.
- Mario Kart DX should now work again.
---------------------------------------------
Changes in TeknoParrot 1.51 Hotfix 2 Release:
- Lindbergh stuff fixed more, sorry about that.
---------------------------------------------
Changes in TeknoParrot 1.51 Hotfix Release:
- Lindbergh games now function properly.
- Initial D8 Infinity TeknoParrot Online now works.
---------------------------------------------
Changes in TeknoParrot 1.51 Release:
- All patron changes
---------------------------------------------
Changes in TeknoParrot 1.50f Patreon Release:
- Picodaemon now automatically run with ID6, ID7 and ID8 when using old card code.
- After Burner Climax should finally work on all pcs.
- Initial D8 Support, including FFB, Online and card saving (only old type).
- WMMT5: No longer crashes when playing a LAN game with saves.
- WMMT5: "SkipMovies" option added for PCs that have strange crash just before intro. (This is due to some MFPlat codecs?)
- WMMT5: Added NameChanger, this does not however go over network yet.
- WMMT5: Cars now save properly by car model, so now you can have save for each car.
---------------------------------------------
Changes in TeknoParrot 1.50e Patreon Release:
- After Burner Climax now works.
- Fixed a crash with TP online.
---------------------------------------------
Changes in TeknoParrot 1.50d Patreon Release:
- Fixed a bug where Lindbergh games would have no picture.
---------------------------------------------
Changes in TeknoParrot 1.50c Patreon Release:
- Fixed glut32.dll which caused Lindbergh games not to run for everyone.
---------------------------------------------
Changes in TeknoParrot 1.50b Patreon Release:
- Added missing SteamChild.exe.
---------------------------------------------
Changes in TeknoParrot 1.50a Patreon Release:
- Added Samurai Spirits Sen, Taisen Hot Gimmick 5, Outrun 2 SP DLX and After Burner Climax icons by POOTERMAN.
- Removed .exe only filtering since Lindbergh executables have no extension.
- SEGA Lindbergh emulation support with new family member BudgieLoader.
NOTE: Test menu saving works, highscore saving works.
NOTE: Minor graphic issues, will be solved soon!
* After Burner Climax Supported
NOTE: Copy abc from disk0 to disk1 and run from there!
* Outrun 2 Special Tours Super Deluxe Supported including Force Feedback.
---------------------------------------------
Changes in TeknoParrot 1.41e Patreon Release:
- Wangan Midnight Maximum Tune 5 Experimental Force Feedback.
NOTE: Adjust the Spring value if you wheel does not autocenter.
- Fixed WMMT5 Gas and Break pedals to be properly sensitive, please recalibrate your game.
- Fixed some force feedback effects.
- Added WhiteScreenFix for people who are getting the whitescreen freeze on beginning.
- Fixed a bug in the method of getting haptic ids, this caused some people to not have force feedback at all.
---------------------------------------------
Changes in TeknoParrot 1.41d Patreon Release:
- Force Feedback stability fixes.
- Chase HQ2 and Wacky Races force feedback now working.
- Initial D6 and Initial D7 force feedback now working for more wheels. No need for old TeknoFfb.
NOTE: Set Force Feedback level to 10 from test menu.
NOTE: Friction and Sine are not finished yet, will be done for 1.42.
- WMMT5 crashes fixed.
- WMMT5 car HP is now saved, each car has own save in TeknoParrot_Cars folder.
NOTE: Color is also saved for the car, so changing color does not work.
NOTE: To make your custom car, copy and rename any car file example: 000000000000000D.car to custom.car
NOTE: If custom.car exists, this is always loaded instead of the selected car save.
NOTE: Feel free to edit the file and experiment making custom cars like Namco Taxi :-)
NOTE: HAVE FUN AND MAKE COOL CARS ;))))
---------------------------------------------
Changes in TeknoParrot 1.41c Patreon Release:
- Fixed a bug where Initial D7 would crash for some people constantly.
- Added custom gear shift with 6 speeds to Initial D7. (Experimental!)
- Force Feedback for the following games, select your haptic device from Emulator settings.
* Sega Racing Classic
* Sega Rally 3
* Ford Racing
NOTE: If it behaves strangely for you or you have Thrustmaster T-GT, enable Thrustmaster fix!
NOTE: If you get error such as "Unable to create xxxx effect, disabling Force Feedback!". Get a modern wheel.
NOTE: If your wheel is not in the menu, it is not supported or does not have Force Feedback.
NOTE: But I have a controller! Ok well get a wheel instead.
NOTE: If your wheel has too much power or too less power, try to edit the Sine/Spring/Friction/Constant values!
NOTE: SRC uses all of these, Sega Rally 3 / Ford Racing only uses Constant.
---------------------------------------------
Changes in TeknoParrot 1.41b Patreon Release:
- MachStorm supported.
- Fixed an issue with WMMT5 where it would be stuck if certain webcam brands were connected.
- Fixed many issues involving DirectInput such as joysticks not functioning or multiple devices not being listened.
---------------------------------------------
Changes in TeknoParrot 1.41a Patreon Release:
- Partial saving for WMMT5.
NOTE: Saves campaign, points and some other things.
NOTE: DOES NOT SAVE CARS YET!
NOTE: Save is done when you select NO in the continue screen.
NOTE: Save is saved to progress.sav file in game directory.
---------------------------------------------
Changes in TeknoParrot 1.41 Release:
- All patron changes
- Added WMMT5 icon by POOTERMAN
- Added missing Cab3IP and Cab4IP from SRC.
- Fixed SRC networking.
---------------------------------------------
Changes in TeknoParrot 1.40b Patreon Release:
- Fixed a crash when using DirectInput in any game.
- Fixed a crash on splash screen when playing WMMT5.
---------------------------------------------
Changes in TeknoParrot 1.40a Patreon Release:
- DualAxis now works properly with DirectInput.
- Other DirectInput code improvements.
- Mario Button added to Mario Kart DX.
- Sega Racing Classic 1-4 gears now work properly.
- Custom incremental - + gearshift for Sega Racing Classic.
- Sega Racing Classic no longer shows "File" menu in fullscreen or windowed mode.
- Support even wider range of JVS buttons in JVS Emulator.
- 64bit TeknoParrot!
- Support for Wangan Midnight Maximum Tune 5.
NOTE:
- Full JVS support including 6 position gearshift, perspective switch button and interuption switch button.
- Custom + - Gearshift option added for users without 6 gears.
- Saving is not yet supported.
- Local play with 1-4 systems works fine.
LAN NOTE:
- Only one terminal emulator instance can exist on your network! Untick TerminalEmulator from TeknoParrot GameSettings on other PCs!
- TeknoParrotOnline coming soon!
---------------------------------------------
Changes in TeknoParrot 1.35 Hotfix Release:
- Fixed Shining Force Cross Raid error.
---------------------------------------------
Changes in TeknoParrot 1.35 Release:
- All patron changes
- ID6, ID7 attract mode should no longer crash. All game specific ghost etc. data now redirected to UserData folder in game directory!
---------------------------------------------
Changes in TeknoParrot 1.34b Patreon Release:
- Added many icons by POOTERMAN
- Updated SharpDX libs (DirectInput, XInput etc.) to help with the idiotic input issues.
- Added option to ID6 and ID7 to use old card code. Just disable "EnableNewCardCode" from options in the TeknoParrotUi.
NOTE: This does require you to manually run picodaemon once again. Will be made automatic for public release!
- Experimental FFB code for ID6 and ID7. Have fun tinkering with it!
How to use: follow instructions on the README.md: https://github.com/teknogods/TeknoFfb
---------------------------------------------
Changes in TeknoParrot 1.34a Patreon Release:
- Added ID7.png by POOTERMAN
- Added ShiningForceCrossRaid.png by POOTERMAN
- Shining Force Cross Raid 1.00 Supported!
NOTE:
- Windowed mode does not work currently.
- Works only on NVIDIA (due to shaders)
- Cards work, place our generated card files iccard.bin / iccard.txt to drive root for example C:\ or on USB stick! NOT GAME DIR!
- To enter card press F2
- Touch screen works, just use mouse or if you have touch screen, use that.
- Multiplayer links but no modes are unlocked, feel free to hax!
- If you have black textures, download shader pack from wiki. Thanks to ShaderGOD for fixing them. Didn't want to be credited.
Cards and shader fixes can be found at: https://wiki.teknoparrot.com/books/compatibility-list/page/shining-force-cross-raid
---------------------------------------------
Changes in TeknoParrot 1.34 Release:
- Added new code by sto0z that make his super popular control adjustment even more adjustable!
- TeknoParrot Online now available for everyone, look at earlier changelogs to understand how it works!
- New card system now available for public too! Do not use modified game files or the cards will corrupt!
---------------------------------------------
Changes in TeknoParrot 1.33a Patreon Release:
- Steam Online works as usual also for Initial D6AA 1.2.
- New card code extensively tested, also now cards are not encrypted for maximum modding support!
---------------------------------------------
Changes in TeknoParrot 1.33 Release:
- Mario Kart DX STRPCB error resolved permanently.
- Fixed a critical developer bug in Mario Kart DX that caused the game never to run on some systems. (Causing STRPCB as a side effect)
- Initial D6 / D7 no longer let's you create more cards than 1, which seem to be the issue when cards corrupt.
NOTE:
- If you now get corrupted card, please send it to the dev team.
---------------------------------------------
Changes in TeknoParrot 1.32 Release:
- Sega Sonic All-Stars Racing Arcade works again! (no network)
- Initial D6AA 1.2 supported.
- DirectInput issues should be fixed and DirectInputOverride.txt should no longer be necessery.
- If you have issues with XBOX controllers, please use XInput.
NOTE: Also Oculus Rift can conflict with XBOX controllers when using Direct Input!
- Mario Kart DX 1.0 public support
- Mario Kart DX TEST button now works by pressing it once instead of holding.
- Parrot UI now detects if it is already running and terminates the stuck processes for you if you wish.
- Steam Online only for Patreon builds for now until is stable.
---------------------------------------------
Changes in TeknoParrot 1.31 Patreon Release:
- Fixed issue of crash when double clicking a lobby in TeknoParrot Online
- Fixed DirectInputOverride.txt to not read the empty fields.
- Added warning if GUID was not parsed correctly from DirectInputOverride.txt
- Fixed an issue where loading a save would cause random crashes on Mario Kart DX.
- Fixed a bug where TeknoParrot Online would stay open in background even after closing.
- Fixed a bug where TeknoParrot Ui would crash after exiting a game.
---------------------------------------------
Changes in TeknoParrot 1.30 Patreon Release:
- Mario Kart DX 1.00 supported including: offline saving, 2-4 player local multiplayer and 2-4 player online steam multiplayer!
NOTE: Calibrate your wheel and pedals to get rid off control issues!
NOTE: If you get STRPCB error, this is not actual STRPCB issue but game bug related. Will be resolved soon!
NOTE: If you get blue graphics issue, try to change resolution and hz settings. Also reboot. Do not run ParrotUi as admin!
NOTE: If you get Direct3D error, install Directx SDK from here: https://www.microsoft.com/en-us/download/details.aspx?id=6812
---------------------------------------------
- Initial D7 multiplayer (Steam Online and DirectIP)
---------------------------------------------
- Tetris The Grand Master 3 Terror Instinct saves no longer saved in D:\ but in game dir.
- Sega Sonic All-Stars Racing works again (no multiplayer)
- King of Fighters Maximum Impact Regulation A getting stuck fixed.
- Initial D6 and D7 card corruption fixes.
---------------------------------------------
- DirectInput override, if your DI device does not work for some reason. You can add GUID(s) to file called DirectInputOverride.txt and it will only use those!
- Use included exe called: ListDirectInputGuids.exe to see GUIDs and Descriptions!
Just put GUID per line on the txt file and nothing else.
---------------------------------------------
- Steam online for: Initial D6, Initial D7 and Mario Kart Deluxe 1.00.
Features:
* NAT punchtrough, no need to open any ports or use Hamachi / Evolve etc.
* Fully seamless, no need to set any IP, cabinet id or anything!
* Join our Steam group to find players:
http://steamcommunity.com/groups/TeknoParrot

How to use:
* Install Steam from http://store.steampowered.com/ and register account.
* Run TeknoParrotUi.exe
* Set your buttons, game dir and other settings for the game you wish to play.
* Save your settings
* Close TeknoParrotUi.exe
* Run TeknoParrot Online
* Either simply create or join a game
* Enjoy!!!!
---------------------------------------------
Changes in TeknoParrot 1.21 Release:
- Fixed a bug where cards would corrupt.
- Added missing AMD Fixes for ID6 and ID7.
---------------------------------------------
Changes in TeknoParrot 1.20 Release:
- All TEST changes.
- Ford Racing Brake is now fixed
- Battle Gear 4 Full screen mode fixed. Please pick 2 pedals in game or controls won't work!
- Initial D6 and Initial D7 now auto read card if it exists. Cards are now saved in the game directory.
- DirectX8 games now run windowed.
- Melty Blood and Sega Sonic All-Stars Racing temporary disabled, will be enabled soon!
- Sega Golden Gun now works again.
- Gun sensitivity works again.
- Various JVS emulation improvements.
---------------------------------------------
Changes in TeknoParrot 1.20 TEST 12 Release:
- Improved code that checks for other emulators to prevent crashes.
---------------------------------------------
Changes in TeknoParrot 1.20 TEST 11 Release:
- Fixed crash on start.
---------------------------------------------
Changes in TeknoParrot 1.20 TEST 10 Release:
- Initial D6 and D7 card loading fixed, cards now save in the game folder.
- Samurai Spirits Sen launch issue fixed, windowed mode does not work yet!
- TeknoParrotUi.exe now checks for the game folder for other emulators to prevent errors with users.
---------------------------------------------
Changes in TeknoParrot 1.20 TEST 6 Release:
- ID6 / ID7 crash fixed.
- Unbinding buttons now possible with right click.
- DirectInput no longer crashes stuff.
- Various DirectInput improvements.
---------------------------------------------
Changes in TeknoParrot 1.20 TEST Release:
- Many many internal things we forgot to add here. Sorry!
- New games supported from Taito Type X series:
* Battle Gear 4 Tuned
* Blaz Blue Calaminity Trigger
* Blaz Blue Continuum Shift
* Blaz Blue Continuum Shift II
* Chaos Breaker
* Chase HQ2
* Giga Wing Generations
* King of Fighters 98 Unlimited Match
* King of Fighters Maximum Impact Regulation A
* King of Fighters Sky Stage
* King of Fighters XII
* King of Fighters XIII
* Power Instinct 5
* Raiden III
* Raiden IV
* Samurai Spirits Sen
* Senko No Ronde Duo
* Shigami 3
* Spica Adventure
* Street Fighter IV
* Super Street Fighter IV Arcade Edition
* Super Street Fighter IV Arcade Edition Export
* Super Street Fighter IV Arcade Edition Ver. 2012
* Taisen Hot Gimmick 5
* Tetris The Grand Master 3 Terror Instinct
* Trouble Witches
* Virtua R-Limit
* Wacky Races
- Steam integration, now all your friends can see what game you are playing with TeknoParrot.
- I/O emu: New I/Os emulated in the JVS emulator.
- I/O emu: JVS Emulator now supports Taito specific commands and other strange Taito only things.
- I/O emu: com0com is no longer necessary, all JVS I/O traffic is now emulated without virtual com ports. No addional software needed!
- I/O emu: Namco specific commands JVS commands working! Tested working I/O emulation on various ES3 game dumps. No problems!
- I/O emu: Brake now work on Ford Racing
- I/O emu: Now special E0/D0 issues are handled properly.
- I/O emu: Various fixes for JVS errors.
- I/O emu: Comm modem state emulated now properly for all Namco/Taito/Sega titles.
- I/O emu: Induvidual button settings for each game, xml based. Easy to add new profiles and test emulation.
- Ring Core: Sram is now saved per game, fixing issues with non-saving test menus, various highscore savings and more.
- Ring Core: Initial D6/D7 cards are now emulated directly in the executable, rendering the need of picodaemon obsolete. This also gets rid of all errors and makes saving instant.
  NOTE: Old saves are no longer compatible.
- Ring Core: Initial D7 is now supported, no multiplayer.
- ParrotUI: Refactored UI
- ParrotUI: All config.ini settings are induvidual per game and can be set from the loader. Removing confusion what is for which game.
- ParrotUI: Windowed mode for all games now built in the emulator.
- ParrotUI: DirectInput multiple devices support, you can use as many devices as you want example: 10 keyboards, 20 joypads and 50 wheels!
- ParrotUI: Removed tons of old garbage code, fixed insane amount of bugs that caused various problems.
- ParrotUI: Separate commandline executable is no more.
- ParrotUI: Separate executable for game directory settings is no more.
- ParrotUI: You can set game directory from Game Settings in the UI.
- ParrotUI: Probably tons of more which I forgot.
- ParrotUI: Now you can run games directly from the commandline with game running or just i/o emulation mode.
  Parameters: To select game profile, use: --profile=. Example: --profile=sr3.xml
  Parameters: To run in the test mode (if supported), use: --test
  Parameters: To run game with only I/O emulation (running parrotloader.exe yourself via script for example), use: --emuonly
  EXAMPLES:
  Parameters: To run game directly from command line: TeknoParrotUi.exe --profile=sr3.xml
  Parameters: To run game directly from command line to test menu: TeknoParrotUi.exe --profile=sr3.xml --test
  Parameters: To run game I/O emulation only (still needs TeknoParrot.dll injected): TeknoParrotUi.exe --profile=sr3.xml --emuonly
  SIMPLE!
---------------------------------------------
Changes in TeknoParrot 1.06c Patreon Release:
- ID6 and ID7 card files are now separate.
NOTE: Make sure you use ID6 dir picodaemon for ID6 and ID7 dir picodaemon for ID7!!!!
      Do not use scripts that are currently around as they just use ID6 dir for both.
---------------------------------------------
Changes in TeknoParrot 1.06b Patreon Release:
- AMD Fixes for ID6 and ID7 are now integrated in the TeknoParrot.
To enable AMD fixes you need to add "EnableAmdFix=true" under [General]
<------------------------------------------->
Example config.ini for Initial D6/D7 settings:
<------------------------------------------->
[General]
DongleRegion=JAPAN
PcbRegion=JAPAN
FreePlay=1
EnableAmdFix=true
---------------------------------------------
Changes in TeknoParrot 1.06a Patreon Release:
- Experimental ID7 support, cards work but no multiplayer.
- Activation process now has more information finally printed out instead of error code number.
- Re-Activation of serial is required as there is small change in the code.
- Sega Racing Classic multiplayer support up to 4 players! JEEZ!
<------------------------------------------->
Example config.ini for Sega Racing Classic LAN settings:
<------------------------------------------->
[General]
DongleRegion=JAPAN
PcbRegion=JAPAN
FreePlay=1

[Network]
Dhcp=1
Ip=192.168.1.100
Mask=255.255.255.0
Gateway=192.168.1.1
Dns1=192.168.1.1
Dns2=0.0.0.0
BroadcastIP=192.168.1.255
Cab1IP=192.168.1.100
Cab2IP=192.168.1.101
Cab3IP=192.168.1.102
Cab4IP=192.168.1.103
---------------------------------------------
Changes in TeknoParrot 1.06 Public Build:
- Card reader emulation works again.
---------------------------------------------
Changes in TeknoParrot 1.05 Public Build:
- ID6 Pair Play! Read 1.04a notes for instructions.
- Easier mode for loaders with Ultimate ASI Loader! (https://github.com/ThirteenAG/Ultimate-ASI-Loader/releases)
How to use: 
* Instead of using ParrotLoader, you can now drag and drop "Extra_For_Loaders" content to game dir.
NOTE: Copy winmmbase.dll only with ID6 as it's needed for cards, other games are fine with dinput8.dll alone!
* Note that this does not work yet for Mouse games but will be fixed soon!
* This way you can just use DumbJvsCmd to init the JVS emulation
* After this run the game exe directly, even the card reader picodaemon.exe will work!
---------------------------------------------
Changes in TeknoParrot 1.04a Patreon Release:
- Pair Play now works in Initial D6AA.
NOTE: You may also use Hamachi, Evolve, Tunngle or other VPN to play with your friends.
      Just remember to use their IP addresses and gateway etc. not your local!
NOTE: DO NOT USE IDLOGGER OR NETWORK DOES NOT WORK!!!! Hopefully this will be fixed soon in idlogger.
<---------------How-to---------------------->
1. Go to TEST MENU, set cabinets ID to A1 and other A2.
2. If you want to use cards you can do that, remember to enable card readers and start picodaemon!
3. Once your settings are saved and each player has separate id you need to edit config.ini
<------------------------------------------->
Cab1IP is A1 cabinets IP.
Cab2IP is A2 cabinets IP.
BroadcastIP is the connections broadcast ip.
Windowed mode also now enable for NVIDIA users, so the minimap doesn't break.
<------------------------------------------->
Example config.ini with LAN settings:
<------------------------------------------->
[General]
DongleRegion=JAPAN
PcbRegion=JAPAN
FreePlay=1
Windowed=true

[Network]
Dhcp=1
Ip=192.168.1.100
Mask=255.255.255.0
Gateway=192.168.1.1
Dns1=192.168.1.1
Dns2=0.0.0.0
BroadcastIP=192.168.1.255
Cab1IP=192.168.1.100
Cab2IP=192.168.1.101
---------------------------------------------
Changes in TeknoParrot 1.04 Public Build:
- All previous Patreon build changes including card readers.
- Saving in all TEST menus should now be fixed.
---------------------------------------------
Changes in TeknoParrot 1.03b Patreon Release:
- Card reader emulator revision 2. Should fix all remaining issues!
---------------------------------------------
Changes in TeknoParrot 1.03a Patreon Release:
- To activate patreon just use register_patreon.bat that is included!
- Card readers are now supported but not tested trought out the game, any bugs you find please report asap!
- How to use card readers by running picodaemon with Parrotloader:
1. Run ParrotLoader.exe "D:\games\id6\picodaemon.exe" (Put real dir on your pc)
2. Now just run ID6 like you normally would, with card readers turned ON from the TEST MENU.
   If you are UNSURE how to enable card readers, just delete %appdata%\TeknoParrot\SBUU_e2prom.bin in case it exists.
3. Enjoy!!!!
Card file is saved to: %appdata%\TeknoParrot\SBUU_card.bin
Special thanks for NTA and Avail for porting Reaver C# code to C++.
---------------------------------------------
Changes in TeknoParrot 1.03 Public Build:
- Virtua Tennis 4 is always now Full HD instead of VGA.
- EEPROM handling upgraded and CRCs are properly calculated for the backup section.
- Fixed Sonic All-Stars Racing missing api hooks and added direct network hooks. Should not crash anymore.
- Chaos Code does not cause JVS errors anymore.
- Sega Rally 3 / Ford Racing no longer cause the loader to stay in the background nor does it cause the loader to crash.
- Fixed Golden Gun Support for XInput.
- Fixed major lag with mouse support.
- DumbJvsSettings is now fixed to draw correctly.
- Disabled mouse from DumbJvsCmd as it doesn't work properly.
- Operation G.H.O.S.T is now supported, Button2, Button 3 and Button 4 from Gamepad buttons is used for the extra gun buttons when playing with direct input / xinput.
  NOTE: EnableJvs=1 and EnableAMLib=1 need to be in gs2.ini or it will not work with Gamepads.
  NOTE: MOUSE control is broken, use the official 1 player mouse support by editing gs2.ini and change: EnableJvs=0 and EnableAMLib=0 and it should work.
  The game features full LUA debugger, this makes it possible for you to make own levels etc!
---------------------------------------------
Changes in TeknoParrot 1.02 Public Build:
- Added support for Chaos Code, if you have problems running it:
Edit: ChaosCode.ini and edit fScreenMode=1 to fScreenMode=0
NOTE: This game has some serious problems with modern operating systems.
---------------------------------------------
Changes in TeknoParrot 1.01 Public Build:
- Pile of internal fixes/features added
- DumbJvsCmd now supports all the same inputs as the UI
- Golden Gun now works and no longer crashes when entering credits via service.
- Initial D6 not working on some systems has been fixed.
- Dream Raiders now works.
- Let's Go Island now works and is run on Standard mode by default.
  (On demand we can add Deluxe option in ini)
- EEPROM files are now saved in %appdata%\TeknoParrot\
- Sega Rally 3 View Change and Handbrake should no longer be swapped.
---------------------------------------------
Changes in TeknoParrot 1.0 Public Build:
- Complete recode of the entire DLL.
- Initial D6 stability fixes
- Sega Sonic All-Stars Racing Arcade test menu supported.
- Golden Gun Test menu supported.
- Virtua Tennis 4 saving issues fixed.
- Fixed missing amLib hooks from certain games which caused issues.
- Melty Blood Actress Again Current Code (1.00 and 1.07) random crashes fixed.
- Sega Rally 3 / Ford Racing bindable buttons for DirectInput and XInput
- Major JVS emulation improvements and bug fixes.
- Namco JVS stack now supported for Namco games in future.
- x64 support for x64 games supported near future.
- Major improvements in RingEdge emulation:
* Dipswitches are now emulated.
* EEPROM now mapped and structured.
* Game data section of EEPROM now is saved on the game folder for players to make save hacks.
* Physical PCB Test / Service switches are now emulated.
* config.ini now lets you set various hardware settings for RingWide/RingEdge games.
* NOTE: NETWORKING DOES NOT FUNCTION YET FOR RING GAMES!!!!
---------------------------------------------
Changes in TeknoParrot 0.8c Patreon Release:
- Sega Rally 3 supported!
NOTE: NTAuthority is on a roll!
NOTE: Remember to enable free play from ..\ShellData\ShellData.ini
[Credit]
Freeplay=1

NOTE: To play linked in LAN, enable it by editing:
[Network]
CabinetID=1
Enabled=1
If you are player one you are CabinetID=1, if you are player 2 use CabinetID=2 etc.

NOTE: To change language, speed meter, difficulty etc. Edit ..\ShellData\GameSettings.ini
NOTE: Usable values you can find from ..\ShellData\Game.ini
---------------------------------------------
Changes in TeknoParrot 0.8b Patreon Release:
- Fixed issues with Ford Racing, make sure you have ..\data\ dir existing with gamesetting.ini etc!
---------------------------------------------
Changes in TeknoParrot 0.8a Patreon Release:
- Thanks to NTAuthority's superior skills first game of Sega Europa-R is now supported!
- Ford Racing support!!!!
- Only works currently with XInput with hardcoded buttons.
- The code was assimilated to TeknoParrot very fast so expect bugs!
NOTE: More Europa-R support coming your way soon! choo choo
---------------------------------------------
Changes in TeknoParrot 0.8 Public Build:
- Includes all Patreon changes.
- Initial D6AA initialization fixed as amNetwork is emulated for upcoming multiplayer update!
---------------------------------------------
Changes in TeknoParrot 0.71d Patreon Release:
- Internal region change support (dongle and PCB). Will be selectable later.
- PCB ID now autogenerated and bound to computer name like dongle serial.
- amNetwork link emulated, I cannot guarantee link working. Sega Racing Classic should work tho.
NOTE: Please test and use wireshark to see if there are problems.
- Thanks to amNetwork emulation Sega Sonic All-Stars Racing attract mode works normally.
---------------------------------------------
Changes in TeknoParrot 0.71c Patreon Release:
- Support for Melty Blood AA CC 1.07.
---------------------------------------------
Changes in TeknoParrot 0.71b Patreon Release:
- Fixed issues with Windows 7 activation.
---------------------------------------------
Changes in TeknoParrot 0.71a Patreon Release:
- Keychip ID is now unique to each PC (Based on PC name)
- Core improvements and bug fixes.
- Golden Gun is now emulated (test menu is not working atm).
NOTE: Do not press TEST as it crashes the game.
NOTE: To get credits press SERVICE, they are unlimited.
---------------------------------------------
Changes in TeknoParrot 0.71 Public Build:
- XInput now supported, will fix compatibility with Xbox One controllers.
- Steering fixed for Sonic (DirectInput and XInput). No more left pull.
- XInput also has separate triggers for drifting in Sonic!
- With XInput left and right trigger can be used to shoot in shooting games.
- sto0z fix now applies to Initial D6AA also.
---------------------------------------------
Changes in TeknoParrot 0.7 Public Build:
- Initial D6AA experimental support, happy midsummer guys!
It has some problems: test menu doesn't work, jvs i/o can jam etc.
---------------------------------------------
Changes in TeknoParrot 0.6 Public Build:
- Since VMPSoft cannot code a decent software and Dream Raiders work ok, this is now public.
- See you later this week with Initial D6AA ;-)
---------------------------------------------
Changes in TeknoParrot 0.54a Patreon Build:
- Experimental support for Sega Dream Raiders
- NOTE: You need to patch the PE header so it loads always on ImageBase 0x400000.
- I tried on various OS and some always had problem when ImageBase was non-standard.
- So for maximum compatibility just patch the PE header one time and play.
- NOTE: Enter test menu first to disable motion, blower and controller feedback!
- For mouse mode now Service and Test works with normal keymap! (numbers: 8 9 0)
- New serial system for Patrons, very easy to use.
- Fixed bugs in ParrotLoader where it would crash when wrong dir was entered.
- Included register.bat for easy patron serial registration.
- Fixed a bug where settings.tg would get sometimes saved in multiple folders.
---------------------------------------------
Changes TeknoParrot 0.54 Public Build:
- Fixed issue with Let's Go Island where with mouse the gun trigger and start would get stuck.
---------------------------------------------
Changes TeknoParrot 0.53 Public Build:
- Fixed crash issues with keyboard by removing experimental driving code with keyboard.
- You can now play Let's Go Island with mouse! Left click shoot, right click start. Cursor is hooked to the window.
- Please use DXWND to hide the cursor from the screen (there is option for this in Input)
- If Let's Go Island crashes please use dxwnd to set windowed and resolution to 1024x600 (or bigger)
- If you want to play full screen, create custom resolution from your graphics card control panel (not TeknoParrot!)
- 2nd player can still play with the gamepad with you :-)
---------------------------------------------
Changes TeknoParrot 0.52 Public Build:
- Fixed a bug in Full Axis steering.
- Fixed bug in gas and brake where they would get stuck.
- Fixed bug in gas and brake where they would mix up badly.
- Fixed a bug where brake would not zero completely even if you let go of it.
---------------------------------------------
Changes TeknoParrot 0.51 Public Build:
- Fixed a bug where joystick controls wouldn't work when not all joystick buttons weren't mapped.
- Fixed a bug where you could enter joystick mapping without setting a joystick.
- Added multiplier for Gun Cursor (Gun Multiplier in mapping) to make cursor move faster.
- Added support for reverse axis for wheels with reverse axis on Gas and Brake.
- Keyboard steering adding, very experimental.
---------------------------------------------
Changes TeknoParrot 0.5 Public Build:
- All Patreon changes, THANKS TO ALL PATREONS!!!!! We will see you in 0.5a.
- Fully customizable joystick controls, including wheel and pedals.
- Unique bindable buttons for special things like: Sonic Item, Sega Racing Classic Gears/View Changes and Gun Trigger / Gun Controls.
- Recoded most of the DirectInput listener, now code is much more easier to maintain and easier to read.
- Fixed TONS of bugs around the program.
- All test menus now should function correctly. (Except Sega Sonic, will be coming a bit later.)
- Controls are now much more fluid
- Let's Go Island also has normal functionality even with 2 players. (Before was double speed)
- Recode Let's Go Island control handling.
- Sega Racing Classic Gears now work by just pushing button instead of holding.
- Added about box with Tekno Colonel Patreon names. Thanks guys!
- Fixed major bug in JVS that caused jerky controls in Sega Racing Classic, now no more sto0z improvements needed!
---------------------------------------------
Changes TeknoParrot 0.4b Patreon Build:
- Added support for Sega Sonic All-Stars Racing Arcade (test menu not functional yet)
- Fixed lot of bugs in JVS Emulation
- Added some custom commands for Namco games
- new APIs emulated and improved.
---------------------------------------------
Changes TeknoParrot 0.4a Patreon Build:
- Fixed some core issues
- Let's Go Island now playable with 2 controllers
- Added new profile for Let's Go Island
- Core work done for RingEdge 2 support, currently disabled. (amAuth emulation)
- Fixed some emulation issues with previous games (just cleaner emulation)
- amNetwork emulation improvements, netplay coming soon!
- Updated SharpDX and SharpDX.DirectInput
- Fixed DumbJvsCmd, now it takes game profile as command line parameter. Run to see params.
---------------------------------------------
Changes TeknoParrot 0.4 Hotfix:
- Steering now works again, one package was emulated wrong. Check Github for more.
- Sega Racing Classics steering now works properly.
- Unit tests fixed for emulation as well.
- All Direct Input devices are now detected except normal Keyboard and Mouse.
---------------------------------------------
Changes TeknoParrot 0.4:
- Preliminary support for Sega Sonic All-Stars Racing (disabled until more testing)
- Rewritten JVS emulator to support multi packages
- Wrote unit tests for many JVS packages and variations.
- Now all JVS I/O errors should be eliminated. (If you get package errors please contact me!)
- Keyboard remapper with saved keys
- Stability fixes in the emulator core
- Steering Wheels / Flight sticks are now identified to the joystick menu
- When you close DumbJvsManager from X it no longer stays in the background.
- Commandline mode for JVS only.
- Melty Blood Actress Again Current Code no longer crashes with certain characters.
NOTE: This was not because of the emulator but because of the differences between WinXP and newer windows.
---------------------------------------------
Changes TeknoParrot 0.3:
- Sega Racing Classic supported! (DO NOT ENABLE NETWORK OR IT WILL FREEZE FOREVER, missing network emu code)
- Test menu now works for all games. (YES this includes saving settings)
- Completely recoded DumbJvsBrain and now it's called DumbJvsManager
- Full UI interface and no more needing to use command line at all.
- Easy to setup joysticks from list, once saved they will be remembered.
- Keyboard support, only uses keyboard for that player that has "No joystick selected"
- com0com now get automatically set when user presses "Auto setup JVS emulation ports" (admin required)
- It even has button to test the jvs emulation ports.
- Added 3 unit tests for JVS emulator, more to come later
- Refactored all code and moved all common items to DumbsJvs.Common
- So if people can want to make own launchers it's easier to use only the dll. (DumbJvs.Common)
- Improved JVS emulation code a little bit.
- Games can now be directly set in the launcher and launched from the launcher easily. (Commandline coming later)
- Jvs emulation is only present when game is running, once game exists it also exists.
- Emulator now reroutes game COM4 to COM13 instead to avoid conflics.
- Emulator core improvements.
- Pressing ESC now quits the game.
---------------------------------------------
Changes TeknoParrot 0.2:
- Core fixes
- Melty Blood Actress Againt Current Code supported!
---------------------------------------------
Changes in OpenParrot / TeknoParrotUI: https://github.com/teknogods
---------------------------------------------
==Requirements==
- .NET 4.5.2
- Dumped arcade game files

==Support==
This release is beta quality. If something breaks, review any
pertinent comments on teknogods.com, then email me as a last resort.
Include all log files and a detailed description of problem and
how to reproduce it.

==Thanks==
Our community of course! :)
King of Spain for his life time of work with the arcades.
MAME crew
Anyone else I forgot to mention whose work has helped me in the past and the future.

Enjoy.
 /\Reaver <reaver@teknogods.com>
/oo\NTAuthority <bas@dotbas.net>
/||\avail <avail@pomf.se>
\>>/OpenParrot Community
Questions or comments are welcomed.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.