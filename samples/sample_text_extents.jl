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
select_font_face(cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                 Cairo.FONT_WEIGHT_NORMAL);
set_font_size(cr, 100.0);
extents = text_extents(cr, "cairo");

#
# typedef struct {
#     double x_bearing;
#     double y_bearing;
#     double width;
#     double height;
#     double x_advance;
#     double y_advance;
# } cairo_text_extents_t;

x = 25.0;
y = 150.0;

move_to(cr, x, y);
show_text(cr, "cairo");

# draw helping lines 
set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
set_line_width(cr, 6.0);
arc(cr, x, y, 10.0, 0, 2*pi);
fill(cr);
move_to(cr, x,y);
rel_line_to(cr, 0, -extents[4]);
rel_line_to(cr, extents[3], 0);
rel_line_to(cr, extents[1], -extents[2]);
stroke(cr);
## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_text_extents.png");
