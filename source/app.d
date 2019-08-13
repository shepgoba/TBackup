import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.stdio, std.zip, std.file, std.format, std.conv;
import std.math : round;
import core.stdc.stdlib : getenv;
import core.thread;

import ui.button;
import ui.label;
import ui.dynamiclabel;
import ui.units;
import ui.textalignment;
import std.string : toStringz;

float progress = 0;
string labelText = "Waiting for backup";
string state = "main";

void zipFolder(string archiveFilePath, string folderPath, bool *running, float *progress)
{
    if (running == null)
    {
        return;
    }
    if (progress == null)
    {
        return;
    }
    if (!*running)
    {
        *running = true;
        labelText = "Backing up...";
        new Thread({
            ZipArchive zip = new ZipArchive();
                
            float currentZipSize = 0;
            float totalFolderSize = 0;
            foreach (entry; dirEntries(folderPath, SpanMode.depth))
            {
                if (!entry.isFile)
                    continue;
                totalFolderSize+=entry.size;
            }

            foreach (DirEntry entry; dirEntries(folderPath, SpanMode.depth))
            {
                if (!entry.isFile)
                    continue;

                ArchiveMember am = new ArchiveMember();
                am.name = entry.name[folderPath.length + 1..$];
                am.expandedData(cast(ubyte[]) read(entry.name));
                am.compressionMethod = CompressionMethod.deflate;
                zip.addMember(am);
                currentZipSize += am.expandedSize;
                if (progress != null)
                {
                    *progress = currentZipSize / totalFolderSize;
                }
            }
            
            void[] compressed_data = zip.build();
            std.file.write(archiveFilePath, compressed_data);
            *progress = 0;
            *running = false;
        }).start();
    }
}
void backupTerrariaFolder()
{
    static bool backingup = false;
    
    string userDrive = to!string(getenv("HOMEDRIVE"));
    string userFolderPath = to!string(getenv("HOMEPATH"));

    string userFolder = format("%s%s", userDrive, userFolderPath);
    zipFolder("TerrariaBackup.tbackup.zip", format("%s\\Documents\\My Games\\Terraria", userFolder), &backingup, &progress);

}
void openSettings()
{
    writeln("coming soon");
    //state = "settings";
}
void main(string[] args) 
{
    DerelictSDL2.load();
    DerelictSDL2ttf.load();
    DerelictSDL2Image.load();

    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();
    IMG_Init(IMG_INIT_PNG|IMG_INIT_JPG);


    const int targetFrameRate = 60;

    const int windowWidth = 400;
    const int windowHeight = 200;


    SDL_Window *win = SDL_CreateWindow("TBackup 1.0", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, windowWidth, windowHeight, 0);
    SDL_Renderer *renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    SDL_Renderer *settingsRenderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    /* Load window icon */
    SDL_Surface *icon = IMG_Load("resources/images/icon.png");
    SDL_SetWindowIcon(win, icon);
    SDL_FreeSurface(icon);


    Button backupButton = new Button(Point(200 - 50, 100 - 25), Size(100, 50), "Backup", 14, Color(0, 100, 255, 255), Color(0, 0, 0, 255), TextAlignment.CenterHV);
    backupButton.init(renderer);
    backupButton.onClick = &backupTerrariaFolder;

    SDL_Rect progressBar = Rect(Point(50, 150), Size(0, 10)).sdl;
    SDL_Rect totalProgress = Rect(Point(50, 150), Size(300, 10)).sdl;


    Button settings = new Button(Point(5, 5), Size(40, 15), "Settings", 9, Color(150, 150, 150, 255), Color(0, 0, 0, 255), TextAlignment.CenterHV);
    settings.init(renderer);
    settings.onClick = &openSettings;
    while (true) 
    {
        SDL_Event e;

        if (SDL_PollEvent(&e)) 
        {
            backupButton.handleEvents(&e);
            settings.handleEvents(&e);
            if (e.type == SDL_QUIT)
            {
                break;
            }
        }
        progressBar.w = cast(int) round(round(progress * 100) * 3);
        SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
        SDL_RenderClear(renderer);

        backupButton.render(renderer);
        settings.render(renderer);
        
        if (progress > 0)
        {
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
            SDL_RenderFillRect(renderer, &totalProgress);

            SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
            SDL_RenderFillRect(renderer, &progressBar);
        }

        SDL_RenderPresent(renderer);

        SDL_Delay(1000 / targetFrameRate);
    }

    backupButton.close();
    settings.close();
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(win);

    TTF_Quit();
    IMG_Quit();
    SDL_Quit();
}