<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                exclude-inline-prefixes="px"
                type="px:fileset-add-entry" name="main">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Add a new entry to a fileset.</p>
  </p:documentation>

  <p:input port="source.fileset" primary="true">
    <p:inline exclude-inline-prefixes="#all"><d:fileset/></p:inline>
  </p:input>
  <p:input port="source.in-memory" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The input fileset</p>
    </p:documentation>
    <p:empty/>
  </p:input>

  <p:output port="result.fileset" primary="true"/>
  <p:output port="result.in-memory" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The fileset with the new entry added</p>
      <p>The result.in-memory port contains all the documents from the source.in-memory port, and if
      the new entry was provided via de "entry" port, that document is appended (or prepended,
      depending on the "first" option).</p>
      <p>If the input fileset already contained a file with the same URI as the new entry, it is not
      added, unless when the 'replace' option is set, in which case the old entry is removed and the
      new one is added to the beginning or the end. (Note however that the document sequence is not
      changed, only the manifest.) If the 'replace-attributes' option is set, attributes of the
      existing entry may be added or replaced.</p>
    </p:documentation>
    <p:pipe step="add-entry" port="result.in-memory"/>
  </p:output>

  <p:input port="entry" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The document to add to the fileset (at most one)</p>
      <p>Must be empty if the href option is specified.</p>
    </p:documentation>
    <p:empty/>
  </p:input>

  <p:option name="href" select="''">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The URI of the new entry</p>
      <p>If the entry is provided via a document on the entry port, the href option must not be
      specified. In this case the entry gets the base URI of the document.</p>
    </p:documentation>
  </p:option>

  <p:option name="media-type" select="''"/>
  <p:option name="original-href" select="''"><!-- if relative; will be resolved relative to the file --></p:option>
  <p:option name="first" cx:as="xs:boolean" select="false()"/>
  <p:option name="replace" cx:as="xs:boolean" select="false()"/>
  <p:option name="replace-attributes" cx:as="xs:boolean" select="false()"/>

  <p:input port="file-attributes" kind="parameter" primary="false">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Additional attributes to add to the new d:file entry, or to the existing entry if the
      fileset already contained a file with the same URI as the provided entry and if
      <code>replace-attributes</code> is set to <code>true</code>.</p>
      <p>Attributes named <code>href</code>, <code>original-href</code> or <code>media-type</code>
      are not allowed.</p>
    </p:documentation>
    <p:inline>
      <c:param-set/>
    </p:inline>
  </p:input>

  <p:declare-step type="pxi:fileset-add-entry">
    <p:input port="source.fileset" primary="true"/>
    <p:input port="source.in-memory" sequence="true"/>
    <p:output port="result.fileset" primary="true"/>
    <p:output port="result.in-memory" sequence="true"/>
    <p:input port="entry" sequence="true"/>
    <p:option name="href"/>
    <p:option name="media-type"/>
    <p:option name="original-href"/>
    <p:option name="first"/>
    <p:option name="replace"/>
    <p:option name="replace-attributes"/>
    <p:input port="file-attributes" kind="parameter" primary="false"/>
    <!-- Implemented in ../../../java/org/daisy/pipeline/fileset/calabash/impl/AddEntryStep.java -->
  </p:declare-step>

  <pxi:fileset-add-entry name="add-entry">
    <p:input port="source.in-memory">
      <p:pipe step="main" port="source.in-memory"/>
    </p:input>
    <p:input port="entry">
      <p:pipe step="main" port="entry"/>
    </p:input>
    <p:input port="file-attributes">
      <p:pipe step="main" port="file-attributes"/>
    </p:input>
    <p:with-option name="href" select="$href"/>
    <p:with-option name="media-type" select="$media-type"/>
    <p:with-option name="original-href" select="$original-href"/>
    <p:with-option name="first" select="$first"/>
    <p:with-option name="replace" select="$replace"/>
    <p:with-option name="replace-attributes" select="$replace-attributes"/>
  </pxi:fileset-add-entry>

</p:declare-step>
