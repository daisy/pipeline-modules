package org.daisy.pipeline.tts;

public interface LoadBalancer {
	static class Host {
		public String address;
		public int port;
	}

	Host selectHost();
}
