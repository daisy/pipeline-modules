<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns="http://www.idpf.org/2007/opf"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">

  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/html">
    <metadata prefix="dc: http://purl.org/dc/elements/1.1/">
      <!--== Title ==-->
      <dc:title>
        <xsl:value-of
          select="if(normalize-space(head/title)) then head/title
          else if (normalize-space(head/body//h1)) then normalize-space(head/body//h1[1])
          else replace(base-uri(/),'.*?([^/]+)\.[^/.]+$','$1')"
        />
      </dc:title>

      <!--== Language ==-->
      <dc:language>
        <xsl:value-of select="(@lang,@xml:lang,'zxx')[1]"/>
      </dc:language>

      <!--== Other ==-->
<!--      <xsl:apply-templates/>-->

    </metadata>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  

</xsl:stylesheet>
