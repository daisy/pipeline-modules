package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.MoreObjects;
import com.google.common.base.MoreObjects.ToStringHelper;
import com.google.common.collect.ImmutableMap;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.runtime.XAtomicStep;

import org.daisy.common.file.URLs;
import org.daisy.common.transform.InputValue;
import org.daisy.common.transform.Mult;
import org.daisy.common.transform.SingleInSingleOutXMLTransformer;
import org.daisy.common.transform.XMLInputValue;
import org.daisy.common.transform.XMLOutputValue;
import org.daisy.common.xproc.calabash.XProcStep;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.daisy.dotify.api.table.Table;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import org.daisy.pipeline.braille.common.calabash.CxEvalBasedTransformer;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.TransformProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

/**
 * @see <a href="../../../../../../../../../doc/">User documentation</a>.
 */
public interface DotifyCSSStyledDocumentTransform {
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.impl.DotifyCSSStyledDocumentTransform.Provider",
		service = {
			TransformProvider.class
		}
	)
	public class Provider extends AbstractTransformProvider<Transform> {
		
		private URI href;
		
		@Activate
		protected void activate(final Map<?,?> properties) {
			href = URLs.asURI(URLs.getResourceFromJAR("xml/transform/dotify-transform.xpl", DotifyCSSStyledDocumentTransform.class));
		}
		
		private final static Iterable<Transform> empty = Iterables.<Transform>empty();
		
		protected Iterable<Transform> _get(Query query) {
			final MutableQuery q = mutableQuery(query);
			try {
				if ("css".equals(q.removeOnly("input").getValue().get())) {
					if (q.containsKey("formatter"))
						if (!"dotify".equals(q.removeOnly("formatter").getValue().get()))
							return empty;
					boolean braille = false;
					boolean pef = false;
					boolean obfl = false;
					for (Feature f : q.removeAll("output"))
						if ("pef".equals(f.getValue().get()))
							pef = true;
						else if ("obfl".equals(f.getValue().get()))
							obfl = true;
						else if ("braille".equals(f.getValue().get()))
							braille = true;
						else
							return empty;
					if ((pef && obfl) || !(pef || obfl))
						return empty;
					boolean forcePretranslation = false;
					if (q.containsKey("force-pre-translation")) {
						forcePretranslation = true;
						q.removeOnly("force-pre-translation");
					}
					final Query textTransformQuery = mutableQuery(q).add("input", "text-css").add("output", "braille");
					final boolean _obfl = obfl;
					if (logSelect(textTransformQuery, brailleTranslatorProvider).iterator().hasNext()) {
						
						// only pre-translate if an intermediary OBFL with braille content is requested
						if (obfl && braille || forcePretranslation) {
							final MutableQuery blockTransformQuery = mutableQuery(q).add("input", "css")
							                                                        .add("output", "css")
							                                                        .add("output", "braille");
							if (logSelect(blockTransformQuery, brailleTranslatorProvider).iterator().hasNext())
								return AbstractTransformProvider.util.Iterables.of(
									logCreate(new TransformImpl(_obfl, blockTransformQuery, textTransformQuery))); }
						else
							return AbstractTransformProvider.util.Iterables.of(
									logCreate(new TransformImpl(_obfl, null, textTransformQuery))); }}}
			catch (IllegalStateException e) {}
			return empty;
		}
		
		private class TransformImpl extends AbstractTransform implements XProcStepProvider {
			
			private final String output;
			private final Query blockTransformQuery;
			private final Query textTransformQuery;
			private final Query mode;
			private final Map<String,String> options;
			
			private TransformImpl(boolean obfl,
			                      Query blockTransformQuery,
			                      Query textTransformQuery) {
				String locale = "und";
				if (textTransformQuery.containsKey("document-locale")) {
					MutableQuery q = mutableQuery(textTransformQuery);
					locale = q.removeOnly("document-locale").getValue().get();
					mode = q;
				} else
					mode = textTransformQuery;
				this.output = obfl ? "obfl" : "pef";
				options = ImmutableMap.of(
					"output", this.output,
					"css-block-transform", blockTransformQuery != null ? blockTransformQuery.toString() : "",
					"document-locale", locale,
					"mode", mode.toString());
				this.blockTransformQuery = blockTransformQuery;
				this.textTransformQuery = textTransformQuery;
			}
			
			@Override
			public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
				return XProcStep.of(
					new SingleInSingleOutXMLTransformer() {
						public Runnable transform(XMLInputValue<?> source, XMLOutputValue<?> result, InputValue<?> params) {
							return () -> {
								Map<String,String> options = TransformImpl.this.options;
								InputValue<?> paramsCopy = params;
								// get value of preview-table parameter
								try {
									Mult<? extends InputValue<?>> m = params.mult(2); // multiply params input
									paramsCopy = m.get();
									Map map = m.get().asObject(Map.class);
									Object v = map.get(new QName("preview-table"));
									if (v != null)
										if (v instanceof InputValue) {
											m = ((InputValue<?>)v).mult(2); // multiply preview-table value
											map.put(new QName("preview-table"), m.get());
											try {
												v = m.get().asObject();
												if (v instanceof String) {
													try {
														Table previewTable = tableProvider.get(query((String)v)).iterator().next();
														// Check if the output charset of the braille translator can be
														// set to this table. If not, ignore preview-table.
														MutableQuery q = mutableQuery(textTransformQuery).add("braille-charset",
														                                                      previewTable.getIdentifier());
														if (logSelect(q, brailleTranslatorProvider).iterator().hasNext()) {
															q.removeAll("document-locale");
															options = new HashMap<>(); {
																options.putAll(TransformImpl.this.options);
																options.put("css-block-transform",
																            blockTransformQuery != null
																                ? mutableQuery(blockTransformQuery)
																                      .add("braille-charset", previewTable.getIdentifier())
																                      .toString()
																                : "");
																options.put("braille-charset", previewTable.getIdentifier());
															}
														}
													} catch (NoSuchElementException e) {
													}
												}
											} catch (UnsupportedOperationException e) {
											}
										}
								} catch (UnsupportedOperationException e) {
								}
								new CxEvalBasedTransformer(
									href,
									null,
									options
								).newStep(runtime, step).transform(
									ImmutableMap.of(
										new QName("source"), source,
										new QName("parameters"), paramsCopy),
									ImmutableMap.of(
										new QName("result"), result)
								).run();
							};
						}
					},
					runtime,
					step
				);
			}
			
			@Override
			public ToStringHelper toStringHelper() {
				return MoreObjects.toStringHelper("o.d.p.b.dotify.impl.DotifyCSSStyledDocumentTransform$Provider$TransformImpl")
					.add("output", output)
					.add("textTransform", textTransformQuery);
			}
		}
		
		@Reference(
			name = "BrailleTranslatorProvider",
			unbind = "unbindBrailleTranslatorProvider",
			service = BrailleTranslatorProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		@SuppressWarnings(
			"unchecked" // safe cast to BrailleTranslatorProvider<BrailleTranslator>
		)
		public void bindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
			brailleTranslatorProviders.add((BrailleTranslatorProvider<BrailleTranslator>)provider);
		}
		
		public void unbindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
			brailleTranslatorProviders.remove(provider);
			brailleTranslatorProvider.invalidateCache();
		}
	
		private List<BrailleTranslatorProvider<BrailleTranslator>> brailleTranslatorProviders
			= new ArrayList<BrailleTranslatorProvider<BrailleTranslator>>();
		private TransformProvider.util.MemoizingProvider<BrailleTranslator> brailleTranslatorProvider
			= TransformProvider.util.memoize(TransformProvider.util.dispatch(brailleTranslatorProviders));
		
		@Reference(
			name = "TableProvider",
			unbind = "removeTableProvider",
			service = TableProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void addTableProvider(TableProvider provider) {
			tableProviders.add(provider);
		}
		
		protected void removeTableProvider(TableProvider provider) {
			tableProviders.remove(provider);
			this.tableProvider.invalidateCache();
		}
		
		private List<TableProvider> tableProviders = new ArrayList<TableProvider>();
		private org.daisy.pipeline.braille.common.Provider.util.MemoizingProvider<Query,Table> tableProvider
			= org.daisy.pipeline.braille.common.Provider.util.memoize(
				org.daisy.pipeline.braille.common.Provider.util.dispatch(tableProviders));
		
		@Override
		public ToStringHelper toStringHelper() {
			return MoreObjects.toStringHelper(DotifyCSSStyledDocumentTransform.Provider.class.getName());
		}
	}
}
