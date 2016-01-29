using Cairo

# shape functions,


function randpos(n,w::Real,h::Real)
    srand(141413)
    px = rand(n)*w
    py = rand(n)*h
    return (px,py)
end

function clear_bg(c::CairoContext,w::Real,h::Real)
    save(c)
    set_source_rgb(c,1.0,1.0,1.0)
    rectangle(c, 0,0,w,h)
    paint(c)
    restore(c)
end

# ddotsx: fill random dots with different methods, disc only (no ring)
function ddots1(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    new_path(cr)
    for i=1:n
       move_to(cr,px[i],py[i])
       rel_move_to(cr,radius,0)
       arc(cr, px[i], py[i], radius, 0, 2*pi)
    end
    close_path(cr)

    set_source_rgb(cr, 0, 0, 1.0)
    fill(cr)
end

function ddots2(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    for i=1:n
        new_path(cr)
        move_to(cr,px[i],py[i])
        rel_move_to(cr,radius,0)
        arc(cr, px[i], py[i], radius, 0, 2*pi)
        close_path(cr)
        set_source_rgb(cr, 0, 0, 1.0)
        fill(cr)
    end
end


function ddots3(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    new_path(cr)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_ROUND)
    set_line_width(cr,radius*2.0)

    for i=1:n
       move_to(cr,px[i],py[i])
       rel_line_to(cr,0,0)
       stroke(cr)
    end

    close_path(cr)

end

function ddots4(cr::CairoContext,
    rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    cc = radius + 1

    rectangle(cr,0,0,2*cc,2*cc)
    clip(cr)
    push_group(cr)
    arc(cr,radius,radius,radius,0,2*pi)
    set_source_rgb(cr,0,0,1.0)
    fill(cr)
    p = pop_group(cr)
    reset_clip(cr)

    for i=1:n
        save(cr)
        translate(cr,px[i]-cc,py[i]-cc)
        set_source(cr,p)
        paint(cr)
        restore(cr)
    end
end

function ddots5(cr::CairoContext,
    rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    cc = radius + 1

    s1 = Cairo.CairoARGBSurface(cc*2,cc*2)
    c1 = Cairo.CairoContext(s1)
    rectangle(c1,0,0,2*cc,2*cc)
    set_source_rgba(c1,0,0,0,0)
    paint(c1)
    new_path(c1)
    arc(c1,radius,radius,radius,0,2*pi)
    set_source_rgb(c1,0,0,1.0)
    fill(c1)

    p = Cairo.CairoPattern(s1)

    for i=1:n
        save(cr)
        translate(cr,px[i]-cc,py[i]-cc)
        set_source(cr,p)
        paint(cr)
        restore(cr)
    end
end

# rdotsx: fill random dots with different methods
function rdots1(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    new_path(cr)
    for i=1:n
       move_to(cr,px[i],py[i])
       rel_move_to(cr,radius,0)
       arc(cr, px[i], py[i], radius, 0, 2*pi)
    end
    close_path(cr)

    set_source_rgb(cr, 0, 0, 1.0)
    fill_preserve(cr)
    set_line_width(cr,1.0)
    set_source_rgb(cr, 0, 0, 0)
    stroke(cr)
end

function rdots2(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    for i=1:n
        new_path(cr)
        move_to(cr,px[i],py[i])
        rel_move_to(cr,radius,0)
        arc(cr, px[i], py[i], radius, 0, 2*pi)
        close_path(cr)
        set_source_rgb(cr, 0, 0, 1.0)
        fill_preserve(cr)
        set_line_width(cr,1.0)
        set_source_rgb(cr, 0, 0, 0)
        stroke(cr)
    end
end


function rdots3(cr::CairoContext, rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    new_path(cr)

    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_ROUND)

    set_source_rgb(cr, 0, 0, 0)
    set_line_width(cr,radius*2 + 2.0)
    for i=1:n
       move_to(cr,px[i],py[i])
       rel_line_to(cr,0,0)
       stroke(cr)
    end

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,radius*2)
    for i=1:n
       move_to(cr,px[i],py[i])
       rel_line_to(cr,0,0)
       stroke(cr)
    end


end

function rdots4(cr::CairoContext,
    rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    cc = radius + 3.0

    rectangle(cr,0,0,2*cc,2*cc)
    clip(cr)
    push_group(cr)
    arc(cr,radius,radius,radius,0,2*pi)
    set_source_rgb(cr,0,0,1.0)
    fill_preserve(cr)
    set_source_rgb(cr,0,0,0)
    set_line_width(cr,1.0)
    stroke(cr)
    p = pop_group(cr)
    reset_clip(cr)

    for i=1:n
        save(cr)
        translate(cr,px[i]-cc,py[i]-cc)
        set_source(cr,p)
        paint(cr)
        restore(cr)
    end
end

function rdots5(cr::CairoContext,
    rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    cc = radius + 3.0

    s1 = Cairo.CairoARGBSurface(cc*2,cc*2)
    c1 = Cairo.CairoContext(s1)
    rectangle(c1,0,0,2*cc,2*cc)
    set_source_rgba(c1,0,0,0,0)
    paint(c1)
    new_path(c1)
    arc(c1,radius+1,radius+1,radius,0,2*pi)
    set_source_rgb(c1,0,0,1.0)
    fill_preserve(c1)
    set_source_rgb(c1,0,0,0)
    set_line_width(c1,1.0)
    stroke(c1)

    p = Cairo.CairoPattern(s1)

    for i=1:n
        save(cr)
        translate(cr,px[i]-cc,py[i]-cc)
        set_source(cr,p)
        paint(cr)
        restore(cr)
    end
end

# alpha transparency using paint_with_alpha
function rdots6(cr::CairoContext,
    rect_width::Real, rect_height::Real, radius::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    cc = radius + 3.0

    s1 = Cairo.CairoARGBSurface(cc*2,cc*2)
    c1 = Cairo.CairoContext(s1)
    rectangle(c1,0,0,2*cc,2*cc)
    set_source_rgba(c1,0,0,0,0)
    paint_with_alpha(c1, 0.5)
    new_path(c1)
    arc(c1,radius+1,radius+1,radius,0,2*pi)
    set_source_rgb(c1,0,0,1.0)
    fill_preserve(c1)
    set_source_rgb(c1,0,0,0)
    set_line_width(c1,1.0)
    stroke(c1)

    p = Cairo.CairoPattern(s1)

    for i=1:n
        save(cr)
        translate(cr,px[i]-cc,py[i]-cc)
        set_source(cr,p)
        paint_with_alpha(cr, 1 - i/n)
        restore(cr)
    end
end

# lines0, random x,y lines
function lines0(cr::CairoContext, rect_width::Real, rect_height::Real, width::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    new_path(cr)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,width)

    new_path(cr)
    move_to(cr,px[1],py[1])
    for i=2:n
       line_to(cr,px[i],py[i])
    end
    stroke(cr)
end

# lines1, x sorted, line a plot
function lines1(cr::CairoContext, rect_width::Real, rect_height::Real, width::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    px = sort(px)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,width)

    new_path(cr)
    move_to(cr,px[1],py[1])
    for i=2:n
        line_to(cr,px[i],py[i])
    end
    stroke(cr)
end

# lines2, x sorted, independent lines per coord
function lines2(cr::CairoContext, rect_width::Real, rect_height::Real, width::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    px = sort(px)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,width)

    new_path(cr)
    for i=1:n-1
        move_to(cr,px[i],py[i])
        line_to(cr,px[i+1],py[i+1])
        stroke(cr)
    end
end

# lines3, x sorted, in clusters of 100
function lines3(cr::CairoContext, rect_width::Real, rect_height::Real, width::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    px = sort(px)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,width)
    new_path(cr)
    for c = 1:100:n
        move_to(cr,px[c],py[c])
        for i=c:min(c+100,n)
            line_to(cr,px[i],py[i])
        end
        stroke(cr)
    end
end

# lines4, x sorted, in clusters of 1000
function lines4(cr::CairoContext, rect_width::Real, rect_height::Real, width::Real, n::Int)

    clear_bg(cr,rect_width,rect_height)
    px,py = randpos(n,rect_width,rect_height)

    px = sort(px)

    set_source_rgb(cr, 0, 0, 1.0)
    set_line_width(cr,width)
    new_path(cr)
    for c = 1:1000:n
        move_to(cr,px[c],py[c])
        for i=c:min(c+1000,n)
            line_to(cr,px[i],py[i])
        end
        stroke(cr)
    end
end
