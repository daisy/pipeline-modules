package org.daisy.pipeline.braille.common;

import java.util.ArrayList;
import java.util.List;

import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import org.daisy.pipeline.braille.common.TransformProvider.util.Memoize;
import org.daisy.pipeline.braille.common.util.Strings;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;

@Component(
	name = "hyphenator-registry",
	service = { HyphenatorRegistry.class }
)
public class HyphenatorRegistry extends Memoize<Hyphenator> implements HyphenatorProvider<Hyphenator> {

	public HyphenatorRegistry() {
		super();
	}

	private final List<TransformProvider<Hyphenator>> providers = new ArrayList<>();
	private final TransformProvider<Hyphenator> dispatch = dispatch(providers);

	@Reference(
		name = "HyphenatorProvider",
		unbind = "-",
		service = HyphenatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	public void addProvider(HyphenatorProvider p) {
		providers.add(p);
	}

	public Iterable<Hyphenator> _get(Query q) {
		if (q.containsKey("document-locale")) {
			MutableQuery fallbackQuery = mutableQuery(q);
			fallbackQuery.removeAll("document-locale");
			fallbackQuery.addAll(FALLBACK_QUERY);
			return Iterables.concat(
				dispatch.get(q),
				dispatch.get(fallbackQuery));
		} else
			return dispatch.get(q);
	}

	private final static Query FALLBACK_QUERY = query("(document-locale:und)");

	public TransformProvider<Hyphenator> _withContext(Logger context) {
		return dispatch.withContext(context);
	}

	@Override
	public String toString() {
		return "memoize(dispatch( " + Strings.join(providers, ", ") + " ))";
	}
}
