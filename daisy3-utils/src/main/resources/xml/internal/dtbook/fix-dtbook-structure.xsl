<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.daisy.org/z3986/2005/dtbook/"
		xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/"
		exclude-result-prefixes="#all" version="2.0">

  <!-- This script add missing elements so as to make the NCX/OPF/SMIL generation easier. -->

  <xsl:template match="bodymatter" priority="2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="first-level" select="(.//level|.//level1)[1]"/>
      <xsl:choose>
	<xsl:when test="not($first-level)">
	  <!-- Case 1: no levels at all -->
	  <level1>
	    <h1 id="faux-heading">
	      <xsl:variable name="title" select="(//meta[@name='dc:Title'])[1]"/>
	      <xsl:choose>
		<xsl:when test="not($title) or $title/@content = ''">
		  <xsl:value-of select="'Content'"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$title/@content"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </h1>
	    <xsl:apply-templates select="node()"/>
	  </level1>
	</xsl:when>
	<xsl:when test="not((.//hd)[1]|(.//h1)[1]|(.//h2)[1]|(.//h3)[1]|(.//h4)[1]|(.//h5)[1]|(.//h6)[1])">
	  <!-- Case 2: no headings at all -->
	  <xsl:apply-templates select="node()" mode="find-level">
	    <xsl:with-param name="first-level" select="$first-level"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="node()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="level|level1" priority="2" mode="find-level">
    <xsl:param name="first-level" select="()"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="$first-level = .">
	<xsl:apply-templates select="." mode="add-heading"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="find-level">
	<xsl:with-param name="first-level" select="$first-level"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="level" mode="add-heading">
    <hd id="faux-heading">Section</hd>
  </xsl:template>

  <xsl:template match="level1" mode="add-heading">
    <h1 id="faux-heading">Section</h1>
  </xsl:template>

  <xsl:template match="node()|@*" priority="1" mode="find-level">
    <xsl:param name="first-level" select="''"/>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="find-level">
	<xsl:with-param name="first-level" select="$first-level"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()|@*" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
