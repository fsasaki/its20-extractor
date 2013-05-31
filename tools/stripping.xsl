<?xml version="1.0" encoding="UTF-8"?>
<!-- Creating an intermediate XML format - the NIF character offsets are easier processed that way -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template match="node()|@*" mode="stripWS">
        <xsl:copy>
            <xsl:apply-templates mode="stripWS" select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template mode="stripWS" match="text()[not(matches(.,'\S'))]"/>
    <xsl:template mode="stripWS" match="text()[matches(.,'\S')]">
        <xsl:value-of select="replace(.,'\s+',' ')"/>
    </xsl:template>
    <xsl:template match="its:rules" xmlns:its="http://www.w3.org/2005/11/its"  mode="stripWS"/>
    <xsl:template match="h:p | h:li | h:h1 | h:h2 | h:h3 | h:h4 | h:h5 | h:h6 | h:div" xmlns:h="http://www.w3.org/1999/xhtml"
        mode="stripWS"  >
        <xsl:variable name="preceding">
            <xsl:value-of select="preceding::text()"/>
        </xsl:variable>
        <xsl:if test="matches($preceding,'\S')"><xsl:text> </xsl:text></xsl:if>
        <xsl:copy>
            <xsl:apply-templates mode="stripWS" select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
