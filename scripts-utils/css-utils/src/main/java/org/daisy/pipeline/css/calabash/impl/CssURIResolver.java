package org.daisy.pipeline.css.calabash.impl;

import java.util.Map;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import org.daisy.common.file.URIs;
import org.daisy.pipeline.css.SassCompiler;

/**
 * URIResolver for CSS files.
 * Compiles SASS to CSS.
 * Throws a TransformerException if an error happens in the backing resolver, if the resource
 * can not be found, or if an error happens in the SASS compilation.
 */
class CssURIResolver implements URIResolver {

	private final URIResolver resolver;
	private final Map<String,String> sassVariables;
	private SassCompiler sassCompiler = null;

	CssURIResolver(URIResolver resolver, Map<String,String> sassVariables) {
		this.resolver = resolver;
		this.sassVariables = sassVariables;
	}

	@Override
	public Source resolve(String href, String base) throws TransformerException {
		Source resolved = resolver.resolve(href, base);
		if (resolved == null) {
			String systemId = URIs.resolve(base, href).toString();
			resolved = new Source() {
					public String getSystemId() { return systemId; }
					public void setSystemId(String systemId) { throw new UnsupportedOperationException(); }
				};
		}
		if (href.endsWith(".scss")) {
			if (sassCompiler == null) sassCompiler = new SassCompiler(resolver);
			try {
				resolved = new StreamSource(
					sassCompiler.compile(resolved, sassVariables),
					resolved.getSystemId()); }
			catch (Exception e) {
				throw new TransformerException(e); }
		}
		return resolved;
	}
}
