<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" />

<xsl:template match="/"># Generated with create-addmenu.xslt
# xsltproc create-addmenu.xslt solps-input.xml > ../../solps-gui/src/widgets/b2menu.py
b2mn_menu = {
# Category : ( parameter, type, default, description )
#         or ( parametergroup, 'paramgroup', [(name, type, default, description)...], description)
  <xsl:call-template name="block">
    <xsl:with-param name="category">Run</xsl:with-param>
  </xsl:call-template> 
  <xsl:call-template name="block">
    <xsl:with-param name="category">Output</xsl:with-param>
  </xsl:call-template> 
  <xsl:call-template name="block">
    <xsl:with-param name="category">Physics</xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="block">
    <xsl:with-param name="category">Atomic Physics</xsl:with-param>
  </xsl:call-template> 
  <xsl:call-template name="block">
    <xsl:with-param name="category">Geometry</xsl:with-param>
  </xsl:call-template>    
  <xsl:call-template name="block">
    <xsl:with-param name="category">Atomic Physics</xsl:with-param>
  </xsl:call-template>   
}
</xsl:template>


<xsl:template name="block">
  <xsl:param name = "category" />
  '<xsl:value-of select="$category"/>': [
  <xsl:for-each select="solps/module/param[category=$category]| solps/module/paramgroup[category=$category]">
	   <xsl:choose><xsl:when test="name(.)='paramgroup'">
      ( '<xsl:value-of select="name"/>', 'paramgroup', [
        <xsl:for-each select="param">
               ('<xsl:value-of select="name"/>', '<xsl:value-of select="type"/>', '<xsl:value-of select="default"/>','''<xsl:value-of select="description"/>'''), 
        </xsl:for-each>],
         """<xsl:value-of select="description"/>"""),</xsl:when>
      <xsl:otherwise>
         ( '<xsl:value-of select="name"/>', '<xsl:value-of select="type"/>', '<xsl:value-of select="default"/>', """<xsl:value-of select="description"/>"""),
      </xsl:otherwise>
     </xsl:choose>
   </xsl:for-each>
   ],
</xsl:template>

</xsl:stylesheet>
