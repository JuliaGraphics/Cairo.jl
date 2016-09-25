# some collection of some painting plus support functions

"""
function ngray(base::Int64,digits::Int64,value::Int64)
Convert a value to a graycode with the given base and digits
"""
function ngray(base::Int64,digits::Int64,value::Int64)
	baseN = zeros(Int64,digits)
	gray = zeros(Int64,1,digits)

	for i=1:digits
		baseN[i] = value % base
		value = div(value,base)
	end

	shift = 0
	for i=digits:-1:1
		gray[i] = (baseN[i] + shift) % base
		shift = shift + base - gray[i]
	end
	gray
end

"""
function hilbert_curve(c,x,y,lg,i1,i2)
recursive hilbert curve (2D), appends pairs of x,y to c, lg = dimension/length
"""
function hilbert_curve(c,x,y,lg,i1,i2)
    if lg == 1
        append!(c,[x,y])
    else
        lg = lg / 2;
        hilbert_curve(c,x+i1*lg,y+i1*lg,lg,i1,1-i2);
        hilbert_curve(c,x+i2*lg,y+(1-i2)*lg,lg,i1,i2);
        hilbert_curve(c,x+(1-i1)*lg,y+(1-i1)*lg,lg,i1,i2);
        hilbert_curve(c,x+(1-i2)*lg,y+i2*lg,lg,1-i1,i2);
    end
end

function hilbert_main3(cr,s,n1)
    zscale = 8;
    offset = 0;
    save(cr)
    c = Float64[]
    hilbert_curve(c,offset,offset,s,0,0)
    #display(c)
    move_to(cr,offset*zscale,offset*zscale)
    #translate(cr,0.5,0.5)
    scale(cr,zscale,zscale)
    set_line_cap(cr,Cairo.CAIRO_LINE_CAP_SQUARE)
    for k in zip(collect(1:2:(length(c)-2)),1:(length(1:2:(length(c)-2))))
        move_to(cr,c[k[1]],c[k[1]+1])
        line_to(cr,c[k[1]+2],c[k[1]+3])
        c1 = ngray(Int64(n1),3,k[2])
        set_source_rgb(cr,c1[1]/float(n1-1),c1[2]/float(n1-1),c1[3]/float(n1-1))
        stroke(cr)
        end
    
    restore(cr)
    end


function hdraw3()
    s = CairoImageSurface(512,512,Cairo.FORMAT_RGB24);

    cr = CairoContext(s);

    save(cr);
    set_source_rgb(cr,0.8,0.8,0.8)
    paint(cr);
    restore(cr);
    set_source_rgb(cr,0.4,0.0,0.8)
    set_line_width(cr,4.0)
    hilbert_main3(cr,64,12)

    write_to_png(s,"a.png")
end