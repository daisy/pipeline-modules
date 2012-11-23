<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-filter" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" exclude-inline-prefixes="cx px">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name="href" select="''"/>
    <p:option name="media-types" select="''"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="resolved-href" select="resolve-uri($href,base-uri(/*))"/>
    
    <p:viewport match="//d:file">
        <!-- filter on media-types -->
        <p:choose>
            <p:when test="$media-types=''">
                <p:identity/>
            </p:when>
            <p:when test="not(/*/@media-type='') and /*/@media-type=tokenize($media-types,' ')">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity name="filter-1"/>
        <p:count name="count-1"/>
        
        <!-- filter on href -->
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="filter-1"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="number(/*)=0">
                <p:xpath-context>
                    <p:pipe port="result" step="count-1"/>
                </p:xpath-context>
                <p:identity/>
            </p:when>
            <p:when test="$href=''">
                <p:identity/>
            </p:when>
            <p:when test="resolve-uri(/*/@href,base-uri(/*))=$resolved-href">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:viewport>
    
</p:declare-step>
