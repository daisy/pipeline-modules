<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" exclude-inline-prefixes="#all" version="1.0" type="px:mediatype-detect">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">Media type detect</h1>
        <p px:role="desc">Determine the media type of a file.</p>
        <div px:role="author maintainer">
            <p px:role="name">Jostein Austvik Jacobsen</p>
            <a href="mailto:josteinaj@gmail.com" px:role="contact">josteinaj@gmail.com</a>
            <p px:role="organization">NLB</p>
        </div>
    </p:documentation>

    <p:input port="source" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Fileset</h2>
            <p px:role="desc">A DAISY Pipeline 2 fileset document as described on <a href="http://code.google.com/p/daisy-pipeline/wiki/FileSetDocument">http://code.google.com/p/daisy-pipeline/wiki/FileSetDocument</a>.</p>
        </p:documentation>
    </p:input>
    <p:input port="in-memory" sequence="true" primary="false">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">In-memory documents</h2>
        </p:documentation>
        <p:empty/>
    </p:input>
    <p:output port="result">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Result fileset</h2>
            <p px:role="desc">The same d:fileset that arrived on the input port, but with "media-type"-attributes added to all d:file elements.</p>
        </p:documentation>
    </p:output>

    <p:option name="load-if-not-in-memory" select="'false'"/>

    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>

    <p:declare-step type="pxi:mediatype-detect-from-extension">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:variable name="ext" select="lower-case(replace(/*/@href,'^.+?([^/\.]+)$','$1'))"/>
        <p:add-attribute match="/*" attribute-name="media-type">
            <p:with-option name="attribute-value" select="(//entry[@key=$ext]/@value, 'application/octet-stream')[1]">
                <p:inline>
                    <map>
                        <entry key="xml"       value="application/xml"/>
                        <entry key="xhtml"     value="application/xhtml+xml"/>
                        <entry key="smil"      value="application/smil+xml"/>
                        <entry key="mp3"       value="audio/mpeg"/>
                        <entry key="epub"      value="application/epub+zip"/>
                        <entry key="xpl"       value="application/xproc+xml"/>
                        <entry key="xproc"     value="application/xproc+xml"/>
                        <entry key="xsl"       value="application/xslt+xml"/>
                        <entry key="xslt"      value="application/xslt+xml"/>
                        <entry key="xq"        value="application/xquery+xml"/>
                        <entry key="xquery"    value="application/xquery+xml"/>
                        <entry key="otf"       value="application/x-font-opentype"/>
                        <entry key="wav"       value="audio/x-wav"/>
                        <entry key="opf"       value="application/oebps-package+xml"/>
                        <entry key="ncx"       value="application/x-dtbncx+xml"/>
                        <entry key="mp4"       value="audio/mpeg4-generic"/>
                        <entry key="jpg"       value="image/jpeg"/>
                        <entry key="jpe"       value="image/jpeg"/>
                        <entry key="jpeg"      value="image/jpeg"/>
                        <entry key="png"       value="image/png"/>
                        <entry key="svg"       value="image/svg+xml"/>
                        <entry key="css"       value="text/css"/>
                        <entry key="dtd"       value="application/xml-dtd"/>
                        <entry key="res"       value="application/x-dtbresource+xml"/>
                        <entry key="ogg"       value="audio/ogg"/>
                        <entry key="au"        value="audio/basic"/>
                        <entry key="snd"       value="audio/basic"/>
                        <entry key="mid"       value="audio/mid"/>
                        <entry key="rmi"       value="audio/mid"/>
                        <entry key="aif"       value="audio/x-aiff"/>
                        <entry key="aifc"      value="audio/x-aiff"/>
                        <entry key="aiff"      value="audio/x-aiff"/>
                        <entry key="m3u"       value="audio/x-mpegurl"/>
                        <entry key="ra"        value="audio/x-pn-realaudio"/>
                        <entry key="ram"       value="audio/x-pn-realaudio"/>
                        <entry key="bmp"       value="image/bmp"/>
                        <entry key="cod"       value="image/cis-cod"/>
                        <entry key="gif"       value="image/gif"/>
                        <entry key="ief"       value="image/ief"/>
                        <entry key="jfif"      value="image/pipeg"/>
                        <entry key="tif"       value="image/tiff"/>
                        <entry key="tiff"      value="image/tiff"/>
                        <entry key="ras"       value="image/x-cmu-raster"/>
                        <entry key="cmx"       value="image/x-cmx"/>
                        <entry key="ico"       value="image/x-icon"/>
                        <entry key="pnm"       value="image/x-portable-anymap"/>
                        <entry key="pbm"       value="image/x-portable-bitmap"/>
                        <entry key="pgm"       value="image/x-portable-graymap"/>
                        <entry key="ppm"       value="image/x-portable-pixmap"/>
                        <entry key="rgb"       value="image/x-rgb"/>
                        <entry key="xbm"       value="image/x-xbitmap"/>
                        <entry key="xpm"       value="image/x-xpixmap"/>
                        <entry key="xwd"       value="image/x-xwindowdump"/>
                        <entry key="mp2"       value="video/mpeg"/>
                        <entry key="mpa"       value="video/mpeg"/>
                        <entry key="mpe"       value="video/mpeg"/>
                        <entry key="mpeg"      value="video/mpeg"/>
                        <entry key="mpg"       value="video/mpeg"/>
                        <entry key="mpv2"      value="video/mpeg"/>
                        <entry key="mov"       value="video/quicktime"/>
                        <entry key="qt"        value="video/quicktime"/>
                        <entry key="lsf"       value="video/x-la-asf"/>
                        <entry key="lsx"       value="video/x-la-asf"/>
                        <entry key="asf"       value="video/x-ms-asf"/>
                        <entry key="asr"       value="video/x-ms-asf"/>
                        <entry key="asx"       value="video/x-ms-asf"/>
                        <entry key="avi"       value="video/x-msvideo"/>
                        <entry key="movie"     value="video/x-sgi-movie"/>
                        <entry key="323"       value="text/h323"/>
                        <entry key="htm"       value="text/html"/>
                        <entry key="html"      value="text/html"/>
                        <entry key="stm"       value="text/html"/>
                        <entry key="uls"       value="text/iuls"/>
                        <entry key="bas"       value="text/plain"/>
                        <entry key="c"         value="text/plain"/>
                        <entry key="h"         value="text/plain"/>
                        <entry key="txt"       value="text/plain"/>
                        <entry key="rtx"       value="text/richtext"/>
                        <entry key="sct"       value="text/scriptlet"/>
                        <entry key="tsv"       value="text/tab-separated-values"/>
                        <entry key="htt"       value="text/webviewhtml"/>
                        <entry key="htc"       value="text/x-component"/>
                        <entry key="etx"       value="text/x-setext"/>
                        <entry key="vcf"       value="text/x-vcard"/>
                        <entry key="mht"       value="message/rfc822"/>
                        <entry key="mhtml"     value="message/rfc822"/>
                        <entry key="nws"       value="message/rfc822"/>
                        <entry key="evy"       value="application/envoy"/>
                        <entry key="fif"       value="application/fractals"/>
                        <entry key="spl"       value="application/futuresplash"/>
                        <entry key="hta"       value="application/hta"/>
                        <entry key="acx"       value="application/internet-property-stream"/>
                        <entry key="hqx"       value="application/mac-binhex40"/>
                        <entry key="doc"       value="application/msword"/>
                        <entry key="dot"       value="application/msword"/>
                        <entry key="*"         value="application/octet-stream"/>
                        <entry key="bin"       value="application/octet-stream"/>
                        <entry key="class"     value="application/octet-stream"/>
                        <entry key="dms"       value="application/octet-stream"/>
                        <entry key="exe"       value="application/octet-stream"/>
                        <entry key="lha"       value="application/octet-stream"/>
                        <entry key="lzh"       value="application/octet-stream"/>
                        <entry key="oda"       value="application/oda"/>
                        <entry key="axs"       value="application/olescript"/>
                        <entry key="pdf"       value="application/pdf"/>
                        <entry key="prf"       value="application/pics-rules"/>
                        <entry key="p10"       value="application/pkcs10"/>
                        <entry key="crl"       value="application/pkix-crl"/>
                        <entry key="ai"        value="application/postscript"/>
                        <entry key="eps"       value="application/postscript"/>
                        <entry key="ps"        value="application/postscript"/>
                        <entry key="rtf"       value="application/rtf"/>
                        <entry key="setpay"    value="application/set-payment-initiation"/>
                        <entry key="setreg"    value="application/set-registration-initiation"/>
                        <entry key="xla"       value="application/vnd.ms-excel"/>
                        <entry key="xlc"       value="application/vnd.ms-excel"/>
                        <entry key="xlm"       value="application/vnd.ms-excel"/>
                        <entry key="xls"       value="application/vnd.ms-excel"/>
                        <entry key="xlt"       value="application/vnd.ms-excel"/>
                        <entry key="xlw"       value="application/vnd.ms-excel"/>
                        <entry key="msg"       value="application/vnd.ms-outlook"/>
                        <entry key="sst"       value="application/vnd.ms-pkicertstore"/>
                        <entry key="cat"       value="application/vnd.ms-pkiseccat"/>
                        <entry key="stl"       value="application/vnd.ms-pkistl"/>
                        <entry key="pot"       value="application/vnd.ms-powerpoint"/>
                        <entry key="pps"       value="application/vnd.ms-powerpoint"/>
                        <entry key="ppt"       value="application/vnd.ms-powerpoint"/>
                        <entry key="mpp"       value="application/vnd.ms-project"/>
                        <entry key="wcm"       value="application/vnd.ms-works"/>
                        <entry key="wdb"       value="application/vnd.ms-works"/>
                        <entry key="wks"       value="application/vnd.ms-works"/>
                        <entry key="wps"       value="application/vnd.ms-works"/>
                        <entry key="hlp"       value="application/winhlp"/>
                        <entry key="bcpio"     value="application/x-bcpio"/>
                        <entry key="cdf"       value="application/x-cdf"/>
                        <entry key="z"         value="application/x-compress"/>
                        <entry key="tgz"       value="application/x-compressed"/>
                        <entry key="cpio"      value="application/x-cpio"/>
                        <entry key="csh"       value="application/x-csh"/>
                        <entry key="dcr"       value="application/x-director"/>
                        <entry key="dir"       value="application/x-director"/>
                        <entry key="dxr"       value="application/x-director"/>
                        <entry key="dvi"       value="application/x-dvi"/>
                        <entry key="gtar"      value="application/x-gtar"/>
                        <entry key="gz"        value="application/x-gzip"/>
                        <entry key="hdf"       value="application/x-hdf"/>
                        <entry key="ins"       value="application/x-internet-signup"/>
                        <entry key="isp"       value="application/x-internet-signup"/>
                        <entry key="iii"       value="application/x-iphone"/>
                        <entry key="js"        value="application/x-javascript"/>
                        <entry key="latex"     value="application/x-latex"/>
                        <entry key="mdb"       value="application/x-msaccess"/>
                        <entry key="crd"       value="application/x-mscardfile"/>
                        <entry key="clp"       value="application/x-msclip"/>
                        <entry key="dll"       value="application/x-msdownload"/>
                        <entry key="m13"       value="application/x-msmediaview"/>
                        <entry key="m14"       value="application/x-msmediaview"/>
                        <entry key="mvb"       value="application/x-msmediaview"/>
                        <entry key="wmf"       value="application/x-msmetafile"/>
                        <entry key="mny"       value="application/x-msmoney"/>
                        <entry key="pub"       value="application/x-mspublisher"/>
                        <entry key="scd"       value="application/x-msschedule"/>
                        <entry key="trm"       value="application/x-msterminal"/>
                        <entry key="wri"       value="application/x-mswrite"/>
                        <entry key="cdf"       value="application/x-netcdf"/>
                        <entry key="nc"        value="application/x-netcdf"/>
                        <entry key="pma"       value="application/x-perfmon"/>
                        <entry key="pmc"       value="application/x-perfmon"/>
                        <entry key="pml"       value="application/x-perfmon"/>
                        <entry key="pmr"       value="application/x-perfmon"/>
                        <entry key="pmw"       value="application/x-perfmon"/>
                        <entry key="p12"       value="application/x-pkcs12"/>
                        <entry key="pfx"       value="application/x-pkcs12"/>
                        <entry key="p7b"       value="application/x-pkcs7-certificates"/>
                        <entry key="spc"       value="application/x-pkcs7-certificates"/>
                        <entry key="p7r"       value="application/x-pkcs7-certreqresp"/>
                        <entry key="p7c"       value="application/x-pkcs7-mime"/>
                        <entry key="p7m"       value="application/x-pkcs7-mime"/>
                        <entry key="p7s"       value="application/x-pkcs7-signature"/>
                        <entry key="sh"        value="application/x-sh"/>
                        <entry key="shar"      value="application/x-shar"/>
                        <entry key="swf"       value="application/x-shockwave-flash"/>
                        <entry key="sit"       value="application/x-stuffit"/>
                        <entry key="sv4cpio"   value="application/x-sv4cpio"/>
                        <entry key="sv4crc"    value="application/x-sv4crc"/>
                        <entry key="tar"       value="application/x-tar"/>
                        <entry key="tcl"       value="application/x-tcl"/>
                        <entry key="tex"       value="application/x-tex"/>
                        <entry key="texi"      value="application/x-texinfo"/>
                        <entry key="texinfo"   value="application/x-texinfo"/>
                        <entry key="roff"      value="application/x-troff"/>
                        <entry key="t"         value="application/x-troff"/>
                        <entry key="tr"        value="application/x-troff"/>
                        <entry key="man"       value="application/x-troff-man"/>
                        <entry key="me"        value="application/x-troff-me"/>
                        <entry key="ms"        value="application/x-troff-ms"/>
                        <entry key="ustar"     value="application/x-ustar"/>
                        <entry key="src"       value="application/x-wais-source"/>
                        <entry key="cer"       value="application/x-x509-ca-cert"/>
                        <entry key="crt"       value="application/x-x509-ca-cert"/>
                        <entry key="der"       value="application/x-x509-ca-cert"/>
                        <entry key="pko"       value="application/ynd.ms-pkipko"/>
                        <entry key="zip"       value="application/zip"/>
                        <entry key="flr"       value="x-world/x-vrml"/>
                        <entry key="vrml"      value="x-world/x-vrml"/>
                        <entry key="wrl"       value="x-world/x-vrml"/>
                        <entry key="wrz"       value="x-world/x-vrml"/>
                        <entry key="xaf"       value="x-world/x-vrml"/>
                        <entry key="xof"       value="x-world/x-vrml"/>
                        <entry key="gitignore" value="text/plain"/>
                        <entry key="hgignore"  value="text/plain"/>
                    </map>
                </p:inline>
            </p:with-option>
        </p:add-attribute>
    </p:declare-step>
    
    <p:declare-step type="pxi:mediatype-detect-from-namespace" name="detect-from-namespace">
        <p:input port="source" primary="true"/>
        <p:input port="in-memory"/>
        <p:output port="result"/>
        <p:variable name="ns" select="namespace-uri(/*)">
            <p:pipe port="in-memory" step="detect-from-namespace"/>
        </p:variable>
         <p:add-attribute match="/*" attribute-name="media-type">
            <p:with-option name="attribute-value" select="(//entry[@key=$ns]/@value, 'application/xml')[1]">
                <p:inline>
                    <map>
                        <entry key="http://www.w3.org/1999/xhtml"                          value="application/xhtml+xml"/>
                        <entry key="http://www.idpf.org/2007/opf"                          value="application/oebps-package+xml"/>
                        <entry key="http://www.daisy.org/z3986/2005/dtbook/"               value="application/x-dtbook+xml"/>
                        <!-- SMIL 1.0 -->
                        <entry key="http://www.w3.org/TR/REC-smil"                         value="application/smil+xml"/>
                        <!-- SMIL 2.0 -->
                        <entry key="http://www.w3.org/2001/SMIL20/"                        value="application/smil+xml"/>
                        <!-- SMIL 2.0 -->
                        <entry key="http://www.w3.org/2001/SMIL20/Language"                value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/"                        value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/Language"                value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/Mobile"                  value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/ExtendedMobile"          value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/MobileProfile"           value="application/smil+xml"/>
                        <!-- SMIL 2.1 -->
                        <entry key="http://www.w3.org/2005/SMIL21/BasicExclTimeContainers" value="application/smil+xml"/>
                        <!-- SMIL 3.0 -->
                        <entry key="http://www.w3.org/ns/SMIL"                             value="application/smil+xml"/>
                        <entry key="http://www.daisy.org/z3986/2005/ncx/"                  value="application/x-dtbncx+xml"/>
                        <entry key="http://www.w3.org/2000/svg"                            value="image/svg+xml"/>
                        <entry key="http://www.w3.org/ns/xproc"                            value="application/xproc+xml"/>
                        <entry key="http://www.w3.org/ns/xproc-step"                       value="application/xproc+xml"/>
                        <entry key="http://www.w3.org/ns/xproc-error"                      value="application/xproc+xml"/>
                        <entry key="http://www.w3.org/1999/XSL/Transform"                  value="application/xslt+xml"/>
                        <entry key="http://www.w3.org/1999/XSL/Format"                     value="application/xml"/>
                        <entry key="http://www.daisy.org/ns/z3986/authoring/"              value="application/z3998-auth+xml"/>
                        <entry key="http://www.daisy.org/ns/z3998/authoring/"              value="application/z3998-auth+xml"/>
                        <entry key="http://www.w3.org/XML/1998/namespace"                  value="application/xml"/>
                        <entry key="http://openebook.org/namespaces/oeb-package/1.0/"      value="application/oebps-package+xml"/>
                        <entry key="http://www.w3.org/2001/XML"                            value="application/xml"/>
                        <entry key="http://www.w3.org/ns/xproc-step"                       value="application/xproc+xml"/>
                        <entry key="urn:oasis:names:tc:entity:xmlns:xml:catalog"           value="application/xml"/>
                    </map>
                </p:inline>
            </p:with-option>
         </p:add-attribute>
    </p:declare-step>

    <p:viewport match="//d:file" name="file">
        <p:choose>
            <p:when test="/*/@media-type">
                <!-- only try to find missing media types -->
                <p:identity/>
            </p:when>
            <p:otherwise>
                <!-- check if the file is in memory -->
                <p:group name="file-in-memory">
                    <p:output port="result"/>
                    <p:variable name="target" select="resolve-uri(/*/@href,base-uri(/*))"/>
                    <p:split-sequence>
                        <p:with-option name="test" select="concat('base-uri(/*)=&quot;',$target,'&quot;')"/>
                        <p:input port="source">
                            <p:pipe port="in-memory" step="main"/>
                        </p:input>
                    </p:split-sequence>
                </p:group>
                <p:count name="filecount-in-memory"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="current" step="file"/>
                    </p:input>
                </p:identity>
                <p:choose>
                    <p:when test="number(.)&gt;0">
                        <!-- file is in memory -->
                        <p:xpath-context>
                            <p:pipe port="result" step="filecount-in-memory"/>
                        </p:xpath-context>
                        <pxi:mediatype-detect-from-namespace>
                            <p:input port="in-memory">
                                <p:pipe port="result" step="file-in-memory"/>
                            </p:input>
                        </pxi:mediatype-detect-from-namespace>
                    </p:when>
                    <p:otherwise>
                        <!-- file is not in memory -->
                        <pxi:mediatype-detect-from-extension name="from-extension"/>
                        <p:xslt>
                            <p:input port="parameters">
                                <p:empty/>
                            </p:input>
                            <p:input port="stylesheet">
                                <p:document href="../xslt/mediatype-functions.xsl"/>
                            </p:input>
                        </p:xslt>

                        <p:choose>
                            <p:when test="/*/@is-xml='true' and $load-if-not-in-memory='true'">
                                <!-- try to load from disk -->
                                <px:fileset-load method="xml" name="file-from-disk">
                                    <p:with-option name="load-if-not-in-memory" select="$load-if-not-in-memory"/>
                                    <p:with-option name="href" select="resolve-uri(/*/@href,base-uri(/*))"/>
                                    <p:input port="fileset">
                                        <p:pipe port="source" step="main"/>
                                    </p:input>
                                    <p:input port="in-memory">
                                        <p:pipe port="in-memory" step="main"/>
                                    </p:input>
                                </px:fileset-load>
                                <p:count name="file.load-count"/>
                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="current" step="file"/>
                                    </p:input>
                                </p:identity>
                                <p:choose>
                                    <p:xpath-context>
                                        <p:pipe port="result" step="file.load-count"/>
                                    </p:xpath-context>
                                    <p:when test="number(/*)&gt;0">
                                        <pxi:mediatype-detect-from-namespace>
                                            <p:input port="in-memory">
                                                <p:pipe port="result" step="file-from-disk"/>
                                            </p:input>
                                        </pxi:mediatype-detect-from-namespace>
                                    </p:when>
                                    <p:otherwise>
                                        <!-- could not load xml from disk; use the file extension -->
                                        <p:identity>
                                            <p:input port="source">
                                                <p:pipe port="result" step="from-extension"/>
                                            </p:input>
                                        </p:identity>
                                    </p:otherwise>
                                </p:choose>
                            </p:when>
                            <p:otherwise>
                                <!-- not xml or not allowed to load from memory; use the file extension -->
                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="result" step="from-extension"/>
                                    </p:input>
                                </p:identity>
                            </p:otherwise>
                        </p:choose>
                    </p:otherwise>
                </p:choose>
            </p:otherwise>

        </p:choose>

    </p:viewport>

</p:declare-step>
