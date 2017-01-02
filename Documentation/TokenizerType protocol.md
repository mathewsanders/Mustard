# TokenizerType protocol: implementing your own tokenizer

You can create your own tokenizers by implementing the `TokenizerType` protocol.

````Swift
/// Token is a typelias for a tuple with the following named elements:
///
/// - tokenizer: An instance of `TokenizerType` that matched the token.
/// - text: A substring that the tokenizer matched in the original string.
/// - range: The range of the matched text in the original string.
public typealias Token = (tokenizer: TokenizerType, text: String, range: Range<String.Index>)

public protocol TokenizerType {

    /// Returns an instance of a tokenizer that starts with the given scalar,
    /// or `nil` if this type can't start with this scalar.
    ///
    /// The default implementation of this method returns `self` if `tokenCanStart(with:)` returns true;
    /// otherwise, nil.
    func token(startingWith scalar: UnicodeScalar) -> TokenizerType?

    /// Checks if tokens of this type can start with the given scalar.
    ///
    /// The default implementation of this method is an alias for `tokenCanTake(_:)`.
    /// Provide an alternate implementation if tokens have special starting criteria.
    ///
    /// - Parameter scalar: The scalar the token could start with.
    ///
    /// - Returns: `true` if the token can start with this scalar; otherwise, false.
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool

    /// Checks if tokens can include this scalar as part of a token.
    ///
    /// This method is called multiple times for each subsequent scalar in a String until the tokenizer
    /// returns `false`.
    ///
    /// - Parameter scalar: The scalar the token could include.
    ///
    /// - Returns: `true` if the token can take this this scalar; otherwise, false.
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool

    /// Returns a boolean value if the token is considered complete.
    ///
    /// The default implementation returns `true`.
    ///
    /// Provide an alternate implementation if tokens have some internal criteria that need to be
    /// satisfied before a token is complete.
    var tokenIsComplete: Bool { get }

    /// Checks if a complete token should be discarded given the context of the first scalar following this token.
    ///
    /// The default implementation of this method performs always returns `false`.
    ///
    /// Provide an alternate implementation to return `true` in situations where a token can not be followed
    /// by certain scalars.
    ///
    /// - Parameter scalar: The first scalar following this token, or `nil` if the tokenizer has
    /// matched a token that reaches the end of the text.
    ///
    /// - Returns: `true` if the token is invalid with the following scalar; otherwise, false.
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool

    /// Ask the tokenizer to prepare itself to start matching a new series of scalars.
    ///
    /// The default implementation of this method does nothing.
    ///
    /// Provide an alternate implementation if the tokenizer maintains an internal state that updates based on calls to
    /// `tokenCanTake(_:)`
    func prepareForReuse()

    /// Initialize an empty instance of the tokenizer.
    init()

    /// Returns an instance of the tokenizer that will be used as the `tokenizer` element in the `Token` tuple.
    ///
    /// If the tokenizer implements `NSCopying` protocol, the default implementation returns the result of
    /// `copy(with: nil)`; otherwise, returns `self` which is suitable for structs.
    ///
    /// Provide an alternate implementation if the tokenizer is a reference type that does not implement `NSCopying`.
    var tokenizerForMatch: TokenizerType { get }
}

````

Default implementations are provided for all methods except for `tokenCanTake(_:)` which means many implementations may be trivial.

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
