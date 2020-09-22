<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                type="px:daisy3-create-opf" name="main">

    <p:input port="source" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>The DAISY 3 fileset.</p>
        <p>If the fileset contains a file marked with a <code>role</code> attribute with value
        <code>mathml-xslt-fallback</code>, it will be used as the "DTBook-XSLTFallback" for
        MathML.</p>
      </p:documentation>
    </p:input>
    <p:input port="source.in-memory" sequence="true"/>

    <p:output port="result" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>The <a
        href="http://web.archive.org/web/20101221093536/http://www.idpf.org/oebps/oebps1.2/download/oeb12-xhtml.htm">OEBPS</a>
        package document</p>
      </p:documentation>
      <p:pipe step="opf" port="result"/>
    </p:output>

    <p:output port="result.fileset">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Result fileset with a single file, the package document.</p>
      </p:documentation>
      <p:pipe step="fileset" port="result"/>
    </p:output>

    <p:option name="title">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Title of the DTBook document.</p>
      </p:documentation>
    </p:option>

    <p:option name="uid">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>UID of the DTBook (in the meta elements)</p>
      </p:documentation>
    </p:option>

    <p:option name="output-base-uri">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Output directory URI if the OPF file were to be stored or refered by a fileset.</p>
      </p:documentation>
    </p:option>

    <p:option name="lang">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Main language of the DTBook file(s).</p>
      </p:documentation>
    </p:option>

    <p:option name="date" required="false" select="''">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Date of publication of the DTB</p>
        <p>Format must be YYYY[-MM[-DD]]</p>
        <p>Defaults to the current date.</p>
      </p:documentation>
    </p:option>

    <p:option name="publisher"/>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
        <p:documentation>
            px:set-base-uri
        </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation>
            px:fileset-load
            px:fileset-create
            px:fileset-add-entry
        </p:documentation>
    </p:import>

    <px:fileset-load media-types="application/smil">
      <p:documentation>Assumes that SMILs are listed in order in fileset and that they are also
      loaded in that order.</p:documentation>
      <p:input port="in-memory">
        <p:pipe step="main" port="source.in-memory"/>
      </p:input>
    </px:fileset-load>
    <p:xslt name="total-time" template-name="main">
      <p:input port="stylesheet">
        <p:document href="compute-total-time.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
    </p:xslt>
    <p:sink/>

    <p:xslt>
      <p:input port="source">
        <p:pipe step="main" port="source"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="create-opf.xsl"/>
      </p:input>
      <p:with-param name="lang" select="$lang"/>
      <p:with-param name="date" select="$date"/>
      <p:with-param name="publisher" select="$publisher"/>
      <p:with-param name="output-base-uri" select="$output-base-uri"/>
      <p:with-param name="uid" select="$uid"/>
      <p:with-param name="title" select="$title"/>
      <p:with-param name="total-time" select="string(/*)">
        <p:pipe step="total-time" port="result"/>
      </p:with-param>
    </p:xslt>

    <px:set-base-uri>
      <p:with-option name="base-uri" select="$output-base-uri"/>
    </px:set-base-uri>
    <p:identity name="opf"/>
    <p:sink/>

    <px:fileset-create>
      <p:with-option name="base" select="resolve-uri('./',$output-base-uri)"/>
    </px:fileset-create>
    <px:fileset-add-entry media-type="text/xml" name="fileset">
      <p:input port="entry">
        <p:pipe step="opf" port="result"/>
      </p:input>
      <p:with-param port="file-attributes" name="indent" select="'true'"/>
      <p:with-param port="file-attributes" name="doctype-public" select="'+//ISBN 0-9673008-1-9//DTD OEB 1.2 Package//EN'"/>
      <p:with-param port="file-attributes" name="doctype-system" select="'http://openebook.org/dtds/oeb-1.2/oebpkg12.dtd'"/>
    </px:fileset-add-entry>
    <p:sink/>

</p:declare-step>
