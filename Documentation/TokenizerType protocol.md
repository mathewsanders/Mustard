# TokenizerType protocol: implementing your own tokenizer

You can create your own tokenizers by implementing the [`TokenizerType`](/Sources/TokenizerType.swift) protocol.

Default implementations are provided for all methods except for `tokenCanTake(_:)` which means many implementations may be trivial.

Here's a slimmed down view of the protocol (see [`TokenizerType.swift`](/Sources/TokenizerType.swift) for full documentation).

````Swift

/// Defines the implementation needed to create a tokenizer for use with Mustard.
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

An brief additional protocol `DefaultTokenizerType` can be used for tokenizers that have a default initializer,
which provides some useful methods (see [type safety using a single tokenizer](Type safety using a single tokenizer) for more information).

````Swift
/// Defines the implementation needed for a TokenizerType to have some convenience methods
/// enabled when the tokenizer has a default initializer.
public protocol DefaultTokenizerType: TokenizerType {

    /// Initialize an empty instance of the tokenizer.
    init()
}
````

Implementations of tokenizers can range from trivial to complex.

As an example, here's the extension that Mustard provides that allows any `CharacterSet` to act as a tokenizer:

````Swift

extension CharacterSet: TokenizerType, DefaultTokenizerType {
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

````

Here's a *slightly* more complex example showing a tokenizer that matches words identified by [camel case](https://en.wikipedia.org/wiki/Camel_case):

````Swift
struct CamelCaseTokenizer: TokenizerType, DefaultTokenizerType {

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

For more complex examples of implementing TokenizerType, see examples for [EmojiTokenizer](Matching emoji.md), [LiteralTokenizer](Literal tokenizer.md), [DateTokenizer](Template tokenizer.md), and [unit tests](/Tests).
