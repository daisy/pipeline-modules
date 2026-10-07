<link rel="dp2:permalink" href="http://daisy.github.io/pipeline/Get-Help/User-Guide/Scripts/dtbook-to-latex/"/>
<link rev="dp2:doc" href="../src/main/resources/xml/dtbook-to-latex.script.xpl"/>
<link rel="rdf:type" href="http://www.daisy.org/ns/pipeline/userdoc"/>

# DTBook to LaTeX

Transforms a DTBook (DAISY 3 XML) document into a LaTeX document.

The LaTeX is meant to be typeset with XeLaTeX into a large print book. It uses
the [memoir](http://texdoc.net/pkg/memoir) class.

## Table of contents

{{>toc}}

## Synopsis

{{>synopsis}}

## Multiple volumes

A large print book quickly becomes too thick to bind as one volume, so the
conversion can split the book into several volumes. Each volume starts on a
recto page with a cover page of its own, which repeats the author and the title
and says which volume it is ("Volume 2 of 3"). If the book has a table of
contents in its frontmatter, it is repeated at the start of every volume.

Set the "Words per volume" option to the number of words that fit in a volume.
The number of volumes follows from the length of the book, and the words are
then spread evenly over that many volumes, so a volume usually holds fewer
words than asked for: a book a little longer than one volume comes out as two
halves rather than as a full volume and a stub. A higher value gives fewer and
thicker volumes.

Only the text that is actually printed is counted. The list of contents in the
frontmatter is left out, for instance, because it is not printed as a list but
replaced by a generated table of contents.

A volume never starts in the middle of a paragraph. Moreover, if the point where
the volume ran full is close to the start or the end of an enclosing level,
list, poem, blockquote or sidebar, the volume starts at the boundary of that
block instead, so that these are not torn apart. A volume may be up to 15%
longer or shorter than asked for to make this work out.

### Choosing the volume boundaries by hand

Instead of letting the conversion decide, the volume boundaries can also be
marked up in the DTBook, by adding the class `volume-split-point` to the element
that should start a new volume:

~~~xml
<level1 class="volume-split-point">
  <h1>Chapter that starts the second volume</h1>
  ...
~~~

A document that is marked up this way is split into volumes whether the "Words
per volume" option is set or not. When it *is* set, the automatic splitting is
skipped: the split points in the document win.

### Endnotes

When the "Endnotes" option is set to `document`, all the notes are printed
together at the very end of the book instead of at the bottom of the page that
references them. Their words are counted at that position accordingly, which
means the notes end up in the last volume. That last volume can therefore come
out bigger than asked for, and with a heavily annotated book it is worth
checking whether it is still of a reasonable size.

A volume cannot start in the middle of the notes, because they are printed as
one block. If the notes do not fit in a volume, set "Endnotes" to `chapter`
instead: the notes are then printed at the end of the chapter that references
them, which spreads them over the whole book and lets the volumes be split
normally.

## See also

* [memoir class documentation](http://texdoc.net/pkg/memoir)
* [Examples](../src/test/xprocspec/test_dtbook-to-latex.script.xprocspec)
