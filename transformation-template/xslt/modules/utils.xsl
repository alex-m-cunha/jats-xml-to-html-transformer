<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xlink="http://www.w3.org/1999/xlink"
exclude-result-prefixes="xlink">

  <!-- Keys to find back-matter targets -->
  <xsl:key name="correspById" match="front/article-meta/author-notes/corresp" use="@id"/>
  <xsl:key name="refById" match="article/back/ref-list/ref" use="@id"/>
  <xsl:key name="fnById"  match="article/back/fn-group//fn | //table-wrap//table-wrap-foot//fn" use="@id"/>
  <xsl:key name="affById" match="article/front/article-meta/aff" use="@id"/>

  <!-- Compute ordinal number of a back/ref-list/ref by id -->
  <xsl:template name="ref-number">
    <xsl:param name="rid"/>
    <xsl:variable name="t" select="key('refById',$rid)[1]"/>
    <xsl:value-of select="count($t/preceding-sibling::ref) + 1"/>
  </xsl:template>

  <!-- Compute ordinal number of a back fn by id -->
  <xsl:template name="fn-number">
    <xsl:param name="rid"/>
    <xsl:variable name="t" select="key('fnById',$rid)[1]"/>
    <xsl:value-of select="count($t/preceding-sibling::fn) + 1"/>
  </xsl:template>

  <!-- Safe id for sections if missing -->
  <xsl:template name="ensure-id">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@id"><xsl:value-of select="$node/@id"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat('sec-', generate-id($node))"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Fallbacks so unknown tags never drop text -->
  <xsl:template match="text()"><xsl:value-of select="."/></xsl:template>

  <!-- Debug highlight of unknown elements (optional) -->
  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="$debug='yes'">
        <span style="background:yellow; border:1px dashed red;">
          [<xsl:value-of select="name()"/>: <xsl:apply-templates/>]
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Prefixes article-img-root to redirect article images -->
  <xsl:template name="graphic-src">
    <xsl:param name="href"/>
    <xsl:value-of select="concat($article-img, $href)"/>
  </xsl:template>
  
</xsl:stylesheet>