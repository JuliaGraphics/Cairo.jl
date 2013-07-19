using BinDeps

function build()
    s = @build_steps begin
	c=Choices(Choice[Choice(:skip,"Skip Installation - Binaries must be installed manually",nothing)])
    end
    
    ## Homebrew
    @osx_only push!(c,Choice(:brew,"Install depdendency using brew",@build_steps begin
	HomebrewInstall("pango",ASCIIString[])
	`brew link cairo`
    end))

    ## Prebuilt Binaries
    depsdir = joinpath(Pkg.dir(),"Cairo","deps")
    @windows_only begin	
	local_file = joinpath(joinpath(depsdir,"downloads"),"Cairo.tar.gz")
	push!(c,Choice(:binary,"Download prebuilt binary",@build_steps begin
				ChangeDirectory(depsdir)
				FileDownloader("http://julialang.googlecode.com/files/Cairo.tar.gz",local_file)
				FileUnpacker(local_file,joinpath(depsdir,"usr"))
		       end))
    end


    println(depsdir)

    ## Install from source
    let 
	prefix=joinpath(depsdir,"usr")
	uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
	libpngver = "1.5.14"
	pngsrcdir = joinpath(depsdir,"src","libpng-"*libpngver)
	builddir = joinpath(depsdir,"builds")
	pngbuilddir = joinpath(builddir,"libpng-"*libpngver)
	CreateDirectory(builddir)
	CreateDirectory(pngbuilddir)
	steps = @build_steps begin ChangeDirectory(depsdir) end

	ENV["PKG_CONFIG_LIBDIR"]=ENV["PKG_CONFIG_PATH"]=joinpath(depsdir,"usr","lib","pkgconfig")
	@unix_only ENV["PATH"]=joinpath(prefix,"bin")*":"*ENV["PATH"]
	@windows_only ENV["PATH"]=joinpath(prefix,"bin")*";"*ENV["PATH"]
	## Windows Specific dependencies
	@windows_only begin
		zlibver = "1.2.8"
		zlibdir = joinpath(depsdir,"src","zlib-"*zlibver)
		zliblib = joinpath(zlibdir, "zlib1.dll")
		steps |= prepare_src(depsdir,"http://zlib.net/zlib-"*zlibver*".tar.gz","zlib-"*zlibver*".tar.gz","zlib-"*zlibver)
		steps |= @build_steps begin
					ChangeDirectory(zlibdir)
					MakeTargets(["-fwin32/Makefile.gcc"])
					#MakeTargets(["-fwin32/Makefile.gcc","DESTDIR=../../usr/","INCLUDE_PATH=include","LIBRARY_PATH=lib","SHARED_MODE=1","install"])
				end
		steps |= prepare_src(depsdir,"ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng15/libpng-"*libpngver*".tar.gz","libpng-"*libpngver*".tar.gz","libpng-"*libpngver)
		steps |= @build_steps begin
					ChangeDirectory(pngbuilddir)
					CreateDirectory(prefix)
					CreateDirectory(joinpath(prefix, "lib"))
					CreateDirectory(joinpath(prefix, "lib", "pkgconfig"))
					CreateDirectory(joinpath(prefix, "include"))
					FileRule(joinpath(prefix,"lib","libpng15.dll"),@build_steps begin
						`cmake -DCMAKE_INSTALL_PREFIX="$prefix" -DZLIB_INCLUDE_DIR:PATH=$zlibdir -DZLIB_LIBRARY:FILEPATH=$zliblib -G"MSYS Makefiles" $pngsrcdir`
						`make`
						`cp libpng*.dll $prefix/lib`
						`cp libpng*.a $prefix/lib`
						`cp libpng*.pc $prefix/lib/pkgconfig`
						`cp pnglibconf.h $prefix/include`
						`cp $pngsrcdir/png.h $prefix/include`
						`cp $pngsrcdir/pngconf.h $prefix/include`
					end)
				end
	end

	## Unix Specific dependencies
	@unix_only  steps |= @build_steps begin
		autotools_install(depsdir,"ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng15/libpng-"*libpngver*".tar.gz","libpng-"*libpngver*".tar.gz",String[],"libpng-"*libpngver,"libpng-"*libpngver,".libs/libpng15.la","libpng15.la")
		autotools_install(depsdir,"http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz","gettext-0.18.2.tar.gz",String[],"gettext-0.18.2","gettext-0.18.2","gettext-tools/gnulib-lib/.libs/libgettextlib.la","libgettextlib.la")
	end

	## Common dependencies
	steps |= @build_steps begin
		autotools_install(depsdir,"http://www.cairographics.org/releases/pixman-0.28.2.tar.gz","pixman-0.28.2.tar.gz",String[],"pixman-0.28.2","pixman-0.28.2","pixman/libpixman-1.la",OS_NAME == :Windows ? "libpixman-1-0."*BinDeps.shlib_ext : (OS_NAME == :Linux ? "libpixman-1."*BinDeps.shlib_ext : "libpixman-1.0."*BinDeps.shlib_ext))
		autotools_install(depsdir,"http://download.savannah.gnu.org/releases/freetype/freetype-2.4.11.tar.gz","freetype-2.4.11.tar.gz",String[],"freetype-2.4.11","freetype-2.4.11",OS_NAME == :Windows ? "objs/.libs/libfreetype.la" : ".libs/libfreetype."*BinDeps.shlib_ext,"libfreetype.la",OS_NAME == :Windows ? "builds/unix" : "")
		autotools_install(depsdir,"http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.10.2.tar.gz","fontconfig-2.10.2.tar.gz",String[],"fontconfig-2.10.2","fontconfig-2.10.2","src/libfontconfig.la","libfontconfig.la")
		autotools_install(depsdir,"http://www.cairographics.org/releases/cairo-1.12.8.tar.xz","cairo-1.12.8.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=\"-I$uprefix/include\"",OS_NAME != :Linux ? "--without-x" : "", OS_NAME != :Linux ? "--disable-xlib" : "", OS_NAME != :Linux ? "--disable-xcb" : "", OS_NAME == :Darwin ? "--enable-quartz" : "", OS_NAME == :Darwin ? "--enable-quartz-font" : "", OS_NAME == :Darwin ? "--enable-quartz-image" : "", OS_NAME == :Darwin ? "--disable-gl" : ""],"cairo-1.12.8","cairo-1.12.8","src/libcairo.la","libcairo.la")
		autotools_install(depsdir,"ftp://sourceware.org/pub/libffi/libffi-3.0.11.tar.gz","libffi-3.0.11.tar.gz",String[],"libffi-3.0.11","libffi-3.0.11",OS_NAME == :Windows ? "i686-pc-mingw32/.libs/libffi.la" : ".libs/libffi.la","libffi.la",OS_NAME == :Windows ? "i686-pc-mingw32" : "")
		autotools_install(depsdir,"http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz","glib-2.34.3.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=-I$uprefix/include",OS_NAME == :Windows?"CFLAGS=-march=i686":""],"glib-2.34.3","glib-2.34.3","glib/libglib-2.0.la","libglib-2.0.la")
		autotools_install(depsdir,"http://ftp.gnome.org/pub/GNOME/sources/pango/1.32/pango-1.32.6.tar.xz","pango-1.32.6.tar.xz",String["LDFLAGS=-L$uprefix/lib","CPPFLAGS=-I$uprefix/include","--with-included-modules=yes", OS_NAME != :Linux ? "--without-x" : ""],"pango-1.32.6","pango-1.32.6","pango/libpango-1.0.la","libpango-1.0.la")
	end
	push!(c,Choice(:source,"Install depdendency from source",steps))
    end
    run(s)

end # build()

alllibs = find_library("Cairo", "libcairo", ["libcairo-2", "libcairo"]) && 
          find_library("Cairo", "libfontconfig", ["libfontconfig-1", "libfontconfig"]) &&
          find_library("Cairo", "libpango",["libpango-1.0-0", "libpango-1.0"]) &&
          find_library("Cairo", "libpangocairo", ["libpangocairo-1.0-0", "libpangocairo-1.0"]) &&
          find_library("Cairo", "libgobject", ["libgobject-2.0-0", "libgobject-2.0"])

if !alllibs; build(); end

function build_wrapper()
    include_paths = ["$prefix/include", "/usr/local/include"]
    lib_paths = ["$prefix/lib"]
    cc = CCompile("src/cairo_wrapper.c","$prefix/lib/libcairo_wrapper."*BinDeps.shlib_ext,
                  ["-shared","-g","-fPIC","-I$prefix/include",
                   ["-I$path" for path in include_paths]...,
                   ["-L$path" for path in lib_paths]...],
                   [""])
    unshift!(cc.options, "-mmacosx-version-min=10.6")
    unshift!(cc.options,"-xobjective-c")
    append!(cc.libs,["-framework","AppKit","-framework","Foundation","-framework","ApplicationServices"])
    s = @build_steps begin
    	ChangeDirectory(depsdir)
        CreateDirectory(joinpath(prefix,"lib"))
        cc
    end

    run(s)
end

# Build cairo_wrapper
@osx_only begin
    depsdir = joinpath(Pkg.dir(),"Cairo","deps")
    prefix=joinpath(depsdir,"usr")
    uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
    find_library("Cairo", "libcairo_wrapper", ["libcairo_wrapper"]) || build_wrapper()
end
