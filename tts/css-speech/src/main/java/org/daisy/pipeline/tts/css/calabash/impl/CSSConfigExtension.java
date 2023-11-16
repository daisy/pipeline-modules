package org.daisy.pipeline.tts.css.calabash.impl;

import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.file.URLs;
import org.daisy.pipeline.tts.config.ConfigReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CSSConfigExtension implements ConfigReader.Extension {

	private final static Logger logger = LoggerFactory.getLogger(CSSConfigExtension.class);

	private final Collection<URI> cssURIs = new ArrayList<>();
	private final Collection<String> embeddedCSS = new ArrayList<>();

	@Override
	public boolean parseNode(XdmNode node, URI documentURI, ConfigReader parent) {
		String name = node.getNodeName().getLocalName();
		if ("css".equalsIgnoreCase(name)) {
			String href = node.getAttributeValue(new QName(null, "href"));
			if (href != null) {
				try {
					URI uri = URLs.resolve(documentURI, URLs.asURI(href));
					if (uri != null)
						cssURIs.add(uri);
				} catch (Throwable e) {
				}
			} else {
				String content = node.getStringValue();
				if (content != null && !content.isEmpty()) {
					embeddedCSS.add(content);
				}
			}
			return true;
		}
		return false;
	}

	public Collection<URI> getCSSstylesheetURIs() {
		return cssURIs;
	}

	public Collection<String> getEmbeddedCSS() {
		return embeddedCSS;
	}
}
