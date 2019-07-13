<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
                exclude-inline-prefixes="#all"
                type="px:odf-store" name="store">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Store a ODF fileset in a ZIP</p>
    </p:documentation>
    
    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The ODF fileset</p>
        </p:documentation>
    </p:input>
    
    <p:option name="href" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The URI of the ZIP file</p>
        </p:documentation>
    </p:option>
    <p:option name="skip-manifest" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Don't generate the META-INF/manifest.xml file. This option is used for instance when
            this step is called from px:epub3-ocf-zip, because the manifest file is not mandatory in
            EPUBs.</p>
        </p:documentation>
    </p:option>

    <p:output port="result" primary="false">
        <p:documentation>
            <p>A c:result document containing the URI of the ZIP file.</p>
        </p:documentation>
        <p:pipe step="result" port="result"/>
    </p:output>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:normalize-uri
            px:set-base-uri
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:zip-manifest-from-fileset
            px:fileset-add-entry
            px:fileset-store
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/library.xpl">
        <p:documentation>
            px:zip
        </p:documentation>
    </p:import>
    <p:import href="manifest-from-fileset.xpl">
        <p:documentation>
            px:odf-manifest-from-fileset
        </p:documentation>
    </p:import>
    
    <px:normalize-uri name="href">
        <p:with-option name="href" select="$href"/>
    </px:normalize-uri>
    
    <!-- ================= -->
    <!-- Generate manifest -->
    <!-- ================= -->
    
    <!-- FIXME: for now creating manifest regardless of $skip-manifest because we need it below to
         get content and location of mimetype -->
    <px:odf-manifest-from-fileset name="manifest"/>
    <p:sink/>
    
    <!-- Remove directories from fileset -->
    <p:delete match="//d:file[ends-with(resolve-uri(@href, base-uri(.)), '/')]">
        <p:input port="source">
            <p:pipe step="store" port="source.fileset"/>
        </p:input>
    </p:delete>
    
    <p:choose name="add-manifest">
        <p:when test="$skip-manifest='true'">
            <p:output port="fileset" primary="true"/>
            <p:output port="in-memory" sequence="true">
                <p:pipe step="store" port="source.in-memory"/>
            </p:output>
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:output port="fileset" primary="true"/>
            <p:output port="in-memory" sequence="true">
                <p:pipe step="add-entry" port="result.in-memory"/>
            </p:output>
            <p:identity/>
            <px:fileset-add-entry media-type="application/xml" name="add-entry">
                <p:input port="source.in-memory">
                    <p:pipe step="store" port="source.in-memory"/>
                </p:input>
                <p:input port="entry">
                    <p:pipe step="manifest" port="result"/>
                </p:input>
            </px:fileset-add-entry>
        </p:otherwise>
    </p:choose>
    <p:sink/>
    
    <!-- ================= -->
    <!-- Generate mimetype -->
    <!-- ================= -->
    
    <p:string-replace match="/c:data/text()">
        <p:input port="source">
            <p:inline>
                <c:data content-type="text/plain">$mimetype</c:data>
            </p:inline>
        </p:input>
        <p:with-option name="replace" select="concat('&quot;', //manifest:file-entry[@manifest:full-path='/']/@manifest:media-type, '&quot;')">
            <p:pipe step="manifest" port="result"/>
        </p:with-option>
    </p:string-replace>
    <p:string-replace match="text()" replace="normalize-space()"/>
    
    <px:set-base-uri>
        <p:with-option name="base-uri" select="resolve-uri('../mimetype', base-uri(/*))">
            <p:pipe step="manifest" port="result"/>
        </p:with-option>
    </px:set-base-uri>
    <p:add-xml-base name="mimetype"/>
    <p:sink/>
    
    <px:fileset-add-entry first="true" media-type="text/plain" name="add-mimetype">
        <p:input port="source">
            <p:pipe step="add-manifest" port="fileset"/>
        </p:input>
        <p:input port="source.in-memory">
            <p:pipe step="add-manifest" port="in-memory"/>
        </p:input>
        <p:input port="entry">
            <p:pipe step="mimetype" port="result"/>
        </p:input>
    </px:fileset-add-entry>
    
    <!-- =================== -->
    <!-- Store files to disk -->
    <!-- =================== -->
    
    <px:fileset-store name="fileset-store">
        <p:input port="in-memory.in">
            <p:pipe step="add-mimetype" port="result.in-memory"/>
        </p:input>
    </px:fileset-store>
    
    <!-- ====== -->
    <!-- Zip up -->
    <!-- ====== -->
    
    <px:zip-manifest-from-fileset>
        <p:input port="source">
            <p:pipe step="add-mimetype" port="result"/>
        </p:input>
    </px:zip-manifest-from-fileset>
    
    <p:add-attribute name="zip-manifest" match="c:entry[@name='mimetype']" attribute-name="compression-method" attribute-value="stored"/>
    
    <px:zip compression-method="deflated" cx:depends-on="fileset-store">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="zip-manifest"/>
        </p:input>
        <p:with-option name="href" select="/c:result/string()">
            <p:pipe step="href" port="normalized"/>
        </p:with-option>
    </px:zip>
    
    <p:string-replace match="/c:result/text()" name="result">
        <p:input port="source">
            <p:inline>
                <c:result>$href</c:result>
            </p:inline>
        </p:input>
        <p:with-option name="replace" select="concat('&quot;', /c:zipfile/@href, '&quot;')"/>
    </p:string-replace>
    
</p:declare-step>
