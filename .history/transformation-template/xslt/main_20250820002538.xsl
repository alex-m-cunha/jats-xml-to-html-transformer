<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">

  <!-- ===== Parameters ===== -->
  <xsl:param name="assets-path" select="'deps/'"/>           <!-- CSS/JS relative folder -->
  <xsl:param name="pdf-href"    select="''"/>                 <!-- optional right-aside button -->
  <xsl:param name="debug"       select="'no'"/>               <!-- 'yes' = highlight unknown tags -->

  <!-- ===== Modules ===== -->
  <xsl:include href="modules/utils.xsl"/>
  <xsl:include href="modules/inline.xsl"/>
  <xsl:include href="modules/front.xsl"/>
  <xsl:include href="modules/body.xsl"/>
  <xsl:include href="modules/figures.xsl"/>
  <xsl:include href="modules/refs.xsl"/>
  <xsl:include href="modules/back.xsl"/>

  <!-- ===== Root template → full HTML page ===== -->
  <xsl:template match="/">
    <xsl:variable name="title"
      select="normalize-space(/article/front/article-meta/title-group/article-title)"/>

    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>
          <xsl:choose>
            <xsl:when test="$title!=''"><xsl:value-of select="$title"/></xsl:when>
            <xsl:otherwise>Article</xsl:otherwise>
          </xsl:choose>
        </title>

        <!-- CSS -->
        <link rel="stylesheet" href="{$assets-path}css/base.css"/>
        <link rel="stylesheet" href="{$assets-path}css/layout.css"/>
        <link rel="stylesheet" href="{$assets-path}css/components.css"/>
        <link rel="stylesheet" href="{$assets-path}css/print.css" media="print"/>
      </head>

      <body>
        <a class="skip" href="#main">Skip to content</a>

        <!-- Masthead/Header -->
        <xsl:apply-templates select="/article/front" mode="masthead"/>

        <!-- 3-column shell -->
        <div class="shell">
          <!-- Left TOC -->
          <xsl:apply-templates select="/article/body" mode="toc"/>

          <!-- Main article -->
          <main id="main">
            <xsl:apply-templates select="/article/front" mode="abstract"/>
            <xsl:apply-templates select="/article/body"/>
            <xsl:apply-templates select="/article/back" mode="appendix"/>
            <xsl:apply-templates select="/article/back/ref-list"/>
            <xsl:apply-templates select="/article/back/fn-group"/>
          </main>

          <!-- Right actions/metadata -->
          <aside class="actions" aria-label="Actions and metadata">
            <xsl:call-template name="actions-panel"/>
          </aside>
        </div>

        <!-- Footer -->
        <footer class="site-footer">
          <xsl:apply-templates select="/article/front/journal-meta" mode="footer"/>
        </footer>

        <!-- JS (progressive enhancement) -->
        <script src="{$assets-path}js/enhance.js"></script>
        <script src="{$assets-path}js/toc.js" defer="defer"></script>
        <script src="{$assets-path}js/copydoi.js" defer="defer"></script>
      </body>
    </html>
  </xsl:template>

  <!-- Right column actions/metadata card(s) -->
  <xsl:template name="actions-panel">
    <xsl:if test="$pdf-href!=''">
      <section class="card">
        <a class="btn btn-primary" href="{$pdf-href}">Download PDF</a>
      </section>
    </xsl:if>

    <!-- DOI + other article IDs (header area) -->
    <xsl:apply-templates select="/article/front/article-meta" mode="id-panel"/>

    <!-- Keywords -->
    <xsl:if test="/article/front/article-meta/article-categories//subject
                  | /article/front/article-meta//kwd-group/kwd">
      <section class="card">
        <h3>Keywords</h3>
        <ul>
          <xsl:for-each select="/article/front/article-meta/article-categories//subject
                                | /article/front/article-meta//kwd-group/kwd">
            <li><xsl:value-of select="normalize-space(.)"/></li>
          </xsl:for-each>
        </ul>
      </section>
    </xsl:if>

    <!-- License / copyright -->
    <xsl:apply-templates select="/article/front/article-meta/permissions" mode="rights"/>
  </xsl:template>

</xsl:stylesheet>