<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:epub3-nav-aggregate" name="main" xmlns:p="http://www.w3.org/ns/xproc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" xmlns:d="http://www.daisy.org/ns/pipeline/data"
    version="1.0">

    <p:input port="source" sequence="true"/>
    <p:output port="result"/>

    <p:option name="title" select="''"/>
    <p:option name="language" select="''"/>
    <p:option name="css" select="''"/>

    <p:choose>
        <p:when test="not($title='') or $language=''">
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <!-- Default to english if no language is given. -->
                        <d:translation lang="en" language-name="English">Table of Contents</d:translation>
                    </p:inline>
                </p:input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:for-each>
                <p:iteration-source select="/*/*">
                    <p:inline>
                        <d:translations>
                            <!-- NOTE: These are automatically translated. -->
                            <d:translation lang="ar" language-name="Arabic">جدول المحتويات</d:translation>
                            <d:translation lang="bg" language-name="Bulgarian">Таблица на съдържанието</d:translation>
                            <d:translation lang="ca" language-name="Catalan">Taula de continguts</d:translation>
                            <d:translation lang="zh-CHS" language-name="Chinese Simplified">表的内容</d:translation>
                            <d:translation lang="zh-CHT" language-name="Chinese Traditional">表的內容</d:translation>
                            <d:translation lang="cs" language-name="Czech">Obsah</d:translation>
                            <d:translation lang="da" language-name="Danish">Indholdsfortegnelse</d:translation>
                            <d:translation lang="nl" language-name="Dutch">Inhoudsopgave</d:translation>
                            <d:translation lang="en" language-name="English">Table of Contents</d:translation>
                            <d:translation lang="et" language-name="Estonian">Sisukord</d:translation>
                            <d:translation lang="fi" language-name="Finnish">Sisällysluettelo</d:translation>
                            <d:translation lang="fr" language-name="French">Table des matières</d:translation>
                            <d:translation lang="de" language-name="German">Inhaltsverzeichnis</d:translation>
                            <d:translation lang="el" language-name="Greek">ΠΙΝΑΚΑΣ ΠΕΡΙΕΧΟΜΕΝΩΝ</d:translation>
                            <d:translation lang="ht" language-name="Haitian Creole">Tab de Contenu</d:translation>
                            <d:translation lang="he" language-name="Hebrew">תוכן עניינים</d:translation>
                            <d:translation lang="hi" language-name="Hindi">सामग्री की तालिका</d:translation>
                            <d:translation lang="mww" language-name="Hmong Daw">Cov txheej txheem</d:translation>
                            <d:translation lang="hu" language-name="Hungarian">Tartalomjegyzék</d:translation>
                            <d:translation lang="id" language-name="Indonesian">Daftar isi</d:translation>
                            <d:translation lang="it" language-name="Italian">Sommario</d:translation>
                            <d:translation lang="ja" language-name="Japanese">目次</d:translation>
                            <d:translation lang="tlh" language-name="Klingon">'a ghIH raS</d:translation>
                            <d:translation lang="tlh-Qaak" language-name="Klingon (pIqaD)">  </d:translation>
                            <d:translation lang="ko" language-name="Korean">목차</d:translation>
                            <d:translation lang="lv" language-name="Latvian">Satura rādītājā</d:translation>
                            <d:translation lang="lt" language-name="Lithuanian">Turinys</d:translation>
                            <d:translation lang="ms" language-name="Malay">Jadual kandungan</d:translation>
                            <d:translation lang="mt" language-name="Maltese">Tabella tal-kontenut</d:translation>
                            <d:translation lang="no" language-name="Norwegian">Innholdsfortegnelse</d:translation>
                            <d:translation lang="fa" language-name="Persian">جدول محتویات</d:translation>
                            <d:translation lang="pl" language-name="Polish">Spis treści</d:translation>
                            <d:translation lang="pt" language-name="Portuguese">Tabela de conteúdos</d:translation>
                            <d:translation lang="ro" language-name="Romanian">Cuprins</d:translation>
                            <d:translation lang="ru" language-name="Russian">Содержание</d:translation>
                            <d:translation lang="sk" language-name="Slovak">Obsah</d:translation>
                            <d:translation lang="sl" language-name="Slovenian">Kazalo vsebine</d:translation>
                            <d:translation lang="es" language-name="Spanish">Tabla de contenidos</d:translation>
                            <d:translation lang="sv" language-name="Swedish">Innehållsförteckning</d:translation>
                            <d:translation lang="th" language-name="Thai">สารบัญ</d:translation>
                            <d:translation lang="tr" language-name="Turkish">İçindekiler tablosu</d:translation>
                            <d:translation lang="uk" language-name="Ukrainian">Зміст</d:translation>
                            <d:translation lang="ur" language-name="Urdu">کی میز کے مندرجات</d:translation>
                            <d:translation lang="vi" language-name="Vietnamese">Bảng nội dung</d:translation>
                        </d:translations>
                    </p:inline>
                </p:iteration-source>
                <p:choose>
                    <p:when test="@lang=$language or matches(@lang,concat('^',replace($language,'-.*','')),'-')">
                        <p:identity/>
                    </p:when>
                    <p:otherwise>
                        <p:identity>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                        </p:identity>
                    </p:otherwise>
                </p:choose>
            </p:for-each>
        </p:otherwise>
    </p:choose>
    <p:split-sequence initial-only="true" test="position()=1"/>

    <p:group>
        <p:variable name="title-translated" select="normalize-space(/*/text())"/>
        <p:in-scope-names name="vars"/>
        <p:template>
            <p:input port="template">
                <p:inline exclude-inline-prefixes="#all">
                    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="{$language}" lang="{$language}">
                        <head>
                            <meta charset="UTF-8"/>
                            <title>{$title-translated}</title>
                            <link rel="stylesheet" type="text/css" href="{$css}"/>
                        </head>
                        <body>{/node()}</body>
                    </html>
                </p:inline>
            </p:input>
            <p:input port="source">
                <p:pipe step="main" port="source"/>
            </p:input>
            <p:input port="parameters">
                <p:pipe step="vars" port="result"/>
            </p:input>
        </p:template>
        <p:delete match="(html:html/@xml:lang|html:html/@lang)[.='']"/>
        <p:delete match="html:html/html:head/html:link[@href='']"/>
    </p:group>

</p:declare-step>
