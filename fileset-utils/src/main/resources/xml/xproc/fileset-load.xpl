<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" type="px:fileset-load" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:p="http://www.w3.org/ns/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
  xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal/fileset-load" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-inline-prefixes="cx px">

  <p:input port="fileset" primary="true"/>
  <p:input port="in-memory" sequence="true"/>
  <p:output port="result" sequence="true">
    <p:pipe port="result" step="load"/>
  </p:output>

  <p:option name="href" select="''"/>
  <p:option name="media-types" select="''"/>
  <p:option name="fail-on-not-found" select="'false'"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/html-utils/html-library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
  <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>

  <p:declare-step type="pxi:load-text">
    <p:output port="result"/>
    <p:option name="href"/>
    <p:identity>
      <p:input port="source">
        <p:inline>
          <c:request method="GET" override-content-type="text/plain; charset=utf-8"/>
        </p:inline>
      </p:input>
    </p:identity>
    <p:add-attribute match="c:request" attribute-name="href">
      <p:with-option name="attribute-value" select="$href"/>
    </p:add-attribute>
    <p:http-request/>
  </p:declare-step>

  <p:declare-step type="pxi:load-binary">
    <p:output port="result"/>
    <p:option name="href"/>
    <p:identity>
      <p:input port="source">
        <p:inline>
          <c:request method="GET" override-content-type="binary/octet-stream"/>
        </p:inline>
      </p:input>
    </p:identity>
    <p:add-attribute match="c:request" attribute-name="href">
      <p:with-option name="attribute-value" select="$href"/>
    </p:add-attribute>
    <p:http-request/>
  </p:declare-step>

  <p:variable name="resolved-href" select="resolve-uri($href,base-uri(/*))">
    <p:pipe port="fileset" step="main"/>
  </p:variable>

  <!--<p:choose>
    <p:when test="$href='' and $media-types=''">
      <p:identity/>
    </p:when>
    <p:otherwise>
      <px:fileset-filter>
        <p:with-option name="href" select="$href"/>
        <p:with-option name="media-types" select="$media-types"/>
      </px:fileset-filter>
    </p:otherwise>
  </p:choose>-->

  <p:for-each name="load">
    <p:output port="result" sequence="true"/>
    <p:iteration-source select="//d:file"/>
    <p:variable name="on-disk-attribute" select="/*/@original-href"/>
    <p:variable name="target" select="/*/resolve-uri(@href, base-uri(.))"/>
    <p:variable name="media-type" select="/*/@media-type"/>

    <p:choose>
      <p:xpath-context>
        <p:pipe port="result" step="fileset.in-memory"/>
      </p:xpath-context>

      <!-- from memory -->
      <p:when test="$target = //d:file/resolve-uri(@href,base-uri(.))">
        <cx:message>
          <p:with-option name="message" select="concat('processing file from memory: ',$target)"/>
        </cx:message>
        <p:split-sequence>
          <p:with-option name="test" select="concat('base-uri(/*)=&quot;',$target,'&quot;')"/>
          <p:input port="source">
            <p:pipe port="in-memory" step="main"/>
          </p:input>
        </p:split-sequence>
      </p:when>

      <!-- load file into memory (from disk, HTTP, etc) -->
      <p:otherwise>
        <p:try>
          <p:group>
            <p:variable name="on-disk" select="if ($on-disk-attribute='') then $target else $on-disk-attribute"/>
            <cx:message>
              <p:with-option name="message" select="concat('loading ',$target,' from disk: ',$on-disk)"/>
            </cx:message>
            <p:sink/>

            <p:choose>
              <!-- HTML -->
              <p:when test="$media-type='text/html' or $media-type='application/xhtml+xml'">
                <px:html-load>
                  <p:with-option name="href" select="$on-disk"/>
                </px:html-load>
              </p:when>

              <!-- XML -->
              <p:when test="$media-type='application/xml' or matches($media-type,'.*\+xml$')">
                <p:try>
                  <p:group>
                    <p:load>
                      <p:with-option name="href" select="$on-disk"/>
                    </p:load>
                  </p:group>
                  <p:catch>
                    <cx:message>
                      <p:input port="source">
                        <p:empty/>
                      </p:input>
                      <p:with-option name="message" select="concat('unable to load ',$on-disk,' as XML; trying as text...')"/>
                    </cx:message>
                    <pxi:load-text>
                      <p:with-option name="href" select="$on-disk"/>
                    </pxi:load-text>
                  </p:catch>
                </p:try>
              </p:when>

              <!-- text -->
              <p:when test="matches($media-type,'^text/')">
                <pxi:load-text>
                  <p:with-option name="href" select="$on-disk"/>
                </pxi:load-text>
              </p:when>

              <!-- binary -->
              <p:otherwise>
                <pxi:load-binary>
                  <p:with-option name="href" select="$on-disk"/>
                </pxi:load-binary>
              </p:otherwise>
              
            </p:choose>
          </p:group>
          <p:catch>
            <!-- could not retrieve file from neither memory nor disk -->
            <p:variable name="file-not-found-message" select="concat('Could neither retrieve file from memory nor disk: ',$target)"/>
            <p:choose>
              <p:when test="$fail-on-not-found='true'">
                <p:in-scope-names name="vars"/>
                <p:template>
                  <p:input port="template">
                    <p:inline>
                      <c:message><![CDATA[]]>{$file-not-found-message}<![CDATA[]]></c:message>
                    </p:inline>
                  </p:input>
                  <p:input port="source">
                    <p:empty/>
                  </p:input>
                  <p:input port="parameters">
                    <p:pipe step="vars" port="result"/>
                  </p:input>
                </p:template>
                <p:error code="PEZE00"/>
              </p:when>
              <p:otherwise>
                <cx:message>
                  <p:with-option name="message" select="$file-not-found-message"/>
                </cx:message>
              </p:otherwise>
            </p:choose>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
          </p:catch>
        </p:try>
      </p:otherwise>
    </p:choose>
  </p:for-each>


  <px:fileset-create name="fileset.in-memory-base" base="/"/>
  <p:for-each>
    <p:iteration-source>
      <p:pipe port="in-memory" step="main"/>
    </p:iteration-source>
    <px:fileset-add-entry>
      <p:with-option name="href" select="resolve-uri(base-uri(/*))"/>
      <p:input port="source">
        <p:pipe port="result" step="fileset.in-memory-base"/>
      </p:input>
    </px:fileset-add-entry>
  </p:for-each>
  <px:fileset-join name="fileset.in-memory"/>
  <p:sink/>

</p:declare-step>
