<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pf="http://www.daisy.org/ns/pipeline/functions"
                xmlns:f="http://www.daisy.org/ns/pipeline/internal-functions">

    <!--
        EPUB 3 Structural Semantics Vocabulary: https://idpf.github.io/epub-vocabs/structure
    -->
    <xsl:variable name="vocab-default"
        select="('cover','frontmatter','bodymatter','backmatter','volume','part','chapter','subchapter','division','abstract','foreword','preface','prologue','introduction','preamble','conclusion','epilogue','afterword','epigraph','toc','toc-brief','landmarks','loa','loi','lot','lov','appendix','colophon','credits','keywords','index','index-headnotes','index-legend','index-group','index-entry-list','index-entry','index-term','index-editor-note','index-locator','index-locator-list','index-locator-range','index-xref-preferred','index-xref-related','index-term-category','index-term-categories','glossary','glossterm','glossdef','dictionary','bibliography','biblioentry','titlepage','halftitlepage','copyright-page','seriespage','acknowledgments','imprint','imprimatur','contributors','other-credits','errata','dedication','revision-history','case-study','help','marginalia','notice','pullquote','sidebar','warning','halftitle','fulltitle','covertitle','title','subtitle','label','ordinal','bridgehead','learning-objective','learning-objectives','learning-outcome','learning-outcomes','learning-resource','learning-resources','learning-standard','learning-standards','answer','answers','assessment','assessments','feedback','fill-in-the-blank-problem','general-problem','qna','match-problem','multiple-choice-problem','practice','practices','question','true-false-problem','panel','panel-group','balloon','text-area','sound-area','annotation','note','footnote','rearnote','footnotes','rearnotes','endnotes','annoref','biblioref','glossref','noteref','referrer','credit','keyword','topic-sentence','concluding-sentence','pagebreak','page-list','table','table-row','table-cell','list','list-item','figure','antonym-group','condensed-entry','def','dictentry','endnote','etymology','example','gram-info','idiom','part-of-speech','part-of-speech-group','part-of-speech-list','phonetic-transcription','phrase-group','phrase-list','sense-group','sense-list','synonym-group','tran','tran-info')"/>
    
    <!--
        Z39.98-2012 Structural Semantics Vocabulary: http://www.daisy.org/z3998/2012/vocab/structure
    -->
    <xsl:variable name="vocab-z3998-uri" select="'http://www.daisy.org/z3998/2012/vocab/structure/#'"/>
    <xsl:variable name="vocab-z3998"
                  select="('abbreviations','acknowledgments','acronym','actor','afterword','alteration','annoref','annotation','appendix','article','aside','attribution','author','award','backmatter','bcc','bibliography','biographical-note','bodymatter','cardinal','catalogue','cc','chapter','citation','clarification','collection','colophon','commentary','commentator','compound','concluding-sentence','conclusion','continuation','continuation-of','contributors','coordinate','correction','covertitle','currency','decimal','decorative','dedication','diary','diary-entry','discography','division','drama','dramatis-personae','editor','editorial-note','email','email-message','epigraph','epilogue','errata','essay','event','example','family-name','fiction','figure','filmography','footnote','footnotes','foreword','fraction','from','frontispiece','frontmatter','ftp','fulltitle','gallery','general-editor','geographic','given-name','glossary','grant-acknowledgment','grapheme','halftitle','halftitle-page','help','homograph','http','hymn','illustration','image-placeholder','imprimatur','imprint','index','initialism','introduction','introductory-note','ip','isbn','keyword','letter','loi','lot','lyrics','marginalia','measure','mixed','morpheme','name-title','nationality','non-fiction','nonresolving-citation','nonresolving-reference','note','noteref','notice','orderedlist','ordinal','organization','other-credits','pagebreak','page-footer','page-header','part','percentage','persona','personal-name','pgroup','phone','phoneme','photograph','phrase','place','plate','poem','portmanteau','postal','postal-code','postscript','practice','preamble','preface','prefix','presentation','primary','product','production','prologue','promotional-copy','published-works','publisher-address','publisher-logo','range','ratio','rearnote','rearnotes','recipient','recto','reference','republisher','resolving-reference','result','role-description','roman','root','salutation','scene','secondary','section','sender','sentence','sidebar','signature','song','speech','stage-direction','stem','structure','subchapter','subject','subsection','subtitle','suffix','surname','taxonomy','tertiary','text','textbook','t-form','timeline','title','title-page','to','toc','topic-sentence','translator','translator-note','truncation','unorderedlist','valediction','verse','verso','v-form','volume','warning','weight','word')"/>
    
    <!--
        Package Metadata Vocabulary: http://www.idpf.org/epub/301/spec/epub-publications.html#sec-package-metadata-vocab
        
        This is the default vocabulary for use of unprefixed terms in package metadata
        
        see http://www.idpf.org/epub/301/spec/epub-publications.html#sec-metadata-default-vocab
    -->
    <xsl:variable name="vocab-package-uri" as="xs:string" select="'http://idpf.org/epub/vocab/package/#'"/>
    
    <!--
        Reserved prefix mappings in package document
        
        see https://www.w3.org/publishing/epub3/epub-packages.html#sec-metadata-reserved-prefixes
    -->
    <xsl:variable name="f:default-prefixes" as="element(f:vocab)*">
        <f:vocab prefix="a11y"      uri="http://www.idpf.org/epub/vocab/package/a11y/#"/>
        <f:vocab prefix="dcterms"   uri="http://purl.org/dc/terms/"/>
        <f:vocab prefix="epubsc"    uri="http://idpf.org/epub/vocab/sc/#"/>
        <f:vocab prefix="marc"      uri="http://id.loc.gov/vocabulary/"/>
        <f:vocab prefix="media"     uri="http://www.idpf.org/epub/vocab/overlays/#"/>
        <f:vocab prefix="onix"      uri="http://www.editeur.org/ONIX/book/codelists/current.html#"/>
        <f:vocab prefix="rendition" uri="http://www.idpf.org/vocab/rendition/#"/>
        <f:vocab prefix="schema"    uri="http://schema.org/"/>
        <f:vocab prefix="xsd"       uri="http://www.w3.org/2001/XMLSchema#"/>
    </xsl:variable>
    
    <!--
        Parse prefix attribute: http://www.idpf.org/epub/301/spec/epub-publications.html#sec-prefix-attr
        
        Returns a sequence of f:vocab elements representing vocab declarations in a @prefix attribute where
        
        * @prefix contains the declared prefix
        * @uri contains the vocab URI
    -->
    <xsl:function name="f:parse-prefix-decl" as="element(f:vocab)*">
        <xsl:param name="prefix-decl" as="xs:string?"/>
        <xsl:analyze-string select="$prefix-decl" regex="([^:\s\t\n\r]+):\s*([^\s\t\n\r]+)">
            <xsl:matching-substring>
                <f:vocab prefix="{regex-group(1)}" uri="{regex-group(2)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:if test="not(matches(.,'[\s\t\n\r]+'))">
                    <xsl:message terminate="yes" select="concat('Error parsing prefix attribute: ',$prefix-decl)"/>
                </xsl:if>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!--
        Merge a sequence of f:vocab elements. The result is a sequence of valid mappings where every
        prefix is unique, no prefix is mapped to the default vocabulary, no reserved prefixes are
        overridden, and duplicates are removed.
    -->
    <xsl:function name="f:merge-prefix-decl" as="element(f:vocab)*">
        <xsl:param name="mappings" as="element(f:vocab)*"/>
        <!--
            no prefix may be mapped to default vocabulary
        -->
        <xsl:if test="$mappings[@uri=$vocab-package-uri]">
            <xsl:message terminate="yes"
                         select="concat('Error: prefix attibute must not be used to define a prefix (',
                                        $mappings[@uri=$vocab-package-uri][1]/@prefix,
                                        ') that maps to the default vocabulary ''',
                                        $vocab-package-uri,'''')"/>
        </xsl:if>
        <!--
            make prefixes unique
        -->
        <xsl:variable name="mappings" as="element(f:vocab)*" select="f:unique-prefixes($mappings)"/>
        <!--
            reserved prefixes should not be overridden
        -->
        <xsl:variable name="mappings" as="element(f:vocab)*">
            <xsl:choose>
                <xsl:when test="some $m in $mappings satisfies
                                $f:default-prefixes[@prefix=$m/@prefix and not(@uri=$m/@uri)]">
                    <xsl:for-each select="$mappings">
                        <xsl:if test="$f:default-prefixes[@prefix=current()/@prefix and not(@uri=current()/@uri)]">
                            <xsl:message select="concat('Warning: reserved prefix ',@prefix,' was overridden to ''',@uri,'''')"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:sequence select="f:unique-prefixes(($f:default-prefixes,$mappings))
                                          [position()&gt;count($f:default-prefixes)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$mappings"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--
            remove duplicates
        -->
        <xsl:variable name="mappings" as="element(f:vocab)*"
                      select="for $p in distinct-values($mappings/@prefix) return $mappings[@prefix=$p][1]"/>
        <xsl:sequence select="$mappings"/>
    </xsl:function>
    
    <!--
        Rename prefixes so that the sequence of f:vocab elements becomes a sequence where a certain
        prefix always maps to the same URI.
    -->
    <xsl:function name="f:unique-prefixes" as="element(f:vocab)*">
        <xsl:param name="mappings" as="element(f:vocab)*"/>
        <xsl:sequence select="f:unique-prefixes((),$mappings)"/>
    </xsl:function>
    
    <xsl:function name="f:unique-prefixes" as="element(f:vocab)*">
        <xsl:param name="head" as="element(f:vocab)*"/>
        <xsl:param name="tail" as="element(f:vocab)*"/>
        <xsl:variable name="head" as="element(f:vocab)*">
            <xsl:sequence select="$head"/>
            <xsl:if test="exists($tail[1])">
                <xsl:choose>
                    <xsl:when test="$head[@prefix=$tail[1]/@prefix and not(@uri=$tail[1]/@uri)]">
                        <f:vocab prefix="{f:unique-prefix($tail[1]/@prefix,$head/@prefix)}"
                                 uri="{$tail[1]/@uri}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$tail[1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="tail" as="element(f:vocab)*" select="$tail[position()&gt;1]"/>
        <xsl:sequence select="if (exists($tail[1]))
                              then f:unique-prefixes($head, $tail)
                              else $head"/>
    </xsl:function>
    
    <!--
        Return a unique prefix from a given prefix and a sequence of existing prefixes. The unique
        prefix is generated by appending the needed amount of '_'.
    -->
    <xsl:function name="f:unique-prefix" as="xs:string">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="existing" as="xs:string*"/>
        <xsl:sequence select="if (not($prefix=$existing))
                              then $prefix
                              else f:unique-prefix(concat($prefix,'_'),$existing)"/>
    </xsl:function>
    
    <!--
        Add a prefix mapping to a list of existing mappings
    -->
    <xsl:function name="pf:epub3-vocab-add-prefix">
        <xsl:param name="mappings" as="xs:string?"/> <!-- existing mappings -->
        <xsl:param name="prefix" as="xs:string"/> <!-- prefix for new mapping -->
        <xsl:param name="uri" as="xs:string"/> <!-- uri for new mapping -->
        <!--
            parse and add new mapping
        -->
        <xsl:variable name="new-mapping" as="element(f:vocab)">
            <f:vocab prefix="{$prefix}" uri="{$uri}"/>
        </xsl:variable>
        <xsl:variable name="mappings" as="element(f:vocab)*"
                      select="f:merge-prefix-decl((
                                if (exists($mappings)) then f:parse-prefix-decl($mappings) else (),
                                $new-mapping))"/>
        <!--
            serialize
        -->
        <xsl:sequence select="string-join(for $m in $mappings return concat($m/@prefix,': ',$m/@uri),' ')"/>
    </xsl:function>
    
</xsl:stylesheet>
