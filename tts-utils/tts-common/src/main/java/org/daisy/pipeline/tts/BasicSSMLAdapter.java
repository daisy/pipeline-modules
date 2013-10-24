package org.daisy.pipeline.tts;

import net.sf.saxon.s9api.QName;

public class BasicSSMLAdapter implements SSMLAdapter {
	@Override
	public String getHeader(String voiceName) {
		return "";
	}

	@Override
	public String getFooter() {
		return "";
	}

	@Override
	public QName adaptElement(QName element) {
		return element;
	}

	@Override
	public QName adaptAttributeName(QName element, QName attr, String value) {
		if (element.getLocalName().equals("s")
		        && !attr.getLocalName().equals("lang"))
			return null; //only xml:lang is allowed in the <s> markups
		return attr;
	}

	@Override
	public String adaptAttributeValue(QName element, QName attr, String value) {
		return value;
	}

}
