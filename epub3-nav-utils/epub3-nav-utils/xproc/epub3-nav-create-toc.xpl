<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-nav-aggregate" name="main"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    version="1.0">

    <p:input port="source" sequence="true"/>
    <p:output port="result"/>

    <!--TODO honnor the 'untitled' option-->
    <p:option name="untitled" select="'excluded'"/>   <!-- "visible" | "hidden" | "excluded" -->
    <!--TODO honnor the 'sidebar' option-->
    <p:option name="sidebars" select="'excluded'"/>   <!-- "visible" | "hidden" | "excluded" -->
    <!--TODO honnor the 'visible-depth' option-->
    <p:option name="visible-depth" select="-1"/>      <!-- integer -->
    
    <p:for-each>
        <p:xslt>
            <p:input port="stylesheet">
                <!--call a dummy html5 outliner-->
                <!--TODO replace by the html-utils XSLT-->
                <p:document href="../xslt/html5-outliner.xsl"/>
                <!--<p:document href="http://www.daisy.org/pipeline/modules/html-utils/html5-outliner.xsl"/>-->
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:filter select="(//h:ol)[1]"/>
    </p:for-each>
    
    <p:insert match="/h:nav/h:ol" position="first-child">
        <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
                <nav epub:type="toc" xmlns="http://www.w3.org/1999/xhtml"
                    xmlns:epub="http://www.idpf.org/2007/ops">
                    <h1>Table of contents</h1>
                    <ol/>
                </nav>
            </p:inline>
        </p:input>
    </p:insert>
    
    <p:unwrap match="/h:nav/h:ol/h:ol"/>
    
    <!--TODO better handling of duplicate IDs-->
    <p:delete match="@xml:id|@id"/>
</p:declare-step>
