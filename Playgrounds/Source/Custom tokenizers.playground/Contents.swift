/**
 Note: To use framework in a playground, the playground must be opened in a workspace that has the framework.
 
 If you recieve the error *"Playground execution failed: error: no such module 'Mustard'"* then run Project -> Build (⌘B).
 */

import Swift
import Mustard

// see Sources/LetterCountTokenizer.swift for `LetterCountTokenizer` implementation

class ThreeLetterWord: LetterCountTokenizer {
    required init() {
        super.init(3)
    }
}

class FourLetterWord: LetterCountTokenizer {
    required init() {
        super.init(4)
    }
    
    override func advanceIfCompleteTokenIsInvalid() -> Bool {
        return true
    }
}

// `ThreeLetterWord` and `FourLetterWord` both return the default token type `AnyToken` so the tokens array can be
// cast to `AnyToken` to get access to that type without casting.
let tokens: [AnyToken] = "one two three four five six seven 8 9 10"
        .tokens(matchedWith: ThreeLetterWord.defaultTokenzier, FourLetterWord.defaultTokenzier)

        //.tokens(matchedWith: ThreeLetterWord.defaultTokenzier)
        //.tokens(matchedWith: ThreeLetterWord.defaultTokenzier, advanceWhenCompleteTokenIsInvalid: true)

for token in tokens {
    
    // Along with the required properties `text` and `range`,  `AnyToken` also exposes a
    // `tokenizerType` property that allows you to check what type of tokenizer was responsible
    // for matching the substring.
    //
    // Here we switch on `token.tokenizerType` to decide what message to print and check against
    // different tokenizer types to see if there's a match.
    switch token.tokenizerType {
        
    case is ThreeLetterWord.Type:
        print("3 letters:", token.text)
        
    case is FourLetterWord.Type:
        print("4 letters:", token.text)
        
    default:
        break
    }
}
