<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                version="2.0">
  
  <xsl:template mode="is-chunk"
                match="/html/body/section[not(epub:has-type(.,'bodymatter') and child::section)]|
                       /html/body/section[epub:has-type(.,'bodymatter')]/section"
                as="xs:boolean">
    <xsl:sequence select="true()"/>
  </xsl:template>
  
  <xsl:function name="epub:has-type" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="type" as="xs:string"/>
    <xsl:sequence select="tokenize($element/@epub:type,'\s+')=$type"/>
  </xsl:function>
  
</xsl:stylesheet>
