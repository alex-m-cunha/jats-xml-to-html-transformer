<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:template match="fig">
    
    <!--Generate id -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('fig-', generate-id())"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- label text: label > id pattern fN > position -->
    <xsl:variable name="fig-label-text">
      <xsl:choose>
        <xsl:when test="normalize-space(label)!=''">
          <xsl:value-of select="normalize-space(label)"/>
        </xsl:when>
        <xsl:when test="starts-with(@id,'f')">
          <xsl:text>Figure </xsl:text>
          <xsl:value-of select="translate(@id,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Figure </xsl:text>
          <xsl:value-of select="count(preceding::fig)+1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="alt" select="normalize-space(alt-text)"/>
    
    <figure id="{$id}" class="figure" role="figure" aria-labelledby="{$id}-cap">
      <div class="figure-media">
        <!-- support single or alternatives -->
        <xsl:for-each select="graphic | alternatives/graphic">
          <xsl:variable name="src">
            <xsl:call-template name="graphic-src">
              <xsl:with-param name="href" select="@xlink:href"/>
            </xsl:call-template>
          </xsl:variable>
          <img src="{$src}">
            <xsl:attribute name="alt">
              <xsl:choose>
                <xsl:when test="$alt!=''"><xsl:value-of select="$alt"/></xsl:when>
                <xsl:otherwise/>
              </xsl:choose>
            </xsl:attribute>
          </img>
        </xsl:for-each>
      </div>
      
      <figcaption id="{$id}-cap">
        <span class="fig-label"><xsl:value-of select="$fig-label-text"/></span>
        <xsl:text> </xsl:text>
        <span class="fig-title"><xsl:value-of select="normalize-space(caption/title)"/></span>
        
        <!-- extra caption text (both under <caption> and stray <p> in <fig>) -->
        <xsl:for-each select="caption/*[not(self::title)] | p">
          <p class="fig-caption-text"><xsl:apply-templates/></p>
        </xsl:for-each>
        
        <xsl:if test="attrib">
          <p class="fig-attrib"><em>Source:</em> <xsl:apply-templates select="attrib/node()"/></p>
        </xsl:if>
      </figcaption>
    </figure>
  </xsl:template>
  
</xsl:stylesheet>