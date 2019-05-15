<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                name="main"
                type="px:epub3-load-spine-documents"
                version="1.0">
    
    <p:input port="fileset" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>A fileset using the root of the EPUB as the base path. Usually created using the px:epub3-load step.</p>
        </p:documentation>
    </p:input>
    <p:input port="in-memory" sequence="true"/>
    
    <p:output port="result" sequence="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
        </p:documentation>
    </p:import>
    
    <p:import href="load-package-document.xpl"/>
    <p:import href="opf-spine-to-fileset.xpl"/>
    
    <px:epub3-load-package-document px:message="Loading package document">
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:epub3-load-package-document>
    
    <px:opf-spine-to-fileset px:message="Listing files in spine in reading order">
        <p:with-option name="base-uri" select="base-uri(/*)">
            <p:pipe port="fileset" step="main"/>
        </p:with-option>
    </px:opf-spine-to-fileset>
    
    <px:fileset-load px:message="Loading spine documents">
        <p:input port="in-memory">
            <p:pipe port="in-memory" step="main"/>
        </p:input>
    </px:fileset-load>
    
</p:declare-step>
