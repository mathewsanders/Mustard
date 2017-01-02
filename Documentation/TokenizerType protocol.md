# TokenizerType protocol: implementing your own tokenizer

You can create your own tokenizers by implementing the [`TokenizerType`](/Mustard/Mustard/TokenizerType.swift) protocol.

Default implementations are provided for all methods except for `tokenCanTake(_:)` which means many implementations may be trivial.

Here's a slimmed down view of the protocol (see [`TokenizerType.swift`](/Mustard/Mustard/TokenizerType.swift) for full documentation).

````Swift

public protocol TokenizerType {

    /* required methods  */

    /// Checks if tokens can include this scalar as part of a token.
    ///
    /// This method is called multiple times for each subsequent scalar in a String until the tokenizer
    /// returns `false`.
    ///
    /// - Parameter scalar: The scalar the token could include.
    ///
    /// - Returns: `true` if the token can take this this scalar; otherwise, false.
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool

    // structs get this for free if any properties have default values
    init()

    /* default implementations provided  */

    // default implementation returns self if `tokenCanStart(with:)` returns true, otherwise nil
    func token(startingWith scalar: UnicodeScalar) -> TokenizerType?

    // default implementation returns result of `tokenCanTake(_:)`
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool

    // default implementation returns `true`
    var tokenIsComplete: Bool { get }

    // default implementation returns `false`
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool

    // default implementation does nothing
    func prepareForReuse()

    // default implementation returns result of `copy(with: nil)` if the type implements `NSCopying`
    // otherwise returns `self` (which is suitable for any value types)
    var tokenizerForMatch: TokenizerType { get }
}

````

As an example, here's the extension that Mustard uses to allow any `CharacterSet` to act as a tokenizer.

````Swift

extension CharacterSet: TokenizerType {
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

````

Here's an example showing how to match individuals words identified by [camel case](https://en.wikipedia.org/wiki/Camel_case):

````Swift
struct CamelCaseTokenizer: TokenizerType {

    // start of token is identified by an uppercase letter
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool
        return CharacterSet.uppercaseLetters.contains(scalar)
    }

    // all remaining characters must be lowercase letters
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.lowercaseLetters.contains(scalar)
    }
}
````

Mustard uses instances of TokenizerType to perform tokenization. If your `TokenizerType` uses the default
initializer, you have the option of using the static property `defaultTokenizer` as a semantic alias.

````Swift
let words = "HelloWorld".tokens(matchedWith: CamelCaseTokenizer.defaultTokenizer)
// `CamelCaseTokenizer.defaultTokenizer` is equivalent to `CamelCaseTokenizer()`

// words.count -> 2
// words[0].text -> "Hello"
// words[1].text -> "World"
````

For more complex examples of implementing TokenizerType, see examples for [EmojiTokenizer](Matching emoji.md), [LiteralTokenizer](Literal tokenizer.md), [DateTokenizer](Template tokenizer.md), and [unit tests](/Mustard/MustardTests).
