package org.daisy.pipeline.braille.dotify.impl;

import java.util.NoSuchElementException;

import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.UnityBrailleTranslator;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;

import org.osgi.service.component.annotations.Component;

/**
 * {@link BrailleTranslatorProvider} of PreTranslatedBrailleTranslator.
 */
@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.PreTranslatedBrailleTranslatorProvider",
	service = {
		BrailleTranslatorProvider.class
	}
)
public class PreTranslatedBrailleTranslatorProvider extends AbstractTransformProvider<BrailleTranslator>
                                                    implements BrailleTranslatorProvider<BrailleTranslator>  {

	protected Iterable<BrailleTranslator> _get(Query query) {
		MutableQuery q = mutableQuery(query);
		boolean isPreTranslatedQuery = false; {
			for (Query.Feature f : q) {
				String key = f.getKey();
				String val = f.getValue().orElse(null);
				if ("input".equals(key)) {
					if ("braille".equals(val))
						isPreTranslatedQuery = true;
					else if (!"text-css".equals(val)) {
						isPreTranslatedQuery = false;
						break; }}
				else if ("output".equals(key)) {
					if (!"braille".equals(val)) {
						isPreTranslatedQuery = false;
						break; }}
				else if ("document-locale".equals(key) && val != null && !isPreTranslatedQuery) {
					try {
						if ("Brai".equals(parseLocale(val).getScript()))
							isPreTranslatedQuery = true; }
					catch (IllegalArgumentException e) {}}
				else {
					isPreTranslatedQuery = false;
					break; }}}
		if (isPreTranslatedQuery)
			return AbstractTransformProvider.util.Iterables.of(new UnityBrailleTranslator(null));
		return AbstractTransformProvider.util.Iterables.<BrailleTranslator>empty();
	}
}
