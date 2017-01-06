//
//  LetterCountTokenizer.swift
//  
//
//  Created by Mat on 1/6/17.
//
//

import Swift
import Mustard

open class LetterCountTokenizer: DefaultTokenizerType {
    
    let targetSize: Int
    private var currentSize: Int = 0
    
    required public init() {
        self.targetSize = 0
    }
    
    public init(_ size: Int) {
        self.targetSize = size
    }
    
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        if CharacterSet.letters.contains(scalar) {
            currentSize += 1
            return currentSize <= targetSize
        }
        return false
    }
    
    public func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        guard let char = scalar else { return false }
        return !CharacterSet.whitespaces.contains(char)
    }
    
    public func tokenIsComplete() -> Bool {
        return targetSize == currentSize
    }
    
    public func prepareForReuse() {
        currentSize = 0
    }
    
    open func advanceIfCompleteTokenIsInvalid() -> Bool {
        return false
    }
}
