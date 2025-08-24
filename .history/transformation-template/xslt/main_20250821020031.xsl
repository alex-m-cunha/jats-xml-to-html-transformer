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
    omit-xml-declaration="yes"/>

  <!-- Strip ignorable whitespace to keep output clean -->
  <xsl:strip-space elements="*"/>

  <!-- ===== Parameters ===== -->
  <xsl:param name="assets-path" select="'assets/'"/>           <!-- CSS/JS relative folder -->
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
      </head>

      <body>
        <a class="skip" href="#main">Skip to content</a>

        <!-- INSERT PUBLISHER HEADER HERE -->

        <!-- Main Container as CSS Grid -->
        <div class="main-container">

          <!-- Masthead/Header -->
          <xsl:apply-templates select="/article/front" mode="masthead"/>

          <!-- TOC -->
          <xsl:apply-templates select="/article/body" mode="toc"/>

          <!-- Full Article Content -->
          <main id="main">
            <xsl:apply-templates select="/article/front" mode="abstract"/>
            <xsl:apply-templates select="/article/body"/>
            <xsl:apply-templates select="/article/back" mode="appendix"/>
            <xsl:apply-templates select="/article/back/ref-list"/>
            <xsl:apply-templates select="/article/back/fn-group"/>
          </main>

          <!-- Figures and Tables Content -->

          <!-- Right column actions/metadata card(s) -->
          <xsl:template name="right-sidebar">

            <!-- Top button: Download PDF (only if provided) -->
          <xsl:if test="$pdf-href!=''">
            <div class="download-button">
              <a href="{$pdf-href}" download="" class="btn primary">
                <img src="{$assets-path}img/download-icon.svg" alt="" width="16" height="16"/>
                <span>Download PDF</span>
              </a>
            </div>
          </xsl:if>

            <!-- Keywords -->
            <xsl:variable name="kw"
              select="/article/front/article-meta/article-categories//subject
                      | /article/front/article-meta//kwd-group/kwd"/>
            <xsl:if test="$kw">
              <section class="card">
                <details>
                  <summary>Keywords</summary>
                  <ul class="kw-list">
                    <xsl:for-each select="$kw">
                      <li><xsl:value-of select="normalize-space(.)"/></li>
                    </xsl:for-each>
                  </ul>
                </details>
              </section>
            </xsl:if>

            <!-- Cite (simple inline citation; you can refine later) -->
            <section class="card">
              <details>
                <summary>&#8220;&#8221; Cite</summary>
                <p class="cite-line">
                  <!-- Authors: Surname, G.; Surname, G. -->
                  <xsl:for-each select="/article/front/article-meta/contrib-group/contrib[@contrib-type='author']">
                    <xsl:value-of select="normalize-space(name/surname)"/>
                    <xsl:if test="normalize-space(name/given-names)!=''">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="substring(normalize-space(name/given-names),1,1)"/>
                      <xsl:text>.</xsl:text>
                    </xsl:if>
                    <xsl:choose>
                      <xsl:when test="position()!=last()"><xsl:text>; </xsl:text></xsl:when>
                      <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>

                  <!-- Year -->
                  <xsl:variable name="y" select="/article/front/article-meta/pub-date[@pub-type='epub']/year
                                                | /article/front/article-meta/pub-date/year"/>
                  <xsl:if test="$y">(<xsl:value-of select="normalize-space($y[1])"/>) </xsl:if>

                  <!-- Title -->
                  <xsl:value-of select="normalize-space(/article/front/article-meta/title-group/article-title)"/>
                  <xsl:text>. </xsl:text>

                  <!-- Journal (if present) -->
                  <xsl:if test="/article/front/journal-meta/journal-title-group/journal-title">
                    <em><xsl:value-of select="normalize-space(/article/front/journal-meta/journal-title-group/journal-title)"/></em>
                    <xsl:text>. </xsl:text>
                  </xsl:if>

                  <!-- DOI -->
                  <xsl:if test="/article/front/article-meta/article-id[@pub-id-type='doi']">
                    <a href="https://doi.org/{normalize-space(/article/front/article-meta/article-id[@pub-id-type='doi'])}">
                      https://doi.org/<xsl:value-of select="normalize-space(/article/front/article-meta/article-id[@pub-id-type='doi'])"/>
                    </a>
                  </xsl:if>
                </p>
                <!-- Optional copy button your JS can hook -->
                <button type="button" class="btn btn-secondary" data-copy="#cite-text" hidden="hidden">Copy</button>
              </details>
            </section>

            <!-- Competing Interests -->
            <xsl:if test="/article/front/article-meta/author-notes//fn[@fn-type='conflict'] or /article/front/article-meta/notes">
              <section class="card">
                <details>
                  <summary>Competing Interests</summary>
                  <xsl:for-each select="/article/front/article-meta/author-notes//fn[@fn-type='conflict']">
                    <p><xsl:apply-templates/></p>
                  </xsl:for-each>
                  <xsl:for-each select="/article/front/article-meta/notes[@notes-type='conflict' or contains(translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'conflict')]">
                    <p><xsl:apply-templates/></p>
                  </xsl:for-each>
                </details>
              </section>
            </xsl:if>

            <!-- Funding Source -->
            <xsl:if test="/article/front/article-meta/funding-group">
              <section class="card">
                <details>
                  <summary>Funding Source</summary>
                  <xsl:for-each select="/article/front/article-meta/funding-group/award-group">
                    <p>
                      <xsl:apply-templates/>
                    </p>
                  </xsl:for-each>
                  <!-- fallback free text -->
                  <xsl:for-each select="/article/front/article-meta/funding-group/..//funding-statement|/article/front/article-meta/funding-group/funding-statement">
                    <p><xsl:apply-templates/></p>
                  </xsl:for-each>
                </details>
              </section>
            </xsl:if>

            <!-- Data Availability -->
            <xsl:if test="/article/front/article-meta/notes[@notes-type='data-availability'] 
                          | /article/back/sec[@sec-type='data-availability']">
              <section class="card">
                <details>
                  <summary>Data Availability</summary>
                  <xsl:for-each select="/article/front/article-meta/notes[@notes-type='data-availability'] | /article/back/sec[@sec-type='data-availability']">
                    <xsl:apply-templates/>
                  </xsl:for-each>
                </details>
              </section>
            </xsl:if>

            <!-- Acknowledgements (usually in back/ack) -->
            <xsl:if test="/article/back/ack">
              <section class="card">
                <details>
                  <summary>Acknowledgements</summary>
                  <xsl:apply-templates select="/article/back/ack/node()"/>
                </details>
              </section>
            </xsl:if>

            <!-- Copyright & License -->
            <xsl:if test="/article/front/article-meta/permissions">
              <section class="card">
                <details>
                  <summary>Copyright &amp; License</summary>
                  <!-- Reuse your existing rights template -->
                  <xsl:apply-templates select="/article/front/article-meta/permissions" mode="rights"/>
                </details>
              </section>
            </xsl:if>
          </xsl:template>
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

</xsl:stylesheet>