<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datc="http://example.com/datacats"
    xmlns:XSL="http://www.w3.org/1999/XSL/TransformAlias" exclude-result-prefixes="xsl"
    xmlns:saxon="http://saxon.sf.net/"
    version="2.0">
<xsl:import href="datacategories-2-xsl.xsl"/>
    <xsl:param name="inputDocUri">notest</xsl:param>
    <xsl:param name="originalInputDoc"/>
    <xsl:variable name="originalInputDocUri" select="concat(substring-before(base-uri(),'tools/datacategories-definition.xml'),$originalInputDoc)"/>
    <!--  	<xsl:variable name="original-base-uri" select="substring-before(base-uri(doc($originalInputDocUri)),tokenize(base-uri(doc($originalInputDocUri)), '(/)|(\\)')[last()])"/>	 -->
    <xsl:param name="inputDatacats">all</xsl:param>
    <xsl:param name="html5-input">no</xsl:param>
    <xsl:variable name="dataCatDoc" select="." as="node()*"/>
    <xsl:variable name="inputDoc" select="doc('../temp/inputfile.xml')" as="node()*"/>
    <xsl:variable name="datacategories">
        <xsl:choose>
            <xsl:when test="$inputDatacats='all'">
                <xsl:copy-of select="//datc:datacat"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="tokenize($inputDatacats,'\s+')">
                    <xsl:variable name="datacatName">
                        <xsl:value-of select="."/>
                    </xsl:variable>
                    <xsl:copy-of select="$dataCatDoc//datc:datacat[@name=$datacatName]"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="locallyAddedMarkup">
        <xsl:choose>
            <xsl:when test="$html5-input='no'">
                <xsl:for-each select="$datacategories//datc:localAdding/@addedMarkup">
                    <xsl:value-of select="."/>
                    <xsl:text> | </xsl:text>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$html5-input='yes'">
                <xsl:message terminate="no">Processing HTML5</xsl:message>
                <xsl:for-each select="$datacategories//datc:localAdding/@addedMarkup-html5">
                    <xsl:value-of select="."/>
                    <xsl:text> | </xsl:text>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">What do you want to process - html5 or
                    xml?</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:variable name="generateStylesheet">
            <XSL:stylesheet version="2.0" xmlns:its="http://www.w3.org/2005/11/its"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <XSL:output method="xml" indent="yes" encoding="utf-8"/>
                <XSL:strip-space elements="*"/>
                <XSL:template match="*|@*" mode="get-full-path">
                    <XSL:apply-templates select="parent::*" mode="get-full-path"/>
                    <XSL:text>/</XSL:text>
                    <XSL:if test="count(. | ../@*) = count(../@*)">@</XSL:if>
                    <XSL:value-of select="name()"/>
                    <XSL:if test="self::element() and parent::element()">
                        <XSL:text>[</XSL:text>
                        <XSL:number/>
                        <!-- <XSL:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/> not necessary, see mail from Sebastian from 2006/07/07 23:50.-->
                        <XSL:text>]</XSL:text>
                    </XSL:if>
                </XSL:template>
                <!-- Write root template. This creates nodeList for one data category and calls the recursion template. -->
                <XSL:template name="writeOutput">
                    <XSL:param name="outputType">no-value</XSL:param>
                    <XSL:param name="outputValue" as="node()*">
                        <output>no-value</output>
                    </XSL:param>
                    <XSL:element name="node">
                        <XSL:attribute name="path">
                            <XSL:apply-templates mode="get-full-path" select="."/>
                        </XSL:attribute>
                        <XSL:attribute name="outputType">
                            <XSL:value-of select="$outputType"/>
                        </XSL:attribute>
                        <XSL:copy-of select="$outputValue"/>
                    </XSL:element>
                </XSL:template>
                <XSL:template match="/">
                    <nodeList xmlns:its="http://www.w3.org/2005/11/its">
                        <xsl:for-each select="$datacategories//datc:datacat">
                            <XSL:element name="nodeList">
                                <XSL:attribute name="datacat">
                                    <XSL:text>
                                        <xsl:value-of select="@name"/>
                                    </XSL:text>
                                </XSL:attribute>
                                <!-- The call of the recursion template used for local and inheritance stuff. Takes care of (possible non-existing) default values. -->
                                <XSL:apply-templates mode="{@name}">
                                    <XSL:with-param name="existingDataCatValue">
                                        <xsl:choose>
                                            <xsl:when test="datc:defaults/datc:*">
                                                <xsl:text>default-value</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>no-value</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </XSL:with-param>
                                </XSL:apply-templates>
                            </XSL:element>
                        </xsl:for-each>
                    </nodeList>
                </XSL:template>
                <xsl:for-each select="$datacategories//datc:datacat">
                    <!--
	    The template below is not used to achieve comparibility with other ITS implementations.
	    <XSL:template match="{concat($locallyAddedMarkup, '@xyzAttr')}" mode="{@name}"/>-->
                    <!-- Just for readability the following is separated.-->
                    <xsl:if test="datc:localAdding">
                        <xsl:call-template name="localMarkupTemplate"/>
                    </xsl:if>
                    <xsl:call-template name="recursionTemplate"/>
                    <xsl:if test="datc:rulesElement">
                        <xsl:call-template name="globalRulesTemplate"/>
                    </xsl:if>
                </xsl:for-each>
            </XSL:stylesheet>
        </xsl:variable>
  <xsl:variable name="transformed" select="saxon:transform(saxon:compile-stylesheet($generateStylesheet),$inputDoc)"/>
        <xsl:copy-of select="$transformed"/>
    </xsl:template>
</xsl:stylesheet>