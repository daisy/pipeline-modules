import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			pipelineModule("common-utils"),
			pipelineModule("css-speech"),
			pipelineModule("epub3-utils"),
			pipelineModule("epub3-tts"),
			pipelineModule("fileset-utils"),
			pipelineModule("file-utils"),
			pipelineModule("html-utils"),
			pipelineModule("zedai-to-html"),
			pipelineModule("zedai-utils")
		};
	}
}
