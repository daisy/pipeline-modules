<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:include href="$stylesheet"/>

  <xsl:output method="xhtml" indent="yes"/>

  <xsl:variable name="doc" select="/"/>

  <xsl:key name="ids" match="*" use="@id|@xml:id"/>

  <xsl:variable name="chunks" as="document-node()*">
    <xsl:apply-templates select="/*" mode="chunking"/>
  </xsl:variable>
  
  <xsl:variable name="chunks-ids" as="xs:string*" select="$chunks/generate-id()"/>

  <xsl:function name="f:chunk-name">
    <xsl:param name="chunk" as="document-node()"/>
    <xsl:sequence
      select="replace(base-uri($doc/*),'.*?([^/]+)(\.[^.]+)$',concat('$1-',index-of($chunks-ids,generate-id($chunk)),'$2'))"
    />
  </xsl:function>

  <xsl:template match="/">
    <xsl:for-each select="$chunks">
      <xsl:result-document href="{replace(base-uri($doc/*),'([^/]+)$',f:chunk-name(.))}">
        <xsl:apply-templates select="/*"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@href[starts-with(.,'#')]">
    <xsl:variable name="refid" select="substring(.,2)" as="xs:string"/>
    <xsl:variable name="refchunk" select="$chunks[key('ids',$refid,.)]"/>
    <xsl:if test="empty($refchunk)">
      <xsl:message>Unable to resolve link to '<xsl:value-of select="."/>'</xsl:message>
    </xsl:if>
    <xsl:attribute name="href"
      select="if (empty($refchunk) or / = $refchunk) then .
              else concat(f:chunk-name($refchunk),.)"
    />
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="chunking" match="*">
    <xsl:variable name="this" select="."/>
    <xsl:for-each-group select="text()[normalize-space()]|*"
                        group-adjacent="exists(descendant-or-self::*[f:is-chunk(.)])">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:for-each select="current-group()">
            <xsl:choose>
              <xsl:when test="f:is-chunk(.)">
                <xsl:call-template name="copy-ancestors">
                  <xsl:with-param name="nodes" select="."/>
                  <xsl:with-param name="original-parent" select="$this"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates mode="#current" select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copy-ancestors">
            <xsl:with-param name="nodes" select="current-group()"/>
            <xsl:with-param name="original-parent" select="$this"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template name="copy-ancestors">
    <xsl:param name="nodes" as="node()*" required="yes"/>
    <xsl:param name="original-parent" as="element()" required="yes"/>
    <xsl:variable name="wrapped">
      <xsl:element name="{local-name($original-parent)}" namespace="{namespace-uri($original-parent)}">
        <xsl:sequence select="$original-parent/@*"/>
        <xsl:sequence select="$nodes"/>
      </xsl:element>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$original-parent/parent::*">
        <xsl:call-template name="copy-ancestors">
          <xsl:with-param name="nodes" select="$wrapped"/>
          <xsl:with-param name="original-parent" select="$original-parent/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$wrapped"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="f:is-chunk" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:apply-templates mode="is-chunk" select="$node"/>
  </xsl:function>

  <xsl:template mode="is-chunk" priority="-100" match="node()" as="xs:boolean">
    <xsl:sequence select="false()"/>
  </xsl:template>

</xsl:stylesheet>
