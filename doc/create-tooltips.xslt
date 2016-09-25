<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" 
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0" >

	<xsl:output method="text/plain" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:strip-space elements="description"/>

<xsl:template match="/">
<xsl:text>b2mn_tooltips = {</xsl:text>
   <xsl:for-each select="solps/code/module/param">
      <xsl:text>'</xsl:text><xsl:value-of select="name"/><xsl:text>' : """
      </xsl:text><xsl:value-of select="description"/><xsl:text>""", </xsl:text>
   </xsl:for-each>
   <xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
