module ui.label;

import ui.units;
import ui.textalignment;

import std.stdio;
import std.path : buildPath;
import std.file : getcwd;
import std.string : toStringz;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;


class Label
{
    protected {
        Point _position;
        string _text;
        Color _textColor;
        int _textSize;
        SDL_Rect _textRect;
        TextAlignment _textAlignment;

        SDL_Texture *_textTexture;
    }

    @property string text() { return _text; }
    @property void text(string s) { _text = s; }

    @property Color textColor() { return _textColor; }
    @property void textColor(Color c) { _textColor = c; }

    @property int textSize() { return _textSize; }
    @property void textSize(int s) { _textSize = s; }

    @property TextAlignment textSize() { return _textAlignment; }
    @property void textSize(TextAlignment a) { _textAlignment = a; }


    this(Point p, string txt, int txtSize, Color txtColor, TextAlignment txtAlignment)
    {
        _position = p;
        _text = txt;
        _textSize = txtSize;
        _textColor = txtColor;
        _textAlignment = txtAlignment;
    }

    void init(SDL_Renderer *context)
    {

        TTF_Font *textFont = TTF_OpenFont(toStringz("resources/fonts/font.ttf"), _textSize);
        if (textFont == null) 
        {
            writeln("Font file for Label class not found");
            return;
        }

        SDL_Surface *_textSurface = TTF_RenderText_Blended(textFont, toStringz(_text), _textColor.sdl);
        if (_textSurface == null)
        {
            writeln("Error loading label text surface");
            return;
        } 

        _textTexture = SDL_CreateTextureFromSurface(context, _textSurface);
        if (_textTexture == null) 
        {
            writeln("Error loading label text texture");
            return;
        } 

        SDL_FreeSurface(_textSurface);
        TTF_CloseFont(textFont);

        int textTextureWidth, textTextureHeight;
        SDL_QueryTexture(_textTexture, null, null, &textTextureWidth, &textTextureHeight);

        if (_textAlignment == TextAlignment.CenterH)
        {
            _position.x = _position.x - textTextureWidth / 2;
        }
        if (_textAlignment == TextAlignment.CenterV)
        {
            _position.y = _position.y - textTextureHeight / 2;
        }
        if (_textAlignment == TextAlignment.CenterHV)
        {
            _position.x = _position.x - textTextureWidth / 2;
            _position.y = _position.y - textTextureHeight / 2;
        }
        _textRect = Rect(_position, Size(textTextureWidth, textTextureHeight)).sdl;
    }

    void render(SDL_Renderer *context)
    {
        SDL_RenderCopy(context, _textTexture, null, &_textRect);
    }

    void handleEvents(SDL_Event *event)
    { 

    }

    void close()
    {
        SDL_DestroyTexture(_textTexture);
    }
}