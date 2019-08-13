module ui.dynamiclabel;

import ui.units;
import ui.textalignment;
import ui.label;

import std.stdio;
import std.path : buildPath;
import std.file : getcwd;
import std.string : toStringz;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class DynamicLabel : Label
{
    private
    {
        TTF_Font *font;
    }
    this(Point p, string txt, int txtSize, Color txtColor, TextAlignment txtAlignment)
    {
        super(p, txt, txtSize, txtColor, txtAlignment);
    }
    override void init(SDL_Renderer *context)
    {
        font = TTF_OpenFont(toStringz("resources/fonts/font.ttf"), _textSize);
        if (font == null) 
        {
            writeln("Font file for Label class not found");
            return;
        }
        writeln("font loaded fine");
        TTF_CloseFont(font);
    }
}