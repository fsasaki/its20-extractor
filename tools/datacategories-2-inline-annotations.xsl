<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output indent="yes"/>
	<xsl:key name="nodePath" match="node" use="@path"/>
	<xsl:variable name="inputdoc-decorated" select="doc('../temp/nodelist-with-its-information.xml')"/>
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
	<xsl:template match="*">
		<xsl:variable name="element-path">
			<xsl:apply-templates select="." mode="get-full-path"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<itsAnn>
				<xsl:for-each select="$inputdoc-decorated">
					<xsl:if test="key('nodePath',$element-path)/output/@* | key('nodePath',$element-path)/output/*"> 
						<elem>
							<xsl:copy-of select="key('nodePath',$element-path)/output/@*"/>
							<xsl:copy-of select="key('nodePath',$element-path)/output/*"/>
						</elem>
					</xsl:if>  
				</xsl:for-each>
				<xsl:for-each select="@*">
					<xsl:variable name="attr" select="name()"/>
					<xsl:variable name="attribute-path">
						<xsl:apply-templates select="." mode="get-full-path"/>
					</xsl:variable>
					<xsl:for-each select="$inputdoc-decorated">
						<xsl:if test="key('nodePath',$attribute-path)/output/@* | key('nodePath',$attribute-path)/output/*"> 
							<attr name="{$attr}">
								<xsl:copy-of select="key('nodePath',$attribute-path)/output/@*"/>
								<xsl:copy-of select="key('nodePath',$attribute-path)/output/*"/>
							</attr>
						</xsl:if>  
					</xsl:for-each>
				</xsl:for-each>
			</itsAnn>
			<xsl:apply-templates select="*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>