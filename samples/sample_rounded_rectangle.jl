## header to provide surface and context
using Cairo
c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

save(cr);
## original example, following here

# a custom shape that could be wrapped in a function */
x         = 25.6;        # parameters like cairo_rectangle */
y         = 25.6;
xw         = 204.8;
yw        = 204.8;
aspect        = 1.0;     # aspect ratio */
corner_radius = yw / 10.0;   #* and corner curvature radius */

radius = corner_radius / aspect;
degrees = pi / 180.0;

new_sub_path(cr);
arc(cr, x + xw - radius, y + radius, radius, -90 * degrees, 0 * degrees);
arc(cr, x + xw - radius, y + yw - radius, radius, 0 * degrees, 90 * degrees);
arc(cr, x + radius, y + yw - radius, radius, 90 * degrees, 180 * degrees);
arc(cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
close_path(cr);

set_source_rgb(cr, 0.5, 0.5, 1);
fill_preserve(cr);
set_source_rgba(cr, 0.5, 0, 0, 0.5);
set_line_width(cr, 10.0);
stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_rounded_rectangle.png");
