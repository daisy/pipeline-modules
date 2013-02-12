<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-filter" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" exclude-inline-prefixes="cx px">

    <p:input port="source"/>
    <p:output port="result">
        <!--<p:pipe port="result" step="result"/>-->
    </p:output>

    <p:option name="href" select="''"/>
    <p:option name="media-types" select="''">
        <!-- space separated list of whitelisted media types. suppports the glob characters '*' and '?', i.e. "image/*" or "application/*+xml". -->
    </p:option>
    <p:option name="not-media-types" select="''">
        <!-- space separated list of blacklisted media types. suppports the glob characters '*' and '?', i.e. "image/*" or "application/*+xml". -->
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>

    <p:variable name="media-types-regexes" select="replace(replace(replace($media-types,'\+','\\+'),'\?','.'),'\*','.*')"/>
    <p:variable name="not-media-types-regexes" select="replace(replace(replace($not-media-types,'\+','\\+'),'\?','.'),'\*','.*')"/>

    <p:group name="canonical-href-fileset">
        <p:output port="result"/>
        <p:choose>
            <p:when test="$href=''">
                <px:fileset-create/>
            </p:when>
            <p:otherwise>
                <px:fileset-create>
                    <p:with-option name="base" select="replace($href,'[^/]+$','')"/>
                </px:fileset-create>
                <px:fileset-add-entry>
                    <p:with-option name="href" select="$href"/>
                </px:fileset-add-entry>
                <p:xslt>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="fileset-join.canonicalize.xsl"/>
                    </p:input>
                </p:xslt>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:sink/>

    <p:xslt>
        <p:input port="source">
            <p:pipe port="source" step="main"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="fileset-join.canonicalize.xsl"/>
        </p:input>
    </p:xslt>
    <p:viewport match="//d:file">
        <p:variable name="resolved-href" select="resolve-uri(/*/@href,base-uri(/*))"/>

        <!-- filter on whitelisted media-types -->
        <p:choose>
            <p:when test="$media-types=''">
                <!-- filter not used -->
                <p:identity/>
            </p:when>
            <p:when test="not(/*/@media-type='') and true() = (for $media-type-regex in tokenize($media-types-regexes,' ') return matches(/*/@media-type,$media-type-regex))">
                <!-- media-type matches filter -->
                <p:identity/>
            </p:when>
            <p:otherwise>
                <!-- media-type does not match filter -->
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity name="filter-1"/>
        <p:count name="count-1"/>

        <!-- filter on blacklisted media-types -->
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="filter-1"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="number(/*)=0">
                <!-- file did not match previous filter -->
                <p:xpath-context>
                    <p:pipe port="result" step="count-1"/>
                </p:xpath-context>
                <p:identity/>
            </p:when>
            <p:when test="$not-media-types=''">
                <!-- filter not used -->
                <p:identity/>
            </p:when>
            <p:when test="not(/*/@media-type='') and not(true() = (for $not-media-type-regex in tokenize($not-media-types-regexes,' ') return matches(/*/@media-type,$not-media-type-regex)))">
                <!-- media-type matches filter -->
                <p:identity/>
            </p:when>
            <p:otherwise>
                <!-- media-type does not match filter -->
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity name="filter-2"/>
        <p:count name="count-2"/>

        <!-- filter on whitelisted hrefs -->
        <p:identity>
            <p:input port="source">
                <p:pipe port="result" step="filter-2"/>
            </p:input>
        </p:identity>
        <p:choose>
            <p:when test="number(/*)=0">
                <!-- file did not match previous filter -->
                <p:xpath-context>
                    <p:pipe port="result" step="count-2"/>
                </p:xpath-context>
                <p:identity/>
            </p:when>
            <p:when test="$href=''">
                <!-- filter not used -->
                <p:identity/>
            </p:when>
            <p:when test="$resolved-href = resolve-uri(/*/*/@href,base-uri(/*))">
                <!-- href matches filter -->
                <p:xpath-context>
                    <p:pipe port="result" step="canonical-href-fileset"/>
                </p:xpath-context>
                <p:identity/>
            </p:when>
            <p:otherwise>
                <!-- href does not match filter -->
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:viewport>
    <p:identity name="result"/>

</p:declare-step>
