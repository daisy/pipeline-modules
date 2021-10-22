package org.daisy.pipeline.braille.dotify.impl;

import java.util.NoSuchElementException;

import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.UnityBrailleTranslator;

import org.osgi.service.component.annotations.Component;

/**
 * {@link BrailleTranslatorProvider} of PreTranslatedBrailleTranslator and NumberBrailleTranslator.
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
		q.removeAll("document-locale");
		boolean isPreTranslatedQuery = false; {
			for (Query.Feature f : q)
				if ("input".equals(f.getKey()) && "braille".equals(f.getValue().orElse(null)))
					isPreTranslatedQuery = true;
				else if (!("input".equals(f.getKey()) && "text-css".equals(f.getValue().orElse(null)) ||
				           "output".equals(f.getKey()) && "braille".equals(f.getValue().orElse(null)))) {
					isPreTranslatedQuery = false;
					break; }}
		if (isPreTranslatedQuery)
			return AbstractTransformProvider.util.Iterables.of(new UnityBrailleTranslator(null));
		try {
			for (Query.Feature f : q.removeAll("input"))
				if (!"text-css".equals(f.getValue().get()))
					throw new NoSuchElementException();
			for (Query.Feature f : q.removeAll("output"))
				if (!"braille".equals(f.getValue().get()))
					throw new NoSuchElementException();
			if (!q.isEmpty())
				throw new NoSuchElementException();
			return AbstractTransformProvider.util.Iterables.of(NumberBrailleTranslator.getInstance());
		} catch (NoSuchElementException e) {}
		return AbstractTransformProvider.util.Iterables.<BrailleTranslator>empty();
	}
}
