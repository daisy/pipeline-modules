import java.io.File;

import com.google.common.collect.ImmutableMap;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import org.junit.Test;
import static org.junit.Assert.assertTrue;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.util.PathUtils;

public class LiblouisMathMLTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			brailleModule("common-utils"),
			brailleModule("liblouis-utils"),
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			pipelineModule("file-utils"),
			pipelineModule("fileset-utils")
		};
	}
	
	@Override @Configuration
	public Option[] config() {
		return options(
			// FIXME: BrailleUtils needs older version of jing
			mavenBundle("org.daisy.libs:jing:20120724.0.0"),
			composite(super.config()));
	}
	
	@Override @Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		boolean success = xprocspecRunner.run(ImmutableMap.of("test_transform_mathml",
		                                                      new File(baseDir, "src/test/xprocspec/test_transform_mathml.xprocspec")),
		                                      new File(baseDir, "target/xprocspec-reports"),
		                                      new File(baseDir, "target/surefire-reports"),
		                                      new File(baseDir, "target/xprocspec"),
		                                      null,
		                                      new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
}
