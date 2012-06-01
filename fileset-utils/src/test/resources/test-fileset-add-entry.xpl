<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../fileset-utils/xproc/fileset-add-entry.xpl"/>
    <p:import href="compare.xpl"/>

    <p:group name="add-entry">
        <px:fileset-add-entry href="doc.html">
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/"/>
                </p:inline>
            </p:input>
        </px:fileset-add-entry>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="doc.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="add-entry-with-media-type">
        <px:fileset-add-entry href="doc.html" media-type="text/html">
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/"/>
                </p:inline>
            </p:input>
        </px:fileset-add-entry>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="doc.html" media-type="text/html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>

    <p:group name="add-entry-first">
        <px:fileset-add-entry href="doc.html" first="true">
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="other"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-add-entry>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="doc.html"/>
                        <d:file href="other"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="add-entry-absolute">
        <px:fileset-add-entry href="file:/doc.html">
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/"/>
                </p:inline>
            </p:input>
        </px:fileset-add-entry>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="file:/doc.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="add-entry-absolute-same-base">
        <px:fileset-add-entry href="file:/users/me/dir/doc.html">
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/"/>
                </p:inline>
            </p:input>
        </px:fileset-add-entry>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/users/me/dir/">
                        <d:file href="doc.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
</p:declare-step>
