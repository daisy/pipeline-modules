<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-result-prefixes="#all">

    <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xsl"/>

    <xsl:param name="flatten" select="'false'"/>
    <xsl:param name="prefix" select="''"/>

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="d:file">
                <xsl:copy>
                    <xsl:copy-of select="@* except @xml:base"/>
                    <xsl:choose>
                        <xsl:when test="$flatten='true'">
                            <!-- remove everything from the path except the file name -->
                            <xsl:variable name="path" as="xs:string*" select="tokenize(@href,'[\\/]+')"/>
                            <xsl:variable name="filename" as="xs:string" select="$path[last()]"/>
                            <xsl:variable name="filename" as="xs:string"
                                          select="if ($filename='') then concat($path[last()-1],'/') else $filename"/>
                            <xsl:attribute name="href" select="concat($prefix,$filename)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- make sure that href is relative to the fileset base -->
                            <xsl:attribute name="href" select="pf:relativize-uri(resolve-uri(@href,base-uri(.)),base-uri(/*))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@original-href">
                        <!-- make sure that original-href is absolute -->
                        <xsl:attribute name="original-href" select="resolve-uri(@original-href, base-uri(.))"/>
                    </xsl:if>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
