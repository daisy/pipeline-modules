package org.daisy.pipeline.nlp.matchrules;

import org.daisy.pipeline.nlp.MatchRule;
import org.daisy.pipeline.nlp.TextCategorizer.Category;
import org.daisy.pipeline.nlp.TextCategorizer.MatchMode;

/**
 * Match ranges like "x-y" where x,y are integers such that x < y
 */
public class NumberRangeMatchRule extends MatchRule {

    public NumberRangeMatchRule(Category category, int priority,
            MatchMode matchMode) {
        super(category, priority, false, matchMode);
    }

    @Override
    protected String match(String input) {
        if (input.charAt(0) <= '0' || input.charAt(0) > '9')
            return null;
        int k = 1;
        for (; k < input.length() && input.charAt(k) >= '0'
                && input.charAt(k) <= '9'; ++k)
            ;
        if (k == input.length() || input.charAt(k) != '-')
            return null;
        int prevk = k++;
        if (k >= input.length() || input.charAt(k) <= '0'
                || input.charAt(k) > '9')
            return null;
        for (++k; k < input.length() && input.charAt(k) >= '0'
                && input.charAt(k) <= '9'; ++k)
            ;
        if (k == prevk + 2
                || Integer.valueOf(input.substring(0, prevk)) > Integer
                        .valueOf(input.substring(prevk + 1, k))
                || (mMatchMode == MatchMode.FULL_MATCH && k != input.length()))
            return null;

        return input.substring(0, k);
    }
}
