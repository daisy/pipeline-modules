<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:h="http://www.w3.org/1999/xhtml" version="1.0" exclude-inline-prefixes="px">

    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>

    <!--<px:html-load href="http://dev.w3.org/html5/spec/Overview.html"/>
    <p:store href="HTML5.xhtml"/>-->
    <p:load href="HTML5.xhtml" name="input"/>

    <p:delete match="h:style | h:link | h:script | h:head"/>
    <p:unwrap match="h:body"/>
    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:output indent="yes" method="xml"/>
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="h:html">
                        <xsl:copy>
                            <xsl:for-each-group select="*" group-starting-with="h:h1|h:h2|h:h3|h:h4|h:h5|h:h6">
                                <section xmlns="http://www.w3.org/1999/xhtml">
                                    <xsl:copy-of select="current-group()"/>
                                </section>
                            </xsl:for-each-group>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:identity name="h4-groups"/>

    <p:delete match="text()"/>
    <p:delete match="/*/*[not(self::h:section and matches(h:h4/@id,'^the-.*-element$'))]"/>
    <p:delete match="//h:section/*[not(self::h:h1 or self::h:h2 or self::h:h3 or self::h:h4 or self::h:h5 or self::h:h6 or self::h:dl[@class='element'])]"/>
    <p:for-each>
        <p:iteration-source select="/*/*"/>
        <p:variable name="element" select="/*/*[self::h:h1 or self::h:h2 or self::h:h3 or self::h:h4 or self::h:h5 or self::h:h6]/replace(@id,'^the-(.*)-element$','$1')"/>
        <p:delete match="/*/*[self::h:h1 or self::h:h2 or self::h:h3 or self::h:h4 or self::h:h5 or self::h:h6]"/>
        <p:xslt>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <xsl:output indent="yes" method="xml"/>
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:for-each select="*">
                                    <xsl:for-each-group select="*" group-starting-with="h:dt">
                                        <d:dfn>
                                            <xsl:copy-of select="current-group()"/>
                                        </d:dfn>
                                    </xsl:for-each-group>
                                </xsl:for-each>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </p:xslt>
        <p:rename match="/*" new-name="d:element"/>
        <p:add-attribute match="/*" attribute-name="name">
            <p:with-option name="attribute-value" select="$element"/>
        </p:add-attribute>
        <p:viewport match="//d:dfn">
            <p:variable name="dfn-name" select="(/*/*[1]//h:a[starts-with(@href,'#element-dfn-')])[1]/replace(@href,'#element-dfn-','')"/>
            <p:rename match="/*">
                <p:with-option name="new-name" select="concat('d:',$dfn-name)"/>
            </p:rename>
            <p:delete match="h:dt"/>
            <p:unwrap match="/*//*[not(self::h:a)]"/>
            <p:delete match="//h:a//node()"/>
            <p:viewport match="//h:a">
                <p:variable name="href" select="/*/@href"/>
                <p:delete match="/*/@*[not(local-name()='href')]"/>
                <p:choose>
                    <p:when test="matches($href,'^#attr-.*?-.*$')">
                        <p:delete match="/*/@href"/>
                        <p:rename match="/*" new-name="d:attribute"/>
                        <p:add-attribute match="/*" attribute-name="name">
                            <p:with-option name="attribute-value" select="replace($href,'^#attr-.*?-(.*)$','$1')"/>
                        </p:add-attribute>
                    </p:when>
                    <p:when test="matches($href,'^#.*?-attributes$')">
                        <p:delete match="/*/@href"/>
                        <p:rename match="/*" new-name="d:attribute"/>
                        <p:add-attribute match="/*" attribute-name="ref">
                            <p:with-option name="attribute-value" select="replace($href,'^#(.*?)-attributes$','$1')"/>
                        </p:add-attribute>
                    </p:when>
                    <p:when test="matches($href,'^#the-.*-element$')">
                        <p:delete match="/*/@href"/>
                        <p:rename match="/*" new-name="d:element"/>
                        <p:add-attribute match="/*" attribute-name="name">
                            <p:with-option name="attribute-value" select="replace($href,'^#the-(.*)-element$','$1')"/>
                        </p:add-attribute>
                    </p:when>
                    <p:when test="matches($href,'^#.*-content$')">
                        <p:delete match="/*/@href"/>
                        <p:rename match="/*" new-name="d:element"/>
                        <p:add-attribute match="/*" attribute-name="ref">
                            <p:with-option name="attribute-value" select="replace($href,'^#(.*)-content$','$1')"/>
                        </p:add-attribute>
                    </p:when>
                    <p:otherwise>
                        <p:identity/>
                    </p:otherwise>
                </p:choose>
            </p:viewport>
        </p:viewport>
        <p:delete match="d:categories | d:contexts | d:dom"/>
        <p:delete match="d:element[@name=preceding-sibling::d:element/@name or @ref=preceding-sibling::d:element/@ref]"/>
        <p:delete match="d:attribute[@name=preceding-sibling::d:attribute/@name or @ref=preceding-sibling::d:attribute/@ref]"/>
        <p:unwrap match="/*/*"/>
        <p:delete match="h:a"/>
    </p:for-each>
    <p:identity name="elements-and-attributes-sequence"/>
    <p:wrap-sequence wrapper="d:elements" name="elements-and-attributes"/>

    <p:for-each>
        <p:output port="result" sequence="true"/>
        <p:iteration-source select="//d:element[string-length(@ref) &gt; 0 and not(@ref=preceding::d:element/@ref)]">
            <p:pipe port="result" step="elements-and-attributes"/>
        </p:iteration-source>
        <p:variable name="ref" select="/*/@ref"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="h4-groups" port="result"/>
            </p:input>
        </p:identity>
        <p:filter>
            <p:with-option name="select" select="concat('//h:section[.//*[@id=concat(&quot;',$ref,'&quot;,&quot;-content&quot;)]]')"/>
        </p:filter>
        <p:delete match="text()"/>
        <p:delete match="/*/*[not(contains(@class,'brief'))]"/>
        <p:unwrap match="/*//*[not(self::h:a)]"/>
        <p:add-attribute match="/*" attribute-name="name">
            <p:with-option name="attribute-value" select="$ref"/>
        </p:add-attribute>
        <p:viewport match="//h:a">
            <p:variable name="href" select="/*/@href"/>
            <p:choose>
                <p:when test="matches($href,'^#the-.*-element$')">
                    <p:delete match="/*/@*"/>
                    <p:rename match="/*" new-name="d:element"/>
                    <p:add-attribute match="/*" attribute-name="name">
                        <p:with-option name="attribute-value" select="replace($href,'^#the-(.*)-element$','$1')"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:viewport>
        <p:delete match="d:element[@name=preceding-sibling::d:element/@name or @ref=preceding-sibling::d:element/@ref]"/>
        <p:delete match="h:a"/>
        <p:rename match="/*" new-name="d:content"/>
    </p:for-each>
    <p:identity name="contents"/>

    <p:for-each>
        <p:output port="result" sequence="true"/>
        <p:iteration-source select="//d:attribute[string-length(@ref) &gt; 0 and not(@ref=preceding::d:attribute/@ref)]">
            <p:pipe port="result" step="elements-and-attributes"/>
        </p:iteration-source>
        <p:variable name="ref" select="/*/@ref"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="h4-groups" port="result"/>
            </p:input>
        </p:identity>
        <p:filter>
            <p:with-option name="select" select="concat('//h:section[.//*[@id=concat(&quot;',$ref,'&quot;,&quot;-attributes&quot;)]]')"/>
        </p:filter>
        <p:delete match="text()"/>
        <p:delete match="/*/*[not(contains(@class,'brief'))]"/>
        <p:unwrap match="/*//*[not(self::h:a)]"/>
        <p:add-attribute match="/*" attribute-name="name">
            <p:with-option name="attribute-value" select="$ref"/>
        </p:add-attribute>
        <p:viewport match="//h:a">
            <p:variable name="href" select="/*/@href"/>
            <p:choose>
                <p:when test="matches($href,'^#attr-.*$')">
                    <p:delete match="/*/@href"/>
                    <p:rename match="/*" new-name="d:attribute"/>
                    <p:add-attribute match="/*" attribute-name="name">
                        <p:with-option name="attribute-value" select="replace($href,'^#attr-(.*)$','$1')"/>
                    </p:add-attribute>
                </p:when>
                <p:when test="matches($href,'^#the-.*-attribute$')">
                    <p:delete match="/*/@href"/>
                    <p:rename match="/*" new-name="d:attribute"/>
                    <p:add-attribute match="/*" attribute-name="name">
                        <p:with-option name="attribute-value" select="replace($href,'^#the-(.*)-attribute$','$1')"/>
                    </p:add-attribute>
                </p:when>
                <p:when test="matches($href,'^#handler-.*$')">
                    <p:delete match="/*/@href"/>
                    <p:rename match="/*" new-name="d:attribute"/>
                    <p:add-attribute match="/*" attribute-name="name">
                        <p:with-option name="attribute-value" select="replace($href,'^#handler-(.*)$','$1')"/>
                    </p:add-attribute>
                </p:when>
                <p:otherwise>
                    <p:identity/>
                </p:otherwise>
            </p:choose>
        </p:viewport>
        <p:delete match="d:attribute[@name=preceding-sibling::d:attribute/@name or @ref=preceding-sibling::d:attribute/@ref]"/>
        <p:delete match="h:a"/>
        <p:rename match="/*" new-name="d:attribute-set"/>
    </p:for-each>
    <p:identity name="attribute-sets"/>

    <p:wrap-sequence wrapper="d:html5">
        <p:input port="source">
            <p:pipe port="result" step="attribute-sets"/>
            <p:pipe port="result" step="elements-and-attributes-sequence"/>
            <p:pipe port="result" step="contents"/>
        </p:input>
    </p:wrap-sequence>

    <p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:output indent="yes" method="xml"/>
                    <xsl:template match="/|comment()|processing-instruction()">
                        <xsl:copy>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:template>

                    <xsl:template match="*">
                        <xsl:element name="{local-name()}" namespace="http://www.daisy.org/ns/pipeline/data">
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:element>
                    </xsl:template>

                    <xsl:template match="@*">
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:insert match="/*" position="last-child">
        <p:input port="insertion" select="/*/*">
            <p:inline exclude-inline-prefixes="#all">
                <wrapper xmlns="http://www.daisy.org/ns/pipeline/data">
                    <element name="h1">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                    <element name="h2">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                    <element name="h3">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                    <element name="h4">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                    <element name="h5">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                    <element name="h6">
                        <element ref="flow"/>
                        <element ref="heading"/>
                        <element ref="phrasing"/>
                        <attribute ref="global"/>
                    </element>
                </wrapper>
            </p:inline>
        </p:input>
    </p:insert>

    <p:insert match="/*/*[@name='hgroup']" position="last-child">
        <p:input port="insertion" select="/*/*">
            <p:inline exclude-inline-prefixes="#all">
                <wrapper xmlns="http://www.daisy.org/ns/pipeline/data">
                    <element name="h1"/>
                    <element name="h2"/>
                    <element name="h3"/>
                    <element name="h4"/>
                    <element name="h5"/>
                    <element name="h6"/>
                </wrapper>
            </p:inline>
        </p:input>
    </p:insert>
    
    <p:insert match="/*/*[@name='flow']" position="last-child">
        <p:input port="insertion" select="/*/*">
            <p:inline exclude-inline-prefixes="#all">
                <wrapper xmlns="http://www.daisy.org/ns/pipeline/data">
                    <element name="h1"/>
                    <element name="h2"/>
                    <element name="h3"/>
                    <element name="h4"/>
                    <element name="h5"/>
                    <element name="h6"/>
                </wrapper>
            </p:inline>
        </p:input>
    </p:insert>
    
    <p:insert match="/*/*[@name='global']" position="first-child">
        <p:input port="insertion" select="/*">
            <p:inline exclude-inline-prefixes="#all">
                <attribute name="class" xmlns="http://www.daisy.org/ns/pipeline/data"/>
            </p:inline>
        </p:input>
    </p:insert>

    <p:store href="html5.xml"/>

</p:declare-step>
