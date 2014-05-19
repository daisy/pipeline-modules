DAISY Pipeline 2 :: NLP Modules
===============================

[![Build Status](https://travis-ci.org/daisy/pipeline-mod-nlp.png?branch=master)](https://travis-ci.org/daisy/pipeline-mod-nlp)

NLP-related modules for the DAISY Pipeline 2

### XProc scripts

The NLP/TTS must always be called before any other transformation to make certain that the aural CSS stylesheets will be applied on the original documents.

Let us consider the transformation of a DTBook document. Such document will be processed in the following order:

- dtbook-break-detection (XProc) passes dtbook-specific lexing options to the generic module break-detection (XProc);
- break-detection starts by calling the Java-based break detection which adds dtbook-independent words and sentences to the document (Java);
- The words and sentences are moved, merged or discarded so as to be compliant with the DTBook grammar (XProc);
- The words and sentences are replaced with DTBook elements (XProc);
- The content is split around the skippable elements (e.g. pagenums) so that the SMIL files will be able to reference them individually (XProc);
- Some IDs are generated to make sure that we'll be able to reference the elements in the SMIL files (XProc);
- The enriched DTBook and the list of sentence IDs are returned to the main script, e.g. to dtbook-to-epub3 or dtbook-to-daisy3.

### Java-based break detection

##### Languages

At the first stage, the step retrieves all the languages that exist in the document. Then the LexRegistry provides to the step the best lexer for each language according to scores returned via the LexService interface. The LexRegistry also provides a fallback lexer that can handle situations where languages are unknown or not expected.

##### Resource allocation

The step doesn't directly use the LexServices. Instead, the LexRegistry returns LexerTokens that contain resources such as dictionaries and compiled regexps. By default, there is one single LexerToken for each pair of working LexService and pipeline job so as to prevent any multi-threading issues. But when the language resources are allocated for a token, the corresponding subclass of LexerToken can choose to share its resources with other LexerTokens if the underlying resources are thread-safe.

The LexerTokens must be explicitly unregistered at the end of the step to allow the GC to free the resources.

##### TextCategorizers

The textCategorizers of nlp-common are the main elements of the RuleBasedLexer. They try to match text streams against lists of prioritized rules made of regexps and dictionaries in order to both find the word boundaries and their category. Once the words have been found and labeled, it is easy for the RuleBasedLexer to detect the sentences (bottom-up approach).

TextCategorizers can be invoked from outside the usual NLP workflow to categorize words whose boundaries have been detected by the NLP step.

##### Current LexServices

- OmniLangLexer: based on Java's break iterators and a top-down approach. Works with any language (fallback lexer).
- LightLexer. Works with any language (fallback lexer). It doesn't detect the words and may mistakenly detect groups of sentences rather than single sentences.
- RuleBasedLexer: Works best for English and French. Should do OK with other Indo-European languages. Not suited for languages such as Japanese or Chinese. Cannot be used as a fallback lexer.

### Current Limitations

- Has only been tested with DTBook documents;
- The CSS inlining (in TTS modules) may be impacted by the partitioning of the content around the skippable elements;
- Even if there are dictionaries of abbreviations, lexers encounter difficulties segmenting strings such as 'I like the U.S. John too.' (two sentences) and 'I like the G.R.R. Martin's books' (one sentence)
- The NLP is not yet designed to allow word-level audio synchronization;
- Some authors forget to add white spaces when there are already inline elements (e.g. span) to separate the words. Depending on the context, the break-detection steps can parse the text as if there were implicit spaces, although not always solicited by the authors.
- Under certain circumstances, the break-detection step reorganizes the inline elements to keep the sentences where they should be (this lexing strategy is configurable though). This can have side effects on the CSS-based display and the meaning of the inline elements;
- The general workflow makes the assumption that any @id added in the first stages will be left
unchanged from the beginning to the end, i.e. the SMIL files generation.
- Existing word elements are never kept;
- Some of the existing sentence elements might be kept;
- Lexicons (in TTS modules) wouldn't work well with elements that cannot contain sentences, such as the 'a' elements in dtbook110.
