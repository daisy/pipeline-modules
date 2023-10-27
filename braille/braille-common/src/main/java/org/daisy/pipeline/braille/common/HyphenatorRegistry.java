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
		super(true); // memoize (id:...) lookups only
		providers = new ArrayList<>();
		dispatch = dispatch(providers);
		unmodifiable = false;
	}

	private HyphenatorRegistry(TransformProvider<Hyphenator> dispatch, HyphenatorRegistry from) {
		super(from);
		this.providers = null;
		this.dispatch = dispatch;
		this.unmodifiable = true;
	}

	private final List<TransformProvider<Hyphenator>> providers;
	private final TransformProvider<Hyphenator> dispatch;
	private final boolean unmodifiable;

	@Reference(
		name = "HyphenatorProvider",
		unbind = "-",
		service = HyphenatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	/**
	 * @throws UnsupportedOperationException if this object is an unmodifiable view of another
	 * {@link BrailleTranslatorRegistry}.
	 */
	public void addProvider(HyphenatorProvider p) {
		if (unmodifiable)
			throw new UnsupportedOperationException("Unmodifiable");
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

	@Override
	public HyphenatorRegistry withContext(Logger context) {
		return (HyphenatorRegistry)super.withContext(context);
	}

	protected HyphenatorRegistry _withContext(Logger context) {
		return new HyphenatorRegistry(dispatch.withContext(context), this);
	}

	@Override
	public String toString() {
		return "memoize(dispatch( " + Strings.join(providers, ", ") + " ))";
	}
}
