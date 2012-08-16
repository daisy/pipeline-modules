<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="merge-dtbook" type="px:merge-dtbook"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="cx">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Merge DTBook</h1>
        <p px:role="desc">Merge 2 or more DTBook documents.</p>
        <div px:role="author maintainer">
            <p px:role="name">Marisa DeMeglio</p>
            <a href="mailto:marisa.demeglio@gmail.com" px:role="contact">marisa.demeglio@gmail.com</a>
            <p px:role="organization">DAISY Consortium</p>
        </div>
    </p:documentation>
    <!-- 
        TODO: 
         * copy referenced resources (such as images)
         * deal with xml:lang (either copy once and put in dtbook/@xml:lang or, if different languages are used, copy the @xml:lang attr into the respective sections.
    -->

    <p:input port="source" primary="true" sequence="true" px:name="in"
        px:media-type="application/x-dtbook+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">in</h2>
            <p px:role="desc">Sequence of DTBook files</p>
        </p:documentation>
    </p:input>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">out</h2>
            <p px:role="desc">The result</p>
        </p:documentation>
    </p:output>
    
    <p:option name="assert-valid" required="false" px:type="boolean" select="'true'">
        <p:documentation>
            Whether to stop processing and raise an error on validation issues.
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/validation-utils/validation-utils-library.xpl">
        <p:documentation>
            Collection of utilities for validation and reporting.
        </p:documentation>
    </p:import>

    <cx:message message="Merging DTBook documents"/>

    <p:for-each name="validate-input">
        <p:output port="result">
            <p:pipe step="ident" port="result"/>
        </p:output>

        <p:iteration-source select="/"/>

        <px:validate-with-relax-ng-and-report>
            <p:input port="schema">
                <p:document href="schema/dtbook-2005-3.rng"/>
            </p:input>
            <p:with-option name="assert-valid" select="$assert-valid"/>
        </px:validate-with-relax-ng-and-report>

        <p:identity name="ident"/>

    </p:for-each>

    <p:for-each name="for-each-head">
        <p:iteration-source select="//dtb:dtbook/dtb:head/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:output port="result"/>

        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-head" wrapper="head"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-head" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-frontmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:frontmatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-frontmatter" wrapper="frontmatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-frontmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-bodymatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:bodymatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-bodymatter" wrapper="bodymatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-bodymatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-rearmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:rearmatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-rearmatter" wrapper="rearmatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:wrap-sequence wrapper="dtbook" wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">

        <p:input port="source">
            <p:pipe step="wrap-head" port="result"/>
            <p:pipe step="wrap-frontmatter" port="result"/>
            <p:pipe step="wrap-bodymatter" port="result"/>
            <p:pipe step="wrap-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:add-attribute match="/dtb:dtbook" attribute-name="version" attribute-value="2005-3"/>

    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="remove-duplicates.xsl"/>
        </p:input>
    </p:xslt>

    <px:validate-with-relax-ng-and-report name="validate-dtbook">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
        <p:with-option name="assert-valid" select="$assert-valid"/>
    </px:validate-with-relax-ng-and-report>

</p:declare-step>
