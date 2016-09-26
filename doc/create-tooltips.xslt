<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" />

<xsl:template match="/"># Generated with create-tooltips.xslt
b2mn_tooltips = {
   <xsl:for-each select="solps/code/module/param">
'<xsl:value-of select="name"/>' : """<xsl:value-of select="description"/>""",
   </xsl:for-each>
}
</xsl:template>

</xsl:stylesheet>
