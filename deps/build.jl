using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

# These are the two binary objects we care about
products = Product[
    LibraryProduct(prefix, "libcairo", :libcairo),
    LibraryProduct(prefix, "libpango", :libpango),
    LibraryProduct(prefix, "libpangocairo", :libpangocairo),
    LibraryProduct(prefix, "libgobject", :libgobject),
]

dependencies = [
    # Freetype2-related dependencies
    "build_Zlib.v1.2.11.jl",
    "build_Bzip2.v1.0.6.jl",
    "build_FreeType2.v2.10.1.jl",
    # Glib-related dependencies
    "build_PCRE.v8.42.0.jl",
    "build_Libffi.v3.2.1.jl",
    "build_Libiconv.v1.16.0.jl",
    "build_Gettext.v0.20.1.jl",
    "build_Glib.v2.59.0.jl",
    # Fontconfig-related dependencies
    "build_Libuuid.v2.34.0.jl",
    "build_Expat.v2.2.7.jl",
    "build_Fontconfig.v2.13.1.jl",
    # HarfBuzz-related dependencies
    "build_Graphite2.v1.3.13.jl",
    "build_HarfBuzz.v2.6.1.jl",
    # Cairo-related dependencies
    "build_X11.v1.6.8.jl",
    "build_LZO.v2.10.0.jl",
    "build_Pixman.v0.38.4.jl",
    "build_libpng.v1.6.37.jl",
    "build_Cairo.v1.16.0.jl",
    # Pango-only dependencies
    "build_FriBidi.v1.0.5.jl",
    # And finally...Pango!
    "build_Pango.v1.42.4.jl"
]

for dependency in dependencies
    # ...these only on Linux and FreeBSD
    platform_key_abi() isa Union{MacOS,Windows} &&
        occursin(r"^build_(Libuuid|X11)", dependency) &&
        continue

    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process

    # Build the dependencies
    Mod = @eval module Anon end
    Mod.include(dependency)
end

# Finally, write out a deps.jl file
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
