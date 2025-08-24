<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xlink">

  <!-- Tell the processor to generate HTML5-like output -->
  <xsl:output
    method="html"
    encoding="UTF-8"
    indent="yes"
    omit-xml-declaration="yes" />

  <!-- Strip ignorable whitespace to keep output clean -->
  <xsl:strip-space elements="*" />

  <!-- ===== Parameters ===== -->
  <xsl:param name="assets-path" select="'assets/'" />           <!-- CSS/JS relative folder -->
  <xsl:param name="pdf-href" select="''" />                 <!-- optional right-aside button -->
  <xsl:param name="debug" select="'no'" />               <!-- 'yes' = highlight unknown tags -->

  <!-- ===== Modules ===== -->
  <xsl:include href="modules/utils.xsl" />
  <xsl:include href="modules/inline.xsl" />
  <xsl:include href="modules/front.xsl" />
  <xsl:include href="modules/body.xsl" />
  <xsl:include href="modules/figures.xsl" />
  <xsl:include href="modules/refs.xsl" />
  <xsl:include href="modules/back.xsl" />
  <xsl:include href="modules/right-sidebar.xsl"/>
  <xsl:include href="modules/footer.xsl"/>

  <!-- ===== Root template → full HTML page ===== -->
  <xsl:template match="/">
    <xsl:variable name="title"
      select="normalize-space(/article/front/article-meta/title-group/article-title)" />

    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>
          <xsl:choose>
            <xsl:when test="$title!=''">
              <xsl:value-of select="$title" />
            </xsl:when>
            <xsl:otherwise>Article</xsl:otherwise>
          </xsl:choose>
        </title>

        <!-- CSS -->
        <link rel="stylesheet" href="{$assets-path}css/base.css" />
        <link rel="stylesheet" href="{$assets-path}css/layout.css" />
        <link rel="stylesheet" href="{$assets-path}css/components.css" />
      </head>

      <body>
        <a class="skip" href="#main">Skip to content</a>

        <!-- INSERT PUBLISHER HEADER HERE -->

        <!-- Main Container as CSS Grid -->
        <div class="main-container">

          <!-- Masthead/Header -->
          <xsl:apply-templates select="/article/front" mode="masthead" />

          <!-- TOC -->
          <xsl:apply-templates select="/article/body" mode="toc" />

          <!-- Full Article Content -->
          <main id="main">
            <xsl:apply-templates select="/article/front" mode="abstract" />
            <xsl:apply-templates select="/article/body" />
            <xsl:apply-templates select="/article/back" mode="appendix" />
            <xsl:apply-templates select="/article/back/ref-list" />
            <xsl:apply-templates select="/article/back/fn-group" />
          </main>

          <!-- Figures and Tables Content -->
          <!-- XXX -->

          <!-- Right Sidebar -->
          <aside class="right-sidebar" aria-label="Actions and metadata">
            <xsl:call-template name="right-sidebar"/>
          </aside>

        </div>

        <!-- JS (progressive enhancement) -->
        <script src="{$assets-path}js/enhance.js"></script>
        <script src="{$assets-path}js/toc.js" defer="defer"></script>
        <script src="{$assets-path}js/copydoi.js" defer="defer"></script>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>