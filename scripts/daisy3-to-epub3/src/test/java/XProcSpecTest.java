import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("daisy3-utils"),
			pipelineModule("dtbook-to-zedai"),
			pipelineModule("epub3-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("file-utils"),
			pipelineModule("mediaoverlay-utils"),
			pipelineModule("zedai-to-html"),
			pipelineModule("common-entities"),
		};
	}
}

