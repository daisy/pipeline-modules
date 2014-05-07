<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:d="http://www.daisy.org/ns/pipeline/data"
		xmlns:dt="http://www.daisy.org/z3986/2005/dtbook/"
		xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
		exclude-result-prefixes="#all" version="2.0">

  <!-- This script takes as inputs the content document and the audio map (in collection()). -->

  <xsl:import href="http://www.daisy.org/pipeline/modules/file-utils/uri-functions.xsl"/>

  <xsl:param name="mo-dir"/>
  <xsl:param name="output-dir"/>

  <xsl:key name="clips" match="*[@idref]" use="@idref"/>
  <xsl:key name="refs" match="*[@node]" use="@node"/>
  <xsl:key name="targets" match="*[@id]" use="@id"/>

  <!-- ============================================ -->
  <!-- ====== MAP THE NODES TO THEIR SMILREF ====== -->
  <!-- ============================================ -->

  <xsl:variable name="mo-dir-rel" select="pf:relativize-uri($mo-dir, $output-dir)"/>
  <xsl:variable name="mo-nodes" select="' img list sent linegroup pagenum table linenum prodnote sidebar hd levelhd h1 h2 h3 h4 h5 h6 '"/>
  <xsl:variable name="link-nodes" select="' noteref annoref '"/>
  <xsl:variable name="target-nodes" select="' note annotation '"/>

  <!-- This variable maps levels to numbers. They will be used for
       determining the smil names (except when the levels are inside
       notes or annotations). -->
  <xsl:variable name="top-elements">
    <d:roots>
      <!-- Note: despite the 'following-sibling' condition, this might
           create position not referenced anywhere, which is harmless. -->
      <xsl:for-each select="//*[starts-with(local-name(), 'level') and following-sibling::*[1]]">
	<d:root pos="{position()}" node="{generate-id(current())}"/>
      </xsl:for-each>
    </d:roots>
  </xsl:variable>

  <xsl:variable name="smilrefs">
    <d:smilrefs>
      <xsl:apply-templates select="/*" mode="generate-smilrefs"/>
    </d:smilrefs>
  </xsl:variable>

  <xsl:template match="*[contains($link-nodes, concat(' ', local-name(), ' '))]"
		mode="generate-smilrefs" priority="3">
    <xsl:param name="ref-node" select="()"/>
    <xsl:apply-templates select="." mode="attach-to-smil-file">
      <!-- $ref-node can exist if the noteref is inside a note. -->
      <xsl:with-param name="ref-node" select="if ($ref-node) then $ref-node else ."/>
      <xsl:with-param name="smilref" select="concat('ref-', generate-id())"/>
    </xsl:apply-templates>
    <xsl:variable name="target" select="key('targets', substring-after(@idref, '#'))"/>
    <xsl:apply-templates select="$target" mode="generate-smilrefs">
      <xsl:with-param name="ref-node" select="if ($ref-node) then $ref-node else ."/>
    </xsl:apply-templates>
    <!-- No recursive call (no child can have a @smilref). -->
  </xsl:template>

  <xsl:template match="*[contains($target-nodes, concat(' ', local-name(), ' '))]"
		mode="generate-smilrefs" priority="3">
    <xsl:param name="ref-node" select="()"/>
    <xsl:if test="$ref-node">
      <xsl:apply-templates select="." mode="attach-to-smil-file">
	<xsl:with-param name="ref-node" select="$ref-node"/>
	<xsl:with-param name="smilref" select="concat('target-', generate-id())"/>
      </xsl:apply-templates>
      <xsl:if test="not(@id and key('clips', @id, collection()[/d:audio-clips])) and count(dt:w) = 0">
	<!-- Recursive calls: children can have a @smilref, for
	     instance a sent in a note. -->
	<xsl:apply-templates select="*" mode="generate-smilrefs">
	  <xsl:with-param name="ref-node" select="$ref-node"/>
	</xsl:apply-templates>
      </xsl:if>
    </xsl:if>
    <!-- No 'otherwise' clause because the smilref of the targets have
         already generated somewhere else (see above). -->
  </xsl:template>

  <xsl:template match="*[key('clips', @id, collection()[/d:audio-clips]) or count(dt:w) > 0]"
		mode="generate-smilrefs" priority="2">
    <xsl:param name="ref-node" select="()"/>
    <xsl:apply-templates select="." mode="attach-to-smil-file">
      <xsl:with-param name="ref-node" select="if ($ref-node) then $ref-node else ."/>
      <xsl:with-param name="smilref" select="concat('leaf-', generate-id())"/>
    </xsl:apply-templates>
    <!-- No recursive call (no child can have a @smilref). -->
  </xsl:template>

  <xsl:template match="*[contains($mo-nodes, concat(' ', local-name(), ' '))]"
		mode="generate-smilrefs" priority="1">
    <xsl:param name="ref-node" select="()"/>
    <xsl:apply-templates select="." mode="attach-to-smil-file">
      <xsl:with-param name="ref-node" select="if ($ref-node) then $ref-node else ."/>
      <xsl:with-param name="smilref" select="concat('seq-', generate-id())"/>
    </xsl:apply-templates>
    <!-- Recursive calls (children can have a @smilref) -->
    <xsl:apply-templates select="*" mode="generate-smilrefs">
      <xsl:with-param name="ref-node" select="$ref-node"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" priority="0" mode="generate-smilrefs">
    <xsl:param name="ref-node" select="()"/>
    <xsl:apply-templates select="*" mode="generate-smilrefs">
      <xsl:with-param name="ref-node" select="$ref-node"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Attach a @smilref to the same SMIL file as where $ref-node is into. -->
  <xsl:template match="*" mode="attach-to-smil-file">
    <xsl:param name="ref-node"/>
    <xsl:param name="smilref"/>
    <xsl:variable name="prev" select="$ref-node/preceding::*[key('refs', generate-id(), $top-elements)][1]"/>
    <xsl:variable name="smil-id">
      <xsl:choose>
	<xsl:when test="$prev">
	  <xsl:value-of select="key('refs', generate-id($prev), $top-elements)/@pos"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'0'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <d:smilref ref="{concat($mo-dir-rel, 'mo', $smil-id, '.smil#', $smilref)}" node="{generate-id()}"/>
  </xsl:template>

  <!-- =============================================================== -->
  <!-- ====== REBUILD THE DOCUMENT WITH THE ADDITIONAL @SMILREF ====== -->
  <!-- =============================================================== -->

  <xsl:template match="node() | @*" priority="1">
    <xsl:copy>
      <xsl:variable name="smilref" select="key('refs', generate-id(), $smilrefs)[1]"/>
      <xsl:if test="$smilref">
	<xsl:if test="not(@id)">
	  <xsl:attribute name="id">
	    <xsl:value-of select="concat('forsmil-', generate-id())"/>
	  </xsl:attribute>
	</xsl:if>
	<xsl:attribute name="smilref">
	  <xsl:value-of select="$smilref/@ref"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
