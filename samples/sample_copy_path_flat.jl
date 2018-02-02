## header to provide surface and context
using Cairo

c = CairoRGBSurface(256,256)
cr = CairoContext(c)

save(cr)
set_source_rgb(cr,0.8,0.8,0.8)    # light gray
rectangle(cr,0.0,0.0,256.0,256.0) # background
fill(cr)
restore(cr)

save(cr)

## original example, following here
move_to(cr, 16.0, 32.0)
curve_to(cr, 16.0, 16.0, 16.0, 16.0, 32.0, 16.0)

opath = Cairo.convert_cairo_path_data(Cairo.copy_path(cr))
dx,dy,ex,ey = path_extents(cr)

fpath = Cairo.convert_cairo_path_data(Cairo.copy_path_flat(cr))

stroke(cr)

restore(cr)

l = 2 # something like a line counter

# loop over all entries and just print out command and available points
for x in opath
    if x.element_type == Cairo.CAIRO_PATH_MOVE_TO
        s0 = "moveto"
    elseif x.element_type == Cairo.CAIRO_PATH_LINE_TO
        s0 = "lineto"
    elseif x.element_type == Cairo.CAIRO_PATH_CURVE_TO
        s0 = "curveto"
    elseif x.element_type == Cairo.CAIRO_PATH_CLOSE_PATH
        s0 = "closepath"
    end
    s1 = repr(x.points)
    move_to(cr,10.0,16.0+(14.0*l))
    global l += 1
    show_text(cr,s0*s1)
end

l = 2 # something like a line counter

# loop over all entries and just print out command and available points
for x in fpath
    if x.element_type == Cairo.CAIRO_PATH_MOVE_TO
        s0 = "moveto"
    elseif x.element_type == Cairo.CAIRO_PATH_LINE_TO
        s0 = "lineto"
    elseif x.element_type == Cairo.CAIRO_PATH_CURVE_TO
        s0 = "curveto"
    elseif x.element_type == Cairo.CAIRO_PATH_CLOSE_PATH
        s0 = "closepath"
    end
    s1 = repr(x.points)
    move_to(cr,10.0,50.0+(14.0*l))
    global l += 1
    show_text(cr,s0*s1)
end


## mark picture with current date
restore(cr)

move_to(cr,0.0,12.0)
set_source_rgb(cr, 0,0,0)
show_text(cr,Libc.strftime(time()))

write_to_png(c,"sample_copy_path_flat.png")
