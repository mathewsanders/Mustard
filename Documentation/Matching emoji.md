# Example: matching emoji

`CharacterSets` provide set operations on unicode scalars, however emoji (and other non latin characters) may use [multiple scalars]((https://oleb.net/blog/2016/12/emoji-4-0/)) to represent a single character.

As an example, the character '👶🏿' is comprised by two scalars: '👶', and the skin tone modifier '🏿'.
The rainbow flag character '🏳️‍🌈' is again comprised by two adjacent scalars '🏳' and '🌈'.
A final example, the character '👨‍👨‍👧‍👦' is actually 7 scalars: '👨' '👨' '👧' '👦' joined by three ZWJs (zero-with joiner).

To create a `TokenizerType` that matches emoji we can instead check to see if a scalar falls within known range, or if it's a ZWJ.

This isn't the most *accurate* emoji tokenizer because it would potentially matches an emoji scalar followed by 100 zero-width joiners, but for basic use it might be enough.

````Swift
struct EmojiTokenizer: TokenizerType {

    // (e.g. can't start with a ZWJ)
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return EmojiTokenizer.isEmojiScalar(scalar)
    }

    // either in the known range for a emoji, or a ZWJ
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return EmojiTokenizer.isEmojiScalar(scalar) || EmojiTokenizer.isJoiner(scalar)
    }

    static func isJoiner(_ scalar: UnicodeScalar) -> Bool {
        return scalar == "\u{200D}" // Zero-width joiner
    }

    static func isEmojiScalar(_ scalar: UnicodeScalar) -> Bool {

        switch scalar {
        case
        "\u{0001F600}"..."\u{0001F64F}", // Emoticons
        "\u{0001F300}"..."\u{0001F5FF}", // Misc Symbols and Pictographs
        "\u{0001F680}"..."\u{0001F6FF}", // Transport and Map
        "\u{00002600}"..."\u{000026FF}", // Misc symbols
        "\u{00002700}"..."\u{000027BF}", // Dingbats
        "\u{0000FE00}"..."\u{0000FE0F}", // Variation Selectors
        "\u{0001F900}"..."\u{0001F9FF}", // Various (e.g. 🤖)
        "\u{0001F1E6}"..."\u{0001F1FF}": // regional flags
            return true

        default:
            return false
        }
    }
}

````
