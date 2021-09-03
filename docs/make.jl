using SSCF
using Documenter

DocMeta.setdocmeta!(SSCF, :DocTestSetup, :(using SSCF); recursive=true)

makedocs(;
    modules=[SSCF],
    authors="Thomas Foerster <tfoerster@sablesys.com> and contributors",
    repo="https://github.com/hawkmoth/SSCF.jl/blob/{commit}{path}#{line}",
    sitename="SSCF.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://hawkmoth.github.io/SSCF.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/hawkmoth/SSCF.jl",
)
