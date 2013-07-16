package org.daisy.pipeline.nlp.matchrules;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

import org.daisy.pipeline.nlp.FullMatchStringFinder;
import org.daisy.pipeline.nlp.IStringFinder;
import org.daisy.pipeline.nlp.MatchRule;
import org.daisy.pipeline.nlp.PrefixMatchStringFinder;
import org.daisy.pipeline.nlp.TextCategorizer.Category;
import org.daisy.pipeline.nlp.TextCategorizer.MatchMode;

/**
 * Match the input strings with a list of strings.
 */
public class WordListMatchRule extends MatchRule {
    private boolean mCapitalSensitive;
    private IStringFinder mStringFinder;

    public WordListMatchRule(Category category, int priority,
            boolean caseSensitive, MatchMode matchMode, boolean capitalSensitive) {
        super(category, priority, caseSensitive, matchMode);
        mCapitalSensitive = capitalSensitive;
        switch (matchMode) {
        case FULL_MATCH:
            mStringFinder = new FullMatchStringFinder();
        default:
            mStringFinder = new PrefixMatchStringFinder();
        }
    }

    public void init(Collection<String> prefixes) {
        Collection<String> tocompile;
        if (mCaseSensitive) {
            if (!mCapitalSensitive) {
                tocompile = new ArrayList<String>();
                tocompile.addAll(prefixes);
                for (String prefix : prefixes) {
                    tocompile.add(Character.toString(Character
                            .toUpperCase(prefix.charAt(0)))
                            + prefix.substring(1));
                }
            } else
                tocompile = prefixes;
        } else {
            String[] lowerCasePrefixes = new String[prefixes.size()];
            int k = 0;
            for (String prefix : prefixes) {
                lowerCasePrefixes[k++] = prefix.toLowerCase();
            }
            tocompile = Arrays.asList(lowerCasePrefixes);
        }
        mStringFinder.compile(tocompile);
    }

    @Override
    protected String match(String input) {
        return mStringFinder.find(input);
    }

}
