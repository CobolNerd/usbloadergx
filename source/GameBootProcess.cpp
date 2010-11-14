#include "menu/menus.h"
#include "mload/mload.h"
#include "mload/mload_modules.h"
#include "system/IosLoader.h"
#include "usbloader/disc.h"
#include "usbloader/apploader.h"
#include "usbloader/wdvd.h"
#include "usbloader/GameList.h"
#include "settings/Settings.h"
#include "settings/CGameSettings.h"
#include "usbloader/frag.h"
#include "usbloader/wbfs.h"
#include "settings/newtitles.h"
#include "patches/fst.h"
#include "patches/gamepatches.h"
#include "patches/wip.h"
#include "system/IosLoader.h"
#include "wad/nandtitle.h"
#include "menu/menus.h"
#include "memory/memory.h"
#include "fatmounter.h"
#include "FontSystem.h"
#include "sys.h"

//appentrypoint has to be global because of asm
u32 AppEntrypoint = 0;

struct discHdr *dvdheader = NULL;
extern int load_from_fs;
extern int mountMethod;


static u32 BootPartition(char * dolpath, u8 videoselected, u8 languageChoice, u8 cheat, u8 vipatch, u8 patchcountrystring,
	u8 alternatedol, u32 alternatedoloffset, u32 returnTo, u8 fix002)
{
    gprintf("booting partition IOS %u v%u\n", IOS_GetVersion(), IOS_GetRevision());
    entry_point p_entry;
    s32 ret;
    u64 offset;

    /* Find game partition offset */
    ret = __Disc_FindPartition(&offset);
    if (ret < 0)
        return 0;

    /* Open specified partition */
    ret = WDVD_OpenPartition(offset);
    if (ret < 0)
        return 0;

    load_wip_code((u8*) Disc_ID);

    /* If a wip file is loaded for this game this does nothing - Dimok */
    PoPPatch();

    /* Setup low memory */
    __Disc_SetLowMem();

    /* Run apploader */
    ret = Apploader_Run(&p_entry, dolpath, cheat, videoselected, languageChoice, vipatch, patchcountrystring,
            alternatedol, alternatedoloffset, returnTo, fix002);

    if (ret < 0)
        return 0;

    free_wip();

    return (u32) p_entry;
}

int BootGame(const char * gameID)
{
    if(!gameID || strlen(gameID) < 3)
        return -1;

    if (mountMethod == 3)
    {
        ExitApp();
        struct discHdr *header = gameList.GetDiscHeader(gameID);
        u32 tid;
        memcpy(&tid, header->id, 4);
        gprintf("\nBooting title %016llx", TITLE_ID( ( header->id[5] == '1' ? 0x00010001 : 0x00010002 ), tid ));
        WII_Initialize();
        return WII_LaunchTitle(TITLE_ID( ( header->id[5] == '1' ? 0x00010001 : 0x00010002 ), tid ));
    }
    if (mountMethod == 2)
    {
        ExitApp();
        gprintf("\nLoading BC for GameCube");
        WII_Initialize();
        return WII_LaunchTitle(0x0000000100000100ULL);
    }

    AppCleanUp();

    gprintf("\tSettings.partition: %d\n", Settings.partition);

    gameList.LoadUnfiltered();

    struct discHdr *header = gameList.GetDiscHeader(gameID);
    if(!header)
    {
        gprintf("Game was not found: %s\n", gameID);
        return -1;
    }

    int ret = 0;
    header = (mountMethod ? dvdheader : header);

    u8 videoChoice = Settings.videomode;
    u8 languageChoice = Settings.language;
    u8 ocarinaChoice = Settings.ocarina;
    u8 viChoice = Settings.videopatch;
    u8 iosChoice = Settings.cios;
    u8 fix002 = Settings.error002;
    u8 countrystrings = Settings.patchcountrystrings;
    u8 alternatedol = OFF;
    u32 alternatedoloffset = 0;
    u8 reloadblock = OFF;
    u8 returnToLoaderGV = 1;

    GameCFG * game_cfg = GameSettings.GetGameCFG(header->id);

    if (game_cfg)
    {
        videoChoice = game_cfg->video;
        languageChoice = game_cfg->language;
        ocarinaChoice = game_cfg->ocarina;
        viChoice = game_cfg->vipatch;
        fix002 = game_cfg->errorfix002;
        iosChoice = game_cfg->ios;
        countrystrings = game_cfg->patchcountrystrings;
        alternatedol = game_cfg->loadalternatedol;
        alternatedoloffset = game_cfg->alternatedolstart;
        reloadblock = game_cfg->iosreloadblock;
        returnToLoaderGV = game_cfg->returnTo;
    }

    if(iosChoice != IOS_GetVersion())
    {
        gprintf("Reloading into game cIOS: %i...\n", iosChoice);
        IosLoader::LoadGameCios(iosChoice);
        if(MountGamePartition(false) < 0)
            return -1;
    }

    if (!mountMethod)
    {
        gprintf("Loading fragment list...");
        ret = get_frag_list(header->id);
        gprintf("%d\n", ret);

        ret = Disc_SetUSB(header->id);
        if (ret < 0) Sys_BackToLoader();
        gprintf("\tUSB set to game\n");
    }
    else
    {
        gprintf("\tUSB not set, loading DVD\n");
    }

    gprintf("Disc_Open()...");
    ret = Disc_Open();
    gprintf("%d\n", ret);

    if (ret < 0)
        Sys_BackToLoader();

    if (dvdheader) delete dvdheader;

    gprintf("Loading BCA data...");
    ret = do_bca_code(header->id);
    gprintf("%d\n", ret);

    if (reloadblock == ON && IosLoader::IsHermesIOS())
    {
        enable_ES_ioctlv_vector();
        if (load_from_fs == PART_FS_WBFS)
        {
            mload_close();
        }
    }

    u32 channel = 0;
    if (returnToLoaderGV)
    {
        int idx = NandTitles.FindU32(Settings.returnTo);
        if (idx >= 0) channel = TITLE_LOWER( NandTitles.At( idx ) );
    }

    //This is temporary
    SetCheatFilepath(Settings.Cheatcodespath);
    SetBCAFilepath(Settings.BcaCodepath);

    gprintf("\tDisc_wiiBoot\n");

    /* Boot partition */
    AppEntrypoint = BootPartition(Settings.dolpath, videoChoice, languageChoice, ocarinaChoice, viChoice, countrystrings,
                        alternatedol, alternatedoloffset, channel, fix002);

    if(AppEntrypoint != 0)
    {
        bool enablecheat = false;

        if (ocarinaChoice)
        {
            // OCARINA STUFF - FISHEARS
            if (ocarina_load_code((u8 *) Disc_ID) > 0)
            {
                ocarina_do_code();
                enablecheat = true;
            }
        }

        shadow_mload();
        UnmountNTFS();
        SDCard_deInit();
        USBDevice_deInit();

        gprintf("Jumping to game entrypoint: 0x%08X.\n", AppEntrypoint);

        return Disc_JumpToEntrypoint(videoChoice, enablecheat);
    }

    WDVD_ClosePartition();

    return -1;
}