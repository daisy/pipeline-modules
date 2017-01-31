package org.daisy.pipeline.braille.liblouis.impl;

import java.util.Map;

import org.daisy.pipeline.braille.liblouis.LiblouisutdmlConfigPath;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisMathMLConfigPath",
	service = { LiblouisutdmlConfigPath.class },
	property = {
		"identifier:String=http://www.daisy.org/pipeline/modules/braille/liblouis-mathml/lbu_files/",
		"path:String=/lbu_files"
	}
)
public class LiblouisMathMLConfigPath extends LiblouisutdmlConfigPath {
	
	@Activate
	@Override
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		super.activate(context, properties);
	}
}
