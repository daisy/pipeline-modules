<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                type="px:check-files-wellformed">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1>Check that files exist and are well-formed XML</h1>
        <p>Given a list of files, ensure that each exists and is well-formed XML.</p>
    </p:documentation>

    <!-- ***************************************************** -->
    <!-- INPUT, OUTPUT and OPTIONS -->
    <!-- ***************************************************** -->

    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Input fileset</p>
            <p>Files are assumed to exist on disk</p>
        </p:documentation>
    </p:input>

    <p:output port="result">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Output fileset which contains the well-formed files from <code>source</code>.</p>
        </p:documentation>
        <p:pipe port="result" step="wrap-fileset"/>
    </p:output>

    <p:output port="report">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>List of malformed files, formatted as <code>d:error</code> elements, or an empty
            <code>d:errors</code> element if nothing is missing.</p>
        </p:documentation>
        <p:pipe port="result" step="process-errors"/>
    </p:output>

    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Validation status (http://daisy.github.io/pipeline/StatusXML) of the file check.</p>
        </p:documentation>
        <p:pipe step="format-validation-status" port="result"/>
    </p:output>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-add-entry
            px:fileset-create
            px:fileset-join
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:message
        </p:documentation>
    </p:import>
    <p:import href="check-files-exist.xpl">
        <p:documentation>
            px:check-files-exist
        </p:documentation>
    </p:import>
    <p:import href="create-validation-report-error-for-file.xpl">
        <p:documentation>
            pxi:create-validation-report-error-for-file
        </p:documentation>
    </p:import>
    <p:import href="validation-status.xpl">
        <p:documentation>
            px:validation-status
        </p:documentation>
    </p:import>

    <p:variable name="base" select="/*/@xml:base"/>
    
    <!-- first, make sure that the files exist on disk -->
    <px:check-files-exist name="check-files-exist"/>

    <p:for-each name="check-each-file">
        <p:iteration-source select="//d:file">
            <p:pipe port="result" step="check-files-exist"/>
        </p:iteration-source>
        <p:output port="result" sequence="true">
            <p:pipe port="result" step="try-loading-each-file"/>
        </p:output>
        <p:output port="report" sequence="true">
            <p:pipe port="report" step="try-loading-each-file"/>
        </p:output>

        <p:variable name="filepath" select="resolve-uri(*/@href, $base)"/>
        <p:try name="try-loading-each-file">
            <p:group>
                <p:output port="result" sequence="true">
                    <p:pipe port="result.fileset" step="create-fileset-entry"/>
                </p:output>
                <p:output port="report" sequence="true">
                    <p:pipe port="result" step="empty-error"/>
                </p:output>
                
                <p:load name="load-file">
                    <p:with-option name="href" select="$filepath"/>
                </p:load>
                
                <p:identity name="empty-error">
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
                <p:sink/>
                
                <px:fileset-add-entry name="create-fileset-entry">
                    <p:with-option name="href" select="$filepath"/>
                    <p:input port="source.fileset">
                        <p:inline>
                            <d:fileset/>
                        </p:inline>
                    </p:input>
                </px:fileset-add-entry>
            </p:group>

            <p:catch>
                <p:output port="report" sequence="true">
                    <p:pipe port="result" step="create-error"/>
                </p:output>
                
                <p:output port="result" sequence="true">
                    <p:pipe port="result" step="empty-fileset"/>
                </p:output>
                
                <px:message severity="WARN">
                    <p:with-option name="message"
                        select="concat('File not well-formed XML: ', $filepath)"/>
                </px:message>
                
                <p:identity name="empty-fileset">
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
                
                <pxi:create-validation-report-error-for-file name="create-error">
                    <p:input port="source">
                        <p:pipe port="current" step="check-each-file"/>
                    </p:input>
                    <p:with-option name="error-type" select="'file-not-wellformed'"/>
                    <p:with-option name="desc" select="'File is not well-formed XML'"/>
                    <p:with-option name="base" select="$base"/>
                </pxi:create-validation-report-error-for-file>
            </p:catch>
        </p:try>
        
    </p:for-each>

    <!-- append the error report from the wellformedness check to the report from the initial check-files-exist step -->
    <p:insert match="d:errors" position="last-child" name="process-errors">
        <p:input port="source">
            <p:pipe port="report" step="check-files-exist"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="report" step="check-each-file"/>
        </p:input>    
    </p:insert>
    
    <px:validation-status name="format-validation-status">
        <p:input port="source">
            <p:pipe port="result" step="process-errors"/>
        </p:input>
    </px:validation-status>
    <p:sink/>    

    <p:group name="wrap-fileset">
        <p:output port="result"/>

        <!-- input fileset -->
        <px:fileset-create name="fileset.in-memory-base"/>

        <!-- output fileset -->
        <px:fileset-join>
            <p:input port="source">
                <p:pipe step="fileset.in-memory-base" port="result"/>
                <p:pipe step="check-each-file" port="result"/>
            </p:input>
        </px:fileset-join>
    </p:group>
    <p:sink/>
</p:declare-step>
