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

pat = pattern_create_linear (0.0, 0.0,  0.0, 256.0);
pattern_add_color_stop_rgba (pat, 1, 0, 0, 0, 1);
pattern_add_color_stop_rgba (pat, 0, 1, 1, 1, 1);
rectangle (cr, 0, 0, 256, 256);
set_source (cr, pat);
fill (cr);
destroy (pat);

pat = pattern_create_radial (115.2, 102.4, 25.6,
                             102.4,  102.4, 128.0);
pattern_add_color_stop_rgba (pat, 0, 1, 1, 1, 1);
pattern_add_color_stop_rgba (pat, 1, 0, 0, 0, 1);
set_source (cr, pat);
arc (cr, 128.0, 128.0, 76.8, 0, 2 * pi);
fill (cr);
destroy (pat);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb (cr, 0,0,0);
show_text(cr,strftime(time()));
write_to_png(c,"sample_gradient.png");
