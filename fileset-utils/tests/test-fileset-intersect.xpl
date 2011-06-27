<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../fileset-utils/xproc/fileset-intersect.xpl"/>
    <p:import href="compare.xpl"/>

    <p:group name="same-base">
        <px:fileset-intersect>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-intersect>
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
    
    
    <p:group name="different-base">
        <px:fileset-intersect>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/other/">
                        <d:file href="doc1.html"/>
                        <d:file href="doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-intersect>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    
    <p:group name="different-base-with-common-resource">
        <px:fileset-intersect>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="../doc1.html"/>
                        <d:file href="doc2.html"/>
                    </d:fileset>
                </p:inline>
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/other/">
                        <d:file href="../doc1.html"/>
                        <d:file href="doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-intersect>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:///Users/me/dir/">
                        <d:file href="../doc1.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>

</p:declare-step>
