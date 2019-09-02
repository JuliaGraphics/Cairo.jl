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

text(cr,16.0,40.0,"Hamburgefons")
text(cr,16.0,72.0,"sp⁰¹²³,min⁻²,αΑβΒφϕΦγΓ")
text(cr,16.0,104.0,"Text<b>Bold</b><i>Italic</i><sup>super-2</sup>",markup=true)

text(cr,40.0,224.0,"Es geht <span foreground=\"white\" background=\"blue\">aufwärts</span> !",markup=true,angle=30.0)

#using textwidth and height

set_font_face(cr, "Sans 12")

a = "A"
aheight = textheight(cr,a)
awidth = textwidth(cr,a)
atext = @sprintf("%s wd=%2.2f,ht=%2.2f",a,awidth,aheight)
text(cr,16.0,240.0,atext,markup=true)


## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_pango_text.png");
