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
    input format is a sequence of these documents:
    http://code.google.com/p/daisy-pipeline/wiki/ValidationReportXML
    -->
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="toc" required="false" select="'false'"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
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
                        <div id="header"><h1>Validation Results</h1><ul id="document-index"/></div>
                    </body>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="result" step="convert-to-html"/>
        </p:input>
    </p:insert>
    
    <p:choose>
        <p:when test="$toc eq 'true'">
            <p:for-each name="generate-document-index">
                <p:output port="result"/>
                
                <p:iteration-source select="//xhtml:div[@class='document-validation-report']"/>
                
                <p:variable name="section-id" select="*/@id"/>
                <p:variable name="document-name" select="*/xhtml:div[@class='document-info']/xhtml:h2"/>
                
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <li xmlns="http://www.w3.org/1999/xhtml">
                                <a href="@@">@@</a>
                            </li>
                        </p:inline>
                    </p:input>
                </p:identity>
                
                <p:string-replace match="xhtml:a/@href">
                    <p:with-option name="replace" select="concat('&quot;', '#', $section-id, '&quot;')"/>
                </p:string-replace>
                
                <p:string-replace match="xhtml:a/text()">
                    <p:with-option name="replace" select="concat('&quot;', $document-name, '&quot;')"/>
                </p:string-replace>
                
                
            </p:for-each>   
            
            <p:insert match="xhtml:ul[@id='document-index']" position="first-child">
                <p:input port="source">
                    <p:pipe port="result" step="assemble-html-report"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe port="result" step="generate-document-index"/>
                </p:input>
            </p:insert>
            
        </p:when>
        <p:otherwise>
            <p:delete match="xhtml:ul[@id='document-index']"></p:delete>
        </p:otherwise>
    </p:choose>
        
</p:declare-step>
