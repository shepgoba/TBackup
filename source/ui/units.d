module ui.units;

import derelict.sdl2.sdl;

struct Color
{
    ubyte r, g, b, a;
}

struct Point
{
    int x, y;
}

struct Size
{
    int width, height;
}

struct Rect
{
    Point position;
    Size size;
}

SDL_Rect sdl(Rect r)
{
    return SDL_Rect(r.position.x, r.position.y, r.size.width, r.size.height);
}

SDL_Color sdl(Color c)
{
    return SDL_Color(c.r, c.g, c.b, c.a);
}