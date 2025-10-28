<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Abstract, Sections, Appendix sec(s), then References -->
  <xsl:template match="body" mode="full-article">
    
    <!-- Abstract -->
    <xsl:if test="/article/front/article-meta/abstract">
      <section id="abstract" class="sec-label">
        <h2>Abstract</h2>
        <xsl:apply-templates select="/article/front/article-meta/abstract/p"/>
      </section>
    </xsl:if>
    
    <!-- Sections -->
    <xsl:apply-templates select="node()"/>
    
    <!-- Appendix -->
    <!-- Grab the first appendix node -->
    <xsl:variable name="app" select="/article/back/app-group/app[1]"/>
    
    <!-- Render the Appendix section somewhere in the body -->
    <xsl:if test="$app">
      <div id="appendix" class="appendix">
        <h2>Appendix</h2>
        <!-- Show everything inside <app> except its original title -->
        <xsl:apply-templates select="$app/node()[not(self::title)]"/>
      </div>
    </xsl:if>
    
    <!-- References -->
    <xsl:apply-templates select="/article/back/ref-list" mode="list"/>
     
  </xsl:template>
  
  <!-- Section to heading mapping based on depth -->
  <xsl:template match="article/body//sec">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('sec-', generate-id())"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <section id="{$id}">
      <xsl:variable name="level" select="count(ancestor::sec) + 2"/> <!-- h2 for top level -->
      <xsl:element name="{concat('h', $level)}">
        <span class="sec-label" aria-hidden="true">
          <xsl:value-of select="label"/><xsl:if test="label"> </xsl:if>
        </span>
        <span class="sec-title"><xsl:value-of select="title"/></span>
      </xsl:element>
      <xsl:apply-templates select="node()[not(self::title or self::label)]"/>
    </section>
  </xsl:template>
  
  <!-- Paragraphs pass through -->
  <xsl:template match="p"><p><xsl:apply-templates/></p></xsl:template>
  
</xsl:stylesheet>