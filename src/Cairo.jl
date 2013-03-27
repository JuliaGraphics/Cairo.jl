include(joinpath(Pkg.dir(),"Cairo","deps","ext.jl"))
require("Color")

module Cairo
using Color

include("constants.jl")

export
    # drawing surface and context types
    GraphicsDevice, GraphicsContext,
    CairoSurface, CairoContext, CairoPattern,

    # surface constructors
    CairoRGBSurface, CairoPDFSurface, CairoEPSSurface, CairoXlibSurface,
    CairoARGBSurface, CairoSVGSurface, CairoImageSurface, CairoQuartzSurface,
    CairoWin32Surface,
    surface_create_similar,
    PNGRenderer, PDFRenderer, EPSRenderer, SVGRenderer,

    # surface and context management
    finish, destroy, status, resize, get_source,
    creategc, getgc, save, restore, show_page,

    # drawing attribute manipulation
    pattern_set_filter, set_fill_type, set_line_width, set_dash,
    set_source_rgb, set_source_rgba, set_source_surface, color_to_rgb,
    set, get,

    # coordinate systems
    reset_transform, setcoords, rotate, scale, translate, user_to_device!,
    device_to_user!, user_to_device_distance!, device_to_user_distance!,

    # clipping
    clip, clip_preserve, reset_clip, set_clip_rect, 

    # fill, stroke, path, and shape commands
    fill, fill_preserve, new_path, new_sub_path, close_path, paint, stroke,
    stroke_preserve, move_to, line_to, rel_line_to, rel_move_to, 
    rectangle, circle, arc, symbol, symbols, curve, polygon,

    # text
    update_layout, show_layout, get_layout_size, layout_text, text,
    textwidth, textheight, set_font_from_string, set_markup,
    TeXLexer, tex2pango,

    # images
    write_to_png, image, read_from_png,

    # cairo constants
    CAIRO_FORMAT_ARGB32,
    CAIRO_FORMAT_RGB24,
    CAIRO_FORMAT_A8,
    CAIRO_FORMAT_A1,
    CAIRO_FORMAT_RGB16_565,
    CAIRO_CONTENT_COLOR,
    CAIRO_CONTENT_ALPHA,
    CAIRO_CONTENT_COLOR_ALPHA,
    CAIRO_FILTER_FAST,
    CAIRO_FILTER_GOOD,
    CAIRO_FILTER_BEST,
    CAIRO_FILTER_NEAREST,
    CAIRO_FILTER_BILINEAR,
    CAIRO_FILTER_GAUSSIAN

import Base.get

global symbol, fill, set, get

const _jl_libcairo = :libcairo
const _jl_libpango = "libpango-1.0"
const _jl_libpangocairo = "libpangocairo-1.0"
const _jl_libgobject = "libgobject-2.0"
const _jl_libglib = "libglib-2.0"

function cairo_write_to_ios_callback(s::Ptr{Void}, buf::Ptr{Uint8}, len::Uint32)
    n = ccall(:ios_write, Uint, (Ptr{Void}, Ptr{Void}, Uint), s, buf, len)
    ret::Int32 = (n == len) ? 0 : 11
end

abstract GraphicsDevice
abstract GraphicsContext

function cairo_write_to_stream_callback(s::AsyncStream, buf::Ptr{Uint8}, len::Uint32)
    n = write(s,buf,len)
    ret::Int32 = (n == len) ? 0 : 11
end

type CairoSurface <: GraphicsDevice
    ptr::Ptr{Void}
    width::Float64
    height::Float64
    data::Array{Uint32,2}

    function CairoSurface(ptr::Ptr{Void}, w, h)
        self = new(ptr, w, h)
        finalizer(self, destroy)
        self
    end

    function CairoSurface(ptr::Ptr{Void}, w, h, data)
        self = CairoSurface(ptr, w, h)
        self.data = data
        self
    end
end

width(surface::CairoSurface) = surface.width
height(surface::CairoSurface) = surface.height

function resize(surface::CairoSurface, w, h)
    println("in Cairo.resize")
    if OS_NAME == :Linux
        CairoXlibSurfaceSetSize(surface.ptr, w, h)
    elseif OS_NAME == :Darwin
    elseif OS_NAME == :Windows
    else
        error("Unsupported operating system")
    end
end

for name in (:destroy,:finish,:flush,:mark_dirty)
    @eval begin
        $(name)(surface::CairoSurface) =
            ccall(($(string("cairo_surface_",name)),_jl_libcairo),
                  Void, (Ptr{Void},), surface.ptr)
    end
end

function status(surface::CairoSurface)
    ccall((:cairo_surface_status,_jl_libcairo),
          Int32, (Ptr{Void},), surface.ptr)
end

function CairoRGBSurface(w::Real, h::Real)
    ptr = ccall((:cairo_image_surface_create,_jl_libcairo),
                Ptr{Void}, (Int32,Int32,Int32), CAIRO_FORMAT_RGB24, w, h)
    CairoSurface(ptr, w, h)
end

function CairoARGBSurface(w::Real, h::Real)
    ptr = ccall((:cairo_image_surface_create,_jl_libcairo),
                Ptr{Void}, (Int32,Int32,Int32), CAIRO_FORMAT_ARGB32, w, h)
    CairoSurface(ptr, w, h)
end

function CairoImageSurface(data::Array, format::Integer, w::Integer, h::Integer, stride::Integer)
    ptr = ccall((:cairo_image_surface_create_for_data,Cairo._jl_libcairo),
                Ptr{Void}, (Ptr{Void},Int32,Int32,Int32,Int32),
                data, format, w, h, stride)
                Cairo.CairoSurface(ptr, w, h, data)
end

function CairoImageSurface(data::Array{Uint32,2}, format::Integer, w::Integer, h::Integer)
    stride = format_stride_for_width(format, w)
    @assert stride == 4w
    CairoImageSurface(data, format, w, h, stride)
end

function CairoImageSurface(img::Array{Uint32,2}, format::Integer)
    data = img'
    w,h = size(data)
    CairoImageSurface(data, format, w, h)
end

CairoARGBSurface(img) = CairoImageSurface(img, CAIRO_FORMAT_ARGB32)
CairoRGBSurface(img) = CairoImageSurface(img, CAIRO_FORMAT_RGB24)

## PDF ##

function CairoPDFSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface(filename::String, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_pdf_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Uint8},Float64,Float64), bytestring(filename), w_pts, h_pts)
    CairoSurface(ptr, w_pts, h_pts)
end

## EPS ##

function CairoEPSSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
          (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
          (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface(filename::String, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_ps_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Uint8},Float64,Float64), bytestring(filename), w_pts, h_pts)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
          (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w_pts, h_pts)
end

## Xlib ##

function CairoXlibSurface(display, drawable, visual, w, h)
    ptr = ccall((:cairo_xlib_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int32, Ptr{Void}, Int32, Int32),
                display, drawable, visual, w, h)
    CairoSurface(ptr, w, h)
end

CairoXlibSurfaceSetSize(surface, w, h) =
    ccall((:cairo_xlib_surface_set_size,_jl_libcairo), Void,
          (Ptr{Void}, Int32, Int32),
          surface, w, h)

## Quartz ##

function CairoQuartzSurface(context, w, h)
    ptr = ccall((:cairo_quartz_surface_create_for_cg_context,_jl_libcairo),
                Ptr{Void}, (Ptr{Void}, Uint32, Uint32),
                context, w, h)

    CairoSurface(ptr,w,h)
end

## Win32 ##

function CairoWin32Surface(hdc,w,h)
	ptr = ccall((:cairo_win32_surface_create, _jl_libcairo), Ptr{Void}, (Ptr{Void},), hdc)
	CairoSurface(ptr,w,h)
end

## SVG ##

function CairoSVGSurface(stream::IOStream, w, h)
    callback = cfunction(cairo_write_to_ios_callback, Int32, (Ptr{Void},Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface{T<:AsyncStream}(stream::T, w::Real, h::Real)
    callback = cfunction(cairo_write_to_stream_callback, Int32, (T,Ptr{Uint8},Uint32))
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface(filename::String, w::Real, h::Real)
    ptr = ccall((:cairo_svg_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Uint8},Float64,Float64), bytestring(filename), w, h)
    CairoSurface(ptr, w, h)
end

## PNG ##

function read_from_png(filename::String)
    ptr = ccall((:cairo_image_surface_create_from_png,_jl_libcairo),
                Ptr{Void}, (Ptr{Uint8},), bytestring(filename))
    w = ccall((:cairo_image_surface_get_width,_jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    h = ccall((:cairo_image_surface_get_height,_jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    CairoSurface(ptr, w, h)
end

function write_to_png(surface::CairoSurface, filename::String)
    ccall((:cairo_surface_write_to_png,_jl_libcairo), Void,
          (Ptr{Uint8},Ptr{Uint8}), surface.ptr, bytestring(filename))
end

function surface_create_similar(s::CairoSurface, w, h)
    ptr = ccall((:cairo_surface_create_similar,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int32, Int32, Int32),
                s.ptr, CAIRO_CONTENT_COLOR_ALPHA, w, h)
    CairoSurface(ptr, w, h)
end

function format_stride_for_width(format::Integer, width::Integer)
    ccall((:cairo_format_stride_for_width,_jl_libcairo), Int32,
          (Int32,Int32), format, width)
end

# -----------------------------------------------------------------------------

type CairoContext <: GraphicsContext
    ptr::Ptr{Void}
    surface::CairoSurface
    layout::Ptr{Void} # cache PangoLayout

    # coordinate system
    left::Float64
    right::Float64
    top::Float64
    bottom::Float64

    # extent in target device
    x::Float64
    y::Float64
    width::Float64
    height::Float64

    function CairoContext(surface::CairoSurface, x, y, w, h, l, t, r, b)
        ptr = ccall((:cairo_create,_jl_libcairo),
                    Ptr{Void}, (Ptr{Void},), surface.ptr)
        layout = ccall((:pango_cairo_create_layout,_jl_libpangocairo),
                       Ptr{Void}, (Ptr{Void},), ptr)
        self = new(ptr, surface, layout)
        setcoords(self, x, y, w, h, l, t, r, b)
        finalizer(self, destroy)
        self
    end
    CairoContext(surface::CairoSurface) = CairoContext(surface, 0, 0, surface.width, surface.height, 0, 0, surface.width, surface.height)

    function CairoContext(c::CairoContext, x, y, w, h, l, t, r, b)
        xy = user_to_device!(c, [float64(x), float64(y)])
        wh = user_to_device_distance!(c, [float64(w), float64(h)])
        CairoContext(c.surface, xy[1], xy[2], wh[1], wh[2], l, t, r, b)
    end
    CairoContext(c::CairoContext) = CairoContext(c.surface, c.x, c.y, c.width, c.height, c.left, c.top, c.right, c.bottom)
end

function destroy(ctx::CairoContext)
    ccall((:g_object_unref,_jl_libgobject), Void, (Ptr{Void},), ctx.layout)
    _destroy(ctx)
end

creategc(d::CairoSurface, args...) = CairoContext(d, args...)

getgc(c::CairoContext) = c
creategc(c::CairoContext, args...) = CairoContext(c, args...)

function setcoords(c::CairoContext, x, y, w, h, l, t, r, b)
    c.x = x; c.y = y
    c.width = w; c.height = h
    c.left = l; c.right = r
    c.top = t; c.bottom = b
    reset_transform(c)
    reset_clip(c)
    rectangle(c, x, y, w, h)
    clip(c)
    if (r-l) != w || (b-t) != h || l != x || t != y
        # note: Cairo assigns integer pixel-space coordinates to the grid
        # points between sample locations, not to the centers of pixels.
        xs = w/(r-l)
        ys = h/(b-t)
        scale(c, xs, ys)

        xcent = (l+r)/2
        ycent = (t+b)/2
        translate(c, -xcent + (w/2 + x)/xs, -ycent + (h/2 + y)/ys)
    end
    c
end

function move(c::CairoContext, x, y)
    setcoords(c, x, y, c.width, c.height, c.left, c.top, c.right, c.bottom)
end

function resize(c::CairoContext, w, h)
    setcoords(c, c.x, c.y, w, h, c.left, c.top, c.right, c.bottom)
end

macro _CTX_FUNC_V(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},), ctx.ptr)
    end
end

@_CTX_FUNC_V _destroy cairo_destroy
@_CTX_FUNC_V save cairo_save
@_CTX_FUNC_V restore cairo_restore
@_CTX_FUNC_V show_page cairo_show_page
@_CTX_FUNC_V clip cairo_clip
@_CTX_FUNC_V clip_preserve cairo_clip_preserve
@_CTX_FUNC_V reset_clip cairo_reset_clip
@_CTX_FUNC_V reset_transform cairo_identity_matrix
@_CTX_FUNC_V fill cairo_fill
@_CTX_FUNC_V fill_preserve cairo_fill_preserve
@_CTX_FUNC_V new_path cairo_new_path
@_CTX_FUNC_V new_sub_path cairo_new_sub_path
@_CTX_FUNC_V close_path cairo_close_path
@_CTX_FUNC_V paint cairo_paint
@_CTX_FUNC_V stroke_transformed cairo_stroke
@_CTX_FUNC_V stroke_transformed_preserve cairo_stroke_preserve

function stroke(ctx::CairoContext)
    save(ctx)
    # use uniform scale for stroking
    reset_transform(ctx)
    ccall((:cairo_stroke, :libcairo), Void, (Ptr{Void},), ctx.ptr)
    restore(ctx)
end

function stroke_preserve(ctx::CairoContext)
    save(ctx)
    reset_transform(ctx)
    ccall((:cairo_stroke_preserve, :libcairo), Void, (Ptr{Void},), ctx.ptr)
    restore(ctx)
end

macro _CTX_FUNC_I(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, i0::Integer) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Int32), ctx.ptr, i0)
    end
end

@_CTX_FUNC_I set_fill_type cairo_set_fill_rule

macro _CTX_FUNC_D(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real) =
            ccall(($(string(FUNCTION),_jl_libcairo)),
                  Void, (Ptr{Void},Float64), ctx.ptr, d0)
    end
end

@_CTX_FUNC_D set_line_width cairo_set_line_width
@_CTX_FUNC_D rotate cairo_rotate
@_CTX_FUNC_D set_font_size cairo_set_font_size

macro _CTX_FUNC_DD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64), ctx.ptr, d0, d1)
    end
end

@_CTX_FUNC_DD line_to cairo_line_to
@_CTX_FUNC_DD move_to cairo_move_to
@_CTX_FUNC_DD rel_line_to cairo_rel_line_to
@_CTX_FUNC_DD rel_move_to cairo_rel_move_to
@_CTX_FUNC_DD scale cairo_scale
@_CTX_FUNC_DD translate cairo_translate

macro _CTX_FUNC_DDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64,Float64), ctx.ptr, d0, d1, d2)
    end
end

@_CTX_FUNC_DDD set_source_rgb cairo_set_source_rgb

macro _CTX_FUNC_DDDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real, d3::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo), Void,
                  (Ptr{Void},Float64,Float64,Float64,Float64),
                  ctx.ptr, d0, d1, d2, d3)
    end
end

@_CTX_FUNC_DDDD set_source_rgba cairo_set_source_rgba
@_CTX_FUNC_DDDD rectangle cairo_rectangle

macro _CTX_FUNC_DDDDD(NAME, FUNCTION)
    quote
        $(esc(NAME))(ctx::CairoContext, d0::Real, d1::Real, d2::Real, d3::Real, d4::Real) =
            ccall(($(string(FUNCTION)),_jl_libcairo), Void,
                  (Ptr{Void},Float64,Float64,Float64,Float64,Float64),
                  ctx.ptr, d0, d1, d2, d3, d4)
    end
end

@_CTX_FUNC_DDDDD arc cairo_arc

function set_dash(ctx::CairoContext, dashes::Vector{Float64})
    ccall((:cairo_set_dash,_jl_libcairo), Void,
          (Ptr{Void},Ptr{Float64},Int32,Float64), ctx.ptr, dashes, length(dashes), 0.)
end

function set_source_surface(ctx::CairoContext, s::CairoSurface, x::Real, y::Real)
    ccall((:cairo_set_source_surface,_jl_libcairo), Void,
          (Ptr{Void},Ptr{Void},Float64,Float64), ctx.ptr, s.ptr, x, y)
end

function set_font_from_string(ctx::CairoContext, str::String)
    fontdesc = ccall((:pango_font_description_from_string,_jl_libpango),
                     Ptr{Void}, (Ptr{Uint8},), bytestring(str))
    ccall((:pango_layout_set_font_description,_jl_libpango), Void,
          (Ptr{Void},Ptr{Void}), ctx.layout, fontdesc)
    ccall((:pango_font_description_free,_jl_libpango), Void,
          (Ptr{Void},), fontdesc)
end

function set_markup(ctx::CairoContext, markup::String)
    ccall((:pango_layout_set_markup,_jl_libpango), Void,
          (Ptr{Void},Ptr{Uint8},Int32), ctx.layout, bytestring(markup), -1)
end

function get_layout_size(ctx::CairoContext)
    w = Array(Int32,2)
    ccall((:pango_layout_get_pixel_size,_jl_libpango), Void,
          (Ptr{Void},Ptr{Int32},Ptr{Int32}), ctx.layout, pointer(w,1), pointer(w,2))
    w
end

function update_layout(ctx::CairoContext)
    ccall((:pango_cairo_update_layout,_jl_libpangocairo), Void,
          (Ptr{Void},Ptr{Void}), ctx.ptr, ctx.layout)
end

function show_layout(ctx::CairoContext)
    ccall((:pango_cairo_show_layout,_jl_libpangocairo), Void,
          (Ptr{Void},Ptr{Void}), ctx.ptr, ctx.layout)
end

# user<->device coordinate translation

for (fname,cname) in ((:user_to_device!,:cairo_user_to_device),
                      (:device_to_user!,:cairo_device_to_user),
                      (:user_to_device_distance!,:cairo_user_to_device_distance),
                      (:device_to_user_distance!,:cairo_device_to_user_distance))
    @eval begin
        function ($fname)(ctx::CairoContext, p::Vector{Float64})
            ccall(($(expr(:quote,cname)),:libcairo),
                  Void, (Ptr{Void}, Ptr{Float64}, Ptr{Float64}),
                  ctx.ptr, pointer(p,1), pointer(p,2))
            p
        end
    end
end

# -----------------------------------------------------------------------------

type CairoPattern
    ptr::Ptr{Void}
end

function get_source(ctx::CairoContext)
    CairoPattern(ccall((:cairo_get_source,_jl_libcairo),
                       Ptr{Void}, (Ptr{Void},), ctx.ptr))
end

function pattern_set_filter(p::CairoPattern, f)
    ccall((:cairo_pattern_set_filter,_jl_libcairo), Void,
          (Ptr{Void},Int32), p.ptr, f)
end

# -----------------------------------------------------------------------------

function set_clip_rect(ctx::CairoContext, x1, y1, x2, y2)
    width = x2 - x1
    height = y2 - y1
    rectangle(ctx, x1, y1, width, height)
    clip(ctx)
end

color_to_rgb(i::Integer) = hex2rgb(i)
color_to_rgb(s::String) = name2rgb(s)

function set_color(ctx::CairoContext, color)
    (r,g,b) = color_to_rgb( color )
    set_source_rgb( ctx, r, g, b )
end

const nick2name = [
    "dot"       => "dotted",
    "dash"      => "shortdashed",
    "dashed"    => "shortdashed",
]
const name2dashes = [
    "solid"           => Float64[],
    "dotted"          => [1.,3.],
    "dotdashed"       => [1.,3.,4.,4.],
    "longdashed"      => [6.,6.],
    "shortdashed"     => [4.,4.],
    "dotdotdashed"    => [1.,3.,1.,3.,4.,4.],
    "dotdotdotdashed" => [1.,3.,1.,3.,1.,3.,4.,4.],
]

function set_line_type(ctx::CairoContext, nick::String)
    name = get(nick2name, nick, nick)
    if has(name2dashes, name)
        # XXX:should be scaled by linewidth
        set_dash(ctx, name2dashes[name])
    end
end

function PNGRenderer(filename::String, width::Integer, height::Integer)
    surface = CairoRGBSurface(width, height)
    r = creategc(surface)
    set_source_rgb(r, 1.,1.,1.)
    paint(r)
    set_source_rgb(r, 0.,0.,0.)
    r
end

# convert to postscipt pt = in/72
const xx2pt = [ "in"=>72., "pt"=>1., "mm"=>2.835, "cm"=>28.35 ]
function _str_size_to_pts( str )
    m = match(r"([\d.]+)([^\s]+)", str)
    num_xx = float64(m.captures[1])
    units = m.captures[2]
    num_pt = num_xx*xx2pt[units]
    return num_pt
end

PDFRenderer(filename::String, w_str::String, h_str::String) =
    PDFRenderer(filename, _str_size_to_pts(w_str), _str_size_to_pts(h_str))

function PDFRenderer(filename::String, w_pts::Float64, h_pts::Float64)
    surface = CairoPDFSurface(filename, w_pts, h_pts)
    creategc(surface)
end

EPSRenderer(filename::String, w_str::String, h_str::String) =
    EPSRenderer(filename, _str_size_to_pts(w_str), _str_size_to_pts(h_str))

function EPSRenderer(filename::String, w_pts::Float64, h_pts::Float64)
    surface = CairoEPSSurface(filename, w_pts, h_pts)
    creategc(surface)
end

function SVGRenderer(stream::IOStream, w::Real, h::Real)
    surface = CairoSVGSurface(stream, w, h)
    creategc(surface)
end

## state commands

const __pl_style_func = [
    "color"     => set_color,
    "linecolor" => set_color,
    "fillcolor" => set_color,
    "linestyle" => set_line_type,
    "linetype"  => set_line_type,
    "linewidth" => set_line_width,
    "filltype"  => set_fill_type,
    "cliprect"  => set_clip_rect,
]

function set( self::CairoContext, key::String, value )
    #set(self.state, key, value )
    if key == "fontface"
        fontsize = get(self, "fontsize", 12)
        set_font_from_string(self, "$value $(fontsize)px")
    elseif key == "fontsize"
        fontface = get(self, "fontface", "sans-serif")
        set_font_from_string(self, "$fontface $(value)px")
    elseif has(__pl_style_func, key)
        __pl_style_func[key](self, value)
    end
end

function get(self::CairoContext, parameter::String, notfound)
    #return get(self.state, parameter, notfound)

# TODO: cairo_pattern_get_rgba, cairo_get_dash, cairo_get_line_width,
# cairo_get_fill_rule, cairo_clip_extents

end

function get(self::CairoContext, parameter::String)
    get(self, parameter, nothing)
end

## drawing commands

function circle(self::CairoContext, x, y, r)
    arc(self, x, y, r, 0, 2pi)
end

const symbol_funcs = [
    "asterisk" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x, y-r);
        move_to(c, x+0.866r, y-0.5r);
        line_to(c, x-0.866r, y+0.5r);
        move_to(c, x+0.866r, y+0.5r);
        line_to(c, x-0.866r, y-0.5r)
    ),
    "cross" => (c, x, y, r) -> (
        move_to(c, x+r, y+r);
        line_to(c, x-r, y-r);
        move_to(c, x+r, y-r);
        line_to(c, x-r, y+r)
    ),
    "diamond" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x+r, y);
        line_to(c, x, y-r);
        line_to(c, x-r, y);
        close_path(c)
    ),
    "dot" => (c, x, y, r) -> (
        new_sub_path(c);
        rectangle(c, x, y, 1., 1.)
    ),
    "plus" => (c, x, y, r) -> (
        move_to(c, x+r, y);
        line_to(c, x-r, y);
        move_to(c, x, y+r);
        line_to(c, x, y-r)
    ),
    "square" => (c, x, y, r) -> (
        new_sub_path(c);
        rectangle(c, x-0.866r, y-0.866r, 1.732r, 1.732r)
    ),
    "triangle" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x+0.866r, y-0.5r);
        line_to(c, x-0.866r, y-0.5r);
        close_path(c)
    ),
    "down-triangle" => (c, x, y, r) -> (
        move_to(c, x, y-r);
        line_to(c, x+0.866r, y+0.5r);
        line_to(c, x-0.866r, y+0.5r);
        close_path(c)
    ),
    "right-triangle" => (c, x, y, r) -> (
        move_to(c, x+r, y);
        line_to(c, x-0.5r, y+0.866r);
        line_to(c, x-0.5r, y-0.866r);
        close_path(c)
    ),
    "left-triangle" => (c, x, y, r) -> (
        move_to(c, x-r, y);
        line_to(c, x+0.5r, y+0.866r);
        line_to(c, x+0.5r, y-0.866r);
        close_path(c)
    ),
]

function symbol(self::CairoContext, x::Real, y::Real, name, size)
    symbols(self, [x], [y], name, size)
end

function symbols(self::CairoContext, x, y, name, size)
    #fullname = get(self.state, "symboltype", "square")
    #size = get(self.state, "symbolsize", 0.01)

    splitname = split(name)
    name = pop!(splitname)
    filled = contains(splitname, "solid") || contains(splitname, "filled")

    default_symbol_func = (ctx,x,y,r) -> (
        new_sub_path(ctx);
        circle(ctx,x,y,r)
    )
    symbol_func = get(symbol_funcs, name, default_symbol_func)

    save(self)
    set_dash(self, Float64[])
    new_path(self)
    for i = 1:min(length(x),length(y))
        symbol_func(self, x[i], y[i], 0.5*size)
    end
    if filled
        fill_preserve(self)
    end
    stroke(self)
    restore(self)
end

function curve(self::CairoContext, x::AbstractVector, y::AbstractVector)
    n = min(length(x), length(y))
    if n <= 0
        return
    end
    new_path(self)
    move_to(self, x[1], y[1])
    for i = 2:n
        line_to(self, x[i], y[i])
    end
    stroke(self)
end

function image(r::CairoContext, s::CairoSurface, x, y, w, h)
    rectangle(r, x, y, w, h)
    save(r)
    translate(r, x, y+h)
    scale(r, w/s.width, h/s.height)
    set_source_surface(r, s, 0, 0)
    if w > s.width && h > s.height
        # use NEAREST filter when stretching an image
        # it's usually better to see pixels than a blurry mess when viewing
        # a small image
        p = get_source(r)
        pattern_set_filter(p, CAIRO_FILTER_NEAREST)
    end
    fill(r)
    restore(r)
end

image(r::CairoContext, img::Array{Uint32,2}, x, y, w, h) =
    image(r, CairoRGBSurface(img), x, y, w, h)

function polygon( self::CairoContext, points::Vector )
    move_to(self, points[1][1], points[1][2])
    for i in 2:length(points)
        p = points[i]
        line_to(self, p[1], p[2])
    end
    close_path(self)
end

# text commands

function text_extents(ctx::CairoContext,value::String,extents)
    ccall((:cairo_text_extents, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Uint8}, Ptr{Float64}),
          ctx.ptr, bytestring(value), extents)
end

function show_text(ctx::CairoContext,value::String)
    ccall((:cairo_text_extents, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Uint8}),
          ctx.ptr, bytestring(value))
end

function select_font_face(ctx::CairoContext,family::String,slant,weight)
    ccall((:cairo_select_font_face, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Uint8},
                 cairo_font_slant_t, cairo_font_weight_t),
          ctx.ptr, bytestring(property.family),
          slant, weight)
end

function layout_text(self::CairoContext, text::String, size)
    markup = tex2pango(text, size)
    set_markup(self, markup)
end

text(self::CairoContext, x, y, text) = text(self, x, y, text, "center", "center", 0.)

function text(self::CairoContext, x::Real, y::Real, text, halign, valign, angle)
    #halign = get( self.state, "texthalign", "center" )
    #valign = get( self.state, "textvalign", "center" )
    #angle = get( self.state, "textangle", 0. )

    move_to(self, x, y)
    save(self)
    rotate(self, -angle*pi/180.)

    layout_text(self, text)
    update_layout(self)

    const _xxx = [
        "center"    => 0.5,
        "left"      => 0.,
        "right"     => 1.,
        "top"       => 0.,
        "bottom"    => 1.,
    ]
    extents = get_layout_size(self)
    dx = -_xxx[halign]*extents[1]
    dy = _xxx[valign]*extents[2]
    rel_move_to(self, dx, dy)

    show_layout(self)
    restore(self)
end

function textwidth( self::CairoContext, str )
    layout_text(self, str)
    extents = get_layout_size(self)
    extents[1]
end

function textheight( self::CairoContext, str )
    #get( self.state, "fontsize" ) ## XXX: kludge?
    # TODO
    return 3.0
end

type TeXLexer
    str::String
    len::Int
    pos::Int
    token_stack::Array{String,1}
    re_control_sequence::Regex

    function TeXLexer( str::String )
        self = new()
        self.str = str
        self.len = length(str)
        self.pos = 1
        self.token_stack = String[]
        self.re_control_sequence = r"^\\[a-zA-Z]+[ ]?|^\\[^a-zA-Z][ ]?"
        self
    end
end

function get_token( self::TeXLexer )
    if self.pos == self.len+1
        return nothing
    end

    if length(self.token_stack) > 0
        return pop!(self.token_stack)
    end

    str = self.str[self.pos:end]
    m = match(self.re_control_sequence, str)
    if m != nothing
        token = m.match
        self.pos = self.pos + length(token)
        # consume trailing space
        if length(token) > 2 && token[end] == ' '
            token = token[1:end-1]
        end
    else
        token = str[1:1]
        self.pos = self.pos + 1
    end

    return token
end

function put_token( self::TeXLexer, token )
    push!(self.token_stack, token)
end

function peek( self::TeXLexer )
    token = get_token(self)
    put_token( self, token )
    return token
end

function map_text_token(token::String)
    if has(_text_token_dict, token)
        return _text_token_dict[token]
    else
        return get(_common_token_dict, token, token )
    end
end

function map_math_token(token::String)
    if has(_math_token_dict, token)
        return _math_token_dict[token]
    else
        return get(_common_token_dict, token, token )
    end
end

function math_group(lexer::TeXLexer)
    output = ""
    bracketmode = false
    while true
        token = get_token(lexer)
        if token == nothing
            break
        end

        if token == "{"
            bracketmode = true
        elseif token == "}"
            break
        else
            output = string(output, map_math_token(token))
            if !bracketmode
                break
            end
        end
    end
    return output
end

#font_code = [ "\\f0", "\\f1", "\\f2", "\\f3" ]

function tex2pango( str::String, fontsize::Real )
    output = ""
    mathmode = true
    font_stack = {}
    font = 1
    script_size = fontsize/1.618034

    lexer = TeXLexer(str)
    while true
        token = get_token(lexer)
        if token == nothing
            break
        end

        more_output = ""

        if token == "\$"
#            mathmode = !mathmode
            more_output = "\$"
        elseif token == "{"
            push!(font_stack, font)
        elseif token == "}"
            old_font = pop!(font_stack)
            if old_font != font
                font = old_font
#                more_output = font_code[font]
            end
        elseif token == "\\rm"
            font = 1
#            more_output = font_code[font]
        elseif token == "\\it"
            font = 2
#            more_output = font_code[font]
        elseif token == "\\bf"
            font = 3
#            more_output = font_code[font]
        elseif !mathmode
            more_output = map_text_token(token)
        elseif token == "_"
            more_output = string("<sub><span font=\"$script_size\">", math_group(lexer), "</span></sub>")
            #if peek(lexer) == "^"
            #    more_output = string("\\mk", more_output, "\\rt")
            #end
        elseif token == "^"
            more_output = string("<sup><span font=\"$script_size\">", math_group(lexer), "</span></sup>")
            #if peek(lexer) == "_"
            #    more_output = string("\\mk", more_output, "\\rt")
            #end
        else
            more_output = map_math_token(token)
        end

        output = string(output, more_output)
    end

    return output
end

end  # module
