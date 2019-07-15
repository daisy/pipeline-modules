<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:template match="/">
    <d:fileset>
      <xsl:for-each-group select="//d:clip" group-by="@src">
        <!--
            Add "temp-audio-file" attribute as a safety so that px:rm-audio-files, to which this
            d:fileset document is passed later on, does not delete just any files.
        -->
        <d:file href="{current-grouping-key()}" temp-audio-file=""/>
      </xsl:for-each-group>
    </d:fileset>
  </xsl:template>

</xsl:stylesheet>
