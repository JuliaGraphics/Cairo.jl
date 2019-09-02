## header to provide surface and context
using Cairo
using Printf

c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

save(cr);

set_font_face(cr, "Sans 16")

text(cr,40.0,40.0,"E<span foreground=\"white\" background=\"blue\">F</span>",markup=true)
text(cr,40.0,60.0,"EGDC")

text(cr,40.0,90.0,"<span foreground=\"white\" background=\"red\">E</span>FGH",markup=true)
text(cr,40.0,110.0,"EGDC",markup=true)

text(cr,40.0,140.0,"G<span foreground=\"white\" background=\"green4\">E</span>FJ",markup=true)
text(cr,40.0,160.0,"EGDC")


## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_pango_text1.png");
