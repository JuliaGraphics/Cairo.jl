__precompile__()

module Cairo

using Compat; import Compat.String

depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
isfile(depsjl) ? include(depsjl) : error("Cairo not properly ",
    "installed. Please run\nPkg.build(\"Cairo\")")

using Colors

importall Graphics
import Base: copy

libcairo_version = VersionNumber(unsafe_string(
      ccall((:cairo_version_string,Cairo._jl_libcairo),Cstring,()) ))
libpango_version = VersionNumber(unsafe_string(
      ccall((:pango_version_string,Cairo._jl_libpango),Cstring,()) ))
if !is_windows()
    libpangocairo_version = VersionNumber(unsafe_string(
          ccall((:pango_version_string,Cairo._jl_libpangocairo),Cstring,()) ))
    libgobject_version = VersionNumber( 
          unsafe_load(cglobal((:glib_major_version, Cairo._jl_libgobject), Cuint)),
          unsafe_load(cglobal((:glib_minor_version, Cairo._jl_libgobject), Cuint)),
          unsafe_load(cglobal((:glib_micro_version, Cairo._jl_libgobject), Cuint)))
end

@compat import Base.show

include("constants.jl")

export
    # drawing surface and context types
    CairoSurface, CairoContext, CairoPattern,

    # surface constructors
    CairoRGBSurface, CairoPDFSurface, CairoEPSSurface, CairoXlibSurface,
    CairoARGBSurface, CairoSVGSurface, CairoImageSurface, CairoQuartzSurface,
    CairoWin32Surface, CairoScriptSurface, CairoRecordingSurface,
    CairoPSSurface, surface_create_similar,

    # surface and context management
    finish, destroy, status, get_source,
    creategc, getgc, save, restore, show_page, width, height,

    # pattern
    pattern_create_radial, pattern_create_linear,
    pattern_add_color_stop_rgb, pattern_add_color_stop_rgba,
    pattern_set_filter, pattern_set_extend, pattern_get_surface,

    # mesh patterns (version > 1.12)
    CairoPatternMesh,
    mesh_pattern_begin_patch, mesh_pattern_end_patch,
    mesh_pattern_move_to, mesh_pattern_line_to,
    mesh_pattern_curve_to,
    mesh_pattern_set_corner_color_rgb,
    mesh_pattern_set_corner_color_rgba,

    # drawing attribute manipulation
    set_antialias, get_antialias,
    set_fill_type, set_line_width, set_dash,
    set_source_rgb, set_source_rgba, set_source_surface, set_line_type,
    set_line_cap, set_line_join,
    set_operator, get_operator, set_source,
    CairoMatrix,

    # coordinate systems
    reset_transform, rotate, scale, translate, user_to_device!,
    device_to_user!, user_to_device_distance!, device_to_user_distance!,
    get_matrix, set_matrix,

    # clipping
    clip, clip_preserve, reset_clip,

    # fill, stroke, path, and shape commands
    fill, fill_preserve, new_path, new_sub_path, close_path, paint, paint_with_alpha, stroke,
    stroke_preserve, stroke_transformed, stroke_transformed_preserve,
    move_to, line_to, rel_line_to, rel_move_to,
    rectangle, circle, arc, arc_negative,
    curve_to, rel_curve_to,
    path_extents,

    # path copy
    copy_path, copy_path_flat, convert_cairo_path_data,

    # text
    text,
    update_layout, show_layout, get_layout_size, layout_text,
    set_text, set_latex,
    set_font_face, set_font_size, select_font_face,
    textwidth, textheight, text_extents,
    TeXLexer, tex2pango, show_text, text_path,

    # images
    write_to_png, image, read_from_png,

    # push+pop group
    push_group, pop_group

function write_to_ios_callback(s::Ptr{Void}, buf::Ptr{UInt8}, len::UInt32)
    n = ccall(:ios_write, UInt, (Ptr{Void}, Ptr{Void}, UInt), s, buf, len)
    @compat Int32((n == len) ? 0 : 11)
end

function write_to_stream_callback(s::IO, buf::Ptr{UInt8}, len::UInt32)
    n = VERSION < v"0.5-dev+2301" ? write(s,buf,len) : unsafe_write(s,buf,len)
    @compat Int32((n == len) ? 0 : 11)
end

get_stream_callback(T) = cfunction(write_to_stream_callback, Int32, (Ref{T}, Ptr{UInt8}, UInt32))


function read_from_stream_callback(s::IO, buf::Ptr{UInt8}, len::UInt32)
    # wrap the provided buf into a julia Array
    b1 = unsafe_wrap(Array,buf,len)
    
    # read from stream
    nb = readbytes!(s,b1,len)

    # provide a return status
    (nb == len) ? STATUS_SUCCESS : STATUS_READ_ERROR
end

get_readstream_callback(T) = cfunction(read_from_stream_callback, Int32, (Ref{T}, Ptr{UInt8}, UInt32))


type CairoSurface{T<:Union{UInt32,RGB24,ARGB32}} <: GraphicsDevice
    ptr::Ptr{Void}
    width::Float64
    height::Float64
    data::Matrix{T}

    @compat function (::Type{CairoSurface{T}}){T}(ptr::Ptr{Void}, w, h)
        self = new{T}(ptr, w, h)
        finalizer(self, destroy)
        self
    end
    @compat function (::Type{CairoSurface{T}}){T}(ptr::Ptr{Void}, w, h, data::Matrix{T})
        self = new{T}(ptr, w, h, data)
        finalizer(self, destroy)
        self
    end
    @compat function (::Type{CairoSurface{T}}){T}(ptr::Ptr{Void})
        ccall(
          (:cairo_surface_reference,_jl_libcairo),
          Ptr{Void}, (Ptr{Void}, ), ptr)
        self = new{T}(ptr)
        finalizer(self, destroy)
        self
    end
end

@compat (::Type{CairoSurface})(ptr, w, h) = CairoSurface{UInt32}(ptr, w, h)
@compat (::Type{CairoSurface})(ptr, w, h, data) = CairoSurface{eltype(data)}(ptr, w, h, data)
@compat (::Type{CairoSurface})(ptr) = CairoSurface{UInt32}(ptr)

width(surface::CairoSurface) = surface.width
height(surface::CairoSurface) = surface.height

function destroy(surface::CairoSurface)
    if surface.ptr == C_NULL
        return
    end
    ccall((:cairo_surface_destroy,_jl_libcairo), Void, (Ptr{Void},), surface.ptr)
    surface.ptr = C_NULL
    nothing
end

# function resize(surface::CairoSurface, w, h)
#     if OS_NAME == :Linux
#         CairoXlibSurfaceSetSize(surface.ptr, w, h)
#     elseif OS_NAME == :Darwin
#     elseif OS_NAME == :Windows
#     else
#         error("Unsupported operating system")
#     end
#     surface.width = w
#     surface.height = h
# end

for name in (:finish,:flush,:mark_dirty)
    @eval begin
        $name(surface::CairoSurface) =
            ccall(($(string("cairo_surface_",name)),_jl_libcairo),
                  Void, (Ptr{Void},), surface.ptr)
    end
end

function status(surface::CairoSurface)
    ccall((:cairo_surface_status,_jl_libcairo),
          Int32, (Ptr{Void},), surface.ptr)
end

function CairoImageSurface(w::Real, h::Real, format::Integer)
    ptr = ccall((:cairo_image_surface_create,_jl_libcairo),
                Ptr{Void}, (Int32,Int32,Int32), format, w, h)
    CairoSurface(ptr, w, h)
end

CairoRGBSurface(w::Real, h::Real) = CairoImageSurface(w, h, FORMAT_RGB24)
CairoARGBSurface(w::Real, h::Real) = CairoImageSurface(w, h, FORMAT_ARGB32)
CairoARGBSurface(img) = CairoImageSurface(img, FORMAT_ARGB32)
CairoRGBSurface(img) = CairoImageSurface(img, FORMAT_RGB24)

function CairoImageSurface(img::Array{UInt32,2}, format::Integer; flipxy::Bool = true)
    if flipxy
        img = img'
    end
    w,h = size(img)
    stride = format_stride_for_width(format, w)
    @assert stride == 4w
    ptr = ccall((:cairo_image_surface_create_for_data,_jl_libcairo),
                Ptr{Void}, (Ptr{Void},Int32,Int32,Int32,Int32),
                img, format, w, h, stride)
    CairoSurface(ptr, w, h, img)
end

function CairoImageSurface{T<:@compat(Union{RGB24,ARGB32})}(img::Matrix{T})
    w,h = size(img)
    stride = format_stride_for_width(format(T), w)
    @assert stride == 4w
    ptr = ccall((:cairo_image_surface_create_for_data,_jl_libcairo),
                Ptr{Void}, (Ptr{Void},Int32,Int32,Int32,Int32),
                img, format(T), w, h, stride)
    CairoSurface(ptr, w, h, img)
end

format(::Type{RGB24}) = FORMAT_RGB24
format(::Type{ARGB32}) = FORMAT_ARGB32
format{T<:@compat(Union{RGB24,ARGB32})}(surf::CairoSurface{T}) = T

## PDF ##

function CairoPDFSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(write_to_ios_callback, Int32, (Ptr{Void},Ptr{UInt8},UInt32))
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface{T<:IO}(stream::T, w::Real, h::Real)
    callback = get_stream_callback(T)
    ptr = ccall((:cairo_pdf_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoPDFSurface(filename::AbstractString, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_pdf_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{UInt8},Float64,Float64), @compat(String(filename)), w_pts, h_pts)
    CairoSurface(ptr, w_pts, h_pts)
end

## EPS ##

function CairoEPSSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(write_to_ios_callback, Int32, (Ptr{Void},Ptr{UInt8},UInt32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface{T<:IO}(stream::T, w::Real, h::Real)
    callback = get_stream_callback(T)
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w, h)
end

function CairoEPSSurface(filename::AbstractString, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_ps_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{UInt8},Float64,Float64), @compat(String(filename)), w_pts, h_pts)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
          (Ptr{Void},Int32), ptr, 1)
    CairoSurface(ptr, w_pts, h_pts)
end

## PS ##

function CairoPSSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(write_to_ios_callback, Int32, (Ptr{Void},Ptr{UInt8},UInt32))
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 0)
    CairoSurface(ptr, w, h)
end

function CairoPSSurface{T<:IO}(stream::T, w::Real, h::Real)
    callback = get_stream_callback(T)
    ptr = ccall((:cairo_ps_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
        (Ptr{Void},Int32), ptr, 0)
    CairoSurface(ptr, w, h)
end

function CairoPSSurface(filename::AbstractString, w_pts::Real, h_pts::Real)
    ptr = ccall((:cairo_ps_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{UInt8},Float64,Float64), @compat(String(filename)), w_pts, h_pts)
    ccall((:cairo_ps_surface_set_eps,_jl_libcairo), Void,
          (Ptr{Void},Int32), ptr, 0)
    CairoSurface(ptr, w_pts, h_pts)
end

## Xlib ##

function CairoXlibSurface(display, drawable, visual, w, h)
    ptr = ccall((:cairo_xlib_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int, Ptr{Void}, Int32, Int32),
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
          Ptr{Void}, (Ptr{Void}, UInt32, UInt32), context, w, h)
    CairoSurface(ptr, w, h)
end

## Win32 ##

function CairoWin32Surface(hdc,w,h)
    ptr = ccall((:cairo_win32_surface_create, _jl_libcairo),
                Ptr{Void}, (Ptr{Void},), hdc)
    CairoSurface(ptr,w,h)
end

## SVG ##

function CairoSVGSurface(stream::IOStream, w::Real, h::Real)
    callback = cfunction(write_to_ios_callback, Int32, (Ptr{Void},Ptr{UInt8},UInt32))
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Ptr{Void}, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface{T<:IO}(stream::T, w::Real, h::Real)
    callback = get_stream_callback(T)
    ptr = ccall((:cairo_svg_surface_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any, Float64, Float64), callback, stream, w, h)
    CairoSurface(ptr, w, h)
end

function CairoSVGSurface(filename::AbstractString, w::Real, h::Real)
    ptr = ccall((:cairo_svg_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{UInt8},Float64,Float64), @compat(String(filename)), w, h)
    CairoSurface(ptr, w, h)
end

## PNG ##

function read_from_png(filename::AbstractString)
    ptr = ccall((:cairo_image_surface_create_from_png,_jl_libcairo),
                Ptr{Void}, (Ptr{UInt8},), @compat(String(filename)))
    w = ccall((:cairo_image_surface_get_width,_jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    h = ccall((:cairo_image_surface_get_height,_jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    CairoSurface(ptr, w, h)
end

function write_to_png(surface::CairoSurface, stream::IOStream)
    callback = cfunction(write_to_ios_callback, Int32, (Ptr{Void},Ptr{UInt8},UInt32))
    ccall((:cairo_surface_write_to_png_stream,_jl_libcairo), Void,
          (Ptr{UInt8},Ptr{Void},Ptr{Void}), surface.ptr, callback, stream)
end

function write_to_png{T<:IO}(surface::CairoSurface, stream::T)
    callback = get_stream_callback(T)
    ccall((:cairo_surface_write_to_png_stream,_jl_libcairo), Void,
          (Ptr{UInt8},Ptr{Void},Any), surface.ptr, callback, stream)
end

function write_to_png(surface::CairoSurface, filename::AbstractString)
    ccall((:cairo_surface_write_to_png,_jl_libcairo), Void,
          (Ptr{UInt8},Ptr{UInt8}), surface.ptr, @compat(String(filename)))
end

@compat show(io::IO, ::MIME"image/png", surface::CairoSurface) =
   write_to_png(surface, io)

function read_from_png{T<:IO}(stream::T)
    callback = get_readstream_callback(T)
    ptr = ccall((:cairo_image_surface_create_from_png_stream, Cairo._jl_libcairo),
                Ptr{Void}, (Ptr{Void},Ref{IO}), callback, stream)
    w = ccall((:cairo_image_surface_get_width,Cairo._jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    h = ccall((:cairo_image_surface_get_height,Cairo._jl_libcairo),
              Int32, (Ptr{Void},), ptr)
    Cairo.CairoSurface(ptr, w, h)
end


## Generic ##

function surface_create_similar(s::CairoSurface, w = width(s), h = height(s))
    ptr = ccall((:cairo_surface_create_similar,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Int32, Int32, Int32),
                s.ptr, CONTENT_COLOR_ALPHA, w, h)
    CairoSurface(ptr, w, h)
end

# Utilities

function format_stride_for_width(format::Integer, width::Integer)
    ccall((:cairo_format_stride_for_width,_jl_libcairo), Int32,
          (Int32,Int32), format, width)
end


## Scripting

type CairoScript <: GraphicsDevice
    ptr::Ptr{Void}

    function CairoScript(filename::AbstractString)
        ptr = ccall((:cairo_script_create,_jl_libcairo),
                    Ptr{Void}, (Ptr{UInt8},), @compat(String(filename)))
        self = new(ptr)
        finalizer(self, destroy)
        self
    end

    function CairoScript{T<:IO}(stream::T)
        callback = get_stream_callback(T)
        ptr = ccall((:cairo_script_create_for_stream,_jl_libcairo), Ptr{Void},
                (Ptr{Void}, Any), callback, stream)
        self = new(ptr)
        finalizer(self, destroy)
        self
    end
end

function destroy(s::CairoScript)
    if s.ptr == C_NULL
        return
    end
    ccall((:cairo_device_destroy,_jl_libcairo), Void, (Ptr{Void},), s.ptr)
    s.ptr = C_NULL
    nothing
end

function CairoScriptSurface(filename::AbstractString, w::Real, h::Real)
    s = CairoScript(filename)
    ptr = ccall((:cairo_script_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Void},Int32,Float64,Float64),s.ptr ,CONTENT_COLOR_ALPHA, w, h)
    CairoSurface(ptr, w, h)
end

function CairoScriptSurface(filename::AbstractString,sc::CairoSurface)
    s = CairoScript(filename)
    ptr = ccall((:cairo_script_surface_create_for_target,_jl_libcairo), Ptr{Void},
                (Ptr{Void},Ptr{Void}),s.ptr, sc.ptr)
    CairoSurface(ptr, sc.width, sc.height)
end

function CairoScriptSurface{T<:IO}(stream::T, w::Real, h::Real)
    s = CairoScript(stream)
    ptr = ccall((:cairo_script_surface_create,_jl_libcairo), Ptr{Void},
                (Ptr{Void},Int32,Float64,Float64),s.ptr ,CONTENT_COLOR_ALPHA, w, h)
    CairoSurface(ptr, w, h)
end


type CairoRectangle
    x0::Float64
    y0::Float64
    x1::Float64
    y1::Float64
end

CairoRectangle() = CairoRectangle(0.0, 0.0, 0.0, 0.0)

function CairoRecordingSurface(content::Int32,extents::CairoRectangle)
    ptr = ccall((:cairo_recording_surface_create,_jl_libcairo), Ptr{Void},
                (Int32,Ptr{Void}),content, Ref(extents))
    CairoSurface(ptr)
end
function CairoRecordingSurface(content::Int32)
    ptr = ccall((:cairo_recording_surface_create,_jl_libcairo), Ptr{Void},
                (Int32,Ptr{Void}),content, C_NULL)
    CairoSurface(ptr)
end

CairoRecordingSurface() = CairoRecordingSurface(CONTENT_COLOR_ALPHA)


function script_from_recording_surface(s::CairoScript,r::CairoSurface)
    ccall((:cairo_script_from_recording_surface,_jl_libcairo), Int32,
                (Ptr{Void},Ptr{Void}),s.ptr, r.ptr)
end
# -----------------------------------------------------------------------------

type CairoContext <: GraphicsContext
    ptr::Ptr{Void}
    surface::CairoSurface
    layout::Ptr{Void} # cache PangoLayout

    function CairoContext(surface::CairoSurface)
        ptr = ccall((:cairo_create,_jl_libcairo),
                    Ptr{Void}, (Ptr{Void},), surface.ptr)
        layout = ccall((:pango_cairo_create_layout,_jl_libpangocairo),
                       Ptr{Void}, (Ptr{Void},), ptr)
        self = new(ptr, surface, layout)
        finalizer(self, destroy)
        self
    end
    function CairoContext(ptr::Ptr{Void})
        ccall((:cairo_reference,_jl_libcairo),
                   Ptr{Void}, (Ptr{Void},), ptr)
        surface_p = ccall((:cairo_get_target,_jl_libcairo),
                   Ptr{Void}, (Ptr{Void},), ptr)
        surface = CairoSurface(surface_p)
        layout = ccall((:pango_cairo_create_layout,_jl_libpangocairo),
                  Ptr{Void}, (Ptr{Void},), ptr)
        self = new(ptr,surface,layout)
        finalizer(self, destroy)
        self
    end


end

creategc(s::CairoSurface) = CairoContext(s)

function destroy(ctx::CairoContext)
    if ctx.ptr == C_NULL
        return
    end
    ccall((:g_object_unref,_jl_libgobject), Void, (Ptr{Void},), ctx.layout)
    _destroy(ctx)
    ctx.ptr = C_NULL
    nothing
end

 width(ctx::CairoContext) =  width(ctx.surface)
height(ctx::CairoContext) = height(ctx.surface)

function copy(ctx::CairoContext)
    surf = surface_create_similar(ctx.surface)
    c = creategc(surf)
    set_source_surface(c, ctx.surface)
    paint(c)
    set_matrix(c, get_matrix(ctx))
    c
end

# Copy a rectangular region
function copy(ctx::CairoContext, bb::BoundingBox)
    w = width(bb)
    h = height(bb)
    surf = surface_create_similar(ctx.surface, ceil(Int,w), ceil(Int,h))
    c = creategc(surf)
    set_source_surface(c, ctx.surface, -bb.xmin, -bb.ymin)
    rectangle(c, 0, 0, w, h)
    fill(c)
    set_matrix(c, get_matrix(ctx))
    c
end

for (NAME, FUNCTION) in Any[(:_destroy, :cairo_destroy),
                         (:save, :cairo_save),
                         (:restore, :cairo_restore),
                         (:show_page, :cairo_show_page),
                         (:clip, :cairo_clip),
                         (:clip_preserve, :cairo_clip_preserve),
                         (:reset_clip, :cairo_reset_clip),
                         (:reset_transform, :cairo_identity_matrix),
                         (:fill, :cairo_fill),
                         (:fill_preserve, :cairo_fill_preserve),
                         (:new_path, :cairo_new_path),
                         (:new_sub_path, :cairo_new_sub_path),
                         (:close_path, :cairo_close_path),
                         (:paint, :cairo_paint),
                         (:stroke_transformed, :cairo_stroke),
                         (:stroke_transformed_preserve, :cairo_stroke_preserve)]
    @eval begin
        $NAME(ctx::CairoContext) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},), ctx.ptr)
    end
end

function stroke(ctx::CairoContext)
    save(ctx)
    # use uniform scale for stroking
    reset_transform(ctx)
    ccall((:cairo_stroke, _jl_libcairo), Void, (Ptr{Void},), ctx.ptr)
    restore(ctx)
end

function stroke_preserve(ctx::CairoContext)
    save(ctx)
    reset_transform(ctx)
    ccall((:cairo_stroke_preserve, _jl_libcairo), Void, (Ptr{Void},), ctx.ptr)
    restore(ctx)
end

function paint_with_alpha(ctx::CairoContext, a)
    ccall((:cairo_paint_with_alpha, _jl_libcairo),
          Void, (Ptr{Void}, Float64), ctx.ptr, a)
end

function get_operator(ctx::CairoContext)
    @compat Int(ccall((:cairo_get_operator,_jl_libcairo), Int32, (Ptr{Void},), ctx.ptr))
end


for (NAME, FUNCTION) in Any[(:set_fill_type, :cairo_set_fill_rule),
                         (:set_operator, :cairo_set_operator),
                         (:set_line_cap, :cairo_set_line_cap),
                         (:set_line_join, :cairo_set_line_join)]
    @eval begin
        $NAME(ctx::CairoContext, i0::Integer) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Int32), ctx.ptr, i0)
    end
end

for (NAME, FUNCTION) in Any[(:set_line_width, :cairo_set_line_width),
                         (:rotate, :cairo_rotate),
                         (:set_font_size, :cairo_set_font_size)]
    @eval begin
        $NAME(ctx::CairoContext, d0::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64), ctx.ptr, d0)
    end
end

for (NAME, FUNCTION) in Any[(:line_to, :cairo_line_to),
                         (:move_to, :cairo_move_to),
                         (:rel_line_to, :cairo_rel_line_to),
                         (:rel_move_to, :cairo_rel_move_to),
                         (:scale, :cairo_scale),
                         (:translate, :cairo_translate)]
    @eval begin
        $NAME(ctx::CairoContext, d0::Real, d1::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64), ctx.ptr, d0, d1)
    end
end

for (NAME, FUNCTION) in Any[(:curve_to, :cairo_curve_to),
                         (:rel_curve_to, :cairo_rel_curve_to)]
    @eval begin
        $NAME(ctx::CairoContext, d0::Real, d1::Real, d2::Real, d3::Real, d4::Real, d5::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64,Float64,Float64,Float64,Float64), ctx.ptr, d0, d1, d2, d3, d4, d5)
    end
end

for (NAME, FUNCTION) in Any[(:arc, :cairo_arc),
                         (:arc_negative, :cairo_arc_negative)]
    @eval begin
        $NAME(ctx::CairoContext, xc::Real, yc::Real, radius::Real, angle1::Real, angle2::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64,Float64,Float64,Float64),
                  ctx.ptr, xc, yc, radius, angle1, angle2)
    end
end


set_source_rgb(ctx::CairoContext, r::Real, g::Real, b::Real) =
    ccall((:cairo_set_source_rgb,_jl_libcairo),
          Void, (Ptr{Void},Float64,Float64,Float64), ctx.ptr, r, g, b)

set_source_rgba(ctx::CairoContext, r::Real, g::Real, b::Real, a::Real) =
    ccall((:cairo_set_source_rgba,_jl_libcairo), Void,
          (Ptr{Void},Float64,Float64,Float64,Float64),
          ctx.ptr, r, g, b, a)

function set_source(ctx::CairoContext, c::Color)
    rgb = convert(RGB, c)
    set_source_rgb(ctx, rgb.r, rgb.g, rgb.b)
end

function set_source(ctx::CairoContext, ac::TransparentColor)
    rgba = convert(RGBA, ac)
    set_source_rgba(ctx, rgba.r, rgba.g, rgba.b, rgba.alpha)
end

set_source(dest::CairoContext, src::CairoContext) = set_source_surface(dest, src.surface)

set_source(dest::CairoContext, src::CairoSurface) = set_source_surface(dest, src)

rectangle(ctx::CairoContext, x::Real, y::Real, w::Real, h::Real) =
    ccall((:cairo_rectangle,_jl_libcairo), Void,
          (Ptr{Void},Float64,Float64,Float64,Float64),
          ctx.ptr, x, y, w, h)

function set_dash(ctx::CairoContext, dashes::Vector{Float64}, offset::Real = 0.0)
    ccall((:cairo_set_dash,_jl_libcairo), Void,
          (Ptr{Void},Ptr{Float64},Int32,Float64), ctx.ptr, dashes, length(dashes), offset)
end

function set_source_surface(ctx::CairoContext, s::CairoSurface, x::Real = 0.0, y::Real = 0.0)
    ccall((:cairo_set_source_surface,_jl_libcairo), Void,
          (Ptr{Void},Ptr{Void},Float64,Float64), ctx.ptr, s.ptr, x, y)
end

function set_source(ctx::CairoContext, s::CairoSurface, x::Real, y::Real)
    set_source_surface(ctx, s, x, y)
end


# cairo_path data and functions

type CairoPath_t
    status::Cairo.status_t
    data::Ptr{Float64}
    num_data::UInt32
end

type CairoPath <: GraphicsDevice
    ptr::Ptr{CairoPath_t}

    function CairoPath(ptr::Ptr{Void})
        self = new(ptr)
        finalizer(self, destroy)
        self
    end
end

# Abstract, contains type (moveto,lineto,curveto,closepath) and points
type CairoPathEntry
    element_type::UInt32
    points::Array{Float64,1}
end


function destroy(path::CairoPath)
    if path.ptr == C_NULL
        return
    end
    ccall((:cairo_path_destroy,_jl_libcairo), Void, (Ptr{Void},), path.ptr)
    path.ptr = C_NULL
    nothing
end

function copy_path(ctx::CairoContext)
    ptr = ccall((:cairo_copy_path, _jl_libcairo),
                    Ptr{Void}, (Ptr{Void},),ctx.ptr)
    path = CairoPath(ptr)
    finalizer(path, destroy)
    path
end

function copy_path_flat(ctx::CairoContext)
    ptr = ccall((:cairo_copy_path_flat, _jl_libcairo),
                    Ptr{Void}, (Ptr{Void},),ctx.ptr)
    path = CairoPath(ptr)
    finalizer(path, destroy)
    path
end

function convert_cairo_path_data(p::CairoPath)
    c = unsafe_load(p.ptr)

    # The original data (pointed by c.data) is an array of Unions. We
    # define here by Float64 (most data is) and reinterpret in the header.

    path_data = CairoPathEntry[]
    c_data = @compat unsafe_wrap(Array,c.data,(Int(c.num_data*2),1),false)

    data_index = 1
    while data_index <= ((c.num_data)*2)

        # read header (reinterpret a Float64 to UInt64 and split to UInt32 x 2)
        element_length = reinterpret(UInt64,c_data[data_index]) >> 32
        element_type = reinterpret(UInt64,c_data[data_index]) & 0xffffffff

        # copy points x,y
        points = Vector{Float64}((element_length - 1) * 2)
        for i=1:(element_length-1)*2
            points[i] = c_data[data_index+i+1]
        end

        g = CairoPathEntry(element_type,points)
        push!(path_data,g)

        # goto next element
        data_index += (element_length*2)

    end
    path_data
end


# user<->device coordinate translation

for (fname,cname) in ((:user_to_device!,:cairo_user_to_device),
                      (:device_to_user!,:cairo_device_to_user),
                      (:user_to_device_distance!,:cairo_user_to_device_distance),
                      (:device_to_user_distance!,:cairo_device_to_user_distance))
    @eval begin
        function ($fname)(ctx::CairoContext, p::Vector{Float64})
            ccall(($(Expr(:quote,cname)),_jl_libcairo),
                  Void, (Ptr{Void}, Ptr{Float64}, Ptr{Float64}),
                  ctx.ptr, pointer(p,1), pointer(p,2))
            p
        end
    end
end

function image(ctx::CairoContext, s::CairoSurface, x, y, w, h)
    rectangle(ctx, x, y, w, h)
    save(ctx)
    translate(ctx, x, y)
    scale(ctx, w/s.width, h/s.height)
    set_source_surface(ctx, s, 0, 0)
    if abs(w) > s.width && abs(h) > s.height
        # use NEAREST filter when stretching an image
        # it's usually better to see pixels than a blurry mess when viewing
        # a small image
        p = get_source(ctx)
        pattern_set_filter(p, FILTER_NEAREST)
    end
    fill(ctx)
    restore(ctx)
end

image(ctx::CairoContext, img::Array{UInt32,2}, x, y, w, h) =
    image(ctx, CairoRGBSurface(img), x, y, w, h)

function push_group(ctx::CairoContext)
    if ctx.ptr == C_NULL
        return
    end
    ccall((:cairo_push_group, _jl_libcairo), Void, (Ptr{Void},),ctx.ptr)
    nothing
end

function pop_group(ctx::CairoContext)
    if ctx.ptr == C_NULL
        return
    end
    ptr = ccall((:cairo_pop_group, _jl_libcairo), Ptr{Void}, (Ptr{Void},),ctx.ptr)
    pattern = CairoPattern(ptr)
    finalizer(pattern, destroy)
    pattern
end

# -----------------------------------------------------------------------------

type CairoPattern
    ptr::Ptr{Void}
end

function CairoPattern(s::CairoSurface)
    ptr = ccall((:cairo_pattern_create_for_surface, _jl_libcairo),
                    Ptr{Void}, (Ptr{Void},), s.ptr)
    # Ideally we'd check the status, but at least for certain releases of the library
    # the return value seems not to be set properly (random values are returned)
#     status = ccall((:cairo_pattern_status, _jl_libcairo),
#                     Cint, (Ptr{Void},), s.ptr)
#     if status != 0
#         error("Error creating Cairo pattern: ", bytestring(
#               ccall((:cairo_status_to_string, _jl_libcairo),
#                     Ptr{UInt8}, (Cint,), status)))
#     end
    pattern = CairoPattern(ptr)
    finalizer(pattern, destroy)
    pattern
end

set_source(dest::CairoContext, src::CairoPattern) =
    ccall((:cairo_set_source, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Void}), dest.ptr, src.ptr)

function get_source(ctx::CairoContext)
    CairoPattern(ccall((:cairo_get_source,_jl_libcairo),
                       Ptr{Void}, (Ptr{Void},), ctx.ptr))
end

function pattern_set_filter(p::CairoPattern, f)
    ccall((:cairo_pattern_set_filter,_jl_libcairo), Void,
          (Ptr{Void},Int32), p.ptr, f)
end

function pattern_set_extend(p::CairoPattern, val)
    ccall((:cairo_pattern_set_extend,_jl_libcairo), Void,
          (Ptr{Void},Int32), p.ptr, val)
end

function pattern_create_radial(cx0::Real, cy0::Real, radius0::Real, cx1::Real, cy1::Real, radius1::Real)
    ptr = ccall((:cairo_pattern_create_radial, _jl_libcairo),
                    Ptr{Void}, (Float64,Float64,Float64,Float64,Float64,Float64),cx0,cy0,radius0,cx1,cy1,radius1)
    pattern = CairoPattern(ptr)
    finalizer(pattern, destroy)
    pattern
end

function pattern_create_linear(x0::Real, y0::Real, x1::Real, y1::Real)
    ptr = ccall((:cairo_pattern_create_linear, _jl_libcairo),
                    Ptr{Void}, (Float64,Float64,Float64,Float64),x0,y0,x1,y1)
    pattern = CairoPattern(ptr)
    finalizer(pattern, destroy)
    pattern
end

function pattern_add_color_stop_rgb(pat::CairoPattern, offset::Real, red::Real, green::Real, blue::Real)
    ccall((:cairo_pattern_add_color_stop_rgb, _jl_libcairo),
                    Void, (Ptr{Void},Float64,Float64,Float64,Float64),pat.ptr,offset,red,green,blue)
end

function pattern_add_color_stop_rgba(pat::CairoPattern, offset::Real, red::Real, green::Real, blue::Real, alpha::Real)
    ccall((:cairo_pattern_add_color_stop_rgba, _jl_libcairo),
                    Void, (Ptr{Void},Float64,Float64,Float64,Float64,Float64),pat.ptr,offset,red,green,blue,alpha)
end

function pattern_get_surface(pat::CairoPattern)
    ptrref = Ref{Ptr{Void}}()
    status = ccall((:cairo_pattern_get_surface, _jl_libcairo), Cint,
                   (Ptr{Void}, Ref{Ptr{Void}}), pat.ptr, ptrref)
    if status == STATUS_PATTERN_TYPE_MISMATCH
        error("Cannot get surface from a non-surface pattern.")
    end
    ptr = ptrref.x

    ccall((:cairo_surface_reference, _jl_libcairo), Ptr{Void}, (Ptr{Void},), ptr)
    typ = ccall((:cairo_surface_get_type, _jl_libcairo), Cint, (Ptr{Void},), ptr)

    w = 0.0
    h = 0.0
    if typ == CAIRO_SURFACE_TYPE_IMAGE
        w = ccall((:cairo_image_surface_get_width, _jl_libcairo),
                  Int32, (Ptr{Void},), ptr)
        h = ccall((:cairo_image_surface_get_height, _jl_libcairo),
                  Int32, (Ptr{Void},), ptr)
    end
    return CairoSurface(ptr, w, h)
end

function destroy(pat::CairoPattern)
    if pat.ptr == C_NULL
        return
    end
    ccall((:cairo_pattern_destroy,_jl_libcairo), Void, (Ptr{Void},), pat.ptr)
    pat.ptr = C_NULL
    nothing
end

# mesh pattern

# create mesh pattern
function CairoPatternMesh()
    ptr = ccall((:cairo_pattern_create_mesh, _jl_libcairo),
                    Ptr{Void}, ())
    pattern = CairoPattern(ptr)                    
    #status = ccall((:cairo_pattern_status, _jl_libcairo),
    #                Cint, (Ptr{Void},), pattern.ptr)
    #if status != 0
    #    error("Error creating Cairo pattern: ", bytestring(
    #          ccall((:cairo_status_to_string, _jl_libcairo),
    #                Ptr{Uint8}, (Cint,), status)))
    #end
    finalizer(pattern, destroy)
    pattern
end

#for (NAME, FUNCTION) in Any[(:set_line_width, :cairo_set_line_width),
#                         (:rotate, :cairo_rotate),
#                         (:set_font_size, :cairo_set_font_size)]
#    @eval begin
#        $NAME(ctx::CairoContext, d0::Real) =
#            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
#                  Void, (Ptr{Void},Float64), ctx.ptr, d0)
#    end
#end

for (NAME, FUNCTION) in Any[(:mesh_pattern_begin_patch, :cairo_mesh_pattern_begin_patch),
                         (:mesh_pattern_end_patch, :cairo_mesh_pattern_end_patch)]
    @eval begin
        $NAME(pattern::CairoPattern) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},), pattern.ptr)
    end
end

for (NAME, FUNCTION) in Any[(:mesh_pattern_line_to, :cairo_mesh_pattern_line_to),
                         (:mesh_pattern_move_to, :cairo_mesh_pattern_move_to)]
    @eval begin
        $NAME(pattern::CairoPattern, d0::Real, d1::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64), pattern.ptr, d0, d1)
    end
end

for (NAME, FUNCTION) in Any[(:mesh_pattern_curve_to, :cairo_mesh_pattern_curve_to)]

    @eval begin
        $NAME(pattern::CairoPattern, d0::Real, d1::Real, d2::Real, d3::Real, d4::Real, d5::Real) =
            ccall(($(Expr(:quote,FUNCTION)),_jl_libcairo),
                  Void, (Ptr{Void},Float64,Float64,Float64,Float64,Float64,Float64), pattern.ptr, d0, d1, d2, d3, d4, d5)
    end
end


function mesh_pattern_set_corner_color_rgb(pat::CairoPattern, corner_num::Real, red::Real, green::Real, blue::Real)
    ccall((:cairo_mesh_pattern_set_corner_color_rgb, _jl_libcairo),
                    Void, (Ptr{Void},Int32,Float64,Float64,Float64),pat.ptr,corner_num,red,green,blue)
end

function mesh_pattern_set_corner_color_rgba(pat::CairoPattern, corner_num::Real, red::Real, green::Real, blue::Real, alpha::Real)
    ccall((:cairo_mesh_pattern_set_corner_color_rgb, _jl_libcairo),
                    Void, (Ptr{Void},Int32,Float64,Float64,Float64,Float64),pat.ptr,corner_num,red,green,blue,alpha)
end

# ----

set_antialias(ctx::CairoContext, a) =
    ccall((:cairo_set_antialias,_jl_libcairo), Void,
          (Ptr{Void},Cint), ctx.ptr, a)

get_antialias(ctx::CairoContext) =
    ccall((:cairo_get_antialias,_jl_libcairo), Cint,
          (Ptr{Void},), ctx.ptr)

# -----------------------------------------------------------------------------

immutable CairoMatrix
    xx::Float64
    yx::Float64
    xy::Float64
    yy::Float64
    x0::Float64
    y0::Float64
end

CairoMatrix() = CairoMatrix(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

function get_matrix(ctx::CairoContext)
    m = [CairoMatrix()]
    ccall((:cairo_get_matrix, _jl_libcairo), Void, (Ptr{Void}, Ptr{Void}), ctx.ptr, m)
    m[1]
end

function set_matrix(ctx::CairoContext, m::CairoMatrix)
    ccall((:cairo_set_matrix, _jl_libcairo), Void, (Ptr{Void}, Ptr{Void}), ctx.ptr, [m])
end

function set_matrix(p::CairoPattern, m::CairoMatrix)
    ccall((:cairo_pattern_set_matrix, _jl_libcairo), Void, (Ptr{Void}, Ptr{Void}), p.ptr, [m])
end


# -----------------------------------------------------------------------------
function set_line_type(ctx::CairoContext, nick::AbstractString)
    if nick == "solid"
        dash = Float64[]
    elseif nick == "dotted" || nick == "dot"
        dash = [1.,3.]
    elseif nick == "dotdashed"
        dash = [1.,3.,4.,4.]
    elseif nick == "longdashed"
        dash = [6.,6.]
    elseif nick == "shortdashed" || nick == "dash" || nick == "dashed"
        dash = [4.,4.]
    elseif nick == "dotdotdashed"
        dash = [1.,3.,1.,3.,4.,4.]
    elseif nick == "dotdotdotdashed"
        dash = [1.,3.,1.,3.,1.,3.,4.,4.]
    else
        error("unknown line type ", nick)
    end
    set_dash(ctx, dash)
end

# -----------------------------------------------------------------------------
# text commands

function set_font_face(ctx::CairoContext, str::AbstractString)
    fontdesc = ccall((:pango_font_description_from_string,_jl_libpango),
                     Ptr{Void}, (Ptr{UInt8},), @compat(String(str)))
    ccall((:pango_layout_set_font_description,_jl_libpango), Void,
          (Ptr{Void},Ptr{Void}), ctx.layout, fontdesc)
    ccall((:pango_font_description_free,_jl_libpango), Void,
          (Ptr{Void},), fontdesc)
end

function set_text(ctx::CairoContext, text::AbstractString, markup::Bool = false)
    if markup
        ccall((:pango_layout_set_markup,_jl_libpango), Void,
            (Ptr{Void},Ptr{UInt8},Int32), ctx.layout, @compat(String(text)), -1)
    else
        ccall((:pango_layout_set_text,_jl_libpango), Void,
            (Ptr{Void},Ptr{UInt8},Int32), ctx.layout, @compat(String(text)), -1)
    end
    text
end

function get_layout_size(ctx::CairoContext)
    w = Vector{Int32}(2)
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

text_extents(ctx::CairoContext,value::AbstractString) = text_extents!(ctx,value, Matrix{Float64}(6, 1))

function text_extents!(ctx::CairoContext,value::AbstractString,extents)
    ccall((:cairo_text_extents, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{UInt8}, Ptr{Float64}),
          ctx.ptr, @compat(String(value)), extents)
    extents
end

function path_extents(ctx::CairoContext)
    dx1 = Cdouble[0]
    dx2 = Cdouble[0]
    dy1 = Cdouble[0]
    dy2 = Cdouble[0]

    ccall((:cairo_path_extents, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{Cdouble}, Ptr{Cdouble},
          Ptr{Cdouble}, Ptr{Cdouble}),
          ctx.ptr, dx1, dy1, dx2, dy2)

    return(dx1[1],dy1[1],dx2[1],dy2[1])
end


function show_text(ctx::CairoContext,value::AbstractString)
    ccall((:cairo_show_text, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{UInt8}),
          ctx.ptr, @compat(String(value)))
end

function text_path(ctx::CairoContext,value::AbstractString)
    ccall((:cairo_text_path, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{UInt8}),
          ctx.ptr, @compat(String(value)))
end


function select_font_face(ctx::CairoContext,family::AbstractString,slant,weight)
    ccall((:cairo_select_font_face, _jl_libcairo),
          Void, (Ptr{Void}, Ptr{UInt8},
                 font_slant_t, font_weight_t),
          ctx.ptr, @compat(String(family)),
          slant, weight)
end

function align2offset(a::AbstractString)
    if     a == "center" return 0.5
    elseif a == "left"   return 0.0
    elseif a == "right"  return 1.0
    elseif a == "top"    return 0.0
    elseif a == "bottom" return 1.0
    end
    @assert false
end

function text(ctx::CairoContext, x::Real, y::Real, str::AbstractString;
              halign::AbstractString = "left", valign::AbstractString = "bottom", angle::Real = 0, markup::Bool=false)
    move_to(ctx, x, y)
    save(ctx)
    reset_transform(ctx)
    rotate(ctx, -angle*pi/180.)

    set_text(ctx, str, markup)
    update_layout(ctx)

    extents = get_layout_size(ctx)
    dxrel = -align2offset(halign)
    dyrel = align2offset(valign)
    rel_move_to(ctx, dxrel*extents[1], -dyrel*extents[2])

    show_layout(ctx)
    restore(ctx)
    w, h = Graphics.device_to_user(ctx, extents[1], extents[2])
    BoundingBox(x+dxrel*w, x+(dxrel+1)*w, y-dyrel*h, y+(1-dyrel)*h)
end

function textwidth(ctx::CairoContext, str::AbstractString, markup::Bool = false)
    set_text(ctx, str, markup)
    extents = get_layout_size(ctx)
    extents[1]
end

function textheight(ctx::CairoContext, str::AbstractString, markup::Bool = false)
    set_text(ctx, str, markup)
    extents = get_layout_size(ctx)
    extents[2]
end

set_latex(ctx::CairoContext, str::AbstractString, fontsize::Real) = set_text(ctx, tex2pango(str, fontsize), true)

type TeXLexer
    str::String
    len::Int
    pos::Int
    token_stack::Array{String,1}

    function TeXLexer(str::AbstractString)
        s = @compat String(str)
        new(s, endof(s), 1, String[])
    end
end

function get_token(self::TeXLexer)
    if self.pos > self.len
        return nothing
    end

    if length(self.token_stack) > 0
        return pop!(self.token_stack)
    end

    str = self.str[self.pos:end]
    re_control_sequence = r"^\\[a-zA-Z]+[ ]?|^\\[^a-zA-Z][ ]?"
    m = match(re_control_sequence, str)
    if m !== nothing
        token = m.match
        self.pos = self.pos + sizeof(token)
        # consume trailing space
        if length(token) > 2 && token[end] == ' '
            token = token[1:end-1]
        end
    else
        token, self.pos = next(self.str, self.pos)
        token = string(token)
    end

    return token
end

function put_token(self::TeXLexer, token)
    push!(self.token_stack, token)
end

function peek(self::TeXLexer)
    token = get_token(self)
    put_token(self, token)
    return token
end

function map_text_token(token::AbstractString)
    if haskey(_text_token_dict, token)
        return _text_token_dict[token]
    else
        return get(_common_token_dict, token, token)
    end
end

function map_math_token(token::AbstractString)
    if haskey(_math_token_dict, token)
        return _math_token_dict[token]
    else
        return get(_common_token_dict, token, token)
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

function tex2pango(str::AbstractString, fontsize::Real)
    output = ""
    mathmode = true
    font_stack = Any[]
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


@deprecate text(ctx::CairoContext,x::Real,y::Real,str::AbstractString,fontsize::Real,halign::AbstractString,valign,angle)    text(ctx,x,y,set_latex(ctx,str,fontsize),halign=halign,valign=valign,angle=angle,markup=true)
@deprecate layout_text(ctx::CairoContext, str::AbstractString, fontsize::Real)       set_latex(ctx, str, fontsize)
@deprecate textwidth(ctx::CairoContext, str::AbstractString, fontsize::Real)         textwidth(ctx, tex2pango(str, fontsize), true)
@deprecate textheight(ctx::CairoContext, str::AbstractString, fontsize::Real)        textheight(ctx, tex2pango(str, fontsize), true)
@deprecate cairo_write_to_ios_callback(s::Ptr{Void}, buf::Ptr{UInt8}, len::UInt32)   write_to_ios_callback(s, buf, len)
@deprecate cairo_write_to_stream_callback(s::IO, buf::Ptr{UInt8}, len::UInt32)       write_to_stream_callback(s, buf, len)
@deprecate text_extents(ctx::CairoContext,value::AbstractString,extents) text_extents!(ctx,value,extents)

end  # module
