## Cairo Constants ##
export CAIRO_FORMAT_ARGB32,
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

typealias cairo_format_t Int32
const CAIRO_FORMAT_INVALID   = int32(-1)
const CAIRO_FORMAT_ARGB32    = int32(0)
const CAIRO_FORMAT_RGB24     = int32(1)
const CAIRO_FORMAT_A8        = int32(2)
const CAIRO_FORMAT_A1        = int32(3)
const CAIRO_FORMAT_RGB16_565 = int32(4)
const CAIRO_FORMAT_RGB30     = int32(5)

typealias cairo_status_t Int32
const CAIRO_STATUS_SUCCESS                   = int32(0)
const CAIRO_STATUS_NO_MEMORY                 = int32(1)
const CAIRO_STATUS_INVALID_RESTORE           = int32(2)
const CAIRO_STATUS_INVALID_POP_GROUP         = int32(3)
const CAIRO_STATUS_NO_CURRENT_POINT          = int32(4)
const CAIRO_STATUS_INVALID_MATRIX            = int32(5)
const CAIRO_STATUS_INVALID_STATUS            = int32(6)
const CAIRO_STATUS_NULL_POINTER              = int32(7)
const CAIRO_STATUS_INVALID_STRING            = int32(8)
const CAIRO_STATUS_INVALID_PATH_DATA         = int32(9)
const CAIRO_STATUS_READ_ERROR                = int32(10)
const CAIRO_STATUS_WRITE_ERROR               = int32(11)
const CAIRO_STATUS_SURFACE_FINISHED          = int32(12)
const CAIRO_STATUS_SURFACE_TYPE_MISMATCH     = int32(13)
const CAIRO_STATUS_PATTERN_TYPE_MISMATCH     = int32(14)
const CAIRO_STATUS_INVALID_CONTENT           = int32(15)
const CAIRO_STATUS_INVALID_FORMAT            = int32(16)
const CAIRO_STATUS_INVALID_VISUAL            = int32(17)
const CAIRO_STATUS_FILE_NOT_FOUND            = int32(17)
const CAIRO_STATUS_INVALID_DASH              = int32(18)
const CAIRO_STATUS_INVALID_DSC_COMMENT       = int32(19)
const CAIRO_STATUS_INVALID_INDEX             = int32(20)
const CAIRO_STATUS_CLIP_NOT_REPRESENTABLE    = int32(21)
const CAIRO_STATUS_TEMP_FILE_ERROR           = int32(22)
const CAIRO_STATUS_INVALID_STRIDE            = int32(23)
const CAIRO_STATUS_FONT_TYPE_MISMATCH        = int32(24)
const CAIRO_STATUS_USER_FONT_IMMUTABLE       = int32(25)
const CAIRO_STATUS_USER_FONT_ERROR           = int32(26)
const CAIRO_STATUS_NEGATIVE_COUNT            = int32(27)
const CAIRO_STATUS_INVALID_CLUSTERS          = int32(28)
const CAIRO_STATUS_INVALID_SLANT             = int32(29)
const CAIRO_STATUS_INVALID_WEIGHT            = int32(30)
const CAIRO_STATUS_INVALID_SIZE              = int32(31)
const CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED = int32(32)
const CAIRO_STATUS_DEVICE_TYPE_MISMATCH      = int32(33)
const CAIRO_STATUS_DEVICE_ERROR              = int32(34)
const CAIRO_STATUS_INVALID_MESH_CONSTRUCTION = int32(35)
const CAIRO_STATUS_DEVICE_FINISHED           = int32(36)
const CAIRO_STATUS_LAST_STATUS               = int32(37)

typealias cairo_font_slant_t Int32
const CAIRO_FONT_SLANT_NORMAL  = int32(0)
const CAIRO_FONT_SLANT_ITALIC  = int32(1)
const CAIRO_FONT_SLANT_OBLIQUE = int32(2)

typealias cairo_font_weight_t Int32
const CAIRO_FONT_WEIGHT_NORMAL = int32(0)
const CAIRO_FONT_WEIGHT_BOLD = int32(1)

const CAIRO_CONTENT_COLOR = int(0x1000)
const CAIRO_CONTENT_ALPHA = int(0x2000)
const CAIRO_CONTENT_COLOR_ALPHA = int(0x3000)

const CAIRO_FILTER_FAST = 0
const CAIRO_FILTER_GOOD = 1
const CAIRO_FILTER_BEST = 2
const CAIRO_FILTER_NEAREST = 3
const CAIRO_FILTER_BILINEAR = 4
const CAIRO_FILTER_GAUSSIAN = 5


## LaTex Token Dicts ##
const _common_token_dict = [
    L"\{"               => L"{",
    L"\}"               => L"}",
    L"\_"               => L"_",
    L"\^"               => L"^",
    L"\-"               => L"-",

    ## ignore stray brackets
    L"{"                => L"",
    L"}"                => L"",
]

const _text_token_dict = [
    ## non-math symbols (p438)
    L"\S"               => E"\ua7",
    L"\P"               => E"\ub6",
    L"\dag"             => E"\u2020",
    L"\ddag"            => E"\u2021",
]

const _math_token_dict = [

    L"-"                => E"\u2212", # minus sign

    ## spacing
    L"\quad"            => E"\u2003", # 1 em
    L"\qquad"           => E"\u2003\u2003", # 2 em
    L"\,"               => E"\u2006", # 3/18 em
    L"\>"               => E"\u2005", # 4/18 em
    L"\;"               => E"\u2004", # 5/18 em

    ## lowercase greek
    L"\alpha"           => E"\u03b1",
    L"\beta"            => E"\u03b2",
    L"\gamma"           => E"\u03b3",
    L"\delta"           => E"\u03b4",
    L"\epsilon"         => E"\u03b5",
    L"\varepsilon"      => E"\u03f5",
    L"\zeta"            => E"\u03b6",
    L"\eta"             => E"\u03b7",
    L"\theta"           => E"\u03b8",
    L"\vartheta"        => E"\u03d1",
    L"\iota"            => E"\u03b9",
    L"\kappa"           => E"\u03ba",
    L"\lambda"          => E"\u03bb",
    L"\mu"              => E"\u03bc",
    L"\nu"              => E"\u03bd",
    L"\xi"              => E"\u03be",
    L"\omicron"         => E"\u03bf",
    L"\pi"              => E"\u03c0",
    L"\varpi"           => E"\u03d6",
    L"\rho"             => E"\u03c1",
    L"\varrho"          => E"\u03f1",
    L"\sigma"           => E"\u03c3",
    L"\varsigma"        => E"\u03c2",
    L"\tau"             => E"\u03c4",
    L"\upsilon"         => E"\u03c5",
    L"\phi"             => E"\u03d5",
    L"\varphi"          => E"\u03c6",
    L"\chi"             => E"\u03c7",
    L"\psi"             => E"\u03c8",
    L"\omega"           => E"\u03c9",

    ## uppercase greek
    L"\Alpha"           => E"\u0391",
    L"\Beta"            => E"\u0392",
    L"\Gamma"           => E"\u0393",
    L"\Delta"           => E"\u0394",
    L"\Epsilon"         => E"\u0395",
    L"\Zeta"            => E"\u0396",
    L"\Eta"             => E"\u0397",
    L"\Theta"           => E"\u0398",
    L"\Iota"            => E"\u0399",
    L"\Kappa"           => E"\u039a",
    L"\Lambda"          => E"\u039b",
    L"\Mu"              => E"\u039c",
    L"\Nu"              => E"\u039d",
    L"\Xi"              => E"\u039e",
    L"\Pi"              => E"\u03a0",
    L"\Rho"             => E"\u03a1",
    L"\Sigma"           => E"\u03a3",
    L"\Tau"             => E"\u03a4",
    L"\Upsilon"         => E"\u03a5",
    L"\Phi"             => E"\u03a6",
    L"\Chi"             => E"\u03a7",
    L"\Psi"             => E"\u03a8",
    L"\Omega"           => E"\u03a9",

    ## miscellaneous
    L"\aleph"           => E"\u2135",
    L"\hbar"            => E"\u210f",
    L"\ell"             => E"\u2113",
    L"\wp"              => E"\u2118",
    L"\Re"              => E"\u211c",
    L"\Im"              => E"\u2111",
    L"\partial"         => E"\u2202",
    L"\infty"           => E"\u221e",
    L"\prime"           => E"\u2032",
    L"\emptyset"        => E"\u2205",
    L"\nabla"           => E"\u2206",
    L"\surd"            => E"\u221a",
    L"\top"             => E"\u22a4",
    L"\bot"             => E"\u22a5",
    L"\|"               => E"\u2225",
    L"\angle"           => E"\u2220",
    L"\triangle"        => E"\u25b3", # == \bigtriangleup
    L"\backslash"       => E"\u2216",
    L"\forall"          => E"\u2200",
    L"\exists"          => E"\u2203",
    L"\neg"             => E"\uac",
    L"\flat"            => E"\u266d",
    L"\natural"         => E"\u266e",
    L"\sharp"           => E"\u266f",
    L"\clubsuit"        => E"\u2663",
    L"\diamondsuit"     => E"\u2662",
    L"\heartsuit"       => E"\u2661",
    L"\spadesuit"       => E"\u2660",

    ## large operators
    L"\sum"             => E"\u2211",
    L"\prod"            => E"\u220f",
    L"\coprod"          => E"\u2210",
    L"\int"             => E"\u222b",
    L"\oint"            => E"\u222e",
    L"\bigcap"          => E"\u22c2",
    L"\bigcup"          => E"\u22c3",
    L"\bigscup"         => E"\u2a06",
    L"\bigvee"          => E"\u22c1",
    L"\bigwedge"        => E"\u22c0",
    L"\bigodot"         => E"\u2a00",
    L"\bigotimes"       => E"\u2a02",
    L"\bigoplus"        => E"\u2a01",
    L"\biguplus"        => E"\u2a04",

    ## binary operations
    L"\pm"              => E"\ub1",
    L"\mp"              => E"\u2213",
    L"\setminus"        => E"\u2216",
    L"\cdot"            => E"\u22c5",
    L"\times"           => E"\ud7",
    L"\ast"             => E"\u2217",
    L"\star"            => E"\u22c6",
    L"\diamond"         => E"\u22c4",
    L"\circ"            => E"\u2218",
    L"\bullet"          => E"\u2219",
    L"\div"             => E"\uf7",
    L"\cap"             => E"\u2229",
    L"\cup"             => E"\u222a",
    L"\uplus"           => E"\u228c", # 228e?
    L"\sqcap"           => E"\u2293",
    L"\sqcup"           => E"\u2294",
    L"\triangleleft"    => E"\u22b2",
    L"\triangleright"   => E"\u22b3",
    L"\wr"              => E"\u2240",
    L"\bigcirc"         => E"\u25cb",
    L"\bigtriangleup"   => E"\u25b3", # == \triangle
    L"\bigtriangledown" => E"\u25bd",
    L"\vee"             => E"\u2228",
    L"\wedge"           => E"\u2227",
    L"\oplus"           => E"\u2295",
    L"\ominus"          => E"\u2296",
    L"\otimes"          => E"\u2297",
    L"\oslash"          => E"\u2298",
    L"\odot"            => E"\u2299",
    L"\dagger"          => E"\u2020",
    L"\ddagger"         => E"\u2021",
    L"\amalg"           => E"\u2210",

    ## relations
    L"\leq"             => E"\u2264",
    L"\prec"            => E"\u227a",
    L"\preceq"          => E"\u227c",
    L"\ll"              => E"\u226a",
    L"\subset"          => E"\u2282",
    L"\subseteq"        => E"\u2286",
    L"\sqsubseteq"      => E"\u2291",
    L"\in"              => E"\u2208",
    L"\vdash"           => E"\u22a2",
    L"\smile"           => E"\u2323",
    L"\frown"           => E"\u2322",
    L"\geq"             => E"\u2265",
    L"\succ"            => E"\u227b",
    L"\succeq"          => E"\u227d",
    L"\gg"              => E"\u226b",
    L"\supset"          => E"\u2283",
    L"\supseteq"        => E"\u2287",
    L"\sqsupseteq"      => E"\u2292",
    L"\ni"              => E"\u220b",
    L"\dashv"           => E"\u22a3",
    L"\mid"             => E"\u2223",
    L"\parallel"        => E"\u2225",
    L"\equiv"           => E"\u2261",
    L"\sim"             => E"\u223c",
    L"\simeq"           => E"\u2243",
    L"\asymp"           => E"\u224d",
    L"\approx"          => E"\u2248",
    L"\cong"            => E"\u2245",
    L"\bowtie"          => E"\u22c8",
    L"\propto"          => E"\u221d",
    L"\models"          => E"\u22a7", # 22a8?
    L"\doteq"           => E"\u2250",
    L"\perp"            => E"\u27c2",

    ## arrows
    L"\leftarrow"       => E"\u2190",
    L"\Leftarrow"       => E"\u21d0",
    L"\rightarrow"      => E"\u2192",
    L"\Rightarrow"      => E"\u21d2",
    L"\leftrightarrow"  => E"\u2194",
    L"\Leftrightarrow"  => E"\u21d4",
    L"\mapsto"          => E"\u21a6",
    L"\hookleftarrow"   => E"\u21a9",
    L"\leftharpoonup"   => E"\u21bc",
    L"\leftharpoondown" => E"\u21bd",
    L"\rightleftharpoons" => E"\u21cc",
    L"\longleftarrow"   => E"\u27f5",
    L"\Longleftarrow"   => E"\u27f8",
    L"\longrightarrow"  => E"\u27f6",
    L"\Longrightarrow"  => E"\u27f9",
    L"\longleftrightarrow" => E"\u27f7",
    L"\Longleftrightarrow" => E"\u27fa",
    L"\hookrightarrow"  => E"\u21aa",
    L"\rightharpoonup"  => E"\u21c0",
    L"\rightharpoondown" => E"\u21c1",
    L"\uparrow"         => E"\u2191",
    L"\Uparrow"         => E"\u21d1",
    L"\downarrow"       => E"\u2193",
    L"\Downarrow"       => E"\u21d3",
    L"\updownarrow"     => E"\u2195",
    L"\Updownarrow"     => E"\u21d5",
    L"\nearrow"         => E"\u2197",
    L"\searrow"         => E"\u2198",
    L"\swarrow"         => E"\u2199",
    L"\nwarrow"         => E"\u2196",

    ## openings
#    L"\lbrack"          => E"[",
#    L"\lbrace"          => E"{",
    L"\langle"          => E"\u27e8",
    L"\lfloor"          => E"\u230a",
    L"\lceil"           => E"\u2308",

    ## closings
#    L"\rbrack"          => E"]",
#    L"\rbrace"          => E"}",
    L"\rangle"          => E"\u27e9",
    L"\rfloor"          => E"\u230b",
    L"\rceil"           => E"\u2309",

    ## alternate names
    L"\ne"              => E"\u2260",
    L"\neq"             => E"\u2260",
    L"\le"              => E"\u2264",
    L"\ge"              => E"\u2265",
    L"\to"              => E"\u2192",
    L"\gets"            => E"\u2192",
    L"\owns"            => E"\u220b",
    L"\land"            => E"\u2227",
    L"\lor"             => E"\u2228",
    L"\lnot"            => E"\uac",
    L"\vert"            => E"\u2223",
    L"\Vert"            => E"\u2225",

    ## extensions
    L"\deg"             => E"\ub0",
    L"\degr"            => E"\ub0",
    L"\degree"          => E"\ub0",
    L"\degrees"         => E"\ub0",
    L"\arcdeg"          => E"\ub0",
    L"\arcmin"          => E"\u2032",
    L"\arcsec"          => E"\u2033",
]