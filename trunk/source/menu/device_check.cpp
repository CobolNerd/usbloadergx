#include <dirent.h>
#include <unistd.h>

#include "gecko.h"
#include "menus.h"
#include "wpad.h"
#include "fatmounter.h"
#include "usbloader/getentries.h"
#include "usbloader/wbfs.h"

extern int load_from_fs;
extern char game_partition[6];

static lwp_t checkthread = LWP_THREAD_NULL;
static bool checkHalt = false;
static bool ExitRequested = false;
static u8 sdState =0;
u8 hddState = 0;
u8 checkthreadState = 0;
bool ScreenshotTriggered = false;

extern u8 shutdown;
extern u8 reset;

void ResumeCheck()
{
    checkHalt = false;
    LWP_ResumeThread(checkthread);
}

void HaltCheck()
{
    if(checkHalt)
        return;

    checkHalt = true;

    while (!LWP_ThreadIsSuspended(checkthread))
        usleep(50);
}

void ReloadHDD_Settings()
{
    if(strstr(bootDevice, "USB:") != 0)
    {
        CFG_Load();
        int ios = 249;
        switch(Settings.cios)
        {
            case ios249:
                ios = 249;
                break;
            case ios222:
                ios = 222;
                break;
            case ios250:
                ios = 250;
                break;
        }
        if(ios != IOS_GetVersion())
            Sys_ChangeIos(ios);
    }
    if(strstr(Settings.ogg_path, "USB:/") != 0)
    {
        bgMusic->Load(Settings.ogg_path);
        bgMusic->Play();
    }

    // open database if available, load titles if needed
    OpenXMLDatabase(Settings.titlestxt_path,Settings.db_language, Settings.db_JPtoEN, true, Settings.titlesOverride == 1 ? true: false, true);
}

int CheckPartition()
{
    s32 ret2 = -1;
    memset(game_partition, 0, 6);
    load_from_fs = -1;

    extern PartList partitions;
    // Added for slow HDD
    for (int runs = 0; runs < 10; runs++)
    {
        if (Partition_GetList(WBFS_DEVICE_USB, &partitions) != 0)
            continue;

        if (Settings.partition != -1 && partitions.num > Settings.partition)
        {
            PartInfo pinfo = partitions.pinfo[Settings.partition];
            if (WBFS_OpenPart(pinfo.part_fs, pinfo.index, partitions.pentry[Settings.partition].sector, partitions.pentry[Settings.partition].size, (char *) &game_partition) == 0)
            {
                ret2 = 0;
                load_from_fs = pinfo.part_fs;
                break;
            }
        }

        if (partitions.wbfs_n != 0)
        {
            ret2 = WBFS_Open();
            for (int p = 0; p < partitions.num; p++)
            {
                if (partitions.pinfo[p].fs_type == FS_TYPE_WBFS)
                {
                    Settings.partition = p;
                    load_from_fs = PART_FS_WBFS;
                    break;
                }
            }
        }

        else if (Sys_IsHermes() && (partitions.fat_n != 0 || partitions.ntfs_n != 0))
        {
            // Loop through FAT/NTFS partitions, and find the first partition with games on it (if there is one)
            u32 count;
            for (int i = 0; i < partitions.num; i++)
            {
                if (partitions.pinfo[i].fs_type == FS_TYPE_FAT32 || partitions.pinfo[i].fs_type == FS_TYPE_NTFS)
                {
                    if (!WBFS_OpenPart(partitions.pinfo[i].part_fs, partitions.pinfo[i].index, partitions.pentry[i].sector, partitions.pentry[i].size, (char *) &game_partition))
                    {
                        // Get the game count...
                        WBFS_GetCount(&count);
                        if (count > 0)
                        {
                            load_from_fs = partitions.pinfo[i].part_fs;
                            Settings.partition = i;
                            break;
                        }
                        else
                        {
                            WBFS_Close();
                        }
                    }
                }
            }
        }

        if ((ret2 >= 0 || load_from_fs != PART_FS_WBFS) && isInserted(bootDevice))
        {
            cfg_save_global();
            break;
        }
    }

    if (ret2 < 0 && load_from_fs != PART_FS_WBFS)
        return -1;

    ret2 = Disc_Init();
    if (ret2 < 0)
        return ret2;

    hddState = 1;

    return hddState;
}

int CheckHDD()
{
    USBDevice_deInit();
    USBDevice_Init();

    int wbfsinit = WBFS_Init(WBFS_DEVICE_USB);

    if (wbfsinit >= 0)
        wbfsinit = CheckPartition();

    return wbfsinit;
}

static void * CheckDevices (void *arg)
{
    sdState = isInserted(bootDevice);
    while (!ExitRequested)
    {
        if (checkHalt && !ExitRequested)
        {
            LWP_SuspendThread(checkthread);
            continue;
        }

		if (shutdown == 1)
			Sys_Shutdown();

		else if (reset == 1)
			Sys_Reboot();

        if (!hddState)
        {
            if(CheckHDD() >= 0)
            {
                LWP_SetThreadPriority(LWP_GetSelf(), 0);

                ReloadHDD_Settings();

                checkthreadState = 1;
            }
        }

        //this really doesnt work right.  it seems that isInserted() isn't what it should be.
        int sdNow = isInserted(bootDevice);
        if (sdState != sdNow)
        {
            sdState = sdNow;
            checkthreadState = 2;
        }

        if(ScreenshotTriggered)
        {
            gprintf("\n\tscreenShotBtn clicked");
            ScreenShot();
            ScreenshotTriggered = false;
            gprintf("...It's easy, mmmmmmKay");
        }

        usleep(20000);
    }

    return NULL;
}

void InitCheckThread()
{
    LWP_CreateThread(&checkthread, CheckDevices, NULL, NULL, 0, 30);
}

void ExitCheckThread()
{
    ExitRequested = true;
    LWP_ResumeThread(checkthread);
    LWP_JoinThread(checkthread, NULL);
    checkthread = LWP_THREAD_NULL;
}
