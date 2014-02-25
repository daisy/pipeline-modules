<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:import href="flatten-css.xsl"/>

  <xsl:param name="skippable-elements"/>
  <xsl:param name="style-ns"/>
  <xsl:param name="pronounce-references" select="'true'"/>

  <!-- must have the same value as in the Java part -->
  <xsl:variable name="mark-delimiter" select="'___'"/>
  <xsl:variable name="skippable-list" select="concat(',', $skippable-elements, ',')" />

  <!-- This could be moved to a place where the format (DTBook, HTML etc.) is known. -->
  <xsl:variable name="dictionaries">
    <tmp:lang lang="fr">
      <tmp:entry type="noteref" say="note $1"/>
      <tmp:entry type="annoref" say="annotation $1"/>
      <tmp:entry type="pagenum" say="page $1"/>
    </tmp:lang>
    <tmp:lang lang="en">
      <tmp:entry type="noteref" say="note $1"/>
      <tmp:entry type="annoref" say="annotation $1"/>
      <tmp:entry type="pagenum" say="page $1"/>
    </tmp:lang>
    <tmp:lang lang="default">
    </tmp:lang>
  </xsl:variable>
  <xsl:key name="translate" match="*[@type]" use="@type"/>

  <xsl:variable name="skippable-properties">
    <d:sks>
      <xsl:for-each select="//*[contains($skippable-list, concat(',', local-name(), ','))]">
	<d:sk id="{@id}">
	  <xsl:apply-templates select="current()" mode="flatten-css-properties">
	    <xsl:with-param name="style-ns" select="$style-ns"/>
	  </xsl:apply-templates>
	</d:sk>
      </xsl:for-each>
    </d:sks>
  </xsl:variable>
  <xsl:key name="skippables" match="*[@id]" use="@id"/>

  <xsl:variable name="main-lang" select="tokenize((//*[@xml:lang])[1]/@xml:lang, '-')[1]"/>
  <xsl:variable name="dictionary" select="if ($pronounce-references = 'true')
					  then $dictionaries//*[@lang=$main-lang or @lang='default'][1]
					  else $dictionaries//*[@lang='default']"/>

  <xsl:template match="/">
    <tmp:root>
      <!-- Group skippable elements with the same CSS properties. -->
      <xsl:for-each-group select="//*[contains($skippable-list, concat(',', local-name(), ','))]"
			  group-by="key('skippables', @id, $skippable-properties)/concat(string-join(@*[namespace-uri()=$style-ns]/local-name(),'_'), string-join(@*[namespace-uri()=$style-ns],'_'))">
	<ssml:speak version="1.1"> <!-- version 1.0 has no <ssml:token> nor <ssml:w> -->
	  <ssml:s id="{concat('cousins-of-',@id)}">
	    <xsl:copy-of select="key('skippables', current-group()[1]/@id, $skippable-properties)/@*[local-name() != 'id']"/>
	    <xsl:for-each select="current-group()">
	      <!-- TODO: merge the adjacent marks with the syntax 'idleft__idright' to speed up the TTS. -->
	      <ssml:mark name="{concat($mark-delimiter, @id)}"/>
	      <xsl:variable name="say" select="key('translate', local-name(current()), $dictionary)/@say"/>
	      <xsl:apply-templates select="current()/node()" mode="inside-skippable">
		<xsl:with-param name="say" select="if ($say) then $say else '$1'"/>
	      </xsl:apply-templates>
	      <xsl:value-of select="','"/> <!-- force the processor to end the pronunciation with a neutral prosody. -->
	      <ssml:mark name="{concat(@id, $mark-delimiter)}"/>
	      <xsl:value-of select="' . '"/> <!-- force the processor to reinitialize the prosody state. -->
	      </xsl:for-each>
	  </ssml:s>
	</ssml:speak>
      </xsl:for-each-group>
    </tmp:root>
  </xsl:template>

  <xsl:template match="@*|*" mode="inside-skippable">
    <xsl:param name="say"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="inside-skippable">
        <xsl:with-param name="say" select="$say"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="inside-skippable">
    <!-- There should be only one text node in the ref. -->
    <xsl:param name="say"/>
    <xsl:value-of select="replace(., '^(.)+$', $say)"/>
  </xsl:template>

</xsl:stylesheet>

