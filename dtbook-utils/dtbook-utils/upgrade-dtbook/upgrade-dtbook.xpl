<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="upgrade-dtbook" type="px:upgrade-dtbook"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" 
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" 
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc"
    exclude-inline-prefixes="cx">
    <!-- 
        TODO: 
        * copy referenced resources (such as images)
    -->
    <p:documentation>
        <xd:short>Upgrade a DTBook document from version 1.1.0, 2005-1, or 2005-2 to version 2005-3. This module was imported from the Pipeline 1.</xd:short>
        <xd:author>
            <xd:name>Marisa DeMeglio</xd:name>
            <xd:mailto>marisa.demeglio@gmail.com</xd:mailto>
            <xd:organization>DAISY</xd:organization>
        </xd:author>
        <xd:maintainer>Marisa DeMeglio</xd:maintainer>
        <xd:input port="source">DTBook 1.1.0, 2005-1, or 2005-2 document.</xd:input>
        <xd:output port="result">DTBook 2005-3 document.</xd:output>
        
        <cd:converter name="upgrade-dtbook" version="1.0" xmlns:cd="http://www.daisy.org/ns/pipeline/upgrade-dtbook">
            <cd:description>Upgrade to DTBook 2005-3.</cd:description>  
            <cd:arg  name="in"  type="input" port="source" desc="Single DTBook file" optional="false"/>         
            <cd:arg  name="out"  type="output" port="result" desc="The result"/>       
        </cd:converter> 
        
    </p:documentation>

    <p:input port="source" primary="true"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result">
        <p:pipe port="result" step="validate-dtbook"/>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="version" select="dtb:dtbook/@version"/>
    
    <cx:message>
        <p:with-option name="message" select="concat('Input document version: ', $version)"/>    
    </cx:message>
    
    <p:choose name="main">
        <p:when test="$version = '1.1.0'">
            <p:output port="result"/>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook110to2005-1.xsl"/>
                </p:input>
            </p:xslt>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook2005-1to2.xsl"/>
                </p:input>
            </p:xslt>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook2005-2to3.xsl"/>
                </p:input>
            </p:xslt>
        </p:when>
        <p:when test="$version = '2005-1'">
            <p:output port="result"/>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook2005-1to2.xsl"/>
                </p:input>
            </p:xslt>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook2005-2to3.xsl"/>
                </p:input>
            </p:xslt>
        </p:when>
        <p:when test="$version = '2005-2'">
            <p:output port="result"/>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="dtbook2005-2to3.xsl"/>
                </p:input>
            </p:xslt>
        </p:when>
        <p:when test="$version = '2005-3'">
            <p:output port="result"/>
            <cx:message>
                <p:with-option name="message" select="concat('File is already the most recent version: ', $version)"/>
            </cx:message>
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:output port="result"/>
            <cx:message>
                <p:with-option name="message" select="concat('Version not identified: ', $version)"/>
            </cx:message>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    
    
    <p:validate-with-relax-ng name="validate-dtbook">
        <p:input port="source">
            <p:pipe port="result" step="main"/>
        </p:input>
        <p:input port="schema">
            <p:document href="schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
</p:declare-step>
