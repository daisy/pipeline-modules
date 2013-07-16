package org.daisy.pipeline.nlp;

import java.util.Collection;
import java.util.TreeMap;

/**
 * Prefix matching strategy based on a naive trie structure.
 */
public class PrefixMatchStringFinder implements IStringFinder {

    static class Trie {
        TreeMap<Byte, Trie> children = new TreeMap<Byte, Trie>();
        boolean present = false;
    }

    private Trie mTrieRoot;

    @Override
    public void compile(Collection<String> matchable) {
        mTrieRoot = new Trie();
        for (String s : matchable) {
            Trie current = mTrieRoot;
            for (Byte b : s.getBytes()) {
                Trie next = current.children.get(b);
                if (next == null) {
                    next = new Trie();
                    current.children.put(b, next);
                }
                current = next;
            }
            current.present = true;
        }
    }

    /**
     * Match the begining of @param input with the provided collection.
     */
    @Override
    public String find(String input) {
        Trie current = mTrieRoot;
        byte[] bytes = input.getBytes();
        int longestMatch = -1;
        for (int k = 0; k < bytes.length && current != null; ++k) {
            if (current.present) {
                longestMatch = k;
            }
            current = current.children.get(bytes[k]);
        }
        if (current != null && current.present) {
            return input;
        } else if (longestMatch > -1) {
            return input.substring(0, longestMatch);
        }

        return null;
    }
}
