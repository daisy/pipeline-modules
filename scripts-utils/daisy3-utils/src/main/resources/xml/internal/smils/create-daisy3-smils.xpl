<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:smil="http://www.w3.org/2001/SMIL20/"
                type="px:daisy3-create-smils" name="main">

    <p:input port="content" primary="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>DTBook</p>
      </p:documentation>
    </p:input>

    <p:input port="audio-map">
       <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p><code>d:audio-clips</code> document with the locations of the audio files.</p>
         <p>The clipBegin and clipEnd attributes must be compliant with the XML time data type and
         not be greater than 24 hours. See pipeline-mod-tts's documentation for more details.</p>
       </p:documentation>
    </p:input>

    <p:output port="result.fileset" primary="true"/>
    <p:output port="result.in-memory" sequence="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Result fileset with the SMIL files and the modified DTBook with smilref attributes.</p>
      </p:documentation>
      <p:pipe port="result" step="copy-smilrefs"/>
      <p:pipe port="result" step="smil-with-durations"/>
    </p:output>

    <p:output port="duration">
      <p:pipe port="result" step="total-duration"/>
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Total duration</p>
        <p>A <code>d:durations</code> document with a <code>d:total</code> child element with a
        <code>duration</code> attribute.</p>
      </p:documentation>
    </p:output>

    <p:option name="smil-dir">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>Directory URI which the URI of the output SMIL files will be based on.</p>
      </p:documentation>
    </p:option>

    <p:option name="uid">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>UID of the DTBook (in the meta elements)</p>
      </p:documentation>
    </p:option>

    <p:option name="audio-only" required="false" select="'false'">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
	<p>No reference to DTBook in SMIL files</p>
      </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl">
      <p:documentation>
        px:message
      </p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
      <p:documentation>
        px:fileset-create
        px:fileset-add-entry
        px:fileset-join
      </p:documentation>
    </p:import>

    <!-- They cannot hold a smilref attribute or they can contain
         levels (which would make them wrongly dispatched over
         multiple smils) -->
    <p:variable name="no-smilref"
		select="' level level1 level2 level3 level4 level5 level6 dtbook frontmatter bodymatter rearmatter br head title meta style book bdo hr w '"/>

    <p:delete match="@smilref"/>

    <p:xslt name="add-ids">
      <p:input port="stylesheet">
	<p:document href="add-ids.xsl"/>
      </p:input>
      <p:with-param name="no-smilref" select="$no-smilref"/>
      <p:with-param name="stop-recursion" select="' math '"/>
    </p:xslt>
    <px:message severity="DEBUG" message="Smil-needed IDs generated"/>

    <p:xslt name="audio-order">
      <p:input port="stylesheet">
    	<p:document href="audio-order.xsl"/>
      </p:input>
      <p:input port="parameters">
    	<p:empty/>
      </p:input>
    </p:xslt>
    <px:message severity="DEBUG" message="SMIL audio order generated"/>
    <p:sink/>

    <p:load name="add-smilrefs-xsl">
      <p:with-option name="href"
      		     select="if ($audio-only='true') then 'add-smilrefs-audio-only.xsl' else 'add-smilrefs.xsl'"/>
    </p:load>

    <p:xslt name="add-smilrefs">
      <p:input port="source">
	<p:pipe port="result" step="audio-order"/>
	<p:pipe port="audio-map" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:pipe port="result" step="add-smilrefs-xsl"/>
      </p:input>
      <p:with-param name="no-smilref" select="$no-smilref"/>
      <p:with-param name="mo-dir" select="$smil-dir"/>
    </p:xslt>
    <px:message severity="DEBUG" message="Smilref generated"/>
    <p:sink/>

    <p:xslt name="copy-smilrefs">
      <p:input port="source">
	<p:pipe port="result" step="add-ids"/>
	<p:pipe port="result" step="add-smilrefs"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="copy-smilrefs.xsl"/>
      </p:input>
      <p:input port="parameters">
	<p:empty/>
      </p:input>
    </p:xslt>
    <px:message severity="DEBUG" message="Smilrefs copied to the original document"/>
    <p:sink/>

    <p:xslt name="create-smils">
      <p:input port="source">
	<p:pipe port="result" step="add-smilrefs"/>
	<p:pipe port="audio-map" step="main"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="create-smils.xsl"/>
      </p:input>
      <p:with-param name="uid" select="$uid"/>
      <p:with-param name="mo-dir" select="$smil-dir"/>
      <p:with-param name="audio-only" select="$audio-only"/>
    </p:xslt>
    <px:message severity="DEBUG" message="SMIL files generated."/><p:sink/>
    <p:for-each name="all-smils">
      <p:iteration-source>
	<p:pipe port="secondary" step="create-smils"/>
      </p:iteration-source>
      <p:output port="result"/>
      <p:xslt>
	<p:input port="stylesheet">
	  <p:document href="fill-end-attrs.xsl"/>
	</p:input>
	<p:input port="parameters">
	  <p:empty/>
	</p:input>
      </p:xslt>
    </p:for-each>

    <p:xslt name="compute-durations">
      <p:input port="source">
	<p:pipe port="result" step="all-smils"/>
      </p:input>
      <p:input port="stylesheet">
	<p:document href="compute-durations.xsl"/>
      </p:input>
      <p:input port="parameters">
	<p:empty/>
      </p:input>
    </p:xslt>
    <p:delete match="d:duration" name="total-duration"/>
    <px:message severity="DEBUG" message="Durations computed."/><p:sink/>

    <p:for-each name="smil-with-durations">
      <p:output port="result"/>
      <p:iteration-source>
	<p:pipe port="result" step="all-smils"/>
      </p:iteration-source>
      <p:variable name="doc-uri" select="base-uri(/*)"/>
      <p:viewport match="smil:head/smil:meta[@name='dtb:totalElapsedTime']">
	<p:add-attribute attribute-name="content" match="/*">
	  <p:with-option name="attribute-value" select="//*[@doc=$doc-uri]/@duration">
	    <p:pipe port="result" step="compute-durations"/>
	  </p:with-option>
	</p:add-attribute>
      </p:viewport>
      <p:choose>
	<p:when test="$audio-only = 'true'">
	  <p:delete match="smil:text"/>
	</p:when>
	<p:otherwise>
	  <p:identity/>
	</p:otherwise>
      </p:choose>
    </p:for-each>

    <p:for-each>
      <p:iteration-source>
	<p:pipe port="result" step="all-smils"/>
      </p:iteration-source>
      <p:identity name="smil"/>
      <p:sink/>
      <px:fileset-create>
	<p:with-option name="base" select="$smil-dir"/>
      </px:fileset-create>
      <px:fileset-add-entry media-type="application/smil">
        <p:input port="entry">
          <p:pipe step="smil" port="result"/>
        </p:input>
        <p:with-param port="file-attributes" name="indent" select="'true'"/>
        <p:with-param port="file-attributes" name="doctype-public" select="'-//NISO//DTD dtbsmil 2005-2//EN'"/>
        <p:with-param port="file-attributes" name="doctype-system" select="'http://www.daisy.org/z3986/2005/dtbsmil-2005-2.dtd'"/>
      </px:fileset-add-entry>
    </p:for-each>
    <px:fileset-join px:message="SMIL fileset created." px:message-severity="DEBUG"/>
    <px:fileset-add-entry media-type="application/x-dtbook+xml">
      <p:input port="entry">
        <p:pipe step="main" port="content"/>
      </p:input>
    </px:fileset-add-entry>

</p:declare-step>
