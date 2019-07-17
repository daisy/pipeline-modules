<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                exclude-inline-prefixes="#all"
                type="px:fileset-copy" name="main">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Copy a fileset to a new location</p>
        <p>Fails if the fileset contains files outside of the base directory. No files are
        physically copied, that is done upon calling px:fileset-store.</p>
    </p:documentation>

    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The input fileset</p>
        </p:documentation>
        <p:empty/>
    </p:input>

    <p:output port="result.fileset" primary="true">
        <p:pipe step="fileset" port="result"/>
    </p:output>
    <p:output port="result.in-memory" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The output fileset at the new location.</p>
            <p>The xml:base is changed to "target". The hrefs are not updated, unless the "flatten"
            option is set, in which case they are reduced to the file name. The base URI of the
            in-memory documents are changed accordingly, and "original-href"-attributes are added
            for files that exist on disk.</p>
        </p:documentation>
        <p:pipe step="in-memory" port="result"/>
    </p:output>

    <p:option name="target" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>The target directory.</p>
        </p:documentation>
    </p:option>
    <p:option name="flatten" required="false" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Move all files to a single directory.</p>
        </p:documentation>
    </p:option>
    <p:option name="prefix" required="false" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p>Prefix to add before file names.</p>
            <p>Only if "flatten" option is set.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
        <p:documentation>
            px:error
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
        </p:documentation>
    </p:import>
    <p:import href="fileset-fix-original-hrefs.xpl"/>

    <p:documentation>Make the original-href attributes reflect what is actually stored on disk</p:documentation>
    <pxi:fileset-fix-original-hrefs>
        <p:input port="source.in-memory">
            <p:pipe step="main" port="source.in-memory"/>
        </p:input>
    </pxi:fileset-fix-original-hrefs>

    <p:documentation>Normalize the fileset and optionally flatten</p:documentation>
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/fileset-copy.xsl"/>
        </p:input>
        <p:with-param name="flatten" select="$flatten"/>
        <p:with-param name="prefix" select="$prefix"/>
    </p:xslt>

    <p:viewport match="d:file" name="add-original-href">
        <p:documentation>Fail if the file is outside of the base directory (URI is absolute or
        starts with "..")</p:documentation>
        <p:choose>
            <p:when test="/*/@href[matches(.,'^[^/]+:') or starts-with(.,'..')]">
                <px:error code="XXXX" message="File outside base directory $1: $2">
                    <p:with-option name="param1" select="base-uri(/*)">
                        <p:pipe step="main" port="source.fileset"/>
                    </p:with-option>
                    <p:with-option name="param2" select="/*/@href"/>
                </px:error>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:viewport>

    <p:label-elements match="/*/d:file" attribute="href-before-move" label="resolve-uri(@href, base-uri(.))"/>

    <p:documentation>Set the base directory to the target directory</p:documentation>
    <px:set-base-uri>
        <p:with-option name="base-uri" select="$target"/>
    </px:set-base-uri>
    <p:identity name="fileset.with-href-before-move"/>

    <p:delete match="/*/*/@href-before-move"/>
    <p:identity name="fileset"/>

    <p:documentation>Update the base URI of the in-memory documents</p:documentation>
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="main" port="source.in-memory"/>
        </p:iteration-source>
        <p:variable name="base-uri" select="base-uri(/*)"/>
        <p:choose>
            <p:xpath-context>
                <p:pipe step="fileset.with-href-before-move" port="result"/>
            </p:xpath-context>
            <p:when test="$base-uri=/*/d:file/@href-before-move">
                <px:set-base-uri>
                    <p:with-option name="base-uri" select="(/*/d:file[@href-before-move=$base-uri])[1]/resolve-uri(@href,base-uri(.))">
                        <p:pipe step="fileset.with-href-before-move" port="result"/>
                    </p:with-option>
                </px:set-base-uri>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:identity name="in-memory"/>

</p:declare-step>
