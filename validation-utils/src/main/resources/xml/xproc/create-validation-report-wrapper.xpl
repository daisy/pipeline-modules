<p:declare-step version="1.0" name="create-validation-report-wrapper" type="px:create-validation-report-wrapper"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:tmp="http://www.daisy.org/ns/pipeline/tmp" 
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:l="http://xproc.org/library" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="#all">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Create Valdation Report Wrapper</h1>
        <p px:role="desc">Wrap one or more validation reports and optional document data. This prepares it for the validation-report-to-html step.</p>
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A validation report</p>
        </p:documentation>
    </p:input>
    <p:option name="document-name" required="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">document-name</h1>
            <p px:role="desc">The name of the document that was validated. Used for display purposes.</p>
        </p:documentation>
    </p:option>
    <p:option name="document-type" required="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">document-type</h1>
            <p px:role="desc">The type of the document. Used for display purposes.</p>
        </p:documentation>
    </p:option>
    <p:option name="document-path" required="false" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">document-path</h1>
            <p px:role="desc">The full path to the document, if available.</p>
        </p:documentation>
    </p:option>
    
    <p:output port="result" primary="true"/>
    
    <p:wrap-sequence name="combine-reports" wrapper="reports" wrapper-namespace="http://www.daisy.org/ns/pipeline/data" wrapper-prefix="d"/>
    
    <p:insert position="last-child">
        <p:input port="insertion">
            <p:pipe port="result" step="combine-reports"/>
        </p:input>    
        <p:input port="source">
            <p:inline>
                <d:document-validation-report>
                    <d:document-info/>
                </d:document-validation-report>
            </p:inline>
        </p:input>
    </p:insert>
    
    <p:choose>
        <p:when test="string-length($document-path) > 0">
            <p:insert match="d:document-validation-report/d:document-info" position="first-child">
                <p:input port="insertion">
                    <p:inline>
                        <d:document-path>@@</d:document-path>
                    </p:inline>
                </p:input>
            </p:insert>
            <p:string-replace match="//d:document-path/text()">
                <p:with-option name="replace" select="concat('&quot;', $document-path, '&quot;')"/>
            </p:string-replace>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    <p:choose>
        <p:when test="string-length($document-type) > 0">
            <p:insert match="d:document-validation-report/d:document-info" position="first-child">
                <p:input port="insertion">
                    <p:inline>
                        <d:document-type>@@</d:document-type>
                    </p:inline>
                </p:input>
            </p:insert>
            <p:string-replace match="//d:document-type/text()">
                <p:with-option name="replace" select="concat('&quot;', $document-type, '&quot;')"/>
            </p:string-replace>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
    <p:choose>
        <p:when test="string-length($document-name) > 0">
            <p:insert match="d:document-validation-report/d:document-info" position="first-child">
                <p:input port="insertion">
                    <p:inline>
                        <d:document-name>@@</d:document-name>
                    </p:inline>
                </p:input>
            </p:insert>
            <p:string-replace match="//d:document-name/text()">
                <p:with-option name="replace" select="concat('&quot;', $document-name, '&quot;')"/>
            </p:string-replace>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>

