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
and says which volume it is ("Volume 2 of 3"), followed by the title page and
the imprint of the front matter. If the book has a table of contents in its
frontmatter, that is repeated at the start of every volume as well.

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

## The front matter

The conversion starts the book with a cover page of its own, and renders the front matter of the
document after it, in the order in which it appears in the document. Where the document has a list
of contents, that is, a `list` with `lic` elements inside a `level1` of the front matter, a
generated table of contents takes its place. The heading in front of that list is left out, because
memoir prints a heading of its own.

The cover page shows the author and the title. They are taken from the `docauthor` and the
`doctitle` of the document, which may contain markup, and from the `dc:Creator` and `dc:Title`
metadata when the document has no `docauthor` or `doctitle`. The publisher is taken from the
`dc:Publisher` metadata.

A name that is too long for one line reads better broken where it makes sense than wherever it
happens to fit. In the `docauthor` and the `doctitle` that is a `br` element; in the metadata, which
cannot carry markup, a line break in the value itself is honoured.

### Title pages and colophons

A `level1` with class `titlepage` is set as a title page rather than as a chapter: it gets no
chapter heading of its own, it starts on a recto page, and every `level2` inside it starts a page.
The first one repeats the author and the title above its content. When the book is split into
volumes, the title page is repeated in every volume.

A `level1` with class `colophon` is an ordinary level that starts a page, which makes it the place
for an imprint, a copyright notice or a word of thanks. A colophon in the front matter is repeated
in every volume along with the title page, because every volume is bound as a book of its own and
carries the imprint of that book. A colophon in the rear matter belongs to the work as a whole and
stays where it is.

On the title page itself, that is in the first `level2`, and on a colophon the last block of the
page is set at the foot of the page, which is where the publisher respectively the imprint belongs.
That means the lines that belong at the foot want to be a *single* block, so use a `linegroup` for
them. The pages after the first one of a title page, where a publisher puts the copyright, the
address and the ISBN, run on as they are written.

A title page and a colophon are display material: the lines of a `linegroup` are set with a little
air between them rather than tight the way the lines of a poem are. A break *within* a line, a `br`
element, stays tight, so a name too long for one line still reads as one name rather than as two
items.

~~~xml
<level1 class="colophon">
  <p>This large print book is an accessible copy of a work protected by copyright.</p>
  <linegroup>
    <line>Published by Example Books, Zurich</line>
    <line>www.example.com</line>
    <line>Example Books 2026</line>
  </linegroup>
</level1>
~~~

## Markup that is recognized by its class

A few typographic conventions are not expressed by an element of their own but by a class on an
element. These are rendered:

| Markup                              | Rendered as                               |
|-------------------------------------|-------------------------------------------|
| `p` with class `precedingemptyline` | a blank line in front of the paragraph    |
| `p` with class `precedingseparator` | three asterisks in front of the paragraph |
| `span` with class `answer`          | a rule to write an answer on              |
| `span` with class `answer_1`        | a shorter rule, for a one word answer     |
| `span` with class `box`             | a box to tick                             |

The EPUB 3 to DTBook conversion generates `precedingemptyline` and `precedingseparator` from an
`hr` element, so a book that was converted from EPUB 3 keeps its blank lines and its separators.

The classes `answer`, `answer_1` and `box` come from the [Nordic Guidelines for the Production of
Accessible EPUB 3](https://format.mtm.se/nordic_epub/2020-1/). The content of a `span` with one of
these classes is not printed, only the rule or the box is.

### Line numbers

A line number is normally a `linenum` element at the start of a `line`, and is set in the left
margin:

~~~xml
<linegroup>
  <line><linenum>12</linenum> a numbered line of a poem</line>
</linegroup>
~~~

For a book where whole chapters are numbered line by line, `line` and `linegroup` are often not
usable, because the numbered lines carry paragraphs, blockquotes and the like. A `span` with class
`linenum` can be used instead, anywhere in the text:

~~~xml
<p><span class="linenum">5</span> The line numbers of a prose text, where a line
<span class="linenum">6</span> is not a line of a poem but a line of the original.</p>
~~~

A line number in the middle of a paragraph starts a new line, so that the number is set in the
margin of the line it belongs to.

## Languages

The conversion generates a few phrases of its own: the volume numbering on the cover of a book that
is split into volumes, and the heading above the endnotes. By default they are written in the
language of the document, which is taken from the `dc:Language` metadata, or from the `xml:lang`
attribute of the `dtbook` element when there is no such metadata. The same language is given to the
babel package, which takes care of everything else, such as the heading above the table of contents.

English, German and Swiss German phrases are provided. To add a language, add it to <a
href="../src/main/resources/xml/i18n.xml" class="userdoc">`i18n.xml`</a>. The `%1` and `%2` in a
phrase are replaced by the number of the volume and the number of volumes. A translation is looked
up by language tag and a tag falls back to the language without the region.

In some cases you might want these phrases not in the language of the book but in the language of
whoever produces it: a library in Zürich writes "Grossdruck" (Swiss German spelling) on the cover of
a book whose text is in the German of Germany. A producer whose house language differs from the
language of the books can therefore set the "Language of the generated phrases" option
(`producer-language`), and the language of the document goes on steering the hyphenation and the
typographic conventions whatever that option says.

The number of volumes is written out in words, which is why `i18n.xml` also holds the numbers from
1 to 50. A language that has no words for the numbers gets the number itself, so "Large print book
in 3 volumes" rather than a number word in the wrong language.

## See also

* [memoir class documentation](http://texdoc.net/pkg/memoir)
* [Examples](../src/test/xprocspec/test_dtbook-to-latex.script.xprocspec)
