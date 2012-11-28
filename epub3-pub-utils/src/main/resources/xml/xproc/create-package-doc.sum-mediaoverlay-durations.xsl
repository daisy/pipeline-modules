<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mo="http://www.w3.org/ns/SMIL" xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
    xmlns="http://www.idpf.org/2007/opf" xpath-default-namespace="http://www.idpf.org/2007/opf"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:include href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/clock-functions.xsl"/>
    <xsl:template match="/*">
        <meta property="media:duration">
            <xsl:value-of
                select="pf:mediaoverlay-seconds-to-clock-value(round-half-to-even(sum(//meta/pf:mediaoverlay-clock-value-to-seconds(.)), 4))"
            />
        </meta>
    </xsl:template>
</xsl:stylesheet>
