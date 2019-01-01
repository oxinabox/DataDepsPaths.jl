const TRAINIMAGES = "train-images-idx3-ubyte.gz"
const TRAINLABELS = "train-labels-idx1-ubyte.gz"
const TESTIMAGES  = "t10k-images-idx3-ubyte.gz"
const TESTLABELS = "t10k-labels-idx1-ubyte.gz"

const BASEURL = "http://yann.lecun.com/exdb/mnist/"

DataDependency(
    "MNIST",
    """
    Dataset: THE MNIST DATABASE of handwritten digits
    Authors: Yann LeCun, Corinna Cortes, Christopher J.C. Burges
    Website: http://yann.lecun.com/exdb/mnist/
    [LeCun et al., 1998a]
        Y. LeCun, L. Bottou, Y. Bengio, and P. Haffner.
        "Gradient-based learning applied to document recognition."
        Proceedings of the IEEE, 86(11):2278-2324, November 1998
    The files are available for download at the offical
    website linked above. Note that using the data
    responsibly and respecting copyright remains your
    responsibility. The authors of MNIST aren't really
    explicit about any terms of use, so please read the
    website to make sure you want to download the
    dataset.
    """,
    
    TRAINIMAGES => Resolver(joinpath(BASEURL, TRAINIMAGES)),
    TRAINLABELS => Resolver(joinpath(BASEURL, TRAINLABELS)),
    TESTIMAGES => Resolver(joinpath(BASEURL, TESTIMAGES)),
    TESTLABELS => Resolver(joinpath(BASEURL, TESTLABELS)),
))

# Resolver(rpath::Union{AbstractString,AbstactPath}) = Resolver(lpath -> download(rpath, lpath))


#######################################################

