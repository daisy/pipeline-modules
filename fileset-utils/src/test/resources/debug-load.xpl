<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" type="pxi:test-fileset-load" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all">
    
    <p:output port="result">
        <p:pipe port="result" step="result"/>
    </p:output>
    
    <p:import href="../../main/resources/xml/xproc/fileset-load.xpl"/>
    <p:import href="compare.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:wrap-sequence wrapper="c:results">
        <p:input port="source">
            <p:pipe port="result" step="test-empty"/>
            <p:pipe port="result" step="test-href-absolute"/>
            <p:pipe port="result" step="test-href-relative"/>
            <p:pipe port="result" step="test-method-xml"/>
            <p:pipe port="result" step="test-method-html"/>
            <!--            <p:pipe port="result" step="test-method-text"/>-->
            <!--            <p:pipe port="result" step="test-method-binary"/>-->
            <!--            <p:pipe port="result" step="test-media-types-filtering"/>-->
            <!--            <p:pipe port="result" step="test-not-media-types-filtering"/>-->
            <!--            <p:pipe port="result" step="test-fail-on-not-found-false"/>-->
            <!--            <p:pipe port="result" step="test-fail-on-not-found-true"/>-->
            <!--            <p:pipe port="result" step="test-load-if-not-in-memory-false"/>-->
            <!--            <p:pipe port="result" step="test-load-if-not-in-memory-true"/>-->
        </p:input>
    </p:wrap-sequence>
    <p:add-attribute match="/*" attribute-name="script-uri">
        <p:with-option name="attribute-value" select="base-uri(/*)">
            <p:inline>
                <doc/>
            </p:inline>
        </p:with-option>
    </p:add-attribute>
    <p:add-attribute match="/*" attribute-name="name">
        <p:with-option name="attribute-value" select="replace(replace(/*/@script-uri,'^.*/([^/]+)$','$1'),'\.xpl$','')"/>
    </p:add-attribute>
    <p:identity name="result"/>
    
    <p:group name="test-fileset">
        <p:output port="result"/>
        <p:identity>
            <p:input port="source">
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data">
    <d:file media-type="application/octet-stream" href="a/MimeDetector.class"/>
    <d:file media-type="application/octet-stream" href="a/MimeDetector.java"/>
    <d:file media-type="application/x-gzip" href="a/f.tar.gz"/>
    <d:file media-type="application/octet-stream" href="a/resources/mime.cache"/>
    <d:file media-type="application/octet-stream" href="a/resources/eu/medsea/mimeutil/magic.mime"/>
    <d:file media-type="application/octet-stream" href="a/resources/eu/medsea/mimeutil/mime-types.properties"/>
    <d:file media-type="application/octet-stream" href="a/c-gif.img"/>
    <d:file media-type="application/octet-stream" href="a/e%5Bxml%5D"/>
    <d:file media-type="image/svg+xml" href="a/e.svg"/>
    <d:file media-type="text/html" href="a/a.html"/>
    <d:file media-type="image/jpeg" href="b.jpg"/>
    <d:file media-type="application/octet-stream" href="d-png.img"/>
    <d:file media-type="application/octet-stream" href="test.bin"/>
    <d:file media-type="image/png" href="d.png"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/MimeUtilTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/util/EncodingGuesserTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/MimeTypeTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/detector/WindowsRegistryMimeDetectorTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/detector/OpendesktopMimeDetectorTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/detector/TextMimeDetectorTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/detector/MagicMimeMimeDetectorTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/MimeTypeHashSetTest.java"/>
    <d:file media-type="application/octet-stream" href="eu/medsea/mimeutil/MimeUtil2Test.java"/>
    <d:file media-type="text/plain" href="plaintext.txt"/>
    <d:file media-type="application/x-gzip" href="f.tar.gz"/>
    <d:file media-type="application/x-gzip" href="porrasturvat-1.0.3.tar.gz"/>
    <d:file media-type="application/zip" href="a.zip"/>
    <d:file media-type="application/octet-stream" href="b-jpg.img"/>
    <d:file media-type="application/octet-stream" href="c-gif.img"/>
    <d:file media-type="application/octet-stream" href="e-svg.img"/>
    <d:file media-type="application/octet-stream" href="e%5Bxml%5D"/>
    <d:file media-type="application/xml" href="e.xml"/>
    <d:file media-type="application/octet-stream" href="META-INF/MANIFEST.MF"/>
    <d:file media-type="application/octet-stream" href="textfiles/western"/>
    <d:file media-type="application/octet-stream" href="textfiles/unicode"/>
    <d:file href="wrong-extensions/html.bin"/>
    <d:file href="wrong-extensions/opf.txt"/>
    <d:file href="wrong-extensions/png.xml"/>
    <d:file href="wrong-extensions/txt.xml"/>
    <d:file media-type="application/octet-stream" href="magic.mime"/>
    <d:file media-type="application/octet-stream" href="plaintext"/>
    <d:file media-type="application/octet-stream" href="afpfile.afp"/>
    <d:file media-type="image/svg+xml" href="e.svg"/>
    <d:file media-type="text/html" href="a.html"/>
    <d:file media-type="application/xml" href="epub/META-INF/container.xml"/>
    <d:file media-type="audio/mpeg" href="epub/Publication/Content/1_Jamen__Benny.mp3"/>
    <d:file media-type="application/xhtml+xml" href="epub/Publication/Content/mqia0001.xhtml"/>
    <d:file media-type="application/smil+xml" href="epub/Publication/Content/mqia0001.smil"/>
    <d:file media-type="image/jpeg" href="epub/Publication/Content/tjcs0000.jpg"/>
    <d:file media-type="image/jpeg" href="epub/Publication/Content/41077stor.jpg"/>
    <d:file media-type="application/xhtml+xml" href="epub/Publication/navigation.xhtml"/>
    <d:file media-type="application/x-dtbncx+xml" href="epub/Publication/ncx.xml"/>
    <d:file media-type="application/oebps-package+xml" href="epub/Publication/package.opf"/>
    <d:file media-type="application/octet-stream" href="epub/mimetype"/>
    <d:file media-type="image/gif" href="c.gif"/>
    <d:file media-type="application/octet-stream" href="log4j.properties"/>
    <d:file media-type="application/octet-stream" href="mime-types.properties"/>
    <d:file media-type="application/epub+zip" href="epub.epub"/>
    <d:file media-type="application/oebps-package+xml" href="xml/package.xml"/>
    <d:file media-type="application/x-dtbncx+xml" href="xml/ncx.xml"/>
    <d:file media-type="application/xml" href="xml/container.xml"/>
    <d:file media-type="application/smil+xml" href="xml/mqia0001.xml"/>
    <d:file media-type="application/xproc+xml" href="xml/XProc.xml"/>
    <d:file media-type="application/xhtml+xml" href="xml/navigation.xml"/>
    <d:file media-type="application/oebps-package+xml" href="xml/package.xml~"/>
    <d:file media-type="application/xslt+xml" href="xml/XSLT.xml"/>
    <d:file media-type="application/xml" href="xml/noFileExtension"/>
</d:fileset>
                </p:inline>
            </p:input>
        </p:identity>
        <p:add-attribute attribute-name="xml:base" match="/*">
            <p:with-option name="attribute-value" select="resolve-uri('samples/fileset2/',base-uri())">
                <p:inline>
                    <doc/>
                </p:inline>
            </p:with-option>
        </p:add-attribute>
        <p:add-xml-base/>
    </p:group>
    <p:sink/>
    
    <p:group name="test-empty">
        <p:output port="result"/>
        
        <px:fileset-load>
            <p:input port="fileset">
                <p:inline>
                    <d:fileset/>
                </p:inline>
            </p:input>
            <p:input port="in-memory">
                <p:empty/>
            </p:input>
        </px:fileset-load>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:empty/>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="load-empty"/>
    </p:group>
    
    <p:group name="test-href-absolute">
        <p:output port="result"/>
        
        <px:fileset-load>
            <p:with-option name="href" select="resolve-uri('a/a.html',/*/@xml:base)">
                <p:pipe step="test-fileset" port="result"/>
            </p:with-option>
            <p:input port="fileset">
                <p:pipe step="test-fileset" port="result"/>
            </p:input>
            <p:input port="in-memory">
                <p:empty/>
            </p:input>
        </px:fileset-load>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline xml:space="preserve">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>This is a test basic html file</title>
    </head>
    <body> </body>
</html>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="load-href-absolute"/>
    </p:group>
    
    <p:group name="test-href-relative">
        <p:output port="result"/>
        
        <px:fileset-load href="a/a.html">
            <p:input port="fileset">
                <p:pipe step="test-fileset" port="result"/>
            </p:input>
            <p:input port="in-memory">
                <p:empty/>
            </p:input>
        </px:fileset-load>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline xml:space="preserve">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>This is a test basic html file</title>
    </head>
    <body> </body>
</html>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="load-href-relative"/>
    </p:group>
    
    <p:group name="test-method-xml">
        <p:output port="result"/>
        
        <px:fileset-load href="wrong-extensions/opf.txt" method="xml">
            <p:input port="fileset">
                <p:pipe step="test-fileset" port="result"/>
            </p:input>
            <p:input port="in-memory">
                <p:empty/>
            </p:input>
        </px:fileset-load>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:empty/>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="load-method-xml"/>
    </p:group>
    
    <p:group name="test-method-html">
        <p:output port="result"/>
        
        <px:fileset-load href="wrong-extensions/html.bin" method="html">
            <p:input port="fileset">
                <p:pipe step="test-fileset" port="result"/>
            </p:input>
            <p:input port="in-memory">
                <p:empty/>
            </p:input>
        </px:fileset-load>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline xml:space="preserve">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>This is a test basic html file</title>
    </head>
    <body> </body>
</html>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="load-method-html"/>
    </p:group>
    
</p:declare-step>
