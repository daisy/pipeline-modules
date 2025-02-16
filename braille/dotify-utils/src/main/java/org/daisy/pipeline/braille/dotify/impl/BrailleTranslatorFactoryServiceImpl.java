package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.Set;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import static com.google.common.collect.Iterables.concat;

import org.daisy.braille.css.PropertyValue;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.dotify.api.translator.AttributeWithContext;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.FollowingText;
import org.daisy.dotify.api.translator.PrecedingText;
import org.daisy.dotify.api.translator.ResolvableText;
import org.daisy.dotify.api.translator.TextAttribute;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslatableWithContext;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator.util.DefaultLineBreaker;
import org.daisy.pipeline.braille.common.BrailleTranslatorRegistry;
import org.daisy.pipeline.braille.common.Query;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.Query.util.QUERY;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.css.CSSStyledText;
import org.daisy.pipeline.braille.css.TextStyleParser;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl",
	service = { BrailleTranslatorFactoryService.class }
)
public class BrailleTranslatorFactoryServiceImpl implements BrailleTranslatorFactoryService {
	
	public void setCreatedWithSPI() {}
	
	@Reference(
		name = "BrailleTranslatorRegistry",
		unbind = "-",
		service = BrailleTranslatorRegistry.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindBrailleTranslatorRegistry(BrailleTranslatorRegistry registry) {
		translatorRegistry = registry;
		logger.debug("Binding BrailleTranslator registry: {}", registry);
	}
	
	private BrailleTranslatorRegistry translatorRegistry;
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			factory.newTranslator(locale, mode);
			return true; }
		catch (TranslatorConfigurationException e) {
			return false; }
	}
	
	public Collection<TranslatorSpecification> listSpecifications() {
		return ImmutableList.of();
	}
	
	public BrailleTranslatorFactory newFactory() {
		return factory;
	}
	
	private final BrailleTranslatorFactory factory = new BrailleTranslatorFactoryImpl();
	
	private class BrailleTranslatorFactoryImpl implements BrailleTranslatorFactory {
		public BrailleTranslator newTranslator(String locale, String mode) throws TranslatorConfigurationException {
			Matcher m = QUERY.matcher(mode);
			if (!m.matches())
				throw new TranslatorConfigurationException();
			Query query = query(mode);
			if (locale != null && !"und".equals(locale))
				query = mutableQuery(query).add("document-locale", locale);
			for (org.daisy.pipeline.braille.common.BrailleTranslator t : translatorRegistry.getWithHyphenator(query))
				try {
					return new BrailleTranslatorFromBrailleTranslator(mode, t.lineBreakingFromStyledText()); }
				catch (UnsupportedOperationException e) {}
			throw new TranslatorConfigurationException("Factory does not support " + locale + "/" + mode);
		}
	}
	
	public <T> void setReference(Class<T> c, T reference) throws TranslatorConfigurationException {}
	
	/**
	 * {@link BrailleTranslator} wrapper for a {@link org.daisy.pipeline.braille.common.BrailleTranslator}
	 *
	 * <a href="http://braillespecs.github.io/braille-css/#h3_white-space-processing">White space
	 * processing</a> and <a href="http://braillespecs.github.io/braille-css/#line-breaking">line
	 * breaking</a> are done according to braille CSS.
	 *
	 * White space is normalised. Preserved spaces must have been converted to
	 * no-break spaces and preserved line feeds must have been converted to
	 * &lt;obfl:br/&gt;.
	 *
	 * Through setHyphenating() the translator can be made to perform automatic hyphenation or
	 * not. Regardless of this setting, hyphenation characters (SHY and ZWSP) in the input are used
	 * in line breaking, except when overridden with a <code>hyphens: none</code> style.
	 */
	private static class BrailleTranslatorFromBrailleTranslator implements BrailleTranslator {
		
		final String mode;
		final org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText translator;
		
		private BrailleTranslatorFromBrailleTranslator(
				String mode,
				org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText translator) {
			this.mode = mode;
			this.translator = translator;
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			if (input.getAttributes() == null && input.isHyphenating() == false) {
				String text = input.getText();
				if ("".equals(text))
					// see org.daisy.dotify.formatter.impl.row.SegmentProcessor.layoutLeader
					return new DefaultLineBreaker.LineIterator("", '\u2800', '\u2824', 1);
				if (" ".equals(text))
					// If input text is a space, it may be used for calculating the margin character
					// (see org.daisy.dotify.formatter.impl.common.FormatterCoreContext)
					return new DefaultLineBreaker.LineIterator("\u2800", '\u2800', '\u2824', 1); }
			return translate(cssStyledTextFromTranslatable(input), 0, -1);
		}
		
		public BrailleTranslatorResult translate(TranslatableWithContext input) throws TranslationException {
			List<CSSStyledText> styledText = Lists.newArrayList(cssStyledTextFromTranslatable(input));
			int from = input.getPrecedingText().size();
			int to = from + input.getTextToTranslate().size();
			for (int i = 0; i < styledText.size(); i++)
				if ("??".equals(styledText.get(i).getText()))
					// If input text is "??", it will be used for creating a placeholder for content that
					// can not be computed yet (see org.daisy.dotify.formatter.impl.row.SegmentProcessor).
					// Because normally this will never end up in the resulting PEF, it is okay to replace
					// it with "0". We choose a number because in some cases the translator may assume that
					// the input is numerical.
					styledText.set(i, new CSSStyledText("0",
					                                    styledText.get(i).getStyle(),
					                                    styledText.get(i).getLanguage(),
					                                    styledText.get(i).getTextAttributes()));
			return translate(styledText, from, to);
		}
		
		private static final Set<String> obflStyleProperties = ImmutableSet.of(
			"text-transform",
			"braille-charset",
			"hyphens",
			"hyphenate-character",
			"white-space",
			"word-spacing",
			"letter-spacing",
			"-dotify-counter-style"
		);
		
		private BrailleTranslatorResult translate(Iterable<CSSStyledText> styledText, int from, int to) throws TranslationException {
			// Because of caching in cssParser, styledText might contain non-inline properties
			// (which should always have the initial value). Omit these properties from the argument
			// that is passed to translator.
			for (Iterator<CSSStyledText> i = styledText.iterator(); i.hasNext();) {
				SimpleInlineStyle s = i.next().getStyle();
				if (s != null)
					for (Iterator<PropertyValue> j = s.iterator(); j.hasNext();) {
						PropertyValue d = j.next();
						if ("braille-charset".equals(d.getProperty()))
							; // initial value of braille-charset depends on translator
						else if (equal(d, d.getDefault()))
							j.remove();
						else if (!obflStyleProperties.contains(d.getProperty()))
							throw new IllegalStateException("coding error");
					}
			}
			return translator.transform(styledText, from, to);
		}
		
		public String getTranslatorMode() {
			return mode;
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleTranslatorFactoryServiceImpl.class);

	/* ========= */
	/* UTILITIES */
	/* ========= */

	private static boolean equal(PropertyValue a, PropertyValue b) {
		if (a == null)
			return b == null;
		else if (b == null)
			return false;
		else {
			if (a.getCSSProperty() != b.getCSSProperty())
				return false;
			if (!a.toString().equals(b.toString()))
				return false;
		}
		return true;
	}

	/**
	 * Convert Translatable specification to text + CSS style. Text attributes are assumed to
	 * contain only CSS or special variable assignments/tests. Computation of the text-transform
	 * property is assumed to have been performed already.
	 */
	protected static Iterable<CSSStyledText> cssStyledTextFromTranslatable(Translatable specification) {
		String locale = specification.getLocale();
		return cssStyledTextFromTranslatable(
			specification.getText(),
			specification.getAttributes(),
			locale != null ? parseLocale(locale) : null,
			specification.isHyphenating(),
			null);
	}

	// FIXME: Ideally, this should be a parser based on SupportedOBFLProperties. Note that such a
	// parser is created by ObflStyleFunctionProvider (through StyleTransformerImpl), however we can
	// not get hold of that parser, and moreover in StyleTransformerImpl the assumption is made that
	// parseInlineStyle() will not be called on it.
	private final static TextStyleParser cssParser = TextStyleParser.getInstance();
	private final static SimpleInlineStyle HYPHENS_AUTO = cssParser.parse("hyphens: auto");

	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(String text,
	                                                                     TextAttribute attributes,
	                                                                     Locale language,
	                                                                     boolean hyphenating,
	                                                                     SimpleInlineStyle parentStyle) {
		if (attributes != null && attributes.getWidth() != text.length())
			throw new RuntimeException("Coding error");
		SimpleInlineStyle style = null; {
			String s = attributes != null ? attributes.getDictionaryIdentifier() : null;
			if (s != null || parentStyle != null)
				style = cssParser.parse(s != null ? s : "", parentStyle);
			if (hyphenating) {
				if (style == null)
					style = HYPHENS_AUTO;
				else if (style.getProperty("hyphens") == null)
					style = HYPHENS_AUTO.inheritFrom(style);
			}
		}
		if (attributes != null && attributes.hasChildren())
			return cssStyledTextFromTranslatable(text, attributes.iterator(), language, false, style);
		else
			return Collections.singleton(new CSSStyledText(text, style, language));
	}

	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(String text,
	                                                                     Iterator<TextAttribute> attributes,
	                                                                     Locale language,
	                                                                     boolean hyphenating,
	                                                                     SimpleInlineStyle parentStyle) {
		if (attributes.hasNext()) {
			TextAttribute a = attributes.next();
			int w = a.getWidth();
			return concat(cssStyledTextFromTranslatable(text.substring(0, w), a, language, hyphenating, parentStyle),
			              cssStyledTextFromTranslatable(text.substring(w), attributes, language, hyphenating, parentStyle)); }
		else
			return empty;
	}

	/**
	 * Convert TranslatableWithContext specification to text + CSS style. Text attributes are
	 * assumed to contain only CSS or special variable assignments/tests. Computation of the
	 * text-transform property is assumed to have been performed already.
	 */
	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(TranslatableWithContext specification) {
		return cssStyledTextFromTranslatable(
			specification.getPrecedingText(),
			specification.getTextToTranslate(),
			specification.getFollowingText(),
			specification.getAttributes().orElse(null),
				null);
	}

	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(List<PrecedingText> preceding,
	                                                                     List<ResolvableText> text,
	                                                                     List<FollowingText> following,
	                                                                     AttributeWithContext attributes,
	                                                                     SimpleInlineStyle parentStyle) {
		int textSize = text == null ? 0 : text.size();
		int precedingSize = preceding == null ? 0 : preceding.size();
		int followingSize = following == null ? 0 : following.size();
		if (attributes != null && attributes.getWidth() != precedingSize + textSize + followingSize)
			throw new RuntimeException("Coding error");
		SimpleInlineStyle style; {
			String s = attributes != null ? attributes.getName().orElse(null) : null;
			if (s != null || parentStyle != null)
				style = cssParser.parse(s != null ? s : "", parentStyle);
			else
				style = null;
		}
		if (attributes != null && attributes.hasChildren())
			return cssStyledTextFromTranslatable(preceding, text, following, attributes.iterator(), style);
		else
			return concat(cssStyledTextFromTranslatable(preceding, style),
			              cssStyledTextFromTranslatable(text, style),
			              cssStyledTextFromTranslatable(following, style));
	}

	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(List<PrecedingText> preceding,
	                                                                     List<ResolvableText> text,
	                                                                     List<FollowingText> following,
	                                                                     Iterator<AttributeWithContext> attributes,
	                                                                     SimpleInlineStyle parentStyle) {
		int textSize = text == null ? 0 : text.size();
		int precedingSize = preceding == null ? 0 : preceding.size();
		int followingSize = following == null ? 0 : following.size();
		if (attributes.hasNext()) {
			AttributeWithContext a = attributes.next();
			int w = a.getWidth();
			if (w == 0)
				return cssStyledTextFromTranslatable(preceding, text, following, attributes, parentStyle);
			if (w <= precedingSize)
				return concat(
					cssStyledTextFromTranslatable(preceding.subList(0, w), null, null, a, parentStyle),
					cssStyledTextFromTranslatable(preceding.subList(w, precedingSize), text, following, attributes, parentStyle));
			else if (w - precedingSize <= textSize)
				return concat(
					cssStyledTextFromTranslatable(preceding, text.subList(0, w - precedingSize), null, a, parentStyle),
					cssStyledTextFromTranslatable(null, text.subList(w - precedingSize, textSize), following, attributes, parentStyle));
			else
				return concat(
					cssStyledTextFromTranslatable(preceding, text, following.subList(0, w - precedingSize - textSize), a, parentStyle),
					cssStyledTextFromTranslatable(null, null, following.subList(w - precedingSize - textSize, followingSize), attributes, parentStyle));
		} else
			return empty;
	}

	private static Iterable<CSSStyledText> cssStyledTextFromTranslatable(List<? extends Object/*PrecedingText|FollowingText*/> precedingOrFollowingText,
	                                                                     SimpleInlineStyle parentStyle) {
		if (precedingOrFollowingText == null)
			return empty;
		List<CSSStyledText> styledText = new ArrayList<>();
		for (Object t : precedingOrFollowingText) {
			String text;
			String lang;
			boolean hyphenate; {
				if (t instanceof PrecedingText) {
					text = ((PrecedingText)t).resolve();
					lang = ((PrecedingText)t).getLocale().orElse(null);
					hyphenate = ((PrecedingText)t).shouldHyphenate(); }
				else if (t instanceof FollowingText) {
					text = ((FollowingText)t).peek();
					lang = ((FollowingText)t).getLocale().orElse(null);
					hyphenate = ((FollowingText)t).shouldHyphenate(); }
				else
					throw new RuntimeException();
			}
			Locale locale = lang != null ? parseLocale(lang) : null;
			SimpleInlineStyle style = null; {
				if (hyphenate && parentStyle == null)
					style = HYPHENS_AUTO;
				else if (hyphenate &&  parentStyle.getProperty("hyphens") == null)
					style = HYPHENS_AUTO.inheritFrom(parentStyle);
				else
					style = parentStyle;
			}
			styledText.add(new CSSStyledText(text, style, locale));
		}
		return styledText;
	}

	private static Iterable<CSSStyledText> empty = Optional.<CSSStyledText>absent().asSet();

}
