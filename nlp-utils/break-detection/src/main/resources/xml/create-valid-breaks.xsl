<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="xs"
    version="2.0">

  <xsl:param name="tmp-word-tag"/>
  <xsl:param name="tmp-sentence-tag"/>
  <xsl:param name="can-contain-words"/>
  <xsl:param name="special-sentences" select="''"/>

  <xsl:param name="output-ns"/>
  <xsl:param name="output-sentence-tag"/>

  <xsl:key name="sentences" match="*[@id]" use="@id"/>

  <xsl:function name="d:sentid">
    <xsl:param name="node"/>
    <xsl:value-of select="if ($node/@id) then $node/@id else concat('st', generate-id($node))"/>
  </xsl:function>

  <!-- The words need an additional pair (attr, val), otherwise they
       could not be identified later on, unlike the sentences which
       are identified thanks to their id. -->
  <xsl:param name="output-word-tag"/>
  <xsl:param name="word-attr" select="''"/>
  <xsl:param name="word-attr-val" select="''"/>

  <xsl:template match="/">
    <!-- Find all the sentences -->
    <xsl:variable name="sentence-ids-tree">
      <d:sentences>
	<xsl:apply-templates select="*" mode="sentence-ids"/>
      </d:sentences>
    </xsl:variable>
    <!-- Create the sentences and the words -->
    <xsl:apply-templates select="node()">
      <xsl:with-param name="sentence-ids-tree" select="$sentence-ids-tree"/>
    </xsl:apply-templates>
    <!-- Write the list of sentences on the secondary port -->
    <xsl:result-document href="sids.xml" method="xml">
      <xsl:copy-of select="$sentence-ids-tree"/>
    </xsl:result-document>
  </xsl:template>

  <!--========================================================= -->
  <!-- FIND ALL THE SENTENCES' ID                               -->
  <!--========================================================= -->

  <xsl:template match="*" mode="sentence-ids" priority="1">
    <xsl:apply-templates select="*" mode="sentence-ids"/>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" mode="sentence-ids" priority="2">
    <d:sentence id="{d:sentid(.)}"/>
  </xsl:template>

  <xsl:variable name="special-list" select="concat(',', $special-sentences, ',')"/>
  <xsl:template mode="sentence-ids" priority="2"
      match="*[contains($special-list, concat(',', local-name(), ',')) or (local-name() = $output-sentence-tag and count(*) = 1 and count(*[local-name() = $tmp-sentence-tag]) = 1)]">
    <d:sentence id="{d:sentid(.)}" recycled="1"/>
  </xsl:template>

  <!--======================================================== -->
  <!-- INSERT THE SENTENCES USING VALID ELEMENTS COMPLIANT     -->
  <!-- WITH THE FORMAT (e.g. Zedai, DTBook)                    -->
  <!--======================================================== -->

  <!-- A word is guaranteed to be one sentence's descendant. -->

  <xsl:template match="@*|node()">
    <xsl:param name="sentence-ids-tree"/>
    <xsl:variable name="myid" select="d:sentid(.)"/>
    <xsl:variable name="entry" select="key('sentences', $myid, $sentence-ids-tree)"/>
    <xsl:choose>
      <xsl:when test="$entry and $entry/@recycled">
	<xsl:copy copy-namespaces="no">
	  <xsl:apply-templates select="." mode="copy-namespaces"/>
	  <xsl:copy-of select="@*"/>
	  <xsl:if test="not(@id)">
	    <xsl:attribute name="id">
	      <xsl:value-of select="$entry/@id"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:apply-templates select="node()" mode="inside-sentence"/>
	</xsl:copy>
      </xsl:when>
      <xsl:when test="$entry">
	<xsl:element name="{$output-sentence-tag}" namespace="{$output-ns}">
	  <xsl:attribute name="id">
	    <xsl:value-of select="$entry/@id"/>
	  </xsl:attribute>
	  <xsl:apply-templates select="node()" mode="inside-sentence"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy copy-namespaces="no">
	  <xsl:apply-templates select="." mode="copy-namespaces"/>
	  <xsl:apply-templates select="@*|node()">
	    <xsl:with-param name="sentence-ids-tree" select="$sentence-ids-tree"/>
	  </xsl:apply-templates>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--======================================================== -->
  <!-- INSIDE THE SENTENCES (ONCE THEY HAVE BEEN ADDED)        -->
  <!--======================================================== -->

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" mode="inside-sentence" priority="2">
    <!-- Ignore the sentence: a parent node has been recycled to contain the sentence. -->
    <xsl:apply-templates select="node()" mode="inside-sentence"/>
  </xsl:template>

  <xsl:variable name="ok-parent-list" select="concat(',', $can-contain-words, ',')" />
  <xsl:template match="*[local-name() = $tmp-word-tag]" mode="inside-sentence" priority="2">
    <xsl:choose>
      <xsl:when test="contains($ok-parent-list, concat(',', local-name(..), ','))">
	<xsl:element name="{$output-word-tag}" namespace="{$output-ns}">
	  <xsl:if test="$word-attr != ''">
	    <xsl:attribute name="{$word-attr}">
	      <xsl:value-of select="$word-attr-val"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:apply-templates select="node()" mode="inside-sentence"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<!-- The word is ignored. -->
	<xsl:apply-templates select="node()" mode="inside-sentence"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="inside-sentence" priority="1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="." mode="copy-namespaces"/>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="inside-sentence"/>
    </xsl:copy>
  </xsl:template>

  <!-- UTILS -->
  <xsl:template match="*" mode="copy-namespaces">
    <xsl:for-each select="namespace::* except namespace::tmp">
      <xsl:namespace name="{name(.)}" select="string(.)"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

