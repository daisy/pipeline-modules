package org.daisy.pipeline.braille.common;

import java.net.URI;
import java.util.ArrayList;
import java.util.function.Supplier;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;

import org.daisy.braille.css.LanguageRange;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.logCreate;
import org.daisy.pipeline.braille.common.TransformProvider.util.Memoize;
import org.daisy.pipeline.braille.common.util.Strings;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "hyphenator-registry",
	service = { HyphenatorRegistry.class }
)
public class HyphenatorRegistry extends Memoize<Hyphenator> implements HyphenatorProvider<Hyphenator> {

	public HyphenatorRegistry() {
		super(true); // memoize (id:...) lookups only
		providers = new ArrayList<>();
		dispatch = dispatch(providers);
		context = logger;
		unmodifiable = false;
	}

	private HyphenatorRegistry(TransformProvider<Hyphenator> dispatch,
	                           HyphenatorRegistry from,
	                           Logger context) {
		super(from);
		this.providers = null;
		this.dispatch = dispatch;
		this.context = context;
		this.unmodifiable = true;
	}

	private final List<TransformProvider<Hyphenator>> providers;
	private final TransformProvider<Hyphenator> dispatch;
	private final Logger context;
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
		if (this.context == context)
			return this;
		return new HyphenatorRegistry(dispatch.withContext(context), this, context);
	}

	/**
	 * Select {@link Hyphenator}s based on a query and a CSS style sheet possibly containing
	 * {@code @hyphenation-resource} rules.
	 *
	 * Contrary to {@link #get(Query)}, this method is not memoized, and the returned objects may
	 * not be selectable based on their identifier.
	 *
	 * @param baseURI Base URI for resolving relative paths in CSS against.
	 */
	public Iterable<Hyphenator> get(Query query, String style, URI baseURI) {
		if (style != null) {
			Map<LanguageRange,Query> subQueries = HyphenationResourceParser.getHyphenatorQueries(style, baseURI, query);
			if (subQueries != null && !subQueries.isEmpty()) {
				Map<LanguageRange,Supplier<Hyphenator>> subHyphenators
					= Maps.transformValues(
						subQueries,
						q -> () -> HyphenatorRegistry.this.get(q).iterator().next());
				return Iterables.transform(
					get(query),
					t -> logCreate(new CompoundHyphenator(subHyphenators, t), context));
			}
		}
		return get(query);
	}

	@Override
	public String toString() {
		return "memoize(dispatch( " + Strings.join(providers, ", ") + " ))";
	}

	private static final Logger logger = LoggerFactory.getLogger(HyphenatorRegistry.class);
}
