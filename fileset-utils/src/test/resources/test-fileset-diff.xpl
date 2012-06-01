<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../fileset-utils/xproc/fileset-diff.xpl"/>
    <p:import href="compare.xpl"/>

    <p:group name="test">
        <px:fileset-diff>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
            <p:input port="secondary">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir">
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-diff>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir">
                        <d:file href="doc1.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="no-base">
        <px:fileset-diff>
            <p:input port="source">
                <p:inline>
                    <d:fileset>
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
            <p:input port="secondary">
                <p:inline>
                    <d:fileset>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-diff>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset>
                        <d:file href="doc1.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    
    <p:group name="different-base">
        <px:fileset-diff>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="../doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
            <p:input port="secondary">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/">
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-diff>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="doc1.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    

</p:declare-step>
