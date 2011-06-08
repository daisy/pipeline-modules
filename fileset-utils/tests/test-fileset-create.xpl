<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px">

    <p:import href="../xproc/fileset-create.xpl"/>
    <p:import href="compare.xpl"/>

    <p:group name="absolute-base">
        <px:fileset-create base="file:/tmp/dir"/>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/tmp/dir"/>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="no-base">
        <px:fileset-create/>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset/>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>
    
    <p:group name="relative-base">
        <px:fileset-create base="fileset"/>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="fileset"/>
                </p:inline>
            </p:input>
        </px:compare>
    </p:group>

</p:declare-step>
