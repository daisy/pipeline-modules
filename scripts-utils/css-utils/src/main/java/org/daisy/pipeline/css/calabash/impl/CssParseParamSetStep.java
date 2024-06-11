package org.daisy.pipeline.css.calabash.impl;

import java.util.Map;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import static com.xmlcalabash.core.XProcConstants.NS_XPROC_STEP;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.SaxonApiException;

import static org.daisy.common.stax.XMLStreamWriterHelper.writeAttribute;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeStartElement;
import org.daisy.common.xproc.calabash.XProcStep;
import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.common.xproc.calabash.XMLCalabashOptionValue;
import org.daisy.common.xproc.calabash.XMLCalabashOutputValue;
import org.daisy.common.xproc.XProcMonitor;
import org.daisy.pipeline.css.impl.StylesheetParametersParser;

import org.osgi.service.component.annotations.Component;

public class CssParseParamSetStep extends DefaultStep implements XProcStep {

	@Component(
		name = "px:css-parse-param-set",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/pipeline/xproc}css-parse-param-set" }
	)
	public static class Provider implements XProcStepProvider {
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step, XProcMonitor monitor, Map<String,String> properties) {
			return new CssParseParamSetStep(runtime, step);
		}
	}

	private WritablePipe result = null;
	private static final net.sf.saxon.s9api.QName _PARAMETERS = new net.sf.saxon.s9api.QName("parameters");

	private CssParseParamSetStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
	}

	@Override
	public void setOutput(String port, WritablePipe pipe) {
		result = pipe;
	}

	@Override
	public void reset() {
		result.resetWriter();
	}

	@Override
	public void run() throws SaxonApiException {
		try {
			marshall(
				StylesheetParametersParser.parse(
					new XMLCalabashOptionValue(getOption(_PARAMETERS)).toString()),
				new XMLCalabashOutputValue(result, runtime).asXMLStreamWriter());
		} catch (Throwable e) {
			throw XProcStep.raiseError(e, step);
		}
		super.run();
	}


	private static final QName C_PARAM_SET = new QName(NS_XPROC_STEP, "param-set", "c");
	private static final QName C_PARAM = new QName(NS_XPROC_STEP, "param", "c");
	private static final QName _NAME = new QName("name");
	private static final QName _NAMESPACE = new QName("namespace");
	private static final QName _VALUE = new QName("value");

	/**
	 * Convert map to c:param-set document
	 */
	private static void marshall(Map<String,Object> map, XMLStreamWriter writer) throws XMLStreamException {
		writeStartElement(writer, C_PARAM_SET);
		for (Map.Entry<String,Object> kv : map.entrySet()) {
			writeStartElement(writer, C_PARAM);
			writeAttribute(writer, _NAME, kv.getKey());
			writeAttribute(writer, _NAMESPACE, "");
			writeAttribute(writer, _VALUE, kv.getValue().toString());
			writer.writeEndElement();
		}
		writer.writeEndElement();
	}
}
