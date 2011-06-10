<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">
    <p:input port="source"/>
    <p:output port="result"/>
    <p:option name="target" required="true"/>

    <p:import href="http://www.daisy.org/pipeline/modules/zip-utils/xproc/zip-library.xpl"/>

    <px:zip-manifest-from-fileset/>
    <p:add-attribute name="manifest" match="c:entry[@name='mimetype']"
        attribute-name="compression-method" attribute-value="stored"/>
    <px:zip compression-method="deflated">
        <p:input port="source">
            <p:empty/>
        </p:input>
        <p:input port="manifest">
            <p:pipe port="result" step="manifest"/>
        </p:input>
        <p:with-option name="href" select="$target"/>
    </px:zip>
</p:declare-step>
