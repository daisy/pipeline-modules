<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xpath-default-namespace="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all">

    <xsl:include href="http://www.daisy.org/pipeline/modules/common-utils/generate-id.xsl"/>

    <xsl:key name="ids" match="*[@id]" use="@id"/>
    
    <xsl:template match="/*" priority="1">
        <xsl:call-template name="pf:next-match-with-generated-ids">
            <xsl:with-param name="prefix" select="'id_'"/>
            <xsl:with-param name="for-elements"
                            select="//*[@id][not(key('ids',@id)[1] is .)]|
                                    //body[not(@id)]|
                                    //article[not(@id)]|
                                    //aside[not(@id)]|
                                    //nav[not(@id)]|
                                    //section[not(@id)]|
                                    //h1[not(@id)]|
                                    //h2[not(@id)]|
                                    //h3[not(@id)]|
                                    //h4[not(@id)]|
                                    //h5[not(@id)]|
                                    //h6[not(@id)]|
                                    //hgroup[not(@id)]|
                                    //*[not(@id)][tokenize(@epub:type,'\s+')='pagebreak']"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Remove duplicate IDs -->

    <xsl:template match="@id">
        <xsl:choose>
            <xsl:when test="key('ids',.)[1] is ..">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="..">
                    <xsl:call-template name="pf:generate-id"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/*">
        <xsl:next-match/>
        <xsl:result-document href="mapping">
            <d:fileset>
                <xsl:for-each select="*">
                    <d:file href="{base-uri()}">
                        <xsl:for-each select=".//*[@id][not(key('ids',@id)[1] is .)]">
                            <d:anchor>
                                <xsl:call-template name="pf:generate-id"/>
                                <xsl:attribute name="original-id" select="@id"/>
                            </d:anchor>
                        </xsl:for-each>
                    </d:file>
                </xsl:for-each>
            </d:fileset>
        </xsl:result-document>
    </xsl:template>

    <!-- Add missing IDs -->

    <xsl:template match="body|article|aside|nav|section">
        <xsl:copy>
            <xsl:if test="empty(@id)">
                <xsl:call-template name="pf:generate-id"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="h1|h2|h3|h4|h5|h6|hgroup">
        <xsl:copy>
            <xsl:if test="empty(@id)">
                <xsl:call-template name="pf:generate-id"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[tokenize(@epub:type,'\s+')='pagebreak']">
        <xsl:copy>
            <xsl:if test="empty(@id)">
                <xsl:call-template name="pf:generate-id"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
