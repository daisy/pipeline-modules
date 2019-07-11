import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import org.junit.Test;

public class XSpecAndXProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("file-utils"),
			pipelineModule("html-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("mediaoverlay-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("zip-utils"),
			pipelineModule("odf-utils"),
		};
	}
}
