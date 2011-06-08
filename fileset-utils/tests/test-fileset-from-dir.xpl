<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../xproc/fileset-from-dir.xpl"/>
    <p:import href="compare.xpl"/>

    <p:group name="test">
        <px:fileset-from-dir>
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>

        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:pipe port="result" step="expected"/>
            </p:input>
        </px:compare>

        <p:group name="expected">
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:fileset>
                            <d:file href="dir/file.txt"/>
                            <d:file href="test.txt"/>
                            <d:file href="test.xml"/>
                        </d:fileset>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value"
                    select="resolve-uri('samples/fileset/',base-uri())"/>
            </p:add-attribute>
        </p:group>
        <p:sink/>
    </p:group>
    
    <p:group name="test-non-rec">
        <px:fileset-from-dir recursive="false">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>

        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:pipe port="result" step="expected"/>
            </p:input>
        </px:compare>

        <p:group name="expected">
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:fileset>
                            <d:file href="test.txt"/>
                            <d:file href="test.xml"/>
                        </d:fileset>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value"
                    select="resolve-uri('samples/fileset/',base-uri())"/>
            </p:add-attribute>
        </p:group>
        <p:sink/>
    </p:group>
    
    <p:group name="test-include-filter">
        <px:fileset-from-dir include-filter="test.*">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:pipe port="result" step="expected"/>
            </p:input>
        </px:compare>
        
        <p:group name="expected">
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:fileset>
                            <d:file href="test.txt"/>
                            <d:file href="test.xml"/>
                        </d:fileset>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value"
                    select="resolve-uri('samples/fileset/',base-uri())"/>
            </p:add-attribute>
        </p:group>
        <p:sink/>
    </p:group>
    <p:group name="test-exclude-filter">
        <px:fileset-from-dir exclude-filter="test.*">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:pipe port="result" step="expected"/>
            </p:input>
        </px:compare>
        
        <p:group name="expected">
            <p:output port="result"/>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <d:fileset>
                            <d:file href="dir/file.txt"/>
                        </d:fileset>
                    </p:inline>
                </p:input>
            </p:identity>
            <p:add-attribute attribute-name="xml:base" match="/*">
                <p:with-option name="attribute-value"
                    select="resolve-uri('samples/fileset/',base-uri())"/>
            </p:add-attribute>
        </p:group>
        <p:sink/>
    </p:group>
</p:declare-step>
