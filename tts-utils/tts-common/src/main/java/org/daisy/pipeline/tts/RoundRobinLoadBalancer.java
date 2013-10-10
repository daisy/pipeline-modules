package org.daisy.pipeline.tts;

public class RoundRobinLoadBalancer implements LoadBalancer {

	private Host[] mHosts;
	private int mIndex = 0;
	private Object mSyncPoint;

	public RoundRobinLoadBalancer(String hostlist, Object syncPoint) {
		mSyncPoint = syncPoint;
		String[] parts = hostlist.split("[ ,;\t\n]+");
		mHosts = new Host[parts.length];

		for (int i = 0; i < parts.length; ++i) {
			try {
				mHosts[i] = new Host();
				String[] pair = parts[i].split(":");
				mHosts[i].address = pair[0];
				mHosts[i].port = Integer.valueOf(pair[1]);
			} catch (Exception e) {
				throw new IllegalArgumentException("bad format for: '"
				        + parts[i] + "'");
			}
		}

	}

	@Override
	public Host selectHost() {
		int index;
		if (mSyncPoint != null) {
			synchronized (mSyncPoint) {
				mIndex = (mIndex + 1) % mHosts.length;
				index = mIndex;
			}
		} else {
			mIndex = (mIndex + 1) % mHosts.length;
			index = mIndex;
		}

		return mHosts[index];
	}

}
