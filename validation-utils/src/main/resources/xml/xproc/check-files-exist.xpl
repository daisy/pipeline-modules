<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="check-files-exist" type="px:check-files-exist"
    xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"    
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    exclude-inline-prefixes="#all">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Check that files exist on disk</h1>
        <p px:role="desc">Given a list of files, ensure that each exists on disk.</p>
    </p:documentation>
    
    <!-- ***************************************************** -->
    <!-- INPUT, OUTPUT and OPTIONS -->
    <!-- ***************************************************** -->
    
    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">source</h1>
            <p px:role="desc">A list of files, formatted as described at http://code.google.com/p/daisy-pipeline/wiki/FileSetUtils</p>
        </p:documentation>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">result</h1>
            <p px:role="desc">List of missing files, formatted as &lt;d:error&gt; elements, or an empty d:errors element if nothing is missing.</p>
        </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl">
        <p:documentation>For manipulating files.</p:documentation>
    </p:import>
    
    <p:for-each name="check-each-file">
        <p:iteration-source select="//d:file"/>
        <p:variable name="filepath" select="*/@href"/>
        
        <p:try>
            <p:group>
                <px:info>
                    <p:with-option name="href" select="$filepath"/>
                </px:info>
            </p:group>
            <p:catch>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:catch>
        </p:try>
        
        <p:wrap-sequence wrapper="info"/>
        
        <!-- the <info> element, generated above, will be empty if the file was not found -->
        <p:choose name="file-exists">
            <p:when test="empty(/info/*)">
                <p:output port="result" sequence="true"/>
                
                <!-- for each ref, create an error -->
                <p:for-each>
                    
                    <p:iteration-source select="*/d:ref">
                        <p:pipe port="current" step="check-each-file"/>
                    </p:iteration-source>
                    
                    <p:variable name="ref" select="*/@href"/>
                    
                    <p:identity>
                        <p:input port="source">
                            <p:inline>
                                <d:error type="file-not-found">
                                    <d:desc>File not found</d:desc>
                                    <d:file>@@</d:file>
                                    <d:location href="@@"/>
                                </d:error>
                            </p:inline>
                        </p:input>
                    </p:identity>
                    
                    <p:string-replace match="//d:file/text()">
                        <p:with-option name="replace" select="concat('&quot;', $filepath, '&quot;')"/>
                    </p:string-replace>
                    
                    <p:string-replace match="//d:location/@href">
                        <p:with-option name="replace" select="concat('&quot;', resolve-uri($ref, $filepath), '&quot;')"/>
                    </p:string-replace>
                </p:for-each>
            </p:when>
            <p:otherwise>
                <p:output port="result"/>
                <p:identity>
                    <p:input port="source">
                        <p:empty/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:for-each>  
    
    <p:wrap-sequence wrapper="errors" wrapper-prefix="d" wrapper-namespace="http://www.daisy.org/ns/pipeline/data"/>
    
</p:declare-step>
