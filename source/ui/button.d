module ui.button;

import ui.units;
import ui.textalignment;

import std.stdio;
import std.string : toStringz;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class Button
{
    public void function() onClick;
    private 
    {
        Point _position;
        Point _textPosition;
        Size _buttonSize;
        string _text;
        Color _textColor;
        Color _buttonColor;
        Color _buttonPressedColor;
        int _textSize;
        SDL_Rect _textRect;
        SDL_Rect _buttonRect;
        TextAlignment _textAlignment;


        bool pressed;

        SDL_Texture *_textTexture;
    }

    this(Point p, Size s, string txt, int txtSize, Color btnColor, Color txtColor, TextAlignment txtAlignment)
    {
        pressed = false;
        _position = p;
        _buttonSize = s;
        _text = txt;
        _textSize = txtSize;
        _textColor = txtColor;
        _textAlignment = txtAlignment;
        _buttonColor = btnColor;
        _buttonPressedColor = Color(50, 50, 50, 255);
    }

    void init(SDL_Renderer *context)
    {
        TTF_Font *textFont = TTF_OpenFont(toStringz("resources/fonts/font.ttf"), _textSize);
        if (textFont == null) 
        {
            writeln("Font file for Button class not found");
            return;
        }

        SDL_Surface *_textSurface = TTF_RenderText_Blended(textFont, toStringz(_text), _textColor.sdl);
        if (_textSurface == null)
        {
            writeln("Error loading button text surface");
            return;
        } 

        _textTexture = SDL_CreateTextureFromSurface(context, _textSurface);
        if (_textTexture == null) 
        {
            writeln("Error loading button text texture");
            return;
        } 

        SDL_FreeSurface(_textSurface);
        TTF_CloseFont(textFont);

        int textTextureWidth, textTextureHeight;
        SDL_QueryTexture(_textTexture, null, null, &textTextureWidth, &textTextureHeight);

        if (_textAlignment == TextAlignment.CenterHV)
        {
            _textPosition.x = _position.x + _buttonSize.width / 2 - textTextureWidth / 2;
            _textPosition.y = _position.y + _buttonSize.height / 2 - textTextureHeight / 2;
        }
        _textRect = Rect(_textPosition, Size(textTextureWidth, textTextureHeight)).sdl;
        _buttonRect = Rect(_position, Size(_buttonSize.width, _buttonSize.height)).sdl;
    }

    void render(SDL_Renderer *context)
    {
        if (pressed)
        {
            SDL_SetRenderDrawColor(context, _buttonPressedColor.r, _buttonPressedColor.g, _buttonPressedColor.b, _buttonPressedColor.a);
        }
        else
        {
            SDL_SetRenderDrawColor(context, _buttonColor.r, _buttonColor.g, _buttonColor.b, _buttonColor.a);
        }
        SDL_RenderFillRect(context, &_buttonRect);
        SDL_RenderCopy(context, _textTexture, null, &_textRect);
    }

    void handleEvents(SDL_Event *e) 
    {
        if (e.type == SDL_MOUSEBUTTONDOWN)
        {
            if (e.button.button == SDL_BUTTON_LEFT)
            {
                int mouseX, mouseY;
                SDL_GetMouseState(&mouseX, &mouseY);
                if (mouseX > _buttonRect.x && mouseX < _buttonRect.x + _buttonRect.w && mouseY > _buttonRect.y && mouseY < _buttonRect.y + _buttonRect.h)
                {
                    pressed = true;
                    if (onClick != null)
                    {
                        onClick();
                    }          
                }
            }
        }
        else if (e.type == SDL_MOUSEBUTTONUP)
        {
            pressed = false;
        }
    }

    void close()
    {
        SDL_DestroyTexture(_textTexture);
    }
}