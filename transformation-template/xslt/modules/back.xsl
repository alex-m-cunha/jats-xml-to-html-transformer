<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Appendix -->
  <xsl:template match="back" mode="appendix">
    <xsl:if test="app | app-group/app | sec[@sec-type='appendix']">
      <section id="appendix">
        <h2>Appendix</h2>
        <xsl:apply-templates select="app | app-group/app | sec[@sec-type='appendix']"/>
      </section>
    </xsl:if>
  </xsl:template>
  
  <!-- Global footnotes -->
  <xsl:template match="fn-group">
    <section id="footnotes" aria-labelledby="fn-h">
      <h2 id="fn-h">Footnotes</h2>
      <ol class="footnotes">
        <xsl:for-each select="fn">
          <li id="{@id}" role="doc-footnote">
            <xsl:apply-templates/>
            <a class="fn-back" href="#main" aria-label="Back to content">↩</a>
          </li>
        </xsl:for-each>
      </ol>
    </section>
  </xsl:template>
  
  <!-- Tables -->
  <xsl:template match="table-wrap">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <section id="{$id}" class="table-wrap">
      <xsl:if test="label or caption/title">
        <h3><xsl:value-of select="(label | caption/title)[1]"/></h3>
      </xsl:if>
      <xsl:apply-templates select="caption/p"/>
      <div class="table-scroller">
        <xsl:apply-templates select="table"/>
      </div>
      <xsl:apply-templates select="table-wrap-foot"/>
    </section>
  </xsl:template>
  
  <!-- Table footnotes -->
  <xsl:template match="table-wrap-foot">
    <ol class="table-footnotes">
      <xsl:for-each select="fn">
        <li id="{@id}"><xsl:apply-templates/></li>
      </xsl:for-each>
    </ol>
  </xsl:template>
  
  <!-- Copy tables through -->
  <xsl:template match="table"><table><xsl:apply-templates select="@*|node()"/></table></xsl:template>
  <xsl:template match="@*|node()"><xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy></xsl:template>
  
</xsl:stylesheet>