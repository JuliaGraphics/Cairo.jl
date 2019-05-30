using Compat
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

function write_out_picture(filename::AbstractString,c::CairoSurface)
    ## mark picture with current date
    move_to(cr,0.0,12.0);
    set_source_rgb(cr, 0,0,0);
    show_text(cr,Libc.strftime(time()));
    ##
    write_to_png(c,filename);
    nothing
end

function example_current_point(cr)
    save(cr);

    x=25.6;  y=128.0;
    x1=102.4; y1=30.4;
    x2=123.6; y2=45.6;
    x3=130.4; y3=128.0;

    move_to(cr, x, y);
    curve_to(cr, x1, y1, x2, y2, x3, y3);

    if has_current_point(cr)
        x,y = get_current_point(cr);
        save(cr)
        move_to(cr,x,y)
        set_source_rgb(cr, 0,0,1.0);
        show_text(cr,"current point")
        restore(cr)
    end

set_line_width(cr, 10.0);
stroke(cr);


    restore(cr);
    save(cr);
    
    nothing
end


c,cr = common_header();
save(cr);
example_current_point(cr);
restore(cr);
write_out_picture("sample_current_point.png",c);



