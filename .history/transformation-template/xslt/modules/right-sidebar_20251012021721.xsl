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
                    <svg width="80" height="24" viewBox="0 0 80 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <g clip-path="url(#clip0_197_2541)">
                            <path d="M11.9779 0C15.3345 0 18.1924 1.17187 20.5492 3.5145C21.6772 4.64287 22.5349 5.9325 23.1206 7.38225C23.706 8.83237 23.9996 10.3714 23.9996 12C23.9996 13.6429 23.7097 15.1822 23.1319 16.6174C22.5532 18.0529 21.6994 19.3211 20.5714 20.421C19.4002 21.5779 18.0716 22.464 16.5855 23.0782C15.1001 23.6925 13.5641 23.9996 11.9786 23.9996C10.3931 23.9996 8.87512 23.6966 7.425 23.0887C5.97525 22.482 4.67512 21.6034 3.525 20.4536C2.37487 19.3039 1.5 18.0071 0.9 16.5641C0.3 15.1211 0 13.6001 0 12C0 10.4141 0.303375 8.88937 0.9105 7.425C1.51762 5.96062 2.4 4.65 3.55687 3.49275C5.8425 1.16475 8.64937 0 11.9779 0ZM12.0214 2.1645C9.27862 2.1645 6.97125 3.12187 5.09962 5.03587C4.1565 5.99325 3.43162 7.068 2.92462 8.26087C2.41687 9.45375 2.16375 10.7002 2.16375 12.0004C2.16375 13.2862 2.41687 14.5256 2.92462 15.7177C3.432 16.9114 4.1565 17.9756 5.09962 18.9112C6.04237 19.8472 7.10625 20.5609 8.29275 21.0544C9.47812 21.5471 10.7212 21.7935 12.0214 21.7935C13.3069 21.7935 14.5526 21.5441 15.7612 21.0439C16.9684 20.5432 18.0566 19.8225 19.0286 18.8797C20.8999 17.0512 21.8351 14.7585 21.8351 12.0007C21.8351 10.6721 21.5921 9.41512 21.1065 8.22937C20.6216 7.04362 19.914 5.98687 18.9862 5.05762C17.0565 3.129 14.7356 2.1645 12.0214 2.1645ZM11.871 10.0076L10.2634 10.8435C10.0916 10.4869 9.88125 10.2364 9.6315 10.0935C9.38137 9.951 9.14925 9.87937 8.93475 9.87937C7.86375 9.87937 7.3275 10.5862 7.3275 12.0007C7.3275 12.6435 7.46325 13.1572 7.73437 13.5431C8.00587 13.929 8.406 14.1221 8.93475 14.1221C9.63487 14.1221 10.1276 13.779 10.4137 13.0935L11.892 13.8435C11.5777 14.4296 11.142 14.8901 10.5847 15.2257C10.0282 15.5617 9.41362 15.7294 8.742 15.7294C7.67062 15.7294 6.80587 15.4012 6.14887 14.7435C5.49187 14.0865 5.16337 13.1722 5.16337 12.0011C5.16337 10.8581 5.49562 9.95137 6.15975 9.27975C6.82387 8.6085 7.66312 8.2725 8.67787 8.2725C10.164 8.27175 11.2279 8.85037 11.871 10.0076ZM18.7924 10.0076L17.2065 10.8435C17.0351 10.4869 16.824 10.2364 16.5742 10.0935C16.3237 9.951 16.0841 9.87937 15.8565 9.87937C14.7851 9.87937 14.2489 10.5862 14.2489 12.0007C14.2489 12.6435 14.385 13.1572 14.6561 13.5431C14.9272 13.929 15.327 14.1221 15.8565 14.1221C16.5559 14.1221 17.049 13.779 17.3344 13.0935L18.8344 13.8435C18.5062 14.4296 18.063 14.8901 17.5065 15.2257C16.9492 15.5617 16.3421 15.7294 15.6851 15.7294C14.5991 15.7294 13.7317 15.4012 13.0822 14.7435C12.4312 14.0865 12.1065 13.1722 12.1065 12.0011C12.1065 10.8581 12.4384 9.95137 13.1032 9.27975C13.767 8.6085 14.6062 8.2725 15.6206 8.2725C17.1064 8.27175 18.1642 8.85037 18.7924 10.0076Z" fill="#43423E"/>
                        </g>
                        <g clip-path="url(#clip1_197_2541)">
                            <path d="M39.9786 0C43.3491 0 46.1924 1.15688 48.5069 3.47137C50.8349 5.80013 52 8.643 52 12C52 15.3716 50.8566 18.1785 48.5706 20.421C46.1421 22.8071 43.2782 24 39.9786 24C36.7353 24 33.9212 22.821 31.5359 20.4637C29.179 18.1065 28 15.2858 28 12C28 8.71463 29.179 5.87175 31.5359 3.47175C33.8504 1.15687 36.664 0 39.9786 0ZM40.0214 2.1645C37.2929 2.1645 34.9859 3.12187 33.1 5.03587C31.1425 7.03613 30.1641 9.35775 30.1641 12.0004C30.1641 14.6576 31.1354 16.9579 33.0779 18.8996C35.0208 20.8429 37.3349 21.8137 40.0206 21.8137C42.6918 21.8137 45.0209 20.8361 47.0065 18.8783C48.8924 17.064 49.8351 14.7712 49.8351 11.9996C49.8351 9.27112 48.8778 6.95025 46.9641 5.0355C45.0501 3.1215 42.7356 2.1645 40.0214 2.1645ZM43.2359 9.02137V13.9282H41.8649V19.7565H38.1359V13.9286H36.7649V9.02137C36.7649 8.80687 36.8399 8.625 36.9895 8.475C37.1399 8.32538 37.3221 8.25 37.5359 8.25H42.4649C42.6648 8.25 42.8436 8.325 43.0004 8.475C43.1567 8.625 43.2359 8.80725 43.2359 9.02137ZM38.3282 5.93587C38.3282 4.80788 38.8851 4.24312 40 4.24312C41.1149 4.24312 41.6714 4.80713 41.6714 5.93587C41.6714 7.05 41.1141 7.60725 40 7.60725C38.8859 7.60725 38.3282 7.05 38.3282 5.93587Z" fill="#43423E"/>
                        </g>
                        <g clip-path="url(#clip2_197_2541)">
                            <path d="M67.9783 0C71.3495 0 74.1924 1.15688 76.5069 3.471C78.8349 5.7855 80 8.62838 80 12C80 15.372 78.857 18.1785 76.5706 20.4217C74.1425 22.8075 71.2779 24 67.9783 24C64.721 24 61.907 22.8142 59.5359 20.4431C57.179 18.0855 56 15.2719 56 12C56 8.71425 57.179 5.87138 59.5359 3.47137C61.85 1.15725 64.664 0 67.9783 0ZM58.7 8.7645C58.343 9.75 58.1641 10.8289 58.1641 12.0004C58.1641 14.6576 59.1354 16.9579 61.0779 18.9004C63.035 20.8294 65.3495 21.7935 68.0206 21.7935C70.721 21.7935 73.049 20.8155 75.0069 18.8576C75.707 18.1864 76.2564 17.4862 76.6561 16.7569L72.1351 14.7428C71.9773 15.5002 71.5955 16.1179 70.9888 16.596C70.3805 17.0745 69.6631 17.3501 68.8348 17.421V19.2641H67.442V17.421C66.1134 17.4075 64.8988 16.929 63.7993 15.9859L65.4493 14.3145C66.2345 15.0428 67.1277 15.4069 68.1279 15.4069C68.5419 15.4069 68.8959 15.3146 69.1891 15.1283C69.4816 14.943 69.6286 14.6362 69.6286 14.2069C69.6286 13.9065 69.521 13.6639 69.3069 13.4783L68.15 12.9851L66.7359 12.342L64.8286 11.5061L58.7 8.7645ZM68.0214 2.14275C65.2929 2.14275 62.9859 3.10688 61.1 5.0355C60.6283 5.50725 60.1854 6.04275 59.7714 6.64313L64.3573 8.7C64.5571 8.0715 64.9355 7.56788 65.4931 7.1895C66.0496 6.81113 66.6999 6.60038 67.4431 6.55725V4.71413H68.8363V6.55725C69.9365 6.61462 70.9362 6.98588 71.8363 7.67138L70.2717 9.27863C69.5994 8.80725 68.9146 8.57175 68.2145 8.57175C67.8429 8.57175 67.511 8.64338 67.2185 8.78588C66.9256 8.92875 66.779 9.17175 66.779 9.5145C66.779 9.61462 66.8146 9.71438 66.8859 9.8145L68.4072 10.5008L69.4573 10.9721L71.3862 11.829L77.5351 14.5718C77.7358 13.7288 77.8355 12.8719 77.8355 12.0004C77.8355 9.243 76.8785 6.92175 74.9645 5.0355C73.0644 3.10688 70.7491 2.14275 68.0214 2.14275Z" fill="#43423E"/>
                        </g>
                        <defs>
                            <clipPath id="clip0_197_2541">
                                <rect width="24" height="24" fill="white"/>
                            </clipPath>
                            <clipPath id="clip1_197_2541">
                                <rect width="24" height="24" fill="white" transform="translate(28)"/>
                            </clipPath>
                            <clipPath id="clip2_197_2541">
                                <rect width="24" height="24" fill="white" transform="translate(56)"/>
                            </clipPath>
                        </defs>
                    </svg>
                    <img src="{$assets-path}img/cc-by-nc-4.0-black.svg" alt="Creative Commons BY-NC 4.0" />
                </p>
                
            </details>
        </section>
    </xsl:template>
</xsl:stylesheet>