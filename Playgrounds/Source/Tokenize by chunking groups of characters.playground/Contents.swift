/**
 Note: To use framework in a playground, the playground must be opened in a workspace that has the framework.
 
 If you recieve the error *"Playground execution failed: error: no such module 'Mustard'"* then run Project -> Build (⌘B).
 */

import Swift
import Mustard

class ChunkingTokenizer: TokenizerType {
    
    private let chunkSize: Int
    private var currentSize: Int = 0
    
    required init() {
        chunkSize = 1
    }
    
    init(chunkSize: Int) {
        self.chunkSize = chunkSize
    }
    
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        currentSize += 1
        return currentSize <= chunkSize
    }
    
    func prepareForReuse() {
        currentSize = 0
    }
}

// create a tokenzier that chunks text into groups of 10 *scalars*
let chunker = ChunkingTokenizer(chunkSize: 10)

let sequence = "ACAAGATGCCATTGTCCCCCGGCCTCCTGCTGCTGCTGCTCTCCGGGGCCACGGCCACCGCTGCCCTGCCCCGGAGGGTGGCCCCACCGGCCGAGACAGCGAGCATATGCAGGAAGCGGCAGGAATAAGGAAAAGCAGCCTCCTGACTTTCCTCGCTTGGTGGTTTGAGTGGACCTCCCAGGCCAGTGCCGGGCCCCTCATAGGAGAGGAAGCTCGGGAGGTGGCCAGGCGGCAGGAAGGCGCACCCCCCCAGCAATCCGCGCGCCGGGACAGAATGCCCTGCAGGAACTTCTTCTGGAAGACCTTCTCCTCCTGCAAATAAAACCTCACCCATGAATGCTCACGCAAGTTTAATTACAGACCTGAA"

// get the chunks
let chunks = sequence.tokens(matchedWith: chunker).map({ $0.text })
chunks
chunks.count // -> 37

// print out chunks
chunks.forEach({ chunk in
    print(chunk)
})

// but if you're only using Mustard for this, you're probably better off with a stride based approach:
// (via http://stackoverflow.com/questions/32212220/how-to-split-a-string-into-substrings-of-equal-length)
func split(_ str: String, _ count: Int) -> [String] {
    return stride(from: 0, to: str.characters.count, by: count).map { i -> String in
        let startIndex = str.index(str.startIndex, offsetBy: i)
        let endIndex   = str.index(startIndex, offsetBy: count, limitedBy: str.endIndex) ?? str.endIndex
        return str[startIndex..<endIndex]
    }
}

let functionalChunk = split(sequence, 10)
functionalChunk.count // -> 37


