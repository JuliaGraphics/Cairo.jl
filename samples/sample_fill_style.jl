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
set_line_width(cr, 6);

rectangle(cr, 12, 12, 232, 70);
new_sub_path(cr); arc(cr, 64, 64, 40, 0, 2*pi);
new_sub_path(cr); arc_negative(cr, 192, 64, 40, 0, -2*pi);

set_fill_type(cr, Cairo.CAIRO_FILL_RULE_EVEN_ODD); # should be set_fill_rule
set_source_rgb(cr, 0, 0.7, 0); fill_preserve(cr);
set_source_rgb(cr, 0, 0, 0); stroke(cr);

translate(cr, 0, 128);
rectangle(cr, 12, 12, 232, 70);
new_sub_path(cr); arc(cr, 64, 64, 40, 0, 2*pi);
new_sub_path(cr); arc_negative(cr, 192, 64, 40, 0, -2*pi);

set_fill_type(cr, Cairo.CAIRO_FILL_RULE_WINDING);
set_source_rgb(cr, 0, 0, 0.9); fill_preserve(cr);
set_source_rgb(cr, 0, 0, 0); stroke(cr);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_fill_style.png");
