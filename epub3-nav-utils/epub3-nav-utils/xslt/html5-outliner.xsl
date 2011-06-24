<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head> </head>
            <body>
                <nav>
                    <h1>Table of contents</h1>
                    <ol>
                        <li>
                            <a href="chap1.xhtml">Chapter 1</a>
                            <ol>
                                <li>
                                    <a href="chap1.xhtml#sec-1.1">Chapter 1.1</a>
                                    <ol hidden="">
                                        <li>
                                            <a href="chap1.xhtml#sec-1.1.1">Section 1.1.1</a>
                                        </li>
                                        <li>
                                            <a href="chap1.xhtml#sec-1.1.2">Section 1.1.2</a>
                                        </li>
                                    </ol>
                                </li>
                                <li>
                                    <a href="chap1.xhtml#sec-1.2">Chapter 1.2</a>
                                </li>
                            </ol>
                        </li>
                        <li>
                            <a href="chap2.xhtml">Chapter 2</a>
                        </li>
                    </ol>
                </nav>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>