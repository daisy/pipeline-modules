import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("daisy202-utils"),
			pipelineModule("epub3-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("file-utils"),
			pipelineModule("html-utils"),
			pipelineModule("mediaoverlay-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("common-entities")
		};
	}
}
