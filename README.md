# DataDepsPaths.jl ![https://www.tidyverse.org/lifecycle/#experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)


Thinking about a new design for DataDeps (the old one wouldn't go away but the new one would be more flexible). 

The notion would be to be based around paths (as in FilePaths.jl)

A DataDep would be a kind of Path.
Completely resolved lazily

The DataDep would define the root of the path.

When asked for a file (or directory) within that DataDep root,


