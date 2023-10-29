# <> Release 2.13.x - 

## > Functions
- `ffmped.all_XtoY()` now accepts parameter `frameRate` to determine what framerate you want the remux to obide by. This can help stop against scenarios like a `60fps` file getting remuxed to `60.0002fps` and help with performance issues within NLE's like Premiere