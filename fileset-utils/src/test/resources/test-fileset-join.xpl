<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" type="pxi:test-fileset-join" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="px" xmlns:c="http://www.w3.org/ns/xproc-step">

    <p:output port="result">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:import href="../../main/resources/xml/xproc/fileset-join.xpl"/>
    <p:import href="compare.xpl"/>

    <p:wrap-sequence wrapper="c:results">
        <p:input port="source">
            <p:pipe port="result" step="same-base"/>
            <p:pipe port="result" step="different-bases"/>
            <p:pipe port="result" step="longest-common-base"/>
            <p:pipe port="result" step="preserve-refs"/>
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

    <p:group name="same-base">
        <p:output port="result"/>
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
        <p:add-attribute match="/*" attribute-name="name" attribute-value="same-base"/>
    </p:group>

    <p:group name="different-bases">
        <!-- when possible, the base URI of the resulting fileset will be made so that all files are subfiles of that folder -->
        <p:output port="result"/>
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
                    <d:fileset xml:base="file:/Users/me/">
                        <d:file href="dir/doc1.html"/>
                        <d:file href="dir/doc2.html"/>
                        <d:file href="other/doc1.html"/>
                        <d:file href="other/doc3.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="different-bases"/>
    </p:group>

    <p:group name="longest-common-base">
        <!-- fileset can not change base unless there are multiple filesets with different bases -->
        <p:output port="result"/>
        <px:fileset-join>
            <p:input port="source">
                <p:inline>
                    <d:fileset xml:base="file:/home/user/">
                        <d:file href="common/uncommon-1/doc1.html"/>
                        <d:file href="common/uncommon-2/doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-join>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline>
                    <d:fileset xml:base="file:/home/user/">
                        <d:file href="common/uncommon-1/doc1.html"/>
                        <d:file href="common/uncommon-2/doc2.html"/>
                    </d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="longest-common-base"/>
    </p:group>

    <p:group name="preserve-refs">
        <!-- preserve refs: https://code.google.com/p/daisy-pipeline/issues/detail?id=277 -->
        <p:output port="result"/>

        <px:fileset-join>
            <p:input port="source">
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/"/>
                </p:inline>
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/">
    <d:file href="href1">
        <d:ref href="ref1"/>
    </d:file>
</d:fileset>
                </p:inline>
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/">
    <d:file href="href2">
        <d:ref href="ref2"/>
    </d:file>
</d:fileset>
                </p:inline>
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/">
    <d:file href="href1">
        <d:ref href="ref3"/>
    </d:file>
</d:fileset>
                </p:inline>
            </p:input>
        </px:fileset-join>
        <px:compare>
            <p:log port="result"/>
            <p:input port="alternate">
                <p:inline xml:space="preserve">
<d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/">
    <d:file href="href1">
        <d:ref href="ref1"/>
        <d:ref href="ref3"/>
    </d:file>
    <d:file href="href2">
        <d:ref href="ref2"/>
    </d:file>
</d:fileset>
                </p:inline>
            </p:input>
        </px:compare>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="preserve-refs"/>
    </p:group>

</p:declare-step>
