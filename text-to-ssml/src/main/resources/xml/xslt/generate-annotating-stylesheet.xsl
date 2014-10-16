<meta:stylesheet xmlns:meta="http://www.w3.org/1999/XSL/Transform"
		 xmlns:xsl="anything-but-the-xsl-namespace"
		 xmlns:tts="http://www.daisy.org/ns/pipeline/tts"
		 xmlns:ssml="http://www.w3.org/2001/10/synthesis"
		 version="2.0">

  <meta:namespace-alias stylesheet-prefix="xsl" result-prefix="meta"/>

  <!-- Note: elements that do not contain any sentence and elements
       not contained by any sentence will not be annotated. -->

  <meta:template match="/">
    <xsl:stylesheet version="2.0" xmlns:ssml="http://www.w3.org/2001/10/synthesis" xmlns:tts="http://www.daisy.org/ns/pipeline/tts">

      <!-- Map the before/after nodes to existing SSML sentences -->
      <xsl:key name="before" match="tts:before" use="@id"/>
      <xsl:key name="after" match="tts:after" use="@id"/>

      <xsl:variable name="mapping">
	<tts:map>
	  <xsl:for-each select="//*">
	    <xsl:variable name="lang" select="current()/ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
	    <xsl:variable name="short-lang" select="tokenize($lang, '-')[1]"/>
	    <xsl:variable name="annotations">
	      <xsl:apply-templates select="current()"/>
	    </xsl:variable>
	    <xsl:if test="$annotations/*">
	      <xsl:variable name="translated-annot" select="$annotations//*[@xml:lang = $lang or @xml:lang=$short-lang][1]"/>
	      <xsl:variable name="parent-sent" select="current()/ancestor-or-self::ssml:s[@id]"/>
	      <xsl:choose>
		<xsl:when test="$parent-sent">
		  <tts:before>
		    <xsl:attribute name="id"><xsl:value-of select="tts:mapping-id(current())"/></xsl:attribute>
		    <xsl:sequence select="$translated-annot/*[local-name() = 'before']/node()"/>
		  </tts:before>
		  <tts:after>
		    <xsl:attribute name="id"><xsl:value-of select="tts:mapping-id(current())"/></xsl:attribute>
		    <xsl:sequence select="$translated-annot/*[local-name() = 'after']/node()"/>
		  </tts:after>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:variable name="children-sent" select="current()/descendant::ssml:s[@id]"/>
		  <xsl:if test="$children-sent">
		    <tts:before>
		      <xsl:attribute name="id"><xsl:value-of select="$children-sent[1]/@id"/></xsl:attribute>
		      <xsl:sequence select="$translated-annot/*[local-name() = 'before']/node()"/>
		  </tts:before>
		  <tts:after>
		    <xsl:attribute name="id"><xsl:value-of select="$children-sent[last()]/@id"/></xsl:attribute>
		    <xsl:sequence select="$translated-annot/*[local-name() = 'after']/node()"/>
		  </tts:after>
		  </xsl:if>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:if>
	  </xsl:for-each>
	</tts:map>
      </xsl:variable>

      <!-- Insert the text thanks to the mapping -->
      <xsl:template match="/">
	<xsl:apply-templates select="node()" mode="insert-text"/>
      </xsl:template>

      <xsl:template match="*" mode="insert-text" priority="2">
	<xsl:variable name="id" select="tts:mapping-id(.)"/>
	<xsl:variable name="before" select="key('before', $id, $mapping)"/>
	<xsl:variable name="after" select="key('after', $id, $mapping)"/>
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:if test="$before">
	    <xsl:value-of select="' '"/>
	    <xsl:copy-of select="$before/node()"/>
	    <xsl:value-of select="' '"/>
	  </xsl:if>
	  <xsl:apply-templates select="node()" mode="insert-text"/>
	  <xsl:if test="$after">
	    <xsl:value-of select="' '"/>
	    <xsl:copy-of select="$after/node()"/>
	    <xsl:value-of select="' '"/>
	  </xsl:if>
	</xsl:copy>
      </xsl:template>

      <xsl:template match="node()" mode="insert-text" priority="1">
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:apply-templates select="node()" mode="insert-text"/>
	</xsl:copy>
      </xsl:template>

      <xsl:function name="tts:mapping-id">
	<xsl:param name="node"/>
	<xsl:value-of select="if ($node/@id) then $node/@id else concat('mapid-', generate-id($node))"/>
      </xsl:function>

      <!-- Copy the user's rules -->
      <meta:copy-of select="collection()[/meta:stylesheet]/meta:stylesheet/meta:variable"/>
      <meta:copy-of select="collection()[/meta:stylesheet]/meta:stylesheet/meta:template"/>
      <meta:copy-of select="collection()[/meta:stylesheet]/meta:stylesheet/meta:function"/>
      <xsl:template match="node()">
	<!-- no annotation -->
      </xsl:template>

    </xsl:stylesheet>
  </meta:template>

</meta:stylesheet>
