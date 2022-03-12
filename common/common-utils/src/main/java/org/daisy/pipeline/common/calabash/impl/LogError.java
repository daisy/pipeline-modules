package org.daisy.pipeline.common.calabash.impl;

import java.util.Map;
import java.util.NoSuchElementException;
import javax.xml.namespace.QName;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import com.google.common.collect.ImmutableMap;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.library.Identity;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.SaxonApiException;

import org.daisy.common.transform.InputValue;
import org.daisy.common.transform.OutputValue;
import org.daisy.common.transform.TransformerException;
import org.daisy.common.transform.XMLInputValue;
import org.daisy.common.transform.XMLTransformer;
import org.daisy.common.xproc.calabash.XMLCalabashInputValue;
import org.daisy.common.xproc.calabash.XProcStep;
import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.common.xproc.XProcError;

import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "px:log-error",
	service = { XProcStepProvider.class },
	property = { "type:String={http://www.daisy.org/ns/pipeline/xproc}log-error" }
)
public class LogError implements XProcStepProvider {

	private static final Logger LOGGER = LoggerFactory.getLogger(LogError.class);
	private static final QName C_ERROR = new QName("http://www.w3.org/ns/xproc-step", "error");

	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new LogErrorStep(runtime, step);
	}

	public static class LogErrorStep extends Identity implements XProcStep {

		private static final net.sf.saxon.s9api.QName _severity = new net.sf.saxon.s9api.QName("severity");
		private ReadablePipe errorPipe = null;

		private LogErrorStep(XProcRuntime runtime, XAtomicStep step) {
			super(runtime, step);
		}

		@Override
		public void setInput(String port, ReadablePipe pipe) {
			if ("source".equals(port))
				super.setInput(port, pipe);
			else
				errorPipe = pipe;
		}

		@Override
		public void run() throws SaxonApiException {
			super.run();
			try {
				new ErrorReporter(getOption(_severity, "INFO"))
					.transform(
						ImmutableMap.of(new QName("source"), new XMLCalabashInputValue(errorPipe)),
						ImmutableMap.of())
					.run();
			} catch (Throwable e) {
				throw XProcStep.raiseError(e, step);
			}
		}

		private static class ErrorReporter implements XMLTransformer {

			private final String severity;

			ErrorReporter(String severity) {
				this.severity = severity;
			}

			private void log(String message) {
				if ("TRACE".equals(severity))
					LOGGER.trace(message);
				else if ("DEBUG".equals(severity))
					LOGGER.debug(message);
				else if ("INFO".equals(severity))
					LOGGER.info(message);
				else if ("WARN".equals(severity))
					LOGGER.warn(message);
				else if ("ERROR".equals(severity))
					LOGGER.error(message);
			}

			@Override
			public Runnable transform(Map<QName,InputValue<?>> input, Map<QName,OutputValue<?>> output) {
				QName _source = new QName("source");
				for (QName n : input.keySet())
					if (!n.equals(_source))
						throw new IllegalArgumentException("unexpected value on input port " + n);
				for (QName n : output.keySet())
					throw new IllegalArgumentException("unexpected value on output port " + n);
				InputValue<?> source = input.get(_source);
				if (source != null && !(source instanceof XMLInputValue))
					throw new IllegalArgumentException("input on 'source' port is not XML");
				return () -> report(((XMLInputValue<?>)source).ensureSingleItem().asXMLStreamReader());
			}

			private void report(XMLStreamReader reader) throws TransformerException {
				try {
					while (true)
						try {
							int event = reader.next();
							switch (event) {
							case START_ELEMENT:
								if (C_ERROR.equals(reader.getName())) {
									XProcError xprocError = XProcError.parse(reader);
									log(xprocError.getMessage() + " (Please see detailed log for more info.)");
									LOGGER.debug(xprocError.toString());
								}
								break;
							default:
							}
						} catch (NoSuchElementException e) {
							break;
						}
				} catch (XMLStreamException e) {
					throw new TransformerException(e);
				}
			}
		}
	}
}
