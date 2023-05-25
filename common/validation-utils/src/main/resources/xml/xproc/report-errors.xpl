<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                type="px:report-errors"
                name="report-errors">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Wrapper step for <code>cx:report-errors</code> that treats an empty value
        <code>code</code> value as an absent value.</p>
    </p:documentation>

    <p:input port="source" primary="true"/>
    <p:input port="report" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Zero or more <a
            href="https://www.w3.org/TR/xproc/#cv.errors"><code>c:errors</code></a> documents.</p>
            <p>The errors are sent as one or more warnings to the error listener.</p>
        </p:documentation>
    </p:input>
    <p:output port="result" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Copy of <code>source</code></p>
        </p:documentation>
    </p:output>
    <p:option name="code" cx:type="xs:string" select="''"> <!-- xs:NCName -->
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>If specified and not empty the step raises an error with this code.</p>
        </p:documentation>
    </p:option>
    <p:option name="code-prefix" cx:type="xs:NCName"/>
    <p:option name="code-namespace" cx:type="xs:anyURI"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>
            cx:report-errors
        </p:documentation>
    </p:import>

    <!-- count the report docs to simply pipe the identity if there are no errors -->
    <p:count name="count" limit="1">
        <p:input port="source">
            <p:pipe step="report-errors" port="report"/>
        </p:input>
    </p:count>
    <p:sink/>
    <p:identity>
        <p:input port="source">
            <p:pipe port="source" step="report-errors"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:xpath-context>
            <p:pipe port="result" step="count"/>
        </p:xpath-context>
        <p:when test="/c:result = '0'">
            <p:identity/>
        </p:when>
        <p:when test="$code != '' and p:value-available('code-prefix') and p:value-available('code-namespace')">
            <cx:report-errors>
                <p:input port="report">
                    <p:pipe step="report-errors" port="report"/>
                </p:input>
                <p:with-option name="code" select="$code"/>
                <p:with-option name="code-prefix" select="$code-prefix"/>
                <p:with-option name="code-namespace" select="$code-namespace"/>
            </cx:report-errors>
        </p:when>
        <p:when test="$code != '' and p:value-available('code-namespace')">
            <cx:report-errors>
                <p:input port="report">
                    <p:pipe step="report-errors" port="report"/>
                </p:input>
                <p:with-option name="code" select="$code"/>
                <p:with-option name="code-namespace" select="$code-namespace"/>
            </cx:report-errors>
        </p:when>
        <p:when test="$code != '' and p:value-available('code-prefix')">
            <cx:report-errors>
                <p:input port="report">
                    <p:pipe step="report-errors" port="report"/>
                </p:input>
                <p:with-option name="code" select="$code"/>
                <p:with-option name="code-prefix" select="$code-prefix"/>
            </cx:report-errors>
        </p:when>
        <p:when test="$code != ''">
            <cx:report-errors>
                <p:input port="report">
                    <p:pipe step="report-errors" port="report"/>
                </p:input>
                <p:with-option name="code" select="$code"/>
            </cx:report-errors>
        </p:when>
        <p:otherwise>
            <cx:report-errors>
                <p:input port="report">
                    <p:pipe step="report-errors" port="report"/>
                </p:input>
            </cx:report-errors>
        </p:otherwise>
    </p:choose>

</p:declare-step>
