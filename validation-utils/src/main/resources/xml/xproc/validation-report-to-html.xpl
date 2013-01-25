<p:declare-step version="1.0" name="validation-report-to-html" type="px:validation-report-to-html"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" 
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-inline-prefixes="#all">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Validation Report to HTML</h1>
        <p px:role="desc">Combines a series of validation reports into one single HTML report.</p>
    </p:documentation>

    <!-- 
    the document(s) on this port can be in several different formats:
    
    * RNG validation result: <c:errors/>
    
    * Schematron validation result: <svrl:schematron-output/>
    
    * wrapped together, with optional info about the file the report(s) represent
    
    to create this wrapper, use create-validation-report-wrapper.xpl 
    
    <d:document-validation-report>
        <d:document-info>
            <d:document-name>display name</d:document-name>
            <d:document-path>filepath</d:document-path>
            <d:document-type>description of what the document was validated against</d:document-type>
        </d:document-info>
        <d:reports>
            <svrl:schematron-output/>
            <c:errors/>
        </d:reports>
    </d:document-validation-report>
            
    -->
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true"/>

    <p:for-each name="convert-to-html">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="source" step="validation-report-to-html"/>
        </p:iteration-source>
        
        <p:xslt name="htmlify-validation-report">
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/validation-report-to-html.xsl"/>
            </p:input>
        </p:xslt>
        
    </p:for-each>
    
    <p:wrap-sequence name="combine-reports" wrapper="div" wrapper-namespace="http://www.w3.org/1999/xhtml"/>
        
    
    <p:insert position="last-child" match="//xhtml:body" name="assemble-html-report">
        <p:input port="source">
            <p:inline>
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <head>
                        <title>Validation Results</title>
                        <style type="text/css"> 
                            body { 
                            font-family: helvetica; 
                            } 
                            pre { 
                            white-space: pre-wrap; /* css-3 */ 
                            white-space: -moz-pre-wrap; /*Mozilla, since 1999 */ 
                            white-space: -pre-wrap; /* Opera 4-6 */
                            white-space: -o-pre-wrap; /* Opera 7 */ 
                            word-wrap: break-word; /*Internet Explorer 5.5+ */ 
                            } 
                            li.error div { 
                            display: table; 
                            border: gray thin solid; 
                            padding: 5px; 
                            } 
                            li.error div h3 { 
                            display: table-cell; 
                            padding-right: 10px; 
                            font-size: smaller; 
                            } 
                            li.error div pre { 
                            display: table-cell; 
                            } 
                            li { 
                            padding-bottom: 15px; 
                            } 
                        </style>
                    </head>
                    <body>
                        <div id="header">Validation Results</div>
                    </body>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="combine-reports"/>
        </p:input>
    </p:insert>    
</p:declare-step>
