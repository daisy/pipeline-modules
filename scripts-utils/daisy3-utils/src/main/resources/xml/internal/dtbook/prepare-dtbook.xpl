<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
                type="px:daisy3-prepare-dtbook">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Add missing elements to a DTBook so as to make the NCX/OPF/SMIL generation easier.</p>
      <p>Also add UID metadata and set DOCTYPE.</p>
    </p:documentation>

    <p:input port="source" primary="true"/>
    <p:output port="result.fileset" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Result fileset with a single file, the DTBook.</p>
      </p:documentation>
    </p:output>
    <p:output port="result.in-memory">
      <p:pipe step="dtbook" port="result"/>
    </p:output>

    <p:option name="output-base-uri" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>The base URI of the result DTBook</p>
      </p:documentation>
    </p:option>
    <p:option name="mathml-formulae-img" select="''"/>
    <p:option name="uid" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>UID of the DTBook (in the meta elements)</p>
      </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl">
      <p:documentation>
        px:set-base-uri
      </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
      <p:documentation>
        px:fileset-create
        px:fileset-add-entry
      </p:documentation>
    </p:import>

    <p:variable name="dtd-version" select="(//dtb:dtbook)[1]/@version"/>

    <!-- fix structure -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="fix-dtbook-structure.xsl"/>
      </p:input>
      <p:with-param name="mathml-formulae-img" select="$mathml-formulae-img"/>
    </p:xslt>

    <!-- add metadata -->
    <p:add-attribute match="//dtb:meta[@name='dtb:uid']" attribute-name="content">
      <p:with-option name="attribute-value" select="$uid"/>
    </p:add-attribute>
    <p:add-attribute match="//dtb:meta[@name='dc:Identifier' and count(@*)=2]"
                     attribute-name="content">
      <p:with-option name="attribute-value" select="$uid"/>
    </p:add-attribute>

    <!-- set base uri -->
    <px:set-base-uri>
      <p:with-option name="base-uri" select="$output-base-uri"/>
    </px:set-base-uri>
    <p:identity name="dtbook"/>
    <p:sink/>

    <px:fileset-create>
      <p:with-option name="base" select="resolve-uri('./',$output-base-uri)"/>
    </px:fileset-create>
    <px:fileset-add-entry media-type="application/x-dtbook+xml" name="fileset">
      <p:input port="entry">
        <p:pipe step="dtbook" port="result"/>
      </p:input>
      <p:with-param port="file-attributes" name="doctype-public"
                    select="concat('-//NISO//DTD dtbook ', $dtd-version, '//EN')"/>
      <p:with-param port="file-attributes" name="doctype-system"
                    select="concat('http://www.daisy.org/z3986/2005/dtbook-', $dtd-version, '.dtd')"/>
    </px:fileset-add-entry>

</p:declare-step>
