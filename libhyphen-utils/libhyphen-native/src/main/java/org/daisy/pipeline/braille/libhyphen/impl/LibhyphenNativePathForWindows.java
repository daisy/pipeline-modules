package org.daisy.pipeline.braille.libhyphen.impl;

import java.util.Map;

import org.daisy.pipeline.braille.common.BundledNativePath;
import org.daisy.pipeline.braille.common.NativePath;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "org.daisy.pipeline.braille.libhyphen.impl.LibhyphenNativePathForWindows",
	service = {
		NativePath.class
	},
	property = {
		"identifier:String=http://hunspell.sourceforge.net/Hyphen/native/windows/",
		"path:String=/native/windows",
		"os.family:String=windows"
	}
)
public class LibhyphenNativePathForWindows extends BundledNativePath {
	
	@Activate
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		super.activate(context, properties);
	}
}
