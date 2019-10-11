using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libffi"], :libffi),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/giordano/Yggdrasil/releases/download/Libffi-v3.2.1-0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Libffi.v3.2.1.aarch64-linux-gnu.tar.gz", "14d36e5eb845398ad875c6b7fec5e56d0c40a1fc98586189d32cf881059355a8"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Libffi.v3.2.1.aarch64-linux-musl.tar.gz", "fdf1c976ee9dc3c89ed593788f579356aa7d07996bc3934bcf04244632d88ec8"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Libffi.v3.2.1.arm-linux-gnueabihf.tar.gz", "b52db9a2bda580b038c093b9ca78249e515eec142f118a01d5da234d9346c95b"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Libffi.v3.2.1.arm-linux-musleabihf.tar.gz", "2c2b5218f345e14ec0552d463ad7fc5977f61fc7f9e04707bf1517db34d0d576"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Libffi.v3.2.1.i686-linux-gnu.tar.gz", "70f56234affc5d4978893f5b7e9bfd8afbb83d8b9c24c8e235d53b0098157d50"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Libffi.v3.2.1.i686-linux-musl.tar.gz", "9fe568a3a5bc80e66a1a1577f39393104d4b3f7dc4dcee37007673657fa88939"),
    Windows(:i686) => ("$bin_prefix/Libffi.v3.2.1.i686-w64-mingw32.tar.gz", "0a0ac472b7b60ca7c644459c60e93ece2042f92969b9c5a07833fdcb53b81adf"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Libffi.v3.2.1.powerpc64le-linux-gnu.tar.gz", "4256ec63eeaeef171e25bf8c80ce000279a03495a3837eda401029d3b597d2c1"),
    MacOS(:x86_64) => ("$bin_prefix/Libffi.v3.2.1.x86_64-apple-darwin14.tar.gz", "454fb7ab1eb1f9746793470e4a3392f3f3ba55d94f7fc302b83c78a555a3238f"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Libffi.v3.2.1.x86_64-linux-gnu.tar.gz", "15a6bb4db2333e54d720acb101e427011566e3434ae65f088964415aa6abb005"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Libffi.v3.2.1.x86_64-linux-musl.tar.gz", "9f2935799f19a2430ac418f334e35a60d0fa0e14d8b4c8cffa71c504914aa71a"),
    FreeBSD(:x86_64) => ("$bin_prefix/Libffi.v3.2.1.x86_64-unknown-freebsd11.1.tar.gz", "2109e1812e4ab78b447a266bc0ede921f6ca0c4b29c6cc367f85c71c3c3f11d4"),
    Windows(:x86_64) => ("$bin_prefix/Libffi.v3.2.1.x86_64-w64-mingw32.tar.gz", "7c19b75bb1ca8970ae3475fed1d72a9a235c911c018fc322702d9c2308cf3ffe"),
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
