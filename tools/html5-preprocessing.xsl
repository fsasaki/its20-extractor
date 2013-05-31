<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:h="http://www.w3.org/1999/xhtml">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
<!--     <xsl:template match="h:link[@rel='its-rules']">
        <its:rules version="2.0" xlink:href="{@href}" xmlns:xlink="http://www.w3.org/1999/xlink"/>
    </xsl:template>  -->
<!--      <xsl:template match="@its-loc-note">
        <xsl:attribute name="its:locNote" select="."/>
    </xsl:template>
    <xsl:template match="@its-loc-note-type">
        <xsl:attribute name="its:locNoteType" select="."/>
    </xsl:template>
    <xsl:template match="@its-loc-note-ref">
        <xsl:attribute name="its:locNoteRef" select="."/>
    </xsl:template>
    <xsl:template match="@its-term">
        <xsl:attribute name="its:term" select="."/>
    </xsl:template>    
    <xsl:template match="@dir">
        <xsl:attribute name="its:dir" select="."/>
    </xsl:template>    
    <xsl:template match="@translate">
        <xsl:attribute name="its:translate" select="."/>
    </xsl:template>    
    <xsl:template match="@its-term-info-ref">
        <xsl:attribute name="its:termInfoRef" select="."/>
    </xsl:template>    
    <xsl:template match="@its-within-text">
        <xsl:attribute name="its:withinText" select="."/>
    </xsl:template>    
    <xsl:template match="@its-locale-filter-list">
        <xsl:attribute name="its:localeFilterList" select="."/>
    </xsl:template>    
    -->
</xsl:stylesheet>
