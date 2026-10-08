<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
		exclude-result-prefixes="#all">

  <!-- Mark the places in a DTBook where a new volume should start, so that the document can be
       rendered as multiple volumes by dtbook-to-latex.xsl, which inserts a volume cover page at
       every element with class 'volume-split-point'.

       The splitting is done as follows:
       - Divide the words of the whole book by $words_per_volume to get the number of volumes, and
         divide the words by that again to get the words that actually go in a volume, so that the
         volumes come out equally thick.
       - Walk through all paragraphs while counting words, and mark a paragraph as a split point as
         soon as the words since the last split point exceed that number.
       - Then, if a split point happens to be near the start or the end of an enclosing block
         (a level, list, poem, blockquote or sidebar), move it to the boundary of that block, so
         that the block is not torn apart. $allowed_stretch defines how much a volume may be
         stretched or shortened for this.

       Notes and annotations are counted where they sit in the document, which is where they will be
       printed for endnotes='none' (a footnote on the page that references it) and, near enough, for
       endnotes='chapter'. For endnotes='document' they are all printed together at the end of the
       document instead, and move-notes-to-end.xsl is expected to have moved them there first, so
       that counting them in place is correct again.

       A split point can never be placed inside a note or annotation, because a volume cover page
       inside a note is not rendered at all. With endnotes='document' the whole endnotes section
       therefore ends up in the last volume, which may make that volume bigger than asked for.

       Note that marking the note element itself instead of its content does not help: the notes are
       not printed where they sit. Their text is captured at the dtb:noteref that references them
       (\pagenote) and the whole apparatus is printed in one go at the end of the document
       (\printpagenotes), so a split point anywhere in the block of notes renders as a volume cover
       in front of the entire block, and two of them render as two covers in a row with an empty
       volume in between. Splitting the endnotes section itself would mean printing the notes as
       ordinary content rather than leaving them to memoir. For a book with a notes apparatus too
       big for one volume, endnotes='chapter' is the way out: the notes are then printed at the end
       of the chapter that references them, so they are spread over the whole book. -->

  <xsl:output method="xml" encoding="utf-8" indent="no"/>

  <!-- The most words that may go in a volume. The volumes are made equally thick, so they hold
       this many words at most and typically fewer. 0 means: do not split. -->
  <xsl:param name="words_per_volume" select="0"/>

  <!-- How much a volume may be stretched or shortened in order to make a split point coincide with
       the start or the end of an enclosing block, as a fraction of $words_per_volume. Not exposed
       as a script option. -->
  <xsl:param name="allowed_stretch" select="0.15"/>

  <xsl:variable name="block-names" as="xs:string*"
		select="('level1','level2','level3','linegroup','poem','sidebar','blockquote','list')"/>

  <!-- Count the words of a given paragraph, leaving out those of the paragraphs nested inside it
       (the p of a list item, the items of a nested list), which are counted on their own -->
  <xsl:function name="f:wc" as="xs:integer">
    <xsl:param name="para" as="element()"/>
    <xsl:variable name="own-text"
		  select="$para//text()[ancestor::*[self::dtb:p or self::dtb:li or self::dtb:line][1] is $para]"/>
    <!-- the text is joined as it is, so that a word split by inline markup, such as
         H<sub>2</sub>O, stays one word -->
    <xsl:sequence select="count(tokenize(normalize-space(string-join($own-text, '')), '\s+'))"/>
  </xsl:function>

  <!-- Determine the paragraphs where a volume should be split, i.e. the paragraphs where the
       number of words since the last split point is greater than the wanted words per volume -->
  <xsl:function name="f:split" as="element()*">
    <xsl:param name="words-so-far" as="xs:double"/>
    <xsl:param name="words-per-volume" as="xs:double"/>
    <xsl:param name="paragraphs" as="element()*"/>
    <xsl:variable name="head" select="$paragraphs[1]"/>
    <xsl:variable name="tail" select="$paragraphs[position() gt 1]"/>
    <xsl:choose>
      <xsl:when test="empty($paragraphs)">
	<xsl:sequence select="()"/>
      </xsl:when>
      <!-- Never split inside a note or annotation: its content is not printed at this position, so
           a split point here would not correspond to any real content boundary. -->
      <xsl:when test="$words-so-far ge $words-per-volume
		      and not($head/ancestor::dtb:note or $head/ancestor::dtb:annotation)">
	<xsl:sequence select="$head, f:split(0, $words-per-volume, $tail)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:sequence select="f:split($words-so-far + f:wc($head), $words-per-volume, $tail)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Given a paragraph within a level, linegroup, poem, sidebar, blockquote or list, move to the
       beginning or the end of that block if it is within a certain threshold of words -->
  <xsl:function name="f:closest-block" as="element()">
    <xsl:param name="split-point" as="element()"/>
    <xsl:param name="allowed-stretch-in-words" as="xs:double"/>
    <xsl:variable name="blocks" select="$split-point/ancestor::dtb:*[local-name()=$block-names]"/>
    <xsl:choose>
      <xsl:when test="exists($blocks)">
	<xsl:variable name="move-before"
		      select="($blocks[sum(for $p in (descendant::dtb:p intersect $split-point/preceding::*)
					   return f:wc($p))
				       &lt; $allowed-stretch-in-words])[1]"/>
	<xsl:variable name="move-after"
		      select="($blocks[sum(for $p in (descendant::dtb:p intersect ($split-point,$split-point/following::*))
					   return f:wc($p))
				       &lt; $allowed-stretch-in-words])[1]"/>
	<xsl:choose>
	  <xsl:when test="exists($move-before) and exists($move-after)">
	    <xsl:sequence select="if (count($move-before/ancestor::*) le count($move-after/ancestor::*))
				  then $move-before
				  else $move-after/following::dtb:*[local-name()=($block-names,'p')][1]"/>
	  </xsl:when>
	  <xsl:when test="exists($move-before)">
	    <xsl:sequence select="$move-before"/>
	  </xsl:when>
	  <xsl:when test="exists($move-after)">
	    <xsl:sequence select="$move-after/following::dtb:*[local-name()=($block-names,'p')][1]"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:sequence select="$split-point"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:sequence select="$split-point"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- A table of contents in the frontmatter is not printed as a list: dtbook-to-latex.xsl drops it
       and generates a table of contents instead. Its words are therefore not counted. -->
  <xsl:variable name="not-printed" select="//dtb:frontmatter/dtb:level1/dtb:list[descendant::dtb:lic]"/>

  <xsl:variable name="paragraphs"
		select="(//dtb:p|//dtb:li|//dtb:line) except $not-printed//(dtb:p|dtb:li|dtb:line)"/>

  <xsl:variable name="total-words" as="xs:double" select="sum(for $p in $paragraphs return f:wc($p))"/>

  <!-- The number of volumes follows from the words that are to go in one, and the words are then
       spread evenly over that many volumes. A book one paragraph longer than a volume is therefore
       split into two halves rather than into a full volume and a stub. -->
  <xsl:variable name="volumes" as="xs:integer"
		select="if (number($words_per_volume) gt 0)
			then xs:integer(ceiling($total-words div number($words_per_volume)))
			else 0"/>

  <xsl:variable name="words-per-volume" as="xs:double"
		select="if ($volumes gt 0) then $total-words div $volumes else 0"/>

  <!-- Split points that are already in the document, e.g. inserted by hand -->
  <xsl:variable name="pre-marked" as="xs:boolean"
		select="exists(//*['volume-split-point'=tokenize(@class,'\s+')])"/>

  <xsl:variable name="split-points" as="element()*"
		select="if ($words-per-volume gt 0 and not($pre-marked))
			then (for $split-point in f:split(0, $words-per-volume, $paragraphs)
			      return f:closest-block($split-point,
						     ceiling($words-per-volume * number($allowed_stretch))))
			else ()"/>

  <xsl:template match="/">
    <xsl:if test="$pre-marked and $words-per-volume gt 0">
      <xsl:message>The document already contains volume split points. Not inserting any
      more.</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:linegroup|dtb:poem|dtb:sidebar|
		       dtb:blockquote|dtb:list|dtb:p">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="some $split-point in $split-points satisfies . is $split-point">
	<xsl:attribute name="class"
			select="normalize-space(string-join((@class,'volume-split-point'),' '))"/>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all other elements and attributes -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
