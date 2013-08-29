<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-result-prefixes="xs"
    version="2.0">

  <xsl:param name="tmp-word-tag"/>
  <xsl:param name="tmp-sentence-tag"/>
  <xsl:param name="can-contain-sentences"/>    

  <xsl:param name="output-ns"/>    
  <xsl:param name="output-sentence-tag"/>   

  <!-- the words need an additional pair (attr, val) because they cannot be -->
  <!-- identified later on otherwise, unlike the sentences which are -->
  <!-- identified thanks to their id. -->
  <xsl:param name="output-word-tag"/>
  <xsl:param name="word-attr" select="''"/>
  <xsl:param name="word-attr-val" select="''"/>

  <xsl:template match="/">
    <xsl:variable name="sentence-ids-tree">
      <d:sentences>
	<xsl:apply-templates select="*" mode="sentence-ids"/>
      </d:sentences>      
    </xsl:variable>
    <xsl:apply-templates select="node()">
      <xsl:with-param name="sentence-ids-tree" select="$sentence-ids-tree"/>
    </xsl:apply-templates>
    <xsl:result-document href="sids.xml" method="xml">
      <xsl:copy-of select="$sentence-ids-tree"/>
    </xsl:result-document>
  </xsl:template>

  <!--========================================================= -->
  <!-- WRITE THE SENTENCE IDS ON THE SECONDARY PORT             -->
  <!--========================================================= -->

  <xsl:variable name="ok-list" select="concat(',', $can-contain-sentences, ',')"/>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" mode="sentence-ids" priority="2">
    <xsl:choose>
      <xsl:when test="contains($ok-list, concat(',', local-name(..), ','))">
	<d:sentence id="{if (@id) then (@id) else generate-id()}"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="children" select="*[count(descendant::*[local-name() = $tmp-word-tag]) > 0]" />
	<xsl:choose>
	  <xsl:when test="count($children) = 1">	  
	    <d:sentence id="{if ($children[1]/@id) then ($children[1]/@id) else generate-id($children[1])}"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <d:sentence id="{if (../@id) then (../@id) else generate-id(..)}"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="*" mode="sentence-ids"/>
  </xsl:template>
  
  <xsl:template match="*" mode="sentence-ids" priority="1">
    <xsl:apply-templates  select="*" mode="sentence-ids"/>
  </xsl:template>

  <!--======================================================== -->
  <!-- REGENERATION OF THE CONTENT INCLUDING SENTENCES AND     -->
  <!-- WORDS REPLACED WITH VALID EQUIVALENT ELEMENTS           -->
  <!--======================================================== -->

  <xsl:template match="@*|node()">
    <xsl:param name="sentence-ids-tree"/>
    <xsl:copy>
      <xsl:if test="$sentence-ids-tree/*/*[@id = generate-id(current())]">
	<xsl:attribute name="id">
	  <xsl:value-of select="generate-id()"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()">
	<xsl:with-param name="sentence-ids-tree" select="$sentence-ids-tree"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-word-tag]" priority="2">
    <xsl:param name="sentence-ids-tree" select="/"/>
    <xsl:element name="{$output-word-tag}" namespace="{$output-ns}">
      <xsl:if test="$word-attr != ''">
	<xsl:attribute name="{$word-attr}">
	  <xsl:value-of select="$word-attr-val"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" mode="default-cpy"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[local-name() = $tmp-sentence-tag]" priority="2">
    <xsl:param name="sentence-ids-tree"/>
    <xsl:variable name="myid" select="if (@id) then (@id) else generate-id()"/>
    <xsl:choose>
      <xsl:when test="$sentence-ids-tree/*/*[@id = $myid]">
	<xsl:element name="{$output-sentence-tag}" namespace="{$output-ns}">
	  <xsl:if test="not(@id)">
	    <xsl:attribute name="id">
	      <xsl:value-of select="generate-id()"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:apply-templates select="@*|node()" mode="default-cpy"/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="@*|node()">
	  <!-- current node is not a true sentence -->
	  <!-- => we keep looking for sentences in this branch -->
	  <xsl:with-param name="sentence-ids-tree" select="$sentence-ids-tree"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

