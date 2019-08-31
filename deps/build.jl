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
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Bzip2-v1.0.6-2/build_Bzip2.v1.0.6.jl",
    "https://github.com/JuliaGraphics/FreeTypeBuilder/releases/download/v2.9.1-4/build_FreeType2.v2.10.0.jl",
    # Glib-related dependencies
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/PCRE-v8.42-2/build_PCRE.v8.42.0.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Libffi-v3.2.1-0/build_Libffi.v3.2.1.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Libiconv-v1.15-0/build_Libiconv.v1.15.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Gettext-v0.19.8-0/build_Gettext.v0.19.8.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Glib-v2.59.0%2B0/build_Glib.v2.59.0.jl",
    # Fontconfig-related dependencies
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Libuuid.v2.34.0.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Expat.v2.2.7.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Fontconfig.v2.13.1.jl",
    # HarfBuzz-related dependencies
    "https://github.com/giordano/Yggdrasil/releases/download/Graphite2-v1.3.13/build_Graphite2.v1.3.13.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/HarfBuzz-v2.6.1/build_HarfBuzz.v2.6.1.jl",
    # Cairo-related dependencies
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_X11.v1.6.8.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_LZO.v2.10.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Pixman-v0.36.0-0/build_Pixman.v0.36.0.jl",
    "https://github.com/JuliaIO/LibpngBuilder/releases/download/v1.0.3/build_libpng.v1.6.37.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Cairo.v1.14.12.jl",
    # Pango-only dependencies
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/FriBidi-v1.0.5%2B0/build_FriBidi.v1.0.5.jl",
    # And finally...Pango!
    "https://github.com/giordano/Yggdrasil/releases/download/Pango-v.1.42.4/build_Pango.v1.42.4.jl"
]


for dependency in dependencies
    platform_key_abi() isa Union{MacOS,Windows} &&
        occursin(r"build_(Libuuid|Expat|Fontconfig|Graphite2|HarfBuzz|X11)", dependency) &&
        continue

    file = joinpath(@__DIR__, basename(dependency))
    isfile(file) || download(dependency, file)
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process

    # Build the dependencies
    Mod = @eval module Anon end
    Mod.include(file)
end

# Finally, write out a deps.jl file
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
