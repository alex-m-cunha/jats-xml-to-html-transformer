<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">

  <!-- Simple inline formatting -->
  <xsl:template match="italic"><em><xsl:apply-templates/></em></xsl:template>
  <xsl:template match="bold"><strong><xsl:apply-templates/></strong></xsl:template>
  <xsl:template match="sup"><sup><xsl:apply-templates/></sup></xsl:template>
  <xsl:template match="sub"><sub><xsl:apply-templates/></sub></xsl:template>

  <!-- External links -->
  <xsl:template match="uri|ext-link">
    <a href="{@xlink:href}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- XREF: bibliography -->
  <xsl:template match="xref[@ref-type='bibr']">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="normalize-space(.)!=''"><xsl:value-of select="normalize-space(.)"/></xsl:when>
        <xsl:otherwise><xsl:call-template name="ref-number"><xsl:with-param name="rid" select="$rid"/></xsl:call-template></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a class="cite" role="doc-biblioref" href="#{$rid}" aria-label="Reference {$num}">[<xsl:value-of select="$num"/>]</a>
  </xsl:template>

  <!-- XREF: footnote (global or table) -->
  <xsl:template match="xref[@ref-type='fn']">
    <xsl:variable name="rid" select="@rid"/>
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="normalize-space(.)!=''"><xsl:value-of select="normalize-space(.)"/></xsl:when>
        <xsl:otherwise><xsl:call-template name="fn-number"><xsl:with-param name="rid" select="$rid"/></xsl:call-template></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <sup class="fn-ref">
      <a href="#{$rid}" data-fn-popup="{$rid}" role="doc-noteref"><xsl:value-of select="$num"/></a>
    </sup>
  </xsl:template>

  <!-- XREF: sections/figures/tables (plain anchors) -->
  <xsl:template match="xref[@ref-type='sec' or @ref-type='fig' or @ref-type='table']">
    <a href="#{@rid}"><xsl:apply-templates/></a>
  </xsl:template>
</xsl:stylesheet>