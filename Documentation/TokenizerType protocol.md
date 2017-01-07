# TokenizerType protocol: implementing your own tokenizer

You can create your own tokenizers by implementing the [`TokenizerType`](/Sources/Mustard.swift) protocol.

Default implementations are provided for all methods except for `tokenCanTake(_:)` which means many implementations may be trivial.

Here's a slimmed down view of the protocol (see [`Mustard.swift`](/Sources/Mustard.swift) for full documentation).

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
    func tokenizerStartingWith(_ scalar: UnicodeScalar) -> AnyTokenizer?

    // default implementation returns result of `tokenCanTake(_:)`
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool

    // default implementation returns `true`
    func tokenIsComplete() -> Bool

    // default implementation returns `false`
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool

    // default implementation returns `false`
    func advanceIfCompleteTokenIsInvalid() -> Bool

    // default implementation does nothing
    func prepareForReuse()

    // The type of token associated with this tokenizer
    associatedtype Token: TokenType

    // Default implementation returns an instance of `AnyToken` which contains the matched text,
    // the range of the matched text in the original substring, and the type of tokenizer that
    // found the match.
    // Provide an alternative implementation of this method if you have a specific `TokenType`
    // type that you want the tokenizer to return.
    func makeToken(text: String, range: Range<String.Index>) -> Token
}

````

The protocol `DefaultTokenizerType` is used to identify tokenizers with a default initializer,
which enables the `defaultTokenzier` property (which returns an instance of `AnyTokenizer`).

````Swift
public protocol DefaultTokenizerType: TokenizerType {

    /// Initialize a default instance of the tokenizer.
    init()
}
````

Implementations of tokenizers can range from trivial to complex.

As an example, here's the extension that Mustard provides that allows any `CharacterSet` to act as a tokenizer by implementing the `tokenCanTake(_:)` method and providing an alternative implementation of `makeToken(text:, range:)` so
that tokenizer returns a more useful `TokenType`:

````Swift

public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }

    public struct CharacterSetToken: TokenType {
        public let text: String
        public let range: Range<String.Index>
        public let set: CharacterSet
    }

    public func makeToken(text: String, range: Range<String.Index>) -> CharacterSetToken {
        return CharacterSetToken(text: text, range: range, set: self)
    }
}

````

Here's another example showing a tokenizer that matches words identified by [camel case](https://en.wikipedia.org/wiki/Camel_case). Here `makeToken(text:, range:)` is not defined so instead Mustard
will use the type `AnyToken`.

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
