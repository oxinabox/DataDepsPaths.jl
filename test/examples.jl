const TRAINIMAGES = "train-images-idx3-ubyte.gz"
const TRAINLABELS = "train-labels-idx1-ubyte.gz"
const TESTIMAGES  = "t10k-images-idx3-ubyte.gz"
const TESTLABELS = "t10k-labels-idx1-ubyte.gz"

const BASEURL = "http://yann.lecun.com/exdb/mnist/"

DataDependency(
    "MNIST-static",
    "Dataset: THE MNIST DATABASE of handwritten digits\nAuthors: Yann LeCun, Corinna Cortes, Christopher J.C. Burges\n Website: http://yann.lecun.com/exdb/mnist/ \n[LeCun et al., 1998a] \n\t Y. LeCun, L. Bottou, Y. Bengio, and P. Haffner. \n\t\"Gradient-based learning applied to document recognition.\" \n\tProceedings of the IEEE, 86(11):2278-2324, November 1998 \n\n The files are available for download at the offical website linked above. Note that using the data responsibly and respecting copyright remains your responsibility. The authors of MNIST aren't really explicit about any terms of use, so please read the website to make sure you want to download the dataset.",        
    TRAINIMAGES => Resolver(joinpath(BASEURL, TRAINIMAGES)),
    TRAINLABELS => Resolver(joinpath(BASEURL, TRAINLABELS)),
    TESTIMAGES => Resolver(joinpath(BASEURL, TESTIMAGES)),
    TESTLABELS => Resolver(joinpath(BASEURL, TESTLABELS)),
))

# Resolver(rpath::Union{AbstractString,AbstactPath}) = Resolver(lpath -> download(rpath, lpath))

DataDependency(
    "MNIST-dynamic",
    "Dataset: THE MNIST DATABASE of handwritten digits\nAuthors: Yann LeCun, Corinna Cortes, Christopher J.C. Burges\n Website: http://yann.lecun.com/exdb/mnist/ \n[LeCun et al., 1998a] \n\t Y. LeCun, L. Bottou, Y. Bengio, and P. Haffner. \n\t\"Gradient-based learning applied to document recognition.\" \n\tProceedings of the IEEE, 86(11):2278-2324, November 1998 \n\n The files are available for download at the offical website linked above. Note that using the data responsibly and respecting copyright remains your responsibility. The authors of MNIST aren't really explicit about any terms of use, so please read the website to make sure you want to download the dataset.",    
    fn -> Resolver(joinpath(BASEURL, fn)),
))


#######################################################
# Fake example




DataDependency(
    "Fake example",
    """
        - AyeDir # This is a zip archieve that must be extracted
               - ayefile.csv
               - beefile.csv
        - BeeDir
               - x.txt
               - y.txt
               - z.txt
        - cee.txt
    """,
    
    "AyeDir" => Resolver("http://example.com/Aye.zip", unpack),
    "BeeDir" => [
        "x.txt" => Resolver("http://example.com/x.txt"),
        "y.txt" => Resolver("http://example.com/y.txt"),
        "z.txt" => Resolver("http://example.com/z.txt"),
    ],
    "cee.txt" => Resolver("http://example.com/cee.txt")
))

@test isfile(DataDepPath("Fake example/AyeDir/ayefile.csv"))
@test isfile(DataDepPath("Fake example/AyeDir/beefile.csv"))

@test isfile(DataDepPath("Fake example/BeeDir/x.csv"))
@test isfile(DataDepPath("Fake example/BeeDir/y.csv"))
@test isfile(DataDepPath("Fake example/BeeDir/z.csv"))

@test isfile(DataDepPath("Fake example/Cee.txt"))
