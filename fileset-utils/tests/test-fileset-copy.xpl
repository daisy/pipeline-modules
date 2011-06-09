<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxf="http://exproc.org/proposed/steps/file" exclude-inline-prefixes="#all">

    <p:import href="../xproc/fileset-copy.xpl"/>
    <p:import href="compare.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/file-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:variable name="out-dir" select="p:resolve-uri('samples/out/',base-uri())">
        <p:inline>
            <irrelevant/>
        </p:inline>
    </p:variable>

    <p:group name="test">

        <p:group name="test-fileset-copy">
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:fileset>
                            <d:file href="dir/file.txt"/>
                            <d:file href="test.txt"/>
                            <d:file href="test.xml"/>
                            <d:file href="http://www.example.org/style.css"/>
                        </d:fileset>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value"
                    select="resolve-uri('samples/fileset/',base-uri())"/>
            </p:add-attribute>
            <p:add-xml-base name="source"/>
            <p:add-attribute name="expected" attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value" select="$out-dir"/>
            </p:add-attribute>
            <p:sink/>

            <px:fileset-copy>
                <p:input port="source">
                    <p:pipe port="result" step="source"/>
                </p:input>
                <p:with-option name="target" select="$out-dir"/>
            </px:fileset-copy>

            <px:compare>
                <p:log port="result"/>
                <p:input port="alternate">
                    <p:pipe port="result" step="expected"/>
                </p:input>
            </px:compare>
        </p:group>

        <p:group name="test-filesystem" cx:depends-on="test-fileset-copy">
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <c:directory name="out">
                            <c:directory name="dir">
                                <c:file name="file.txt"/>
                            </c:directory>
                            <c:file name="test.txt"/>
                            <c:file name="test.xml"/>
                        </c:directory>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*/c:directory">
                <p:with-option name="attribute-value" select="concat($out-dir,'dir/')"/>
            </p:add-attribute>
            <p:add-attribute name="expected" attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value" select="$out-dir"/>
            </p:add-attribute>
            <p:sink/>

            <px:directory-list>
                <p:with-option name="path" select="$out-dir"/>
            </px:directory-list>
            <px:compare>
                <p:log port="result"/>
                <p:input port="alternate">
                    <p:pipe port="result" step="expected"/>
                </p:input>
            </px:compare>
        </p:group>
    </p:group>

</p:declare-step>
