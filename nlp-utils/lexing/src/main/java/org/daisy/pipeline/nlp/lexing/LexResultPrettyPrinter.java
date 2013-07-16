package org.daisy.pipeline.nlp.lexing;

import java.util.List;

import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.LexService.TextReference;

/**
 * Convert one Lexer's result to formatted text. Likely to be used for testing.
 */
public class LexResultPrettyPrinter {

    private String mWordSeparator = "/";

    void setWordSeperator(String wordSeparator) {
        mWordSeparator = wordSeparator;
    }

    public String convert(Object result, List<String> lexerInput) {
        StringBuilder sb = new StringBuilder();
        dispatch(result, sb, lexerInput);
        return sb.toString();
    }

    private void dispatch(Object v, StringBuilder sb, List<String> references) {
        if (v instanceof List) {
            visit((List<Sentence>) v, sb, references);
        } else if (v instanceof Sentence) {
            visit((Sentence) v, sb, references);
        } else if (v instanceof TextReference) {
            visit((TextReference) v, sb, references);
        }
    }

    private void visit(TextReference t, StringBuilder sb,
            List<String> references) {
        sb.append(t.properNoun ? mWordSeparator + mWordSeparator
                : mWordSeparator);
        if (t.firstSegment == t.lastSegment) {
            sb.append(references.get(t.firstSegment).substring(t.firstIndex,
                    t.lastIndex));
        } else {
            sb.append(references.get(t.firstSegment).substring(t.firstIndex));
            for (int i = t.firstSegment + 1; i < t.lastSegment; ++i) {
                sb.append(references.get(i));
            }
            sb.append(references.get(t.lastSegment).substring(0, t.lastIndex));
        }
    }

    private void visit(List<Sentence> sentences, StringBuilder sb,
            List<String> references) {
        for (Sentence s : sentences)
            dispatch(s, sb, references);
    }

    private void visit(Sentence s, StringBuilder sb, List<String> references) {
        sb.append("{");
        for (TextReference t : s.content)
            dispatch(t, sb, references);
        sb.append("}");
    }
}
