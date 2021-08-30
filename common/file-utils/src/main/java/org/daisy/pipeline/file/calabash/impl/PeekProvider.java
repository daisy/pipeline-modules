package org.daisy.pipeline.file.calabash.impl;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URI;

import net.sf.saxon.om.AttributeMap;
import net.sf.saxon.om.EmptyAttributeMap;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;

import org.daisy.common.xproc.calabash.XProcStep;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.Base64;
import com.xmlcalabash.util.TreeWriter;
import com.xmlcalabash.util.TypeUtils;

import org.osgi.service.component.annotations.Component;

@Component(
	name = "pxi:file-peek",
	service = { XProcStepProvider.class },
	property = { "type:String={http://www.daisy.org/ns/pipeline/xproc/internal}file-peek" }
)
public class PeekProvider implements XProcStepProvider {

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new Peek(runtime, step);
	}

	/**
	 * Returns a base64-encoded string, skipping the first `offset` bytes, up to a number of `length` bytes, from the file `href`.
	 */
	public static class Peek extends DefaultStep implements XProcStep {
		private static final QName _href = new QName("href");
		private static final QName _offset = new QName("offset");
		private static final QName _length = new QName("length");

		private WritablePipe result = null;

		public Peek(XProcRuntime runtime, XAtomicStep step) {
			super(runtime,step);
		}

		public void setOutput(String port, WritablePipe pipe) {
			result = pipe;
		}

		public void reset() {
			result.resetWriter();
		}

		public void run() throws SaxonApiException {
			super.run();

			int offset = getOption(_offset, 0);
			int length = getOption(_length, 0);

			RuntimeValue href = getOption(_href);
			URI sourceUri = href.getBaseURI().resolve(href.getString());
			File file = new File(sourceUri.getPath());
			
			if (file.isDirectory()) {
				throw new XProcException(step, "Cannot peek into file: file is a directory: " + file.getAbsolutePath());
			}
			
			byte[] resultBytes = null;
			try {
				resultBytes = Peek.read(file, offset, length);
				
			} catch (IOException | IndexOutOfBoundsException e) {
				logger.error("px:file-peek failed to read from "+file+" (offset: "+offset+", length: "+length+", filesize: "+(file==null?'?':file.length())+")", e);
				e.printStackTrace();
			}

			TreeWriter tree = new TreeWriter(runtime);
			tree.startDocument(step.getNode().getBaseURI());
			AttributeMap attrs = EmptyAttributeMap.getInstance();
			attrs = attrs.put(TypeUtils.attributeInfo(new QName("content-type"), "binary/octet-stream"));
			attrs = attrs.put(TypeUtils.attributeInfo(new QName("encoding"), "base64"));
			if (resultBytes == null) {
				attrs = attrs.put(TypeUtils.attributeInfo(new QName("error"), "px:file-peek failed to read from " + file
				                                          + " (offset: " + offset + ", length: " + length
				                                          + ", filesize: " + (file == null ? '?' : file.length()) + ")"));
			}
			tree.addStartElement(XProcConstants.c_result, attrs);
			if (resultBytes != null) {
				tree.addText(Peek.encodeBase64(resultBytes));
			}
			tree.addEndElement();
			tree.endDocument();

			result.write(tree.getResult());
		}
		
		public static byte[] read(File file, int offset, int length) throws IOException, IndexOutOfBoundsException {
			if (offset > file.length()) {
				offset = 0;
				length = 0;
			}
			if (length + offset > file.length()) {
				length = (int) (file.length() - offset);
			}

			FileInputStream fis = null;
			byte[] resultBytes = new byte[length];
			if (length > 0) {
				try {
					if (file.exists() && file.canRead()) {
						fis = new FileInputStream(file);
						fis.skip(offset);
						fis.read(resultBytes, 0, length);
					}

				} finally {
					try {
						fis.close();
					} catch (IOException e) { // Ignore any exceptions here
					}
				}
			}
			
			return resultBytes;
		}

		public static String encodeBase64(byte[] bytes) {
			return Base64.encodeBytes(bytes);
		}
	}

}
