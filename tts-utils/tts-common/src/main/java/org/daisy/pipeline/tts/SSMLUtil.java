package org.daisy.pipeline.tts;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

public class SSMLUtil {
	private static void toStringNoPrefix(XdmNode ssml, StringBuilder sb) {
		if (ssml.getNodeKind() == XdmNodeKind.TEXT) {
			sb.append(ssml.getStringValue());
		} else if (ssml.getNodeKind() == XdmNodeKind.ELEMENT) {
			sb.append("<" + ssml.getNodeName().getLocalName());
			XdmSequenceIterator iter = ssml.axisIterator(Axis.ATTRIBUTE);
			while (iter.hasNext()) {
				sb.append(" ");
				XdmNode node = (XdmNode) iter.next();
				if (node.getNodeName().getLocalName().equals("lang"))
					sb.append(" xml:");
				sb.append(node.getNodeName().getLocalName() + "=\""
				        + node.getStringValue() + "\"");
			}
			sb.append(">");

			iter = ssml.axisIterator(Axis.CHILD);
			while (iter.hasNext()) {
				toStringNoPrefix((XdmNode) iter.next(), sb);
			}
			sb.append("</" + ssml.getNodeName().getLocalName() + ">");
		}
	}

	public static String toStringNoPrefix(XdmNode ssml) {
		StringBuilder sb = new StringBuilder();
		toStringNoPrefix(ssml, sb);
		return sb.toString();
	}
}
