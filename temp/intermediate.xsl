<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:its="http://www.w3.org/2005/11/its"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:datc="http://example.com/datacats"
                version="2.0">
   <xsl:output method="xml" indent="yes" encoding="utf-8"/>
   <xsl:strip-space elements="*"/>
   <xsl:template match="*|@*" mode="get-full-path">
      <xsl:apply-templates select="parent::*" mode="get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:if test="count(. | ../@*) = count(../@*)">@</xsl:if>
      <xsl:value-of select="name()"/>
      <xsl:if test="self::element() and parent::element()">
         <xsl:text>[</xsl:text>
         <xsl:number/>
         <xsl:text>]</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template name="writeOutput">
      <xsl:param name="outputType">no-value</xsl:param>
      <xsl:param name="outputValue" as="node()*">
         <output>no-value</output>
      </xsl:param>
      <xsl:element name="node">
         <xsl:attribute name="path">
            <xsl:apply-templates mode="get-full-path" select="."/>
         </xsl:attribute>
         <xsl:attribute name="outputType">
            <xsl:value-of select="$outputType"/>
         </xsl:attribute>
         <output>
            <xsl:copy-of select="$outputValue/@*"/>
            <xsl:if test="ancestor-or-self::*[@its:annotatorsRef or @its-annotators-ref]">
               <xsl:attribute name="its:annotatorsRef">
                  <xsl:value-of select="ancestor-or-self::*[@its:annotatorsRef][last()]/@its:annotatorsRef | ancestor::*[@its-annotators-ref][last()]/@its-annotators-ref"/>
               </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$outputValue/node()"/>
         </output>
      </xsl:element>
   </xsl:template>
   <xsl:template match="/">
      <xsl:variable name="nodeList-v1">
         <nodeList>
            <xsl:element name="nodeList">
               <xsl:attribute name="datacat">
                  <xsl:text>textanalysis</xsl:text>
               </xsl:attribute>
               <xsl:attribute name="annotatorsRef">
                  <xsl:text>text-analysis</xsl:text>
               </xsl:attribute>
               <xsl:apply-templates mode="textanalysis">
                  <xsl:with-param name="existingDataCatValue">no-value</xsl:with-param>
               </xsl:apply-templates>
            </xsl:element>
         </nodeList>
      </xsl:variable>
      <xsl:variable name="nodeList-v2">
         <xsl:apply-templates select="$nodeList-v1" mode="aftermath"/>
      </xsl:variable>
      <xsl:apply-templates select="$nodeList-v2" mode="aftermath-remove-unused-annotators-ref"/>
   </xsl:template>
   <xsl:template match="@its:annotatorsRef"
                 mode="aftermath-remove-unused-annotators-ref">
      <xsl:variable name="current-annotators-ref">
         <xsl:value-of select="."/>
      </xsl:variable>
      <xsl:variable name="current-datacategory">
         <xsl:value-of select="ancestor::nodeList[@annotatorsRef]/@annotatorsRef"/>
      </xsl:variable>
      <xsl:if test="contains($current-annotators-ref,$current-datacategory) and not (ancestor::node/@outputType='no-value')">
         <xsl:copy-of select="."/>
      </xsl:if>
   </xsl:template>
   <xsl:template match="node()|@*" mode="aftermath-remove-unused-annotators-ref">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="aftermath-remove-unused-annotators-ref"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="node()|@*" mode="aftermath">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="aftermath"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="*[@its:taConfidence | @taConfidence[parent::its:span] | @its:taClassRef | @taClassRef[parent::its:span] | @its:taSource | @taSource[parent::its:span] | @its:taIdent | @taIdent[parent::its:span] | @its:taIdentRef | @taIdentRef[parent::its:span]]"
                 mode="textanalysis"
                 priority="+1000">
      <xsl:call-template name="writeOutput">
         <xsl:with-param name="outputType">new-value-local</xsl:with-param>
         <xsl:with-param name="outputValue" as="node()*">
            <output>
               <xsl:for-each select="@its:taConfidence | @taConfidence[parent::its:span] | @its:taClassRef | @taClassRef[parent::its:span] | @its:taSource | @taSource[parent::its:span] | @its:taIdent | @taIdent[parent::its:span] | @its:taIdentRef | @taIdentRef[parent::its:span]">
                  <xsl:copy-of select="."/>
               </xsl:for-each>
            </output>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="textanalysis" select="@* | element()">
         <xsl:with-param name="existingDataCatValue" as="node()*">no-value</xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="textanalysis" priority="-1000">
      <xsl:param name="existingDataCatValue" as="node()*">no-value</xsl:param>
      <xsl:if test="$existingDataCatValue='no-value'">
         <xsl:call-template name="writeOutput">
            <xsl:with-param name="outputType">no-value</xsl:with-param>
            <xsl:with-param name="outputValue" as="node()*">
               <output/>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:apply-templates mode="textanalysis" select="@* | element()">
            <xsl:with-param name="existingDataCatValue" as="node()*">no-value</xsl:with-param>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="@*" mode="textanalysis" priority="-1000">
      <xsl:param name="existingDataCatValue" as="node()*">no-value</xsl:param>
      <xsl:call-template name="writeOutput">
         <xsl:with-param name="outputType">no-value</xsl:with-param>
         <xsl:with-param name="outputValue" as="node()*">
            <output/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template mode="textanalysistaClassRefPointer"
                 match="element() | @*"
                 priority="1">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="textanalysistaClassRefPointer"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="textanalysistaIdentRefPointer"
                 match="element() | @*"
                 priority="1">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="textanalysistaIdentRefPointer"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template xmlns:xlf2="urn:oasis:names:tc:xliff:document:2.0"
                 xmlns:itsm="urn:oasis:names:tc:xliff:itsm:2.1"
                 mode="textanalysis"
                 match="//xlf2:mrk[@type='itsm:generic' and (@itsm:taClassRef or @itsm:taIdentRef)]"
                 priority="1">
      <xsl:call-template name="writeOutput">
         <xsl:with-param name="outputType">new-value-global</xsl:with-param>
         <xsl:with-param name="outputValue" as="node()*">
            <output>
               <taClassRefPointer>
                  <xsl:apply-templates select="@itsm:taClassRef" mode="textanalysistaClassRefPointer"/>
               </taClassRefPointer>
               <taIdentRefPointer>
                  <xsl:apply-templates select="@itsm:taIdentRef" mode="textanalysistaIdentRefPointer"/>
               </taIdentRefPointer>
            </output>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="textanalysis" select="@* | element()">
         <xsl:with-param name="existingDataCatValue" as="node()*">
            <output>
               <taClassRefPointer>
                  <xsl:apply-templates select="@itsm:taClassRef" mode="textanalysistaClassRefPointer"/>
               </taClassRefPointer>
               <taIdentRefPointer>
                  <xsl:apply-templates select="@itsm:taIdentRef" mode="textanalysistaIdentRefPointer"/>
               </taIdentRefPointer>
            </output>
         </xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template mode="textanalysistaClassRefPointer"
                 match="element() | @*"
                 priority="2">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="textanalysistaClassRefPointer"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="textanalysistaIdentRefPointer"
                 match="element() | @*"
                 priority="2">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()" mode="textanalysistaIdentRefPointer"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template xmlns:xlf2="urn:oasis:names:tc:xliff:document:2.0"
                 xmlns:itsm="urn:oasis:names:tc:xliff:itsm:2.1"
                 mode="textanalysis"
                 match="//xlf2:sm[@type='itsm:generic' and (@itsm:taClassRef or @itsm:taIdentRef)]"
                 priority="2">
      <xsl:call-template name="writeOutput">
         <xsl:with-param name="outputType">new-value-global</xsl:with-param>
         <xsl:with-param name="outputValue" as="node()*">
            <output>
               <taClassRefPointer>
                  <xsl:apply-templates select="@itsm:taClassRef" mode="textanalysistaClassRefPointer"/>
               </taClassRefPointer>
               <taIdentRefPointer>
                  <xsl:apply-templates select="@itsm:taIdentRef" mode="textanalysistaIdentRefPointer"/>
               </taIdentRefPointer>
            </output>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="textanalysis" select="@* | element()">
         <xsl:with-param name="existingDataCatValue" as="node()*">
            <output>
               <taClassRefPointer>
                  <xsl:apply-templates select="@itsm:taClassRef" mode="textanalysistaClassRefPointer"/>
               </taClassRefPointer>
               <taIdentRefPointer>
                  <xsl:apply-templates select="@itsm:taIdentRef" mode="textanalysistaIdentRefPointer"/>
               </taIdentRefPointer>
            </output>
         </xsl:with-param>
      </xsl:apply-templates>
   </xsl:template>
</xsl:stylesheet>
