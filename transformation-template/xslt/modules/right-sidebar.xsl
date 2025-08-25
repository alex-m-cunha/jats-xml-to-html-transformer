<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xlink">

    <xsl:template name="right-sidebar">

        <!-- Download Article PDF Button -->
        <xsl:if test="$pdf-href!=''">
            <div class="download-button">
                <a href="{$pdf-href}" download="" class="btn primary">
                    <img src="{$assets-path}img/download-icon.svg" alt="" width="16" height="16" />
                    <span>Download PDF</span>
                </a>
            </div>
        </xsl:if>

        <!-- ============== KEYWORDS ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <span>Keywords</span>
            </summary>
            <xsl:variable name="kw"
                select="/article/front/article-meta/article-categories//subject
                        | /article/front/article-meta//kwd-group/kwd" />
            <xsl:choose>
                <xsl:when test="$kw">
                    <ul class="kw-list">
                        <xsl:for-each select="$kw">
                            <li>
                                <xsl:value-of select="normalize-space(.)" />
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <p>No keywords provided.</p>
                </xsl:otherwise>
            </xsl:choose>
        </details>

        <!-- ============== HOW TO CITE (preformatted) ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <!-- quotes icon -->
                <img src="{$assets-path}img/quotes-icon.svg" alt="" aria-hidden="true" class="article-viewer-icons" />
                <span>Cite</span>
            </summary>

            <!-- Assume publishers provide a fully formatted citation string here: -->
            <!--
            /article/front/article-meta/custom-meta-group/custom-meta[meta-name='citation']/meta-value -->
            <xsl:variable name="cite"
                select="/article/front/article-meta/custom-meta-group/custom-meta[meta-name='citation']/meta-value" />

            <p id="cite-text">
                <xsl:choose>
                    <xsl:when test="$cite">
                        <xsl:value-of select="normalize-space($cite)" />
                    </xsl:when>
                    <xsl:otherwise>Full citation not provided.</xsl:otherwise>
                </xsl:choose>
            </p>

            <!-- Button you’ll wire up in JS -->
            <button type="button" class="btn secondary" data-copy="#cite-text">Copy to clipboard</button>
        </details>

        <!-- ============== COMPETING INTERESTS ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <!-- shield icon -->
                <span>Competing Interests</span>
            </summary>
            <xsl:variable name="conflicts"
                select="/article/front/article-meta/author-notes//fn[@fn-type='conflict']
                        | /article/front/article-meta/notes[@notes-type='conflict' or contains(translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'conflict')]" />
            <xsl:choose>
                <xsl:when test="$conflicts">
                    <xsl:for-each select="$conflicts">
                        <p>
                            <xsl:apply-templates />
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>None declared.</p>
                </xsl:otherwise>
            </xsl:choose>
        </details>

        <!-- ============== FUNDING SOURCE ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <span>Funding Source</span>
            </summary>
            <xsl:variable name="awards"
                select="/article/front/article-meta/funding-group/award-group" />
            <xsl:variable name="statement"
                select="/article/front/article-meta/funding-group/..//funding-statement
                        | /article/front/article-meta/funding-group/funding-statement" />
            <xsl:choose>
                <xsl:when test="$awards">
                    <xsl:for-each select="$awards">
                        <p>
                            <xsl:apply-templates />
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$statement">
                    <xsl:for-each select="$statement">
                        <p>
                            <xsl:apply-templates />
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>None declared.</p>
                </xsl:otherwise>
            </xsl:choose>
        </details>

        <!-- ============== DATA AVAILABILITY ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <span>Data Availability</span>
            </summary>
            <xsl:variable name="data"
                select="/article/front/article-meta/notes[@notes-type='data-availability']
                        | /article/back/sec[@sec-type='data-availability']" />
            <xsl:choose>
                <xsl:when test="$data">
                    <xsl:for-each select="$data">
                        <p>
                            <xsl:apply-templates />
                        </p>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <p>None declared.</p>
                </xsl:otherwise>
            </xsl:choose>
        </details>

        <!-- ============== ACKNOWLEDGEMENTS ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <span>Acknowledgements</span>
            </summary>
            <xsl:choose>
                <xsl:when test="/article/back/ack">
                    <xsl:apply-templates select="/article/back/ack/node()" />
                </xsl:when>
                <xsl:otherwise>
                    <p>None declared.</p>
                </xsl:otherwise>
            </xsl:choose>
        </details>

        <!-- ============== COPYRIGHT & LICENSE (static) ============== -->
        <details class="accordion">
            <summary role="heading" aria-level="3">
                <span>Copyright &amp; License</span>
            </summary>

            <p> Content on this website is licensed under a Creative Commons
                Attribution-NonCommercial 4.0 International License <a
                    href="https://creativecommons.org/licenses/by-nc/4.0/" rel="noopener"
                    target="_blank">
                    CC BY-NC 4.0
                </a> except where otherwise stated. </p>

            <p class="cc-by-nc-icon">
                <img src="{$assets-path}img/cc-by-nc-4.0.svg" alt="Creative Commons BY-NC 4.0" />
            </p>
            
        </details>
    </xsl:template>
</xsl:stylesheet>