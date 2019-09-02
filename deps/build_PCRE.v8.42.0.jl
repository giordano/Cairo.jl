using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true #"--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libpcre"], :libpcre),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/PCRE_jll.jl/releases/download/PCRE-v8.42.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/PCRE.v8.42.0.aarch64-linux-gnu.tar.gz", "cad94565f7e49e598b06f3f88ac64564a698dae0ed8bd7222a17c4bd8eb8f49f"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/PCRE.v8.42.0.aarch64-linux-musl.tar.gz", "973af124f4f0d436f95274aa3edba7dedf6589504af3459afc85129b52b03388"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/PCRE.v8.42.0.arm-linux-gnueabihf.tar.gz", "079c6ef6f7e900827cd69514bd7ef168ec4c748e20bbff6c3ec14dabd47b71fc"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/PCRE.v8.42.0.arm-linux-musleabihf.tar.gz", "fa7cc3983e40f178d3f603d46cf4decea02d371f0895c62372838a805e034294"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/PCRE.v8.42.0.i686-linux-gnu.tar.gz", "3982b22c9b0be1fbec86bdccb278332f71dab574f5b842d493dca1053c9c17df"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/PCRE.v8.42.0.i686-linux-musl.tar.gz", "0d2b0c809b8a4058e5f2c1a2308e69fa64af5709a71714fd2bc705d55c077178"),
    Windows(:i686) => ("$bin_prefix/PCRE.v8.42.0.i686-w64-mingw32.tar.gz", "a353fcc978ad839936180a0103f4ce58e41ae2cb0fad11850c689834a38ba856"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/PCRE.v8.42.0.powerpc64le-linux-gnu.tar.gz", "47caf73d585b5cb3f222875a5f0538aec78951717dfaf10738a5175dd0c12e73"),
    MacOS(:x86_64) => ("$bin_prefix/PCRE.v8.42.0.x86_64-apple-darwin14.tar.gz", "880220e1e5b6590e3e3539c489fc5dd8f15daeea3ad6b1c2e0ed28500b6a6acb"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/PCRE.v8.42.0.x86_64-linux-gnu.tar.gz", "25dd7fef0d0b99b83a3eabe963ab20aef658d3c8700852c2b643123f1f42e9d1"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/PCRE.v8.42.0.x86_64-linux-musl.tar.gz", "877299efd8aa916d17ffa2274bad25afa3f6216b4a574b0c678760459bdab546"),
    FreeBSD(:x86_64) => ("$bin_prefix/PCRE.v8.42.0.x86_64-unknown-freebsd11.1.tar.gz", "97f284cc981dc824ac835f94b71e316c7bf34c7922ce36f05c98589e97af595d"),
    Windows(:x86_64) => ("$bin_prefix/PCRE.v8.42.0.x86_64-w64-mingw32.tar.gz", "ec4801feb89955b07ca0e44d8794d354e8602ca090a0fd8fb6ed9d29ce77a72b"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
