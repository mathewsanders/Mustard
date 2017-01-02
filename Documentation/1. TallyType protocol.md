# TallyType protocol: implementing your own tokenizer

You can create your own tokenizers by implementing the `TallyType` protocol.

````Swift

/// A tuple capturing information about a token match.
///
/// - tokenizer: The instance of `TokenType` that matched the token.
/// - text: The text that the token matched.
/// - range: The range of the matched text in the original input.
public typealias Match = (tokenizer: TokenType, text: String, range: Range<String.Index>)

public protocol TokenType {

    /// Asks the token if it can start with the given scalar.
    ///
    /// The default implementation of this method is an alias for `canTake(_:)`.
    /// Implement this method if the token has unique criteria for the first scalar to match.
    ///
    /// - Parameter scalar: The scalar to check.
    ///
    /// - Returns: `true` if the token can start with this scalar; otherwise, false.
    func canStart(with scalar: UnicodeScalar) -> Bool

    /// Asks the token if if can capture this scalar as a valid match.
    ///
    /// - Parameter scalar: The scalar to check using the token.
    ///
    /// - Returns: `true` if the token can take this this scalar; otherwise, false.
    func canTake(_ scalar: UnicodeScalar) -> Bool

    /// Returns a boolean value if the token is complete.
    var isComplete: Bool { get }

    /// Asks the token if it is invalid given context of the first scalar following this token.
    ///
    /// The default implementation of this method performs always returns `false`.
    /// Implement this method to return `true` in situations where a token can not be followed
    /// by certain scalars.
    ///
    /// - Parameter scalar: The first scalar following this token, or `nil` if the token has
    /// reached the end of the text.
    ///
    /// - Returns: `true` if the token is invalid with the following scalar; otherwise, false.
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool

    /// Ask the token to prepare itself to start matching a new series of scalars.
    ///
    /// The default implementation of this method does nothing.
    /// Implement this method to reset the token if calls to `canTake(_:)` change the state
    /// of the token.
    func prepareForReuse()

    /// Returns an instance of that can start with the given scalar,
    /// or `nil` if type can't start with this scalar.
    ///
    /// The default implementation of this method returns itself if `canStart(with:)` returns true;
    /// otherwise, nil.
    func token(startingWith scalar: UnicodeScalar) -> TokenType?

    /// Initialize an empty instance.
    init()

    /// Returns a new instance of a token that's a copy of the receiver.
    ///
    /// The object returned is set as the `tokenizer` element from a call to `matches()`
    /// If the type implements NSCopying protocol, the default implementation returns the result of
    /// `copy(with: nil)`; otherwise, returns self.
    var tokenizerForMatch: TokenType { get }
}

````

Default implementations are provided for all methods except for `canTake(_:)` which means many implementations may be trivial.
As an example, here's the extension of `CharacterSet` allowing any character set to act as a `TokenType`.

````Swift

extension CharacterSet: TokenType {
    public func canTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

````

Here's an example showing how to match individuals words identified by [camel case](https://en.wikipedia.org/wiki/Camel_case):

````Swift
struct CamelCaseToken: TokenType {

    // start of token is identified by an uppercase letter
    func canStart(with scalar: UnicodeScalar) -> Bool
        return CharacterSet.uppercaseLetters.contains(scalar)
    }

    // all remaining characters must be lowercase letters
    public func canTake(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.lowercaseLetters.contains(scalar)
    }
}
````

Mustard uses instances of TokenType to perform tokenization. If your `TokenType` uses the default initializer, you can use the static property `tokenizer` as a semantic alias.

````Swift
let words = "HelloWorld".matches(from: CamelCaseToken.tokenizer)
// `CamelCaseToken.tokenizer` is equivalent to `CamelCaseToken()`

// words.count -> 2
// words[0].text -> "Hello"
// words[1].text -> "World"
````
