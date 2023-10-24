package org.daisy.pipeline.braille.common;

import java.net.URI;
import java.util.ArrayList;
import java.util.function.Supplier;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;

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
	name = "braille-translator-registry",
	service = { BrailleTranslatorRegistry.class }
)
public class BrailleTranslatorRegistry extends Memoize<BrailleTranslator>
                                       implements BrailleTranslatorProvider<BrailleTranslator> {

	public BrailleTranslatorRegistry() {
		super(true); // memoize (id:...) lookups only
		providers = new ArrayList<>();
		dispatch = dispatch(providers);
		context = logger;
		unmodifiable = false;
	}

	private BrailleTranslatorRegistry(TransformProvider<BrailleTranslator> dispatch,
	                                  BrailleTranslatorRegistry from,
	                                  Logger context) {
		super(from);
		this.providers = null;
		this.dispatch = dispatch;
		this.context = context;
		this.unmodifiable = true;
	}

	private final List<TransformProvider<BrailleTranslator>> providers;
	private final TransformProvider<BrailleTranslator> dispatch;
	private final Logger context;
	private final boolean unmodifiable;

	@Reference(
		name = "BrailleTranslatorProvider",
		unbind = "-",
		service = BrailleTranslatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	/**
	 * @throws UnsupportedOperationException if this object is an unmodifiable view of another
	 * {@link BrailleTranslatorRegistry}.
	 */
	public void addProvider(BrailleTranslatorProvider p) throws UnsupportedOperationException {
		if (unmodifiable)
			throw new UnsupportedOperationException("Unmodifiable");
		providers.add(p);
	}

	public Iterable<BrailleTranslator> _get(Query q) {
		return dispatch.get(q);
	}

	@Override
	public BrailleTranslatorRegistry withContext(Logger context) {
		return (BrailleTranslatorRegistry)super.withContext(context);
	}
	
	protected BrailleTranslatorRegistry _withContext(Logger context) {
		if (this.context == context)
			return this;
		return new BrailleTranslatorRegistry(dispatch.withContext(context), this, context);
	}

	/**
	 * Select {@link BrailleTranslator}s based on a query and a CSS style sheet possibly containing
	 * {@code @text-transform} rules.
	 *
	 * Contrary to {@link #get(Query)}, this method is not memoized, and the returned objects may
	 * not be selectable based on their identifier.
	 *
	 * @param baseURI Base URI for resolving relative paths in CSS against.
	 * @param forceMainTranslator if {@code true}, the translator defined in {@code query} is used
	 *                            even if a default translator has been defined in CSS.
	 */
	public Iterable<BrailleTranslator> get(Query query, String style, URI baseURI, boolean forceMainTranslator) {
		if (style != null) {
			Map<String,Query> subQueries = TextTransformParser.getBrailleTranslatorQueries(style, baseURI, query);
			if (subQueries != null && !subQueries.isEmpty()) {
				Query mainQuery = subQueries.remove("auto");
				if (mainQuery == null || forceMainTranslator)
					mainQuery = query;
				if (subQueries.isEmpty())
					return get(mainQuery);
				else {
					Map<String,Supplier<BrailleTranslator>> subTranslators
						= Maps.transformValues(
							subQueries,
							q -> () -> BrailleTranslatorRegistry.this.get(q).iterator().next());
					return Iterables.transform(
						get(mainQuery),
						t -> logCreate(new CompoundBrailleTranslator(t, subTranslators), context));
				}
			}
		}
		return get(query);
	}

	@Override
	public String toString() {
		return "memoize(dispatch( " + Strings.join(providers, ", ") + " ))";
	}

	private static final Logger logger = LoggerFactory.getLogger(BrailleTranslatorRegistry.class);
}
