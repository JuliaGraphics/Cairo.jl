
using Cairo

function common_header()
    ## header to provide surface and context
    c = CairoRGBSurface(256,256);
    cr = CairoContext(c);

    save(cr);
    set_source_rgb(cr,0.8,0.8,0.8);    # light gray
    rectangle(cr,0.0,0.0,256.0,256.0); # background
    fill(cr);
    restore(cr);

    return c,cr
end

function write_out_picture(filename::String,c::CairoSurface)
    ## mark picture with current date
    move_to(cr,0.0,12.0);
    set_source_rgb (cr, 0,0,0);
    show_text(cr,strftime(time()));
    ## 
    write_to_png(c,filename);
    nothing
end

function example_copy_path(cr)

    save(cr);
    # single (large) character set with text_path+stroke
    select_font_face (cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                        Cairo.FONT_WEIGHT_BOLD);
    set_font_size (cr, 100.0);
    translate(cr, 10.0, 100.0);
    text_path (cr, "J");
    stroke_preserve(cr);

    # copied and converted
    opath = Cairo.convert_cairo_path_data(Cairo.copy_path(cr));

    restore(cr);

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
        move_to(cr,100.0,14.0*l)
        l += 1
        show_text(cr,s0*s1); # 
    end
    nothing
end


c,cr = common_header();
save(cr);
example_copy_path(cr);
restore(cr);
write_out_picture("sample_copy_path.png",c);



