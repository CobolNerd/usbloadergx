/****************************************************************************
 * PromptWindows
 * USB Loader GX 2009
 *
 * PromptWindows.h
 ***************************************************************************/

#ifndef _PROMPTWINDOWS_H_
#define _PROMPTWINDOWS_H_

#include "usbloader/partition.h"
#define NOTFULLCHANNEL

int WindowPrompt(const char *title, const char *msg = NULL, const char *btn1Label = NULL,
                const char *btn2Label = NULL, const char *btn3Label = NULL,
                const char *btn4Label = NULL, int wait = -1);

void WindowCredits();
int OnScreenKeyboard(char * var, u32 maxlen, int min);
int WindowExitPrompt(const char *title, const char *msg, const char *btn1Label, const char *btn2Label, const char *btn3Label, const char *btn4Label);
int GameWindowPrompt();
int DiscWait(const char *title, const char *msg, const char *btn1Label, const char *btn2Label, int IsDeviceWait);
int FormatingPartition(const char *title, partitionEntry *entry);
void SearchMissingImages(int choice2);
int ProgressDownloadWindow(int choice2);
int ProgressUpdateWindow();
char * GetMissingFiles();
int WindowScreensaver();
int CodeDownload(const char *id);
void GetLanguageToLangCode(char *langcode);
int HBCWindowPrompt(const char *name, const char *coder, const char *version,
                const char *release_date, const char *long_description, 
					 const char *iconPath, const char *filesize);


#endif