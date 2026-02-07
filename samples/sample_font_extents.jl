## header to provide surface and context
using Cairo
c = CairoRGBSurface(1024,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,1024.0,256.0); # background
fill(cr);
restore(cr);

save(cr);
## original example, following here
select_font_face(cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                 Cairo.FONT_WEIGHT_NORMAL);
set_font_size(cr, 100.0);
extents = font_extents(cr);

#typedef struct {
#    double ascent;
#    double descent;
#    double height;
#    double max_x_advance;
#    double max_y_advance;
#} cairo_font_extents_t;

x = 25.0;
y = 150.0;

move_to(cr, x, y);
show_text(cr, "Cairo! abcdefghijklmnopqrstuvwxyz");

# draw helping lines 
set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
set_line_width(cr, 6.0);
arc(cr, x, y, 10.0, 0, 2*pi);
fill(cr);
move_to(cr, x,y);
rel_line_to(cr, 0, -extents[1]);
rel_line_to(cr, 1024, 0);
#rel_line_to(cr, extents[1], -extents[2]);
stroke(cr);
move_to(cr, x,y);
rel_line_to(cr, 0, extents[2]);
rel_line_to(cr, 1024, 0);
stroke(cr);
## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_font_extents.png");
