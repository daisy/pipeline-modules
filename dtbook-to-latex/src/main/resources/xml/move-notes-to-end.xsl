<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
		exclude-result-prefixes="#all">

  <!-- When notes and annotations are typeset as endnotes for the whole document
       (endnotes='document'), they are all deferred and printed together at the very end of the
       document, no matter where in the book they were referenced. The word count based volume
       splitting in insert-volume-split-points.xsl has no way of knowing this: it counts each
       note's words where the note happens to sit in the XML, which is wrong once the text is
       printed somewhere else entirely.

       This stylesheet fixes the mismatch at the source: when endnotes='document' it moves every
       note and annotation to the end of the document, in their original order, so that the word
       order in the XML matches the order in which the text will be printed.

       This does not affect the LaTeX output: dtbook-to-latex.xsl renders a note at the position of
       the dtb:noteref that references it (looked up by @id anywhere in the document) and renders
       nothing where the note itself sits.

       For endnotes='none' and endnotes='chapter' the notes are printed where they are referenced,
       respectively at the end of their own chapter, so the document is left untouched. -->

  <xsl:output method="xml" encoding="utf-8" indent="no"/>

  <xsl:param name="endnotes" select="'none'"/>

  <!-- Where the notes are moved to: the last level in document order. Both numbered (dtb:level1)
       and unnumbered (dtb:level) levels are taken into account. -->
  <xsl:variable name="target" as="element()?" select="(//dtb:level1|//dtb:level)[last()]"/>

  <xsl:variable name="move-notes" as="xs:boolean" select="$endnotes = 'document' and exists($target)"/>

  <xsl:template match="/">
    <xsl:if test="$endnotes = 'document' and empty($target)">
      <xsl:message>Could not find a level to move the notes to. Leaving them where they are, which
      may result in unevenly sized volumes.</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dtb:note|dtb:annotation">
    <xsl:if test="not($move-notes)">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dtb:level1|dtb:level">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xsl:if test="$move-notes and . is $target">
	<xsl:copy-of select="//dtb:note|//dtb:annotation"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all other elements and attributes -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
