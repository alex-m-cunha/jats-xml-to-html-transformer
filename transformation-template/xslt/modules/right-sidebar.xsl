<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xlink">

    <xsl:template name="right-sidebar">

        <!-- Download Article PDF Button -->
        <xsl:variable name="pdf-available"
            select="string-length(normalize-space($pdf-href)) &gt; 0"/>
        
        <div>
            <!-- download-button + availability modifier -->
            <xsl:attribute name="class">
                <xsl:text>download-button </xsl:text>
                <xsl:choose>
                    <xsl:when test="$pdf-available">pdf-available</xsl:when>
                    <xsl:otherwise>pdf-unavailable</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <a class="btn primary" target="_blank" rel="noopener"> 
                <!-- href: real URL or placeholder -->
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="$pdf-available">
                            <xsl:value-of select="$pdf-href"/>
                        </xsl:when>
                        <xsl:otherwise>#</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                
                <!-- a11y: make the link non-focusable/announced as disabled when no PDF -->
                <xsl:if test="not($pdf-available)">
                    <xsl:attribute name="aria-disabled">true</xsl:attribute>
                    <xsl:attribute name="tabindex">-1</xsl:attribute>
                </xsl:if>
                
                <img src="{$assets-path}img/download-icon.svg" alt=""/>
                <span>
                    <xsl:choose>
                        <xsl:when test="$pdf-available">Download PDF</xsl:when>
                        <xsl:otherwise>PDF Unavailable</xsl:otherwise>
                    </xsl:choose>
                </span>
            </a>
        </div>
        
        <section class="accordion-wrapper" aria-label="More Article Metadata">
        
            <!-- ============== KEYWORDS ============== -->
            <details class="accordion">
                <summary role="heading" aria-level="3">
                    <span>Keywords</span>
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
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
                    <span class="quote-icon-option">
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M7.20852 2.95557V5.97143C7.20852 9.7741 5.26191 12.3514 2.52174 13.0441L2.00261 11.6101C3.27148 10.9988 4.08696 9.18476 4.08696 7.71076H2L2 2.95557H7.20852ZM14 2.95557V5.97143C14 9.7741 12.0445 12.3521 9.30435 13.0441L8.7847 11.6101C10.0541 10.9988 10.8696 9.18476 10.8696 7.71076H8.79148V2.95557H14Z" fill="#43423E"/>
                        </svg>
                        <span>How to Cite</span>
                    </span>
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
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
                <button type="button" class="btn secondary" data-copy="#cite-text">
                    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <g clip-path="url(#clip0_197_1913)">
                            <path d="M11.6667 5.25H6.41667C5.77233 5.25 5.25 5.77233 5.25 6.41667V11.6667C5.25 12.311 5.77233 12.8333 6.41667 12.8333H11.6667C12.311 12.8333 12.8333 12.311 12.8333 11.6667V6.41667C12.8333 5.77233 12.311 5.25 11.6667 5.25Z" stroke="#6D6C69" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M2.91663 8.74984H2.33329C2.02387 8.74984 1.72713 8.62692 1.50833 8.40813C1.28954 8.18934 1.16663 7.89259 1.16663 7.58317V2.33317C1.16663 2.02375 1.28954 1.72701 1.50833 1.50821C1.72713 1.28942 2.02387 1.1665 2.33329 1.1665H7.58329C7.89271 1.1665 8.18946 1.28942 8.40825 1.50821C8.62704 1.72701 8.74996 2.02375 8.74996 2.33317V2.9165" stroke="#6D6C69" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                        </g>
                        <defs>
                            <clipPath id="clip0_197_1913">
                                <rect width="14" height="14" fill="white"/>
                            </clipPath>
                        </defs>
                    </svg>
                    <span>Copy to Clipboard</span>
                </button>
            </details>
    
            <!-- ============== COMPETING INTERESTS ============== -->
            <details class="accordion">
                <summary role="heading" aria-level="3">
                    <span>Competing Interests</span>
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
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
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
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
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
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
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </summary>
                <xsl:choose>
                    <xsl:when test="/article/back/ack/p">
                        <xsl:apply-templates select="/article/back/ack/p" />
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
                    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.5 3.75L6 8.25L10.5 3.75" stroke="#43423E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </summary>
    
                <p> Content on this website is licensed under a Creative Commons
                    Attribution-NonCommercial 4.0 International License <a
                        href="https://creativecommons.org/licenses/by-nc/4.0/" rel="noopener"
                        target="_blank">
                        CC BY-NC 4.0
                    </a> except where otherwise stated. </p>
    
                <p class="cc-by-nc-icon">
                    <img src="{$assets-path}img/cc-by-nc-4.0-black.svg" alt="Creative Commons BY-NC 4.0" />
                </p>
                
            </details>
        </section>
    </xsl:template>
</xsl:stylesheet>