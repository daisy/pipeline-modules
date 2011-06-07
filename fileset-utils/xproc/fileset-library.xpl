<p:library version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:err="http://www.w3.org/ns/xproc-error" xmlns:file="http://expath.org/ns/file"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxf="http://exproc.org/proposed/steps/file" exclude-inline-prefixes="px pxf">

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/file-library.xpl"/>
    <p:import href="../fileset-copy.xpl"/>

    <!-- ============================================================ -->
    <p:documentation> </p:documentation>
    <p:declare-step type="px:fileset-add-entry" name="fileset-add-entry">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:option name="href" required="true"/>
        <p:option name="media-type"/>
        <p:option name="first" select="'false'"/>

        <!-- Create a new d:entry element -->
        <p:group name="fileset-add-entry.create-entry">
            <p:output port="result"/>
            <p:add-attribute match="/d:file" attribute-name="href">
                <p:input port="source">
                    <p:inline>
                        <d:file/>
                    </p:inline>
                </p:input>
                <p:with-option name="attribute-value" select="$href"/>
            </p:add-attribute>
            <p:choose>
                <p:when test="p:value-available('media-type')">
                    <p:add-attribute match="/d:file" attribute-name="media-type">
                        <p:with-option name="attribute-value" select="$media-type"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:group>
        <!-- Add the d:entry to the source d:fileset -->
        <p:insert match="/*">
            <p:input port="source">
                <p:pipe port="source" step="fileset-add-entry"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe port="result" step="fileset-add-entry.create-entry"/>
            </p:input>
            <p:with-option name="position"
                select="if ($first='true') then 'first-child' else 'last-child'"/>
        </p:insert>
        <!-- Add xml:base on all d:entry and on the d:fileset -->
        <p:label-elements match="d:file[not(@xml:base)]" attribute="xml:base" label="base-uri(..)"/>
        <p:add-xml-base/>
    </p:declare-step>

    <!-- ============================================================ -->
    <p:declare-step type="px:fileset-copy" name="fileset-copy">
        <p:input port="source"/>
        <p:option name="target" required="true"/>
        <p:option name="fail-on-error" select="'true'"/>
        <p:output port="result"/>

        <p:try>
            <p:group>
                <pxf:info>
                    <p:with-option name="href" select="$target"/>
                </pxf:info>
                <p:choose>
                    <p:when test="empty()">
                        <p:error code="err:empty"/>
                    </p:when>
                    <p:when test="not(/c:directory)">
                        <p:error code="err:empty"/>
                    </p:when>
                    <p:otherwise>
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="source" step="fileset-copy"/>
                            </p:input>
                        </p:identity>
                        <p:viewport name="handle-outer-file" match="/d:fileset/d:file[@href='']">
                            <!--resolve relative outer resources-->
                            <p:label-elements attribute="href">
                                <p:with-option name="label" select="new-href"/>
                            </p:label-elements>
                        </p:viewport>
                        <p:viewport name="handle-inner-file" match="">
                            <!--copy relative local resources-->
                            <p:variable name="href" select="resolve-uri(*/@href, base-uri())"/>
                            <p:variable name="target-file" select="resolve-uri(*/@href, $target)"/>
                            <pxf:mkdir name="mkdir">
                                <p:with-option name="href"
                                    select="replace($target-file,'[^/]+$','')"/>
                            </pxf:mkdir>
                            <pxf:copy name="copy">
                                <p:with-option name="href" select="$href">
                                    <!-- hack to define the execution order -->
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
                        <p:label-elements match="/d:fileset" attribute="xml:base">
                            <p:with-option name="label" select="$target"/>
                        </p:label-elements>
                    </p:otherwise>
                </p:choose>
            </p:group>
            <p:catch>
                <!--TODO sort the errors-->
                <!--TODO convert into dynamic errors or error documents-->
                <p:output port="result"/>
                <p:choose>
                    <p:when test="$fail-on-error = 'true'">
                        <p:identity>
                            <p:input port="source">
                                <p:inline>
                                    <c:error>Directory does not exist.</c:error>
                                </p:inline>
                            </p:input>
                        </p:identity>
                    </p:when>
                    <p:otherwise>
                        <p:error code="err:PFSU01"/>
                    </p:otherwise>
                </p:choose>
            </p:catch>
        </p:try>

    </p:declare-step>

    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-create">
        <p:output port="result"/>
        <p:option name="base"/>
        <p:add-attribute attribute-name="xml:base" match="/d:fileset">
            <p:input port="source">
                <p:inline exclude-inline-prefixes="px">
                    <d:fileset/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="$base"/>
        </p:add-attribute>
    </p:declare-step>-->
    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-diff">
        <p:input port="source" primary="true"/>
        <p:input port="secondary"/>
        <p:output port="result"/>
    </p:declare-step>-->
    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-from-dir">
        <p:output port="result"/>
        <p:option name="path" required="true"/>
        <!-\- anyURI -\->
        <p:option name="recursive" select="'true'"/>
        <!-\- boolean -\->
        <p:option name="include-filter"/>
        <!-\- RegularExpression -\->
        <p:option name="exclude-filter"/>
        <!-\- RegularExpression -\->
    </p:declare-step>-->
    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-from-dir-list">
        <p:input port="source"/>
        <p:output port="result"/>
    </p:declare-step>-->
    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-intersect">
        <p:input port="source" sequence="true"/>
        <p:output port="result"/>
    </p:declare-step>-->
    <!-- ============================================================ -->
    <!--<p:declare-step type="px:fileset-join">
        <p:input port="source" sequence="true"/>
        <p:output port="result"/>
    </p:declare-step>-->
    <!-- ============================================================ -->



    <!--<p:declare-step type="px:join-manifests" name="join-manifests">
        <p:input port="source" sequence="true"/>
        <p:output port="result"/>
        <p:wrap-sequence wrapper="c:manifest"/>
        <p:unwrap match="/c:manifest/c:manifest"/>
        <p:choose>
            <p:when test="//c:entry">
                <p:label-elements match="c:entry" attribute="href"
                    label="resolve-uri(@href,base-uri())" replace="true"/>
                <p:label-elements match="c:manifest" attribute="xml:base"
                    label="
                   (
                   for $pref in
                       reverse(
                           for $uri in //@href
                           return
                               for $i in 1 to count(tokenize($uri,'/'))
                               return concat(string-join(
                                   for $p in 1 to $i return tokenize($uri,'/')[$p]
                               ,'/'),'/')
                       )
                   return
                       if (every $h in //@href satisfies starts-with($h,$pref)) then $pref else ()
                   )[1]
                   "
                    replace="true"/>
                <p:label-elements match="c:entry" attribute="xml:base" label="/*/@xml:base"
                    replace="true"/>
                <p:label-elements match="c:entry" attribute="href"
                    label="if (starts-with(@href,base-uri())) then substring-after(@href,base-uri()) else @href"
                    replace="true"/>
                <p:add-xml-base/>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>-->

    <!--<p:declare-step type="px:to-zip-manifest" name="to-zip-manifest">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:rename match="c:manifest" new-name="c:zip-manifest"/>
        <p:rename match="c:entry/@href" new-name="name"/>
        <p:label-elements match="c:entry" attribute="href" label="resolve-uri(@name,base-uri())"/>
    </p:declare-step>-->

</p:library>
