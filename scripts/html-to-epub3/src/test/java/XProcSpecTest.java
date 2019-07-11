import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("epub3-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("file-utils"),
			pipelineModule("html-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("zedai-to-html")
		};
	}
	
	// XSpec tests are already run with Maven plugin
	@Override
	public void runXSpec() throws Exception {
	}
}
