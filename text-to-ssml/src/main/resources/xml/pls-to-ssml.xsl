<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pls="http://www.w3.org/2005/01/pronunciation-lexicon"
    xmlns:ssml="http://www.w3.org/2001/10/synthesis"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:param name="provided-lexicons" />
  <xsl:param name="builtin-lexicons" />

  <xsl:key name="pronunciation1" match="*[local-name() = $provided-lexicons]//pls:lexeme" use="lower-case(string-join(pls:grapheme/text(),''))" />
  <xsl:key name="pronunciation2" match="*[local-name() = $builtin-lexicons]//pls:lexeme"
	   use="concat(ancestor-or-self::*[@xml:lang][1]/@xml:lang, lower-case(string-join(pls:grapheme/text(),'')))" />

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select=".//ssml:speak" mode="speak"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- default behaviour: copy everything -->
  <xsl:template match="@*|node()" mode="speak" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="speak"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="ssml:token" mode="speak" priority="2">
    <xsl:copy>
      <!-- get the corresponding lexeme if it exists, depending on the language -->
      <xsl:variable name="pr">
	<xsl:variable name="pr1" select="collection()/key('pronunciation1', lower-case(string-join(text(),'')))"/>
	<xsl:choose>
	  <xsl:when test="$pr1">
	    <xsl:value-of select="$pr1"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="collection()/key('pronunciation2', concat(ancestor-or-self::*[@xml:lang][1]/@xml:lang, lower-case(string-join(text(),''))))"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <!-- use the lexeme's alias or phoneme -->
      <xsl:choose>
	<xsl:when test="count($pr/pls:phoneme) = 1">
	  <ssml:phoneme>
	    <xsl:attribute name="ph">
	      <xsl:value-of select="$pr/pls:phoneme/text()"/>
	    </xsl:attribute>
	    <xsl:attribute name="alphabet">
	      <xsl:variable name="alph" select="$pr/pls:phoneme/@alphabet"/>
	      <xsl:choose>
		<xsl:when test="$alph">
		  <xsl:value-of select="$alph"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$pr/ancestor::pls:lexicon/@alphabet"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:apply-templates select="node()" mode="speak"/>
	  </ssml:phoneme>
	</xsl:when>
	<xsl:when test="count($pr/pls:alias) = 1">
	  <xsl:value-of select="$pr/pls:alias/text()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="node()" mode="speak"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

