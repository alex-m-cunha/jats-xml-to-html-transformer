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
  <xsl:template match="underline|u"><u><xsl:apply-templates/></u></xsl:template>
  <xsl:template match="monospace"><code><xsl:apply-templates/></code></xsl:template>
  <xsl:template match="sc"><span class="sc"><xsl:apply-templates/></span></xsl:template>

  <!-- External links -->
  <xsl:template match="uri|ext-link">
    <xsl:variable name="href" select="normalize-space(@xlink:href)"/>
    <xsl:choose>
      <xsl:when test="$href">
        <a href="{$href}" rel="noopener">
          <xsl:choose>
            <xsl:when test="normalize-space(.)">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$href"/></xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Email -->
  <xsl:template match="email">
    <a href="mailto:{normalize-space(.)}">
      <xsl:value-of select="normalize-space(.)"/>
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

  <!-- Debug fallback for unknown inline tags -->
  <xsl:template match="*">
    <xsl:choose>
      <xsl:when test="$debug='yes'">
        <span class="u-unknown-inline">
          <xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>