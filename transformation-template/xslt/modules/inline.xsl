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
        <a href="{$href}" target="_blank" rel="noopener">
          <xsl:choose>
            <xsl:when test="normalize-space(.)">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$href"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Email -->
  <xsl:template match="email">
    <a href="mailto:{normalize-space(.)}">
      <xsl:value-of select="normalize-space(.)"/>
    </a>
  </xsl:template>

  <!-- Inline bibliography citation → trigger-only (no brackets, renders as (N)) -->
  <xsl:template match="xref[@ref-type='bibr']">
    <xsl:variable name="rid" select="@rid"/>
    
    <!-- Label: use provided text if present; otherwise compute numeric index from ref-list -->
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="normalize-space(.)">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(/article/back/ref-list/ref[@id=$rid]/preceding-sibling::ref) + 1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Display as: (N) where N is a button that controls a popover -->
    <span class="citation">
      <button
        type="button"
        class="popover-trigger citation-trigger"
        aria-haspopup="dialog"
        aria-expanded="false"
        aria-controls="ref-pop-{$rid}">
        <xsl:value-of select="$label"/>
      </button>
    </span>
  </xsl:template>

  <!-- Inline footnote trigger → renders as (N), not superscript -->
  <xsl:template match="xref[@ref-type='fn']">
    <!-- Target id from the xref -->
    <xsl:variable name="rid" select="normalize-space(@rid)"/>
    
    <!-- Find the actual fn node (global or table footnote) -->
    <xsl:variable name="fn"
      select="(/article/back/fn-group//fn[@id=$rid]
      | //table-wrap//table-wrap-foot//fn[@id=$rid])[1]"/>
    
    <!-- Compute the ordinal N safely -->
    <xsl:variable name="n">
      <xsl:choose>
        <xsl:when test="$fn"><xsl:value-of select="count($fn/preceding-sibling::fn) + 1"/></xsl:when>
        <xsl:otherwise>?</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Tight parentheses; button is the only focusable element -->
    <span class="footnote">
      <button
        type="button"
        class="popover-trigger fn-trigger"
        aria-haspopup="dialog"
        aria-expanded="false"
        aria-controls="{concat('fn-pop-',$rid)}"
        aria-label="Footnote {$n}"
        data-popover-kind="fn"
        data-popover-rid="{$rid}">
        <xsl:value-of select="$n"/>
      </button>
    </span>
  </xsl:template>

  <!-- XREF: sections/figures/tables (plain anchors) -->
  <xsl:template match="xref[@ref-type='sec' or @ref-type='fig' or @ref-type='table']">
    <a href="#{@rid}"><xsl:apply-templates/></a>
  </xsl:template>

</xsl:stylesheet>