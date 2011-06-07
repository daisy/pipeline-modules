<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:err="http://www.w3.org/ns/xproc-error"
    xmlns:d="http://www.daisy.org/ns/pipeline/data "
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxf="http://exproc.org/proposed/steps/file" name="fileset-copy" type="px:fileset-copy"
    exclude-inline-prefixes="err px pxf">

    <p:input port="source"/>
    <p:output port="result" primary="true"/>
    <p:option name="target" required="true"/>
    <p:option name="fail-on-error" select="'false'"/>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/file-library.xpl"/>
    <!--    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>-->

    <p:try>
        <p:group>
            <p:output port="result" primary="true"/>

            <!--Get file system info on the directory-->
            <!--Note: we wrap the result since an empty sequence is returned when the file does not exist-->
            <pxf:info>
                <p:with-option name="href" select="$target"/>
            </pxf:info>
            <p:wrap-sequence wrapper="info"/>



            <!-- Check the existence of the directory -->
            <p:group name="fileset-copy.checkdir">
                <p:output port="result" primary="true"/>
                <!--                <cx:message message="Checking target directory"/>-->
                <p:choose>
                    <p:when test="empty(/info/*)">
                        <!--TODO rename the error-->
                        <p:error code="err:empty">
                            <p:input port="source">
                                <p:inline exclude-inline-prefixes="d">
                                    <c:message>The target directory does not exist.</c:message>
                                </p:inline>
                            </p:input>
                        </p:error>
                    </p:when>
                    <p:when test="not(/info/c:directory)">
                        <!--TODO rename the error-->
                        <p:error code="err:file">
                            <p:input port="source">
                                <p:inline exclude-inline-prefixes="d">
                                    <c:message>The target is not a directory.</c:message>
                                </p:inline>
                            </p:input>
                        </p:error>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="source" step="fileset-copy"/>
                    </p:input>
                </p:identity>
            </p:group>


            <!-- Handle relative resources outside of the base directory -->
            <!--            <cx:message message="Handling outer resources"/>-->
            <p:viewport name="handle-outer-file"
                match="/d:fileset/d:file[not(matches(@href,'^[^/]+:')) and starts-with(@href,'..')]">
                <!--TODO: extract XPath functions in uri-utils -->
                <p:label-elements attribute="href" label="@href"/>
            </p:viewport>

            <!-- Handle relative resources in the base directory -->
            <!--            <cx:message message="Handling inner resources"/>-->
            <p:viewport name="handle-inner-file"
                match="/d:fileset/d:file[not(matches(@href,'^[^/]+:')) and not(starts-with(@href,'..'))]">
                <p:variable name="href" select="p:resolve-uri(*/@href, concat(base-uri(),'/'))"/>
                <p:variable name="target-file" select="p:resolve-uri(*/@href, concat($target,'/'))"/>
                <pxf:mkdir name="mkdir">
                    <p:with-option name="href" select="replace($target-file,'[^/]+$','')"/>
                </pxf:mkdir>
                <pxf:copy name="copy">
                    <p:with-option name="href" select="$href">
                        <!--pipe hack to ensure sequential execution-->
                        <p:pipe port="result" step="mkdir"/>
                    </p:with-option>
                    <p:with-option name="target" select="$target-file"/>
                    <p:with-option name="fail-on-error" select="$fail-on-error"/>
                </pxf:copy>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="current" step="handle-inner-file"/>
                    </p:input>
                </p:identity>
            </p:viewport>

            <!--Set the base directory to the target directory-->
            <p:label-elements match="/d:fileset" attribute="xml:base">
                <p:with-option name="label" select="concat('&quot;',$target,'&quot;')"/>
            </p:label-elements>

        </p:group>
        <p:catch name="catch">
            <p:output port="result" primary="true"/>
            <!--Rethrows the error if $fail-on-error is true, or issue a c:errors document-->
            <p:identity>
                <p:input port="source">
                    <p:pipe port="error" step="catch"/>
                </p:input>
            </p:identity>
            <p:choose>
                <p:when test="$fail-on-error = 'true'">
                    <p:variable name="code" select="/c:errors/c:error[1]/@code"/>
                    <p:error xmlns:err="http://www.w3.org/ns/xproc-error">
                        <p:with-option name="code" select="if ($code) then $code else 'err:XD0030'"/>
                        <p:input port="source">
                            <p:pipe port="error" step="catch"/>
                        </p:input>
                    </p:error>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:catch>
    </p:try>

</p:declare-step>
