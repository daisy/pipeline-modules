<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="skippable-elements" />
  <xsl:param name="pronounce-references" select="'true'"/>

  <!-- must have the same value as in the Java part -->
  <xsl:variable name="mark-delimiter" select="'___'"/>

  <xsl:variable name="reshaped-skippable-elements" select="concat(',', $skippable-elements, ',')" />

  <!-- This could be moved to a place where the format (DTBook, HTML etc.) is known. -->
  <xsl:variable name="dictionaries">
    <tmp:lang lang="fr">
      <tmp:entry type="noteref" say="note $1"/>
      <tmp:entry type="annoref" say="annotation $1"/>
    </tmp:lang>
    <tmp:lang lang="en">
      <tmp:entry type="noteref" say="note $1"/>
      <tmp:entry type="annoref" say="annotation $1"/>
    </tmp:lang>
  </xsl:variable>
  <xsl:key name="translate" match="*[@type]" use="@type"/>

  <xsl:template match="/">
    <xsl:variable name="main-lang" select="tokenize((//*[@xml:lang])[1]/@xml:lang, '-')[1]"/>
    <xsl:variable name="dictionary" select="if ($pronounce-references) then $dictionaries//*[@lang=$main-lang] else ()"/>
    <xsl:copy>
      <xsl:element name="{name(/*)}" namespace="{namespace-uri(/*)}">
	<xsl:copy-of select="/*/@*"/>
	<xsl:apply-templates select="/*/node()"/>
	<!-- The skippable types are processed separately in order to
	     build groups on which the CSS properties can apply. -->
	<xsl:variable name="doc-context" select="/"/>
	<xsl:for-each select="tokenize($skippable-elements, ',')">
	  <xsl:variable name="skippable" select="string(current())"/>
	  <xsl:variable name="all-skippable" select="$doc-context//*[local-name() = $skippable]"/>
	  <xsl:if test="$all-skippable">
	    <tmp:group> <!-- Makes possible to the Java-step to process the following sentence in a separate thread. -->
	      <!-- Adding a non-existing element here allows us to apply
		   CSS properties on the whole sentence, especially the
		   engine name which is customizable at the sentence-level
		   only (not inside the sentences). -->
	      <xsl:element name="{$skippable}" namespace="http://www.daisy.org/ns/pipeline/tmp">
		<!-- The id does not matter here because it won't be visible in the output document. -->
		<!-- Only the ssml:marks' id will be visible. -->
		<ssml:s id="{concat('group-of-', $skippable)}">
		  <xsl:for-each select="$all-skippable">
		    <xsl:variable name="id" select="if (current()/@id) then (current()/@id) else (current()/../@id)"/>
		    <xsl:if test="$id">
		      <ssml:mark name="{concat($mark-delimiter, $id)}"/>
		      <xsl:variable name="say" select="key('translate', $skippable, $dictionary)/@say"/>
		      <xsl:apply-templates select="current()" mode="copy-ref">
			<xsl:with-param name="say" select="if ($say) then $say else '$1'"/>
		      </xsl:apply-templates>
		      <ssml:mark name="{concat($id, $mark-delimiter)}"/>
		      <xsl:value-of select="' , '"/> <!-- break in prosody -->
		    </xsl:if>
		  </xsl:for-each>
		</ssml:s>
	      </xsl:element>
	    </tmp:group>
	  </xsl:if>
	</xsl:for-each>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|*" mode="copy-ref">
    <xsl:param name="say"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
	<xsl:with-param name="say" select="$say"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <!-- There should be only one text node in the ref. -->
    <xsl:param name="say"/>
    <xsl:value-of select="replace(., '^(.)+$', $say)"/>
  </xsl:template>

  <xsl:template match="@*|node()" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@id and ((count(*|text()) = 1
		       and contains($reshaped-skippable-elements, concat(',', *[1]/local-name(), ',')))
		       or contains($reshaped-skippable-elements, concat(',', local-name(), ',')))]"
		priority="2">

    <ssml:mark name="{concat(preceding-sibling::*[@id][1]/@id, $mark-delimiter, following-sibling::*[@id][1]/@id)}"/>
  </xsl:template>

</xsl:stylesheet>

