<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  
  <xsl:template match="fig">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="href" select="normalize-space(graphic/@xlink:href)"/>
    <!-- naive .tif -> .webp/.png mapping (done by your build step) -->
    <xsl:variable name="base">
      <xsl:choose>
        <xsl:when test="contains($href,'.tif')">
          <xsl:value-of select="substring-before($href,'.tif')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before($href,'.tiff')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <figure id="{$id}">
      <picture>
        <source srcset="{$assets-path}img/{$base}.webp" type="image/webp"/>
        <img src="{$assets-path}img/{$base}.png"
             alt="{normalize-space((title | caption//p)[1])}"/>
      </picture>
      <figcaption>
        <xsl:apply-templates select="label | caption/node()"/>
      </figcaption>
    </figure>
  </xsl:template>
  
</xsl:stylesheet>