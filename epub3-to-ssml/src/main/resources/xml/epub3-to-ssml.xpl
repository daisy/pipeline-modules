<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc" name="main" type="px:epub3-to-ssml"
    version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Pipes a verbatime copy of its input on its output, while logging a 'Hello World'
            message.</p>
    </p:documentation>

    <!--=========================================================================-->
    <!-- STEP SIGNATURE                                                          -->
    <!--=========================================================================-->

    <p:input port="source"/>
    <p:output port="result"/>

    <!--=========================================================================-->
    <!-- IMPORTS                                                                 -->
    <!--=========================================================================-->

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/logging-library.xpl"/>

    <!--=========================================================================-->
    <!-- IMPLEMEMTATION BODY                                                     -->
    <!--=========================================================================-->

    <px:message message="Hello World!"/>

</p:declare-step>
