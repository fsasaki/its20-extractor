<!-- Stylesheet implementing Conversion NIF2ITS, as defined at http://www.w3.org/TR/its20/#nif-backconversion 
Copyright Felix Sasaki fsasaki@w3.org 2013
For further information about ITS 2.0 text analysis annotation see http://www.w3.org/TR/its20/#textanalysis
For further information about NIF see http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core
License: http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
$Id: nif-2-its-ta.xsl,v 1.9 2013-05-16 16:38:50 fsasaki Exp $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs rdf itsrdf"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:itsrdf="http://www.w3.org/2005/11/its/rdf#">
    <xsl:include href="stripping.xsl"/>
    <xsl:param name="nif-rdf-xml" select="doc('../sample/nif-conversion/its-ta-2-nif-output.rdf')"/>
    <xsl:param name="annotation-tool">http://example.com/myTools</xsl:param>
    <xsl:variable name="whiteSpaceStripped">
        <xsl:apply-templates select="/" mode="stripWS"/>
    </xsl:variable>
    <xsl:variable name="annotations">
        <x><extractor><xsl:value-of select="$annotation-tool"/></extractor>
            <xsl:for-each select="$nif-rdf-xml//rdf:Description[.//itsrdf:taConfidence or .//itsrdf:taClassRef or .//itsrdf:taIdentRef]">
                <array>
                    <startChar><xsl:value-of select="substring-before(substring-after(@rdf:about,'#char='),',')"/></startChar>
                    <endChar><xsl:value-of select="substring-after(substring-after(@rdf:about,'#char='),',')"/></endChar>
                    <xsl:if test="itsrdf:taConfidence"><confidence><xsl:value-of select="itsrdf:taConfidence"/></confidence></xsl:if>
                    <xsl:if test="itsrdf:taClassRef"><Class><xsl:value-of select="itsrdf:taClassRef/@rdf:resource"/></Class></xsl:if>
                    <xsl:if test="itsrdf:taIdentRef"><Ident><xsl:value-of select="itsrdf:taIdentRef/@rdf:resource"/></Ident></xsl:if>
                </array>
            </xsl:for-each>
        </x>
    </xsl:variable>
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- Add annotors-ref attribute, using the extractor field -->
            <xsl:attribute name="its-annotators-ref"
                select="concat('text-analysis|',$annotations/x/extractor)"/>
            <xsl:apply-templates select="$whiteSpaceStripped/*/*" mode="processStripped"/>
        </xsl:copy>
    </xsl:template>
    <!-- Just copied to the output -->
    <xsl:template match="processing-instruction()|comment()">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="*" mode="processStripped">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="preceding">
                <xsl:value-of select="preceding::text()"/>
            </xsl:variable>
            <!-- Generating character offsets for comparison of original text content with NIF offsets.  -->
            <xsl:variable name="offset-start" select="xs:integer(string-length($preceding))"/>
            <xsl:variable name="offset-end" select="$offset-start + string-length(.)"/>
             <xsl:choose>
                 <!-- CASE 1 at http://www.w3.org/TR/its20/#nif-backconversion : 
                     "The NLP annotation created in NIF matches the text node. Solution: Attach the annotation to the parent element of the text node." -->
                <xsl:when test="$annotations/x/array[xs:integer(startChar) = $offset-start and xs:integer(endChar) = $offset-end]">
<!--                     <xsl:attribute name="offset-start"><xsl:value-of select="$offset-start"/></xsl:attribute>
                    <xsl:attribute name="offset-end"><xsl:value-of select="$offset-end"/></xsl:attribute> -->
                    <xsl:variable name="this" select="$annotations/x/array[xs:integer(startChar) = $offset-start and xs:integer(endChar) = $offset-end][1]"/>
                    <xsl:if test="$this/Class">
                        <xsl:attribute name="its-ta-class-ref" select="$this/Class"/>
                    </xsl:if>
                    <xsl:if test="$this/Ident and not($this[1]/Ident='null')">
                        <xsl:attribute name="its-ta-ident-ref" select="$this/Ident"/>
                    </xsl:if>
                    <xsl:if test="$this/confidence">
                        <xsl:attribute name="its-ta-confidence" select="$this/confidence"/>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </xsl:when>
                 <!-- Otherwise we process text nodes and child elements -->
                <xsl:otherwise> 
                    <xsl:apply-templates mode="processStripped"/> 
                </xsl:otherwise>  
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()" mode="processStripped">
        <!-- The current text nodes -->
        <xsl:variable name="currentText" select="."/>
        <xsl:variable name="preceding">
            <xsl:value-of select="preceding::text()"/>
        </xsl:variable>
        <!-- The offsets -->
        <xsl:variable name="offset-start" select="xs:integer(string-length($preceding))"/>
        <xsl:variable name="offset-end" select="xs:integer($offset-start + string-length($currentText))"/>
        <!-- In foundAnnotations: add intermediate output (= array element) if the annotated string is part of the current text node. -->
        <xsl:variable name="foundAnnotations">
            <!-- Checking for CASE 2 at http://www.w3.org/TR/its20/#nif-backconversion : 
                     "The NLP annotation created in NIF is a substring of the text node. 
                     Solution: Create a new element, e.g. for HTML "span" ... " -->
            <xsl:for-each
                select="$annotations/x/array[xs:integer(startChar) &gt;= $offset-start and xs:integer(endChar) &lt;= $offset-end]">
                <xsl:sort select="xs:integer(startChar)"/>
                <xsl:variable name="startChar" select="self::array/startChar"/>
                <xsl:variable name="endChar" select="self::array/endChar"/>
                <!-- in its2.0 we can't have several annotators :( . Here we just take the last annotation available for a given span of text.-->
                <xsl:if
                    test="not(self::array[preceding-sibling::array/startChar=$startChar and preceding-sibling::array/endChar=$endChar])">
                    <xsl:copy-of select="self::array"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <!-- If there is an annotation, output the string  in the current text node before that annotation and call a template to write the annotations.-->
            <xsl:when test="$foundAnnotations/array">
                <xsl:variable name="startChar" select="$foundAnnotations/array[1]/startChar"/>
                <xsl:variable name="endChar" select="$foundAnnotations/array[1]/endChar"/>
                <xsl:value-of select="substring($currentText,0,$startChar - $offset-start + 1)"/>
                <xsl:call-template name="writeAnnotations">
                    <xsl:with-param name="currentText" select="$currentText"/>
                    <xsl:with-param name="currentAnnotations" select="$foundAnnotations/array"/>
                    <xsl:with-param name="offset-start" select="$offset-start"/>
                    <xsl:with-param name="startChar" select="$startChar"/>
                    <xsl:with-param name="endChar" select="$endChar"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Template to write annotations -->
    <xsl:template name="writeAnnotations">
        <xsl:param name="currentText"/>
        <xsl:param name="currentAnnotations"/>
        <xsl:param name="offset-start" as="xs:integer"/>
        <xsl:param name="startChar" as="xs:double"/>
        <xsl:param name="endChar" as="xs:double"/>
        <!-- A dummy element to deal with the situation that sometimes there is no Ident (= no its-ta-class-ref) given in the NIF file. -->
        <xsl:variable name="attribs">
            <dummy>
                <xsl:if test="$currentAnnotations[1]/Class">
                    <xsl:attribute name="its-ta-class-ref" select="$currentAnnotations[1]/Class"/>
                </xsl:if>
                <xsl:if test="$currentAnnotations[1]/Ident">
                    <xsl:attribute name="its-ta-ident-ref" select="$currentAnnotations[1]/Ident"/>
                </xsl:if>
                <xsl:if test="$currentAnnotations[1]/confidence">
                    <xsl:attribute name="its-ta-confidence" select="$currentAnnotations[1]/confidence"/>
                </xsl:if>
            </dummy>
        </xsl:variable>
        <!-- Generate a span that serves as an anchor for the annotations. -->
        <!-- offset-start="{$startChar}" offset-end="{$startChar + string-length(substring($currentText,$startChar - $offset-start,$endChar - $startChar))}" -->
        <span xmlns="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="$attribs/dummy/@*"/>
            <!-- Output the text string that is being annotated-->
            <xsl:value-of
                select="substring($currentText,$startChar - $offset-start +1,$endChar - $startChar)"/>
        </span>
        <xsl:choose>
            <!-- If there are other annotations left: call the writeAnnotations template again, with the annotations left and with the new annotation startChar and endChar. The offset for the currentText and the current text itself are just transported through the iteration of the template. -->
            <xsl:when test="count($currentAnnotations) &gt; 1">
                <xsl:variable name="newStartChar" select="xs:double($currentAnnotations[2]/startChar)"/>
                <xsl:variable name="newEndChar" select="xs:double($currentAnnotations[2]/endChar)"/>
                <xsl:value-of
                    select="substring($currentText,$endChar - $offset-start +1, $newStartChar - $endChar)"/>
                <xsl:call-template name="writeAnnotations">
                    <xsl:with-param name="currentText" select="$currentText"/>
                    <xsl:with-param name="currentAnnotations" select="$currentAnnotations[position() &gt; 1]"/>
                    <xsl:with-param name="offset-start" select="$offset-start"/>
                    <xsl:with-param name="startChar" select="$newStartChar"/>
                    <xsl:with-param name="endChar" select="$newEndChar"/>
                </xsl:call-template>
            </xsl:when>
            <!-- If there are no other annotations left: output the sub string after the last annotation that has been created.-->
            <xsl:otherwise>
                <xsl:value-of select="substring($currentText,$endChar - $offset-start +1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
