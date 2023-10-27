package org.daisy.pipeline.braille.common;

import java.util.ArrayList;
import java.util.List;

import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import org.daisy.pipeline.braille.common.TransformProvider.util.Memoize;
import org.daisy.pipeline.braille.common.util.Strings;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;

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
		unmodifiable = false;
	}

	private BrailleTranslatorRegistry(TransformProvider<BrailleTranslator> dispatch,
	                                  BrailleTranslatorRegistry from) {
		super(from);
		this.providers = null;
		this.dispatch = dispatch;
		this.unmodifiable = true;
	}

	private final List<TransformProvider<BrailleTranslator>> providers;
	private final TransformProvider<BrailleTranslator> dispatch;
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
		return new BrailleTranslatorRegistry(dispatch.withContext(context), this);
	}

	@Override
	public String toString() {
		return "memoize(dispatch( " + Strings.join(providers, ", ") + " ))";
	}
}
