# DataDepsPaths.jl ![https://www.tidyverse.org/lifecycle/#experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)


Thinking about a new design for DataDeps (the old one wouldn't go away but the new one would be more flexible). 

The notion would be to be based around paths (as in FilePaths.jl)

A DataDep would be a kind of Path.
Completely resolved lazily

The DataDep would define the root of the path.

When asked for a file (or directory) within that DataDep root,
it would look for a satisfier (matching selecting the first that matches),
then execute it.


## Examples

### Example 1, Simple

```julia
register(
  DataDependency(
    "Root", # i.e. name in current DataDeps.jl
    "Message", # The message is only displayed, if the root local directory is empty,
  )
)

DataDepPath()

```



## Notes from Slack discussion (JuliaLang#data 1/1/2019)


### Lyndon White [10:40 AM]
Thinking about the next advancement of DataDeps.jl.
@evizero are you around to brainstorm?

### Christof Stocker [10:41 AM]
sure. I am just blankly staring at unicodeplot-tests (that i should have finished long ago) anyway

### Lyndon White [10:42 AM]
Some bits and half written notes are at https://github.com/oxinabox/DataDepsPaths.jl/

### Christof Stocker [10:43 AM]
maybe to bring me up to speed. what are the current limitations you want to fix? or is it "just" a design cleanup

### Lyndon White [10:44 AM]
Key limitation is around the thing you brought up, when you want a datadep, but you only want some of the files.
So like subdatadeps.
There is another problem we ran into recently where we have a remote folder which contains records for every day,
so like many GB of data,
and we only want a few days (edited) 

### Christof Stocker [10:47 AM]
right

### Lyndon White [10:47 AM]
So the core change is that it would be path/(file/folder/subfolder) orientated, rather than folder orientated.

### Christof Stocker [10:47 AM]
I'll take a look at MLDatasets real quick to jog my memory

### Lyndon White [10:48 AM]
This issue really
https://github.com/oxinabox/DataDeps.jl/issues/35

### Christof Stocker [10:49 AM]
right i was thinking about SVHN2 right now as well

### Lyndon White [10:50 AM]
I’ve been looking at FilePaths.jl lately and I really like it.
So the notion I have is that a there would be a `DataDepPath`
say `DataDepPath("Name/Foo/bar.csv")`
And there would be a `DataDepedency` with the name `"Name"`
and it would have as part of it a number of what I am calling `satisfiers` (kinda like BinDeps _“providers”_).
And a satisfier would have a way to say what *paths it should satisfy*, and how to resolve it. (Where resolving it normally does something like the current `fetch`,`checksum`,`postfetch`) (edited) 

### Christof Stocker [10:58 AM]
so what triggers what. if I say `datadep"Foo/bar.csv"` it only requests the download of that file and returns that single path, while `datadep"Foo"` downloads and returns all files. right?
is a satisfier linked to each individual file?

### Lyndon White [10:59 AM]
So I think satisfiers need to be linked to more than file.
Say the file structure is
 ```- Foo
        - AyeDir
               - ayefile.csv
               - beefile.csv
        - BeeDir
        - cee.txt
 ```
So `datadep"Foo"` should result in the download of everything.
`datadep"Foo/AyeDir"` should result in the download/creation of `AyeDir/ayefile.csv` and `AyeDir/beefile.csv`,
and this might be down by downloading a zip file for `AyeDir` and extracting it.

### Christof Stocker [11:05 AM]
right so `datadep"Foo/AyeDir/ayefile.csv"` might do the same as its not really an individual file to download

### Lyndon White [11:05 AM]
Exactly.
`datadep"Foo/AyeDir/ayefile.csv` should result in the creation of `AyeDir/ayefile.csv`.
And in the previous senario that would be be done by the download of the `AyeDir` zip, and its extraction, and so it would also creation of `AyeDir/beefile.csv`.

### Christof Stocker [11:06 AM]
right makes perfect sense, yes

### Lyndon White [11:09 AM]
So a satisfier needs to define a set of files it would satify.
I was thinking for full generality this might want to be a function, though I am not sure.
It being a list would be too annoying for things with lots of files.
Maybe Glob.jl or something glob like.
So you can say
`Satisfier(glob"AyeDir/**",   download_and_extract("http://example.com/Aye.zip")`

### Christof Stocker [11:11 AM]
I think I understand. I'll think on this during my lunch now

### Lyndon White [11:13 AM]
I’ll just get out the rest of the thought (feel free not to reply if you are eating)

let me complicated the previous structure.
 ```
 - Foo
        - AyeDir
               - ayefile.csv
               - beefile.csv
        - BeeDir
               - x.txt
               - y.txt
               - z.txt
        - cee.txt
```
        
Let’s say individual satisfiers were defined
```
Satisfier("BeeDir/x.txt", download("http://example.com/x.txt")),
Satisfier("BeeDir/y.txt", download("http://example.com/y.txt")),
Satisfier("BeeDir/z.txt", download("http://example.com/z.txt")),

```
And you asked for `datadep"Foo/BeeDir"`.
Now it needs to go an resolve all three satisfiers.
So the tricky part i think really is how to determine the match part of the `Satisfier`,
to cover both the cases where one `Satisfier`, solves multiple `DataDepPath`s,
and the case where one `DataDepPath` is requires resolving multiple `Satisfier`s (edited) 

### Christof Stocker [11:36 AM]
`Satisfier("...", () -> download("..."))` you mean, right?
I think that makes sense. do you have a full mock definition of a dataset somewhere?

### Lyndon White [11:38 AM]
no, not yet.
Assembling a few of those would help

### Christof Stocker [11:38 AM]
I do like it conceptually. the question is more what the boilerplate is

### Lyndon White [11:40 AM]
I’m not sure on how to be  specifying matching for Satisfiers.
(I’ll be back in 15)

### Christof Stocker [11:46 AM]
but i think that matching logic should at least be doable. With that in mind it might be more informative to find a good syntax first (edited) 
Which may be done already, but I am having a hard time visualizing it

### Lyndon White [12:05 PM]
Hmm, I guess things would be simplified a lot it hierarchical structure was required upon Satisfiers and the paths they fill.
So that you couldn’t have for example a `Satisfier` that provides just `["AyeDir/ayefile.csv", "BeeDir/x.txt]`.
and maybe you couldn’t have one that provides `["BeeDir/x.txt", "BeeDir/y.txt"]` without also providing `"BeeDir/z.txt"` (edited) 

### Christof Stocker [12:08 PM]
My main point is that if you try to translate existing real world datadep definitions to the new form, you might encounter issues/questions you wouldn't otherwise think about
and it seems like you are at that point in your design phase
where the big picture makes sense

### Lyndon White [1:16 PM]
1 example in, MNIST>
idk where exactly checksums fit into this now.
I guess as part of a `Resolver`.
https://github.com/oxinabox/DataDepsPaths.jl/blob/master/test/examples.jl

### Lyndon White [1:22 PM]
I think writing `Satisfiers` as `Pairs` is nice.
Oh for the use case I mentioned before, with the 1 file per day.
The remote URL actually needs to be generated from the local path…
Maybe that could be written as
`local_basename -> Resolver(joinpath(rurl, local_basename)`
Which would have nice symmetry for that dynamic case to the  static case being written as
`"Foo" => Resolver(joinpath(rurl, "Foo"))`

### Christof Stocker [1:29 PM]
is this an either/or? in the sense that either all are provided as `"foo" => ...` or as a single function

### Lyndon White [1:31 PM]
I think static named folder paths  can have dynamic (or static)  named subfiles/subfolders but I am not sure if dynamic named subfolders could have subitems at all, I guess they could.

### Christof Stocker [1:33 PM]
https://github.com/oxinabox/DataDepsPaths.jl/blob/master/test/examples.jl#L56
how does BeeDir know to unpack?
should this be a nested `Resolver`?
oh wait. I think I am confused

### Lyndon White [1:35 PM]
Because `BeeDir` is a `Vector` on the RHS

### Christof Stocker [1:35 PM]
right its just a "virtual" folder more or less
not a zip file

### Lyndon White [1:36 PM]
It would be a real folder on disk is what I am thinking.

### Christof Stocker [1:36 PM]
makes sense

### Lyndon White [1:36 PM]
But it doesn’t correspond to a Zip file, but to a a list of other ( I guess you could call them) _sub-satifiers_ (edited) 

### Christof Stocker [1:37 PM]
I still think (like outlined in the issue you linked to that i opened)  it would be nice if they unpack stage was a bit more priviledged

### Christof Stocker [1:39 PM]
in the sense that imagine I have a dataset that when downloaded is a bunch of mat files. that is the native format. I would like to say what the local dowloaded mat file would be called so that i can check if someone put them there manually. if they aren't there I would like to download them. then I would like to process them into a different format with a different local file name
This almost works right now except there is no way to manually download the raw files and then have DataDeps just do the post_fetch

### Christof Stocker [1:41 PM]
I think it would almost be possible to implement this if only the local file name way known. like

```
"AyeDir" => Resolver("http://example.com/Aye.zip", unpack, "Aye.zip")
```

### Christof Stocker [1:41 PM]
i guess in most cases one could deduce the file name anyway

### Christof Stocker [1:41 PM]
from the url

### Lyndon White [1:43 PM]
What if code take makes partial products, was also handled as a `Satisfier`? (maybe we can get rid of the seperation of `fetch` from `post_fetch`)
E.g

```
"Foo.mat" => Resolvers("http://eg.com/Foo.mat"),
"Foo.jld" => Resolver(() -> convert_mat2jld(DataDepPath("Name/Foo.mat"))
```


### Christof Stocker [1:49 PM]
mhm intruiging

### Christof Stocker [1:51 PM]
maybe
```"Foo.jld" => Resolver(DataDepPath("Name/Foo.mat"), convert_mat2jld)```

### Lyndon White [2:00 PM]
replied to a thread:



Right, I see now.
I think I like the idea of using `Satisifiers` for it better. Feels less adhoc.
So one would have a Satisfier for `AyeDir` that unpacks `Aye.zip`,
and a Satisfier for `Aye.zip` that downloads it.

Interestly, it is safe to delete `Aye.zip` as part of satisfying `AyeDir`, if one wants. If you expect that noone will want to `Aye.zip` once they have `AyeDir`. (edited) View newer replies

### Lyndon White [2:16 PM]
One could maybe be using a dynamic satisfier to do something like
```
"Foo.mat" => Resolvers("http://eg.com/Foo.mat"),
"Bar.mat" => Resolvers("http://eg.com/Bar.mat"),
jldfile -> Resolver(DataDepPath("Name/" * replace(jldfile, ".jld"=>".mat"Foo.mat")), convert_mat2jld)
```
(edited)

### Christof Stocker [2:19 PM]
so the function is basically the default if nothing else matches?

### Lyndon White [2:19 PM]
Yeah that was what I was thinking.
One problem with dynamic satisfiers, is that it is impossible to resolve them as part of resolving their parent folder.
So if we had
```
"Foo" => filename -> Resolver(joinpath(rurl,"Foo", filename)),
```
then doing  `download(DataDepPath("Foo"))`,
would not actually be able to download anything.

### Christof Stocker [2:23 PM]
right
well to play devils advocate, using it doesn't have to make sense at every possible place. the utility at those that do is pretty good though

### Lyndon White [2:26 PM]
Which 2 features?
(This has been a big discussion. So it would be good to me to know what you see as the two big take aways.)

### Christof Stocker
the other two aspects feel like great features though
From a thread in #dataToday at 2:13 PMView reply

### Christof Stocker [2:28 PM]
1. to support predownloaded raw files that then only cause the post_fetch_method to be executed

### Christof Stocker [2:29 PM]
2. to support downloading only required files if requested, or the whole dataset if requested, and still have it all in one place

### Lyndon White [2:31 PM]
3. to support downloading files with remote name dependent on (runtime) local name (dynamic satisfiers)
Ok, I am going to dump this discussion into a markdown file on github. Thanks a bunch
