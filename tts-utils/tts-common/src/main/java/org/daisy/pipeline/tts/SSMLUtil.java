package org.daisy.pipeline.tts;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

public class SSMLUtil {
	private static void toString(XdmNode ssml, StringBuilder sb,
	        SSMLAdapter adapter) {
		if (ssml.getNodeKind() == XdmNodeKind.TEXT) {
			sb.append(ssml.getStringValue());
		} else if (ssml.getNodeKind() == XdmNodeKind.ELEMENT) {
			QName elementName = adapter.adaptElement(ssml.getNodeName());
			if (elementName != null) {
				sb.append("<" + elementName.toString());
				XdmSequenceIterator iter = ssml.axisIterator(Axis.ATTRIBUTE);
				while (iter.hasNext()) {
					sb.append(" ");
					XdmNode node = (XdmNode) iter.next();
					QName attrName = adapter.adaptAttributeName(
					        ssml.getNodeName(), node.getNodeName(),
					        node.getStringValue());
					if (attrName != null)
						sb.append(attrName.toString()
						        + "=\""
						        + adapter.adaptAttributeValue(
						                ssml.getNodeName(), node.getNodeName(),
						                node.getStringValue()) + "\"");
				}
				sb.append(">");
			}

			XdmSequenceIterator iter = ssml.axisIterator(Axis.CHILD);
			while (iter.hasNext()) {
				toString((XdmNode) iter.next(), sb, adapter);
			}

			if (elementName != null) {
				sb.append("</" + elementName.toString() + ">");
			}
		}
	}

	public static String toString(XdmNode ssml, SSMLAdapter adapter) {
		if (adapter == null)
			adapter = new BasicSSMLAdapter();
		StringBuilder sb = new StringBuilder();
		sb.append(adapter.getHeader());
		toString(ssml, sb, adapter);
		sb.append(adapter.getFooter());
		return sb.toString();
	}
}
