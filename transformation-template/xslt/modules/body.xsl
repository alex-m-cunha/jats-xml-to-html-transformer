<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Left column TOC (top-level sections only) -->
  <xsl:template match="body" mode="toc">
    <nav class="toc" aria-label="Article">
      <ol>
        <xsl:for-each select="sec">
          <xsl:variable name="id">
            <xsl:choose>
              <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <li>
            <a href="#{$id}"><xsl:value-of select="normalize-space(title)"/></a>
            <xsl:if test="sec">
              <ol>
                <xsl:for-each select="sec">
                  <xsl:variable name="sid">
                    <xsl:choose>
                      <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
                      <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <li><a href="#{$sid}"><xsl:value-of select="normalize-space(title)"/></a></li>
                </xsl:for-each>
              </ol>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ol>
    </nav>
  </xsl:template>
  
  <!-- Body: recurse through sections -->
  <xsl:template match="body">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <!-- Section to heading mapping based on depth -->
  <xsl:template match="sec">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
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