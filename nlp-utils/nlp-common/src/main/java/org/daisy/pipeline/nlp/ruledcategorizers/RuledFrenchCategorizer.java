package org.daisy.pipeline.nlp.ruledcategorizers;

import java.io.IOException;
import java.util.Locale;

import org.daisy.pipeline.nlp.ResourceUtils;
import org.daisy.pipeline.nlp.matchrules.AbbrMatchRule;
import org.daisy.pipeline.nlp.matchrules.CompactAbbrMatchRule;
import org.daisy.pipeline.nlp.matchrules.RegexMatchRule;

public class RuledFrenchCategorizer extends RuledMultilangCategorizer {

	@Override
	public void init(MatchMode matchMode) throws IOException {
		super.init(matchMode);

		RegexMatchRule rsm = new RegexMatchRule(Category.COMMON,
		        RuledMultilangCategorizer.COMMON_WORD_MAX_PRIORITY + 1, true, mMatchMode);
		rsm.init(CommonWordPattern + "'?");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.TIME, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init("(2[0-4]|[01][0-9])[ ]?h[ ]?[0-6][0-9](?![0-9])");
		addRule(rsm);

		//// *** common abbreviations that should not end sentences ****
		final String dictFolder = "dictionaries";
		AbbrMatchRule amr = new AbbrMatchRule(Category.ABBREVIATION, DICTIONARY_MAX_PRIORITY,
		        true, mMatchMode, false, Locale.FRANCE);
		amr.init(ResourceUtils.readLines(dictFolder, "dot_abbr_fr.txt"));
		addRule(amr);

		CompactAbbrMatchRule cmr = new CompactAbbrMatchRule(Category.ABBREVIATION,
		        DICTIONARY_MAX_PRIORITY, true, mMatchMode, false, Locale.FRANCE);
		cmr.init(ResourceUtils.readLines(dictFolder, "compact_abbr_fr.txt"));
		addRule(cmr);

		compile();
	}

}
