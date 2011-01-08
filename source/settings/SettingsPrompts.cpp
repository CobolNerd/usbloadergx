#include <gccore.h>
#include <unistd.h>
#include <string.h>

#include "language/gettext.h"
#include "language/UpdateLanguage.h"
#include "prompts/PromptWindows.h"
#include "prompts/ProgressWindow.h"
#include "libwiigui/gui.h"
#include "libwiigui/gui_customoptionbrowser.h"
#include "settings/CSettings.h"
#include "settings/GameTitles.h"
#include "themes/CTheme.h"
#include "network/URL_List.h"
#include "FileOperations/fileops.h"
#include "FileOperations/DirList.h"
#include "main.h"
#include "prompts/filebrowser.h"
#include "sys.h"
#include "menu/menus.h"

/*** Extern variables ***/
extern u8 shutdown;
extern u8 reset;


/****************************************************************************
 * MenuOGG
 ***************************************************************************/
bool MenuBackgroundMusic()
{
    bool ret = false;
    char entered[1024];
    int result = -1;
    snprintf( entered, sizeof( entered ), "%s", Settings.ogg_path );

    if ( strcmp( entered, "" ) == 0 )
    {
        sprintf( entered, "%s", Settings.BootDevice );
    }
    else
    {
        char * pathptr = strrchr( entered, '/' );
        if ( pathptr )
        {
            pathptr++;
            int choice = WindowPrompt( tr( "Playing Music:" ), pathptr, tr( "Play Previous" ), tr( "Play Next" ), tr( "Change Play Path" ), tr( "Cancel" ) );
            if ( choice == 1 )
            {
                return bgMusic->PlayPrevious();
            }
            else if ( choice == 2 )
            {
                return bgMusic->PlayNext();
            }
            else if ( choice == 3 )
            {
                pathptr[0] = 0;
            }
            else
                return true;
        }
        else
            sprintf( entered, "%s", Settings.BootDevice );
    }

    result = BrowseDevice( entered, sizeof( entered ), FB_DEFAULT );

    if ( result )
    {
        if ( !bgMusic->Load( entered ) )
        {
            WindowPrompt( tr( "Not supported format!" ), tr( "Loading standard music." ), tr( "OK" ) );
        }
        else
            ret = true;
        bgMusic->Play();
        bgMusic->SetVolume( Settings.volume );
    }

    return ret;
}

/****************************************************************************
 * MenuLanguageSelect
 ***************************************************************************/
int MenuLanguageSelect()
{
    int cnt = 0;
    int ret = 0, choice = 0;
    int returnhere = 0;
    char OldLangCode[10];
    snprintf(OldLangCode, sizeof(OldLangCode), Settings.db_language);

    GuiImageData btnOutline(Resources::GetFile("button_dialogue_box.png"), Resources::GetFileSize("button_dialogue_box.png"));
    GuiImageData settingsbg(Resources::GetFile("settings_background.png"), Resources::GetFileSize("settings_background.png"));

    GuiTrigger trigA;
    trigA.SetSimpleTrigger( -1, WPAD_BUTTON_A | WPAD_CLASSIC_BUTTON_A, PAD_BUTTON_A );
    GuiTrigger trigB;
    trigB.SetButtonOnlyTrigger( -1, WPAD_BUTTON_B | WPAD_CLASSIC_BUTTON_B, PAD_BUTTON_B );

    char fullpath[100];
    DirList Dir(Settings.languagefiles_path, ".lang");

    if ( !strcmp( "", Settings.language_path ) )
    {
        sprintf( fullpath, "%s", tr( "Default" ) );
    }
    else
    {
        sprintf( fullpath, "%s", Settings.languagefiles_path );
    }

    GuiText titleTxt( fullpath, 24, ( GXColor ) {0, 0, 0, 255} );
    titleTxt.SetAlignment( ALIGN_CENTRE, ALIGN_MIDDLE );
    titleTxt.SetPosition( 0, 0 );
    GuiButton pathBtn( 300, 50 );
    pathBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    pathBtn.SetPosition( 0, 28 );
    pathBtn.SetLabel( &titleTxt );
    pathBtn.SetSoundOver( btnSoundOver );
    pathBtn.SetSoundClick( btnSoundClick2 );
    pathBtn.SetTrigger( &trigA );
    pathBtn.SetEffectGrow();

    GuiImage oggmenubackground( &settingsbg );
    oggmenubackground.SetAlignment( ALIGN_LEFT, ALIGN_TOP );
    oggmenubackground.SetPosition( 0, 0 );

    GuiText backBtnTxt( tr( "Back" ) , 22, thColor("r=0 g=0 b=0 a=255 - prompt windows text color"));
    backBtnTxt.SetMaxWidth( btnOutline.GetWidth() - 30 );
    GuiImage backBtnImg( &btnOutline );
    if ( Settings.wsprompt == ON )
    {
        backBtnTxt.SetWidescreen( Settings.widescreen );
        backBtnImg.SetWidescreen( Settings.widescreen );
    }
    GuiButton backBtn( btnOutline.GetWidth(), btnOutline.GetHeight() );
    backBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    backBtn.SetPosition( -190, 400 );
    backBtn.SetLabel( &backBtnTxt );
    backBtn.SetImage( &backBtnImg );
    backBtn.SetSoundOver( btnSoundOver );
    backBtn.SetSoundClick( btnSoundClick2 );
    backBtn.SetTrigger( &trigA );
    backBtn.SetTrigger( &trigB );
    backBtn.SetEffectGrow();

    GuiText defaultBtnTxt( tr( "Default" ) , 22, thColor("r=0 g=0 b=0 a=255 - prompt windows text color"));
    defaultBtnTxt.SetMaxWidth( btnOutline.GetWidth() - 30 );
    GuiImage defaultBtnImg( &btnOutline );
    if ( Settings.wsprompt == ON )
    {
        defaultBtnTxt.SetWidescreen( Settings.widescreen );
        defaultBtnImg.SetWidescreen( Settings.widescreen );
    }
    GuiButton defaultBtn( btnOutline.GetWidth(), btnOutline.GetHeight() );
    defaultBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    defaultBtn.SetPosition( 190, 400 );
    defaultBtn.SetLabel( &defaultBtnTxt );
    defaultBtn.SetImage( &defaultBtnImg );
    defaultBtn.SetSoundOver( btnSoundOver );
    defaultBtn.SetSoundClick( btnSoundClick2 );
    defaultBtn.SetTrigger( &trigA );
    defaultBtn.SetEffectGrow();

    GuiText updateBtnTxt( tr( "Update Files" ) , 22, thColor("r=0 g=0 b=0 a=255 - prompt windows text color"));
    updateBtnTxt.SetMaxWidth( btnOutline.GetWidth() - 30 );
    GuiImage updateBtnImg( &btnOutline );
    if ( Settings.wsprompt == ON )
    {
        updateBtnTxt.SetWidescreen( Settings.widescreen );
        updateBtnImg.SetWidescreen( Settings.widescreen );
    }
    GuiButton updateBtn( btnOutline.GetWidth(), btnOutline.GetHeight() );
    updateBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    updateBtn.SetPosition( 0, 400 );
    updateBtn.SetLabel( &updateBtnTxt );
    updateBtn.SetImage( &updateBtnImg );
    updateBtn.SetSoundOver( btnSoundOver );
    updateBtn.SetSoundClick( btnSoundClick2 );
    updateBtn.SetTrigger( &trigA );
    updateBtn.SetEffectGrow();

    OptionList options2;

    for ( cnt = 0; cnt < Dir.GetFilecount(); cnt++ )
    {
        char filename[64];
        strlcpy( filename, Dir.GetFilename( cnt ), sizeof( filename ) );
        char *dot = strchr( filename, '.' );
        if ( dot ) *dot = '\0';
        options2.SetName( cnt, "%s", filename );
        options2.SetValue( cnt, NULL );

    }

    GuiCustomOptionBrowser optionBrowser4( 396, 280, &options2, "bg_options_settings.png");
    optionBrowser4.SetPosition( 0, 90 );
    optionBrowser4.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );

    HaltGui();
    GuiWindow w( screenwidth, screenheight );
    w.Append( &oggmenubackground );
    w.Append( &pathBtn );
    w.Append( &backBtn );
    w.Append( &defaultBtn );
    w.Append( &updateBtn );
    w.Append( &optionBrowser4 );
    mainWindow->Append( &w );

    w.SetEffect( EFFECT_FADE, 20 );
    ResumeGui();

    while ( w.GetEffect() > 0 ) usleep( 50 );

    while ( !returnhere )
    {
		usleep(100);

        if ( shutdown == 1 )
            Sys_Shutdown();
        else if ( reset == 1 )
            Sys_Reboot();

        else if ( backBtn.GetState() == STATE_CLICKED )
        {
            backBtn.ResetState();
            break;
        }

        else if ( defaultBtn.GetState() == STATE_CLICKED )
        {
            choice = WindowPrompt( tr( "Loading standard language." ), 0, tr( "OK" ), tr( "Cancel" ) );
            if ( choice == 1 )
            {
                Settings.LoadLanguage(NULL, CONSOLE_DEFAULT);
                Settings.Save();
                returnhere = 2;
            }
            defaultBtn.ResetState();
            //optionBrowser4.SetFocus(1); // commented out to prevent crash
        }

        else if ( updateBtn.GetState() == STATE_CLICKED )
        {
            choice = WindowPrompt( tr( "Update all Language Files" ), tr( "Do you wish to update/download all language files?" ), tr( "OK" ), tr( "Cancel" ) );
            if ( choice == 1 )
            {
                if (IsNetworkInit() || NetworkInitPrompt())
                {
                    if(DownloadAllLanguageFiles() > 0)
                        WindowPrompt(tr("Update successfull"), 0, tr("OK"));
                    returnhere = 1;
                    break;
                }
            }
            updateBtn.ResetState();
            //optionBrowser4.SetFocus(1); // commented out to prevent crash
        }

        else if ( pathBtn.GetState() == STATE_CLICKED )
        {
            w.Remove( &optionBrowser4 );
            w.Remove( &backBtn );
            w.Remove( &pathBtn );
            w.Remove( &defaultBtn );
            char entered[43] = "";
            strlcpy( entered, Settings.languagefiles_path, sizeof( entered ) );
            int result = OnScreenKeyboard( entered, 43, 0 );
            w.Append( &optionBrowser4 );
            w.Append( &pathBtn );
            w.Append( &backBtn );
            w.Append( &defaultBtn );
            if (result == 1)
            {
                if (entered[strlen(entered)-1] != '/')
                    strcat (entered, "/");
                snprintf(Settings.languagefiles_path, sizeof(Settings.languagefiles_path), entered);
                WindowPrompt(tr("Languagepath changed."), 0, tr("OK"));
            }
            if ( Dir.GetFilecount() > 0 )
            {
                optionBrowser4.SetFocus( 1 );
            }
            pathBtn.ResetState();
        }

        ret = optionBrowser4.GetClickedOption();

        if (ret >= 0)
        {
            choice = WindowPrompt( tr( "Do you want to change language?" ), 0, tr( "Yes" ), tr( "Cancel" ) );
            if (choice == 1)
            {
                char newLangPath[150];
                snprintf(Settings.languagefiles_path, sizeof( Settings.languagefiles_path ), "%s", Dir.GetFilepath(ret));
                char * ptr = strrchr(Settings.languagefiles_path, '/');
                if(ptr) ptr[1] = 0;
                snprintf(newLangPath, sizeof(newLangPath), "%s", Dir.GetFilepath(ret));
                if (!CheckFile(newLangPath))
                {
                    WindowPrompt(tr("File not found."), tr("Loading standard language."), tr("OK"));
                    Settings.LoadLanguage(NULL, CONSOLE_DEFAULT);
                }
                else
                {
                    Settings.LoadLanguage(newLangPath);
                }
                Settings.Save();
                returnhere = 2;
                break;
            }
            optionBrowser4.SetFocus( 1 );
        }

    }

    //! Reload game list in new language
    if(strcmp(Settings.db_language, OldLangCode) != 0)
    {
        GameTitles.LoadTitlesFromWiiTDB(Settings.titlestxt_path);
    }

    w.SetEffect( EFFECT_FADE, -20 );
    while ( w.GetEffect() > 0 ) usleep( 50 );

    HaltGui();
    mainWindow->Remove( &w );
    ResumeGui();

    return returnhere;
}


/****************************************************************************
 * MenuThemeSelect
 ***************************************************************************/
int MenuThemeSelect()
{
    int cnt = 0;
    int ret = 0, choice = 0;
    int returnVal = 0;

    GuiImageData btnOutline(Resources::GetFile("button_dialogue_box.png"), Resources::GetFileSize("button_dialogue_box.png"));
    GuiImageData settingsbg(Resources::GetFile("settings_background.png"), Resources::GetFileSize("settings_background.png"));

    GuiTrigger trigA;
    trigA.SetSimpleTrigger( -1, WPAD_BUTTON_A | WPAD_CLASSIC_BUTTON_A, PAD_BUTTON_A );
    GuiTrigger trigB;
    trigB.SetButtonOnlyTrigger( -1, WPAD_BUTTON_B | WPAD_CLASSIC_BUTTON_B, PAD_BUTTON_B );

    GuiText titleTxt(Settings.theme_path, 24, ( GXColor ) {0, 0, 0, 255} );
    titleTxt.SetAlignment( ALIGN_CENTRE, ALIGN_MIDDLE );
    titleTxt.SetPosition( 0, 0 );
    GuiButton pathBtn( 300, 50 );
    pathBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    pathBtn.SetPosition( 0, 28 );
    pathBtn.SetLabel( &titleTxt );
    pathBtn.SetSoundOver( btnSoundOver );
    pathBtn.SetSoundClick( btnSoundClick2 );
    pathBtn.SetTrigger( &trigA );
    pathBtn.SetEffectGrow();

    GuiImage backgroundImg( &settingsbg );
    backgroundImg.SetAlignment( ALIGN_LEFT, ALIGN_TOP );
    backgroundImg.SetPosition( 0, 0 );

    GuiText backBtnTxt( tr( "Back" ) , 22, thColor("r=0 g=0 b=0 a=255 - prompt windows text color"));
    backBtnTxt.SetMaxWidth( btnOutline.GetWidth() - 30 );
    GuiImage backBtnImg( &btnOutline );
    if ( Settings.wsprompt == ON )
    {
        backBtnTxt.SetWidescreen( Settings.widescreen );
        backBtnImg.SetWidescreen( Settings.widescreen );
    }
    GuiButton backBtn( btnOutline.GetWidth(), btnOutline.GetHeight() );
    backBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    backBtn.SetPosition( -190, 400 );
    backBtn.SetLabel( &backBtnTxt );
    backBtn.SetImage( &backBtnImg );
    backBtn.SetSoundOver( btnSoundOver );
    backBtn.SetSoundClick( btnSoundClick2 );
    backBtn.SetTrigger( &trigA );
    backBtn.SetTrigger( &trigB );
    backBtn.SetEffectGrow();

    GuiText defaultBtnTxt( tr( "Default" ) , 22, thColor("r=0 g=0 b=0 a=255 - prompt windows text color"));
    defaultBtnTxt.SetMaxWidth( btnOutline.GetWidth() - 30 );
    GuiImage defaultBtnImg( &btnOutline );
    if ( Settings.wsprompt == ON )
    {
        defaultBtnTxt.SetWidescreen( Settings.widescreen );
        defaultBtnImg.SetWidescreen( Settings.widescreen );
    }
    GuiButton defaultBtn( btnOutline.GetWidth(), btnOutline.GetHeight() );
    defaultBtn.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );
    defaultBtn.SetPosition( 190, 400 );
    defaultBtn.SetLabel( &defaultBtnTxt );
    defaultBtn.SetImage( &defaultBtnImg );
    defaultBtn.SetSoundOver( btnSoundOver );
    defaultBtn.SetSoundClick( btnSoundClick2 );
    defaultBtn.SetTrigger( &trigA );
    defaultBtn.SetEffectGrow();

    DirList * Dir = new DirList(Settings.theme_path, ".them");
    OptionList options2;

    for ( cnt = 0; cnt < Dir->GetFilecount(); cnt++ )
    {
        char filename[64];
        strlcpy( filename, Dir->GetFilename( cnt ), sizeof( filename ) );
        char *dot = strchr( filename, '.' );
        if ( dot ) *dot = '\0';
        options2.SetName( cnt, "%s", filename );
        options2.SetValue( cnt, NULL );

    }

    GuiCustomOptionBrowser optionBrowser4( 396, 280, &options2, "bg_options_settings.png");
    optionBrowser4.SetPosition( 0, 90 );
    optionBrowser4.SetAlignment( ALIGN_CENTRE, ALIGN_TOP );

    HaltGui();
    GuiWindow w( screenwidth, screenheight );
    w.Append( &backgroundImg );
    w.Append( &pathBtn );
    w.Append( &backBtn );
    w.Append( &optionBrowser4 );
    mainWindow->Append( &w );

    w.SetEffect( EFFECT_FADE, 20 );
    ResumeGui();

    while ( w.GetEffect() > 0 ) usleep(100);

    while (returnVal == 0)
    {
		usleep(100);

        if (shutdown)
            Sys_Shutdown();
        else if (reset)
            Sys_Reboot();

        else if ( backBtn.GetState() == STATE_CLICKED )
            break;

        else if ( defaultBtn.GetState() == STATE_CLICKED )
        {
            choice = WindowPrompt( tr( "Loading default theme." ), 0, tr( "OK" ), tr( "Cancel" ) );
            if ( choice == 1 )
            {
                snprintf(Settings.theme_path, sizeof(Settings.theme_path), "%stheme/", Settings.ConfigPath);
                strcpy(Settings.theme, "");
                Theme::SetDefault();
                Settings.Save();
                returnVal = 1;
            }
            defaultBtn.ResetState();
        }

        else if ( pathBtn.GetState() == STATE_CLICKED )
        {
            w.Remove( &optionBrowser4 );
            w.Remove( &backBtn );
            w.Remove( &pathBtn );
            w.Remove( &defaultBtn );
            int result = BrowseDevice(Settings.theme_path, sizeof(Settings.theme_path), FB_DEFAULT, noFILES);
            w.Append( &optionBrowser4 );
            w.Append( &pathBtn );
            w.Append( &backBtn );
            w.Append( &defaultBtn );
            if (result == 1)
            {
                if (Settings.theme_path[strlen(Settings.theme_path)-1] != '/')
                    strcat(Settings.theme_path, "/");

                HaltGui();
                delete Dir;
                Dir = new DirList(Settings.theme_path, ".them");
                options2.ClearList();
                for ( cnt = 0; cnt < Dir->GetFilecount(); cnt++ )
                {
                    char filename[64];
                    strlcpy( filename, Dir->GetFilename( cnt ), sizeof( filename ) );
                    char *dot = strchr( filename, '.' );
                    if ( dot ) *dot = '\0';
                    options2.SetName( cnt, "%s", filename );
                    options2.SetValue( cnt, NULL );
                }
                titleTxt.SetText(Settings.theme_path);
                ResumeGui();
                WindowPrompt( tr( "Theme path is changed." ), 0, tr( "OK" ) );
            }
            pathBtn.ResetState();
        }

        ret = optionBrowser4.GetClickedOption();

        if (ret >= 0 && ret < Dir->GetFilecount())
        {
            choice = WindowPrompt( tr( "Do you want to load this theme?" ), Dir->GetFilename(ret), tr( "Yes" ), tr( "Cancel" ) );
            if ( choice == 1 )
            {
                snprintf(Settings.theme, sizeof( Settings.theme ), "%s", Dir->GetFilepath(ret));
                if ( !CheckFile( Settings.theme ) )
                {
                    WindowPrompt( tr( "File not found." ), tr( "Loading default theme." ), tr( "OK" ) );
                    Theme::SetDefault();
                    strcpy(Settings.theme, "");
                }
                else
                {
                    HaltGui();
                    Theme::Load(Settings.theme);
                    ResumeGui();
                }
                Settings.Save();
                returnVal = 1;
                break;
            }
            optionBrowser4.SetFocus( 1 );
        }
    }

    w.SetEffect( EFFECT_FADE, -20 );
    while ( w.GetEffect() > 0 ) usleep(100);

    HaltGui();
    mainWindow->Remove( &w );
    ResumeGui();

    delete Dir;

    return returnVal;
}

