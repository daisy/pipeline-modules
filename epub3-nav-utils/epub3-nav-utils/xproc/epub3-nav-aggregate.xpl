<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-nav-aggregate" name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" version="1.0">


    <p:input port="source" sequence="true"/>
    <p:output port="result"/>

    <p:insert match="html:body" position="first-child" xmlns:html="http://www.w3.org/1999/xhtml">
        <p:input port="source">
            <!--TODO localize title-->
            <!--TODO add stylesheet-->
            <!--TODO add language attribute-->
            <p:inline exclude-inline-prefixes="#all">
                <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
                    <head>
                        <meta http-equiv="content-type" content="application/xhtml+xml; charset=UTF-8"/>
                        <title>Navigation Document</title>
                    </head>
                    <body/>
                </html>
            </p:inline>
        </p:input>
        <p:input port="insertion">
            <p:pipe port="source" step="main"/>
        </p:input>
    </p:insert>

</p:declare-step>
