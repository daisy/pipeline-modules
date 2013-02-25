<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" type="pxi:test-fileset-from-dir" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" exclude-inline-prefixes="#all" xmlns:c="http://www.w3.org/ns/xproc-step">

    <p:output port="result">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:import href="../../main/resources/xml/xproc/fileset-from-dir.xpl"/>
    <p:import href="compare.xpl"/>
    
    <p:variable name="base-uri" select="base-uri()">
        <p:inline>
            <doc/>
        </p:inline>
    </p:variable>
    
    <p:wrap-sequence wrapper="c:results">
        <p:input port="source">
            <p:pipe port="result" step="test"/>
            <p:pipe port="result" step="test-non-rec"/>
            <p:pipe port="result" step="test-include-filter"/>
            <p:pipe port="result" step="test-exclude-filter"/>
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

    <p:group name="test">
        <p:output port="result"/>
        <px:fileset-from-dir>
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <p:choose>
            <p:when
                test="/d:fileset[@xml:base=resolve-uri('samples/fileset/',$base-uri) and not(@* except @xml:base)]
                and /*/d:file[@href='dir/file.txt' and not(@* except @href) and not(node())]
                and /*/d:file[@href='test.txt' and not(@* except @href) and not(node())]
                and /*/d:file[@href='test.xml' and not(@* except @href) and not(node())]">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>true</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>false</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity>
            <p:log port="result"/>
        </p:identity>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="test" name="test.result"/>
    </p:group>

    <p:group name="test-non-rec">
        <p:output port="result"/>
        <px:fileset-from-dir recursive="false">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <p:choose>
            <p:when
                test="/d:fileset[@xml:base=resolve-uri('samples/fileset/',$base-uri) and not(@* except @xml:base)]
                and /*/d:file[@href='test.txt' and not(@* except @href) and not(node())]
                and /*/d:file[@href='test.xml' and not(@* except @href) and not(node())]">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>true</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>false</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity>
            <p:log port="result"/>
        </p:identity>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="non-rec" name="test-non-rec.result"/>
    </p:group>

    <p:group name="test-include-filter">
        <p:output port="result">
            <p:pipe port="result" step="test-include-filter.result"/>
        </p:output>
        <px:fileset-from-dir include-filter="test.*">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <p:choose>
            <p:when
                test="/d:fileset[@xml:base=resolve-uri('samples/fileset/',$base-uri) and not(@* except @xml:base)]
                and /*/d:file[@href='test.txt' and not(@* except @href) and not(node())]
                and /*/d:file[@href='test.xml' and not(@* except @href) and not(node())]">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>true</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>false</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity>
            <p:log port="result"/>
        </p:identity>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="include-filter" name="test-include-filter.result"/>
    </p:group>

    <p:group name="test-exclude-filter">
        <p:output port="result">
            <p:pipe port="result" step="test-exclude-filter.result"/>
        </p:output>
        <px:fileset-from-dir exclude-filter="test.*">
            <p:with-option name="path" select="resolve-uri('samples/fileset/',base-uri())">
                <p:inline>
                    <irrelevant/>
                </p:inline>
            </p:with-option>
        </px:fileset-from-dir>
        
        <p:choose>
            <p:when
                test="/d:fileset[@xml:base=resolve-uri('samples/fileset/',$base-uri) and not(@* except @xml:base)]
                and /*/d:file[@href='dir/file.txt' and not(@* except @href) and not(node())]">
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>true</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:inline>
                            <c:result>false</c:result>
                        </p:inline>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
        <p:identity>
            <p:log port="result"/>
        </p:identity>
        <p:add-attribute match="/*" attribute-name="name" attribute-value="exclude-filter" name="test-exclude-filter.result"/>
    </p:group>
    
</p:declare-step>
