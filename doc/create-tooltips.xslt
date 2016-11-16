<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" />

<xsl:template match="/"># Generated with create-tooltips.xslt  
# xsltproc create-tooltips.xslt solps-input.xml > ../../solps-gui/src/widgets/tooltips.py
b2mn_tooltips = {
# Tuples of category, type, default, description
   <xsl:for-each select="solps/module/paramgroup">
      <xsl:for-each select="param">
         '<xsl:value-of select="name"/>' : ('<xsl:value-of select="../category"/>', '<xsl:value-of select="type"/>', '<xsl:value-of select="default"/>', """<xsl:value-of select="../description"/>"""),
      </xsl:for-each>
   </xsl:for-each>
   <xsl:for-each select="solps/module/param">
      '<xsl:value-of select="name"/>' : ('<xsl:value-of select="category"/>', '<xsl:value-of select="type"/>', '<xsl:value-of select="default"/>', """<xsl:value-of select="description"/>"""),
   </xsl:for-each>
}
</xsl:template>

</xsl:stylesheet>
