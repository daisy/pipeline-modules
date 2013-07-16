package org.daisy.pipeline.nlp.ruledcategorizers;

import java.io.IOException;

import org.daisy.pipeline.nlp.matchrules.RegexMatchRule;

public class RuledFrenchCategorizer extends RuledMultilangCategorizer {

    @Override
    public void init(MatchMode matchMode) throws IOException {
        super.init(matchMode);

        RegexMatchRule rsm = new RegexMatchRule(Category.COMMON,
                RuledMultilangCategorizer.COMMON_WORD_MAX_PRIORITY + 1, true,
                mMatchMode);
        rsm.init(CommonWordPattern + "'?");
        addRule(rsm);

        compile();
    }

}
