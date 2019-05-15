<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                name="main"
                type="px:epub3-load-package-document"
                version="1.0">
    
    <p:input port="fileset" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>A fileset using the root of the EPUB as the base path. Usually created using the px:epub3-load step.</p>
        </p:documentation>
    </p:input>
    <p:input port="in-memory" sequence="true"/>
    
    <p:output port="result"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
        </p:documentation>
    </p:import>
    
    <px:fileset-load href="META-INF/container.xml" fail-on-not-found="true" px:message="Loading META-INF/container.xml">
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:fileset-load>
    
    <px:fileset-load fail-on-not-found="true" px:message="Loading OPF">
        <p:with-option name="href" select="(//*:rootfile/resolve-uri(@full-path, replace(base-uri(.), '[^/]+/[^/]+$', '')))[1]"/>
        <p:input port="fileset">
            <p:pipe port="fileset" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:fileset-load>
    
</p:declare-step>
