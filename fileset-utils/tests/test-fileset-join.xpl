<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../xproc/fileset-join.xpl"/>
    <p:import href="compare.xpl"/>


    <p:group name="same-base">
        <px:fileset-join>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                        <d:file href="http://www.example.org/test"/>
                    </d:fileset>
                </p:inline>
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc3.html"/>
                        <d:file href="http://www.example.org/test"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-join>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                        <d:file href="http://www.example.org/test"/>
                        <d:file href="doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="different-bases">
        <px:fileset-join>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/other/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-join>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                        <d:file href="file:/Users/me/other/doc1.html"/>
                        <d:file href="file:/Users/me/other/doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
</p:declare-step>
