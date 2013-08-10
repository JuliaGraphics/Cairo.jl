using BinDeps

@BinDeps.setup

deps = [
	libpng = library_dependency("png", aliases = ["libpng","libpng-1.5.14","libpng15","libpng12.so.0"])
	pixman = library_dependency("pixman", aliases = ["libpixman","libpixman-1","libpixman-1-0","libpixman-1.0"], depends = [libpng])
	libffi = library_dependency("ffi", aliases = ["libffi"], runtime = false)
	gobject = library_dependency("gobject", aliases = ["libgobject-2.0-0", "libgobject-2.0"])
	freetype = library_dependency("freetype", aliases = ["libfreetype"])
	fontconfig = library_dependency("fontconfig", aliases = ["libfontconfig-1", "libfontconfig", "ibfontconfig.so.1"], depends = [freetype])
	cairo = library_dependency("cairo", aliases = ["libcairo-2", "libcairo","libcairo.so.2"], depends = [gobject,fontconfig,libpng])
	pango = library_dependency("pango", aliases = ["libpango-1.0-0", "libpango-1.0","libpango-1.0.so.0"])
	pangocairo = library_dependency("pangocairo", aliases = ["libpangocairo-1.0-0", "libpangocairo-1.0", "libpangocairo-1.0.so.0"], depends = [cairo])
	gettext = library_dependency("gettext", aliases = ["libgettext", "libgettextlib"], os = :Unix)
	zlib = library_dependency("zlib", aliases = ["libzlib"], os = :Windows)
]

# System Package Managers
provides(Homebrew,
	{"cairo" => cairo,
	 "fontconfig" => fontconfig,
	 "pango" => [pango,pangocairo],
	 "glib" => gobject,
	 "libpng" => libpng,
	 "gettext" => gettext})

provides(AptGet,
	{"libcairo2" => cairo,
	 "libfontconfig1" => fontconfig,
	 "libpango1.0-0" => [pango,pangocairo],
	 "libglib2.0-0" => gobject,
	 "libpng12-0" => libpng,
	 "libpixman-1-0" => pixman,
	 "gettext" => gettext})

# TODO: check whether these are accurate
provides(Yum,
	{"cairo" => cairo,
	 "fontconfig" => fontconfig,
	 "pango" => [pango,pangocairo],
	 "glib" => gobject,
	 "libpng" => libpng,
	 "gettext" => gettext})

provides(Binaries, {URI("http://julialang.googlecode.com/files/Cairo.tar.gz") => deps}, os = :Windows)
provides(Binaries, {URI("http://julialang.googlecode.com/files/OSX.tar.gz") => deps}, os = :Darwin)

const png_version = "1.5.14"

provides(Sources,
	{URI("http://www.cairographics.org/releases/pixman-0.28.2.tar.gz") => pixman,
	 URI("http://www.cairographics.org/releases/cairo-1.12.8.tar.xz") => cairo,
 	 URI("http://download.savannah.gnu.org/releases/freetype/freetype-2.4.11.tar.gz") => freetype,
	 URI("http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.10.2.tar.gz") => fontconfig,
	 URI("http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz") => gettext,
	 URI("ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng15/libpng-$(png_version).tar.gz") => libpng,
	 URI("ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz") => libffi,
	 URI("http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz") => gobject,
	 URI("http://ftp.gnome.org/pub/GNOME/sources/pango/1.32/pango-1.32.6.tar.xz") => [pango,pangocairo],
	 URI("http://zlib.net/zlib-1.2.7.tar.gz") => zlib})

xx(t...) = (OS_NAME == :Windows ? t[1] : (OS_NAME == :Linux || length(t) == 2) ? t[2] : t[3])

provides(BuildProcess,
	{
		Autotools(libtarget = "pixman/libpixman-1.la", installed_libname = xx("libpixman-1-0.","libpixman-1.","libpixman-1.0.")*BinDeps.shlib_ext) => pixman,
		Autotools(libtarget = xx("objs/.libs/libfreetype.la","libfreetype.la")) => freetype,
		Autotools(libtarget = "src/libfontconfig.la") => fontconfig,
		Autotools(libtarget = "src/libcairo.la", configure_options = append!(append!(
			String[],
			OS_NAME != :Linux ? String["--without-x","--disable-xlib","--disable-xcb"] : String[]),
			OS_NAME == :Darwin ? String["--enable-quartz","--enable-quartz-font","--enable-quartz-image","--disable-gl"] : String[])) => cairo,
		Autotools(libtarget = "gettext-tools/gnulib-lib/.libs/libgettextlib.la") => gettext,
		Autotools() => libffi,
		Autotools() => gobject,
		Autotools() => pango
	})

provides(BuildProcess,Autotools(libtarget = "libpng15.la"),libpng,os = :Unix)

provides(SimpleBuild,
	(@build_steps begin
		GetSources(zlib)
		@build_steps begin
			ChangeDirectory(joinpath(BinDeps.depsdir(zlib),"src","zlib-1.2.7"))
			MakeTargets(["-fwin32/Makefile.gcc"])
			#MakeTargets(["-fwin32/Makefile.gcc","DESTDIR=../../usr/","INCLUDE_PATH=include","LIBRARY_PATH=lib","SHARED_MODE=1","install"])
		end
	end),zlib, os = :Windows)

prefix=joinpath(BinDeps.depsdir(libpng),"usr")
uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
pngsrcdir = joinpath(BinDeps.depsdir(libpng),"src","libpng-$png_version")
pngbuilddir = joinpath(BinDeps.depsdir(libpng),"builds","libpng-$png_version")
provides(BuildProcess,
	(@build_steps begin
		GetSources(libpng)
		CreateDirectory(pngbuilddir)
		@build_steps begin
			ChangeDirectory(pngbuilddir)
			FileRule(joinpath(prefix,"lib","libpng15.dll"),@build_steps begin
				`cmake -DCMAKE_INSTALL_PREFIX="$prefix" -G"MSYS Makefiles" $pngsrcdir`
				`make`
				`cp libpng*.dll $prefix/lib`
				`cp libpng*.a $prefix/lib`
				`cp libpng*.pc $prefix/lib/pkgconfig`
				`cp pnglibconf.h $prefix/include`
				`cp $pngsrcdir/png.h $prefix/include`
				`cp $pngsrcdir/pngconf.h $prefix/include`
			end)
		end
	end),libpng, os = :Windows)

@BinDeps.install
