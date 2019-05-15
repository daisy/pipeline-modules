<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                name="main"
                type="px:epub3-load-navigation-document"
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
    
    <p:import href="load-package-document.xpl"/>
    
    <px:epub3-load-package-document px:message="Loading package document">
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:epub3-load-package-document>
    
    <px:fileset-load px:message="Loading navigation document">
        <p:with-option name="href" select="(/*/*:manifest/*[tokenize(@properties,'\s+') = 'nav']/resolve-uri(@href, base-uri(.)))[1]"/>
        <p:input port="fileset">
            <p:pipe port="fileset" step="main"/>
        </p:input>
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:fileset-load>
    
</p:declare-step>
