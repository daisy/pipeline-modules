package org.daisy.pipeline.nlp.breakdetect;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

/**
 * This class keeps track of the duplicated nodes.
 */
public class DuplicationManager {

	private Set<NodeInfo> mAddedNodes;
	private Set<NodeInfo> mPrevAddedNodes;
	private List<NodeInfo> mDuplicatedNodes;
	private boolean mForbidAnyDup;
	private final static QName IDattr = new QName("id");

	public DuplicationManager(boolean forbidAnyDup) {
		mForbidAnyDup = forbidAnyDup;
	}

	public void onNewDocument() {
		mAddedNodes = new HashSet<NodeInfo>();
		mDuplicatedNodes = new ArrayList<NodeInfo>();
	}

	public void onNewSection() {
		mPrevAddedNodes = mAddedNodes;
		mAddedNodes = new HashSet<NodeInfo>();
	}

	public void onNewNode(XdmNode node) {
		if (!mForbidAnyDup && node.getAttributeValue(IDattr) == null)
			return;
		NodeInfo info = node.getUnderlyingNode();
		if (mPrevAddedNodes.contains(info) || mAddedNodes.contains(info)) {
			mDuplicatedNodes.add(info);
		} else
			mAddedNodes.add(info);
	}

	//the result may contain multiple occurrences of the same node
	public List<NodeInfo> getDuplicatedNodes() {
		return mDuplicatedNodes;
	}
}
