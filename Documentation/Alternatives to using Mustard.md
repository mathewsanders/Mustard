# Alternatives to using Mustard

Mustard may not be the best tool for your problem. Here are some common alternatives with some advantages, disadvantages, and code snippets to help you decide if Mustard is a good candidate for your problem.

- [String.components](#stringcomponentsseparatedby)
- [Scanner](#scanner)
- [Regular expressions](#regular-expressions)
- [Sequence operations](#sequence-operations)

## String.components(separatedBy:)
If you have a clear boundary for how substrings should be separated, then this method is probably the best.

Advantages:
- Great for simple and specific use case

Disadvantages:
- Very narrow use case

````Swift

import Foundation

let str = "his cat slept on 3 mats over 2 hours"
let components = str.components(separatedBy: " ")
// components.count -> 9
// components -> ["his", "cat", "slept", "on", "3", "mats", "over", "2", "hours"]
````

### Refs

- https://developer.apple.com/reference/foundation/nsstring/1410120-components
- https://developer.apple.com/reference/swift/string/1690777-components

## Scanner

Mustard is inspired heavily by Scanner, but also from some of the frustrations of using it.

Advantages:
- Options for case sensitivity
- Values returned by type (e.g. Int, Double)
- Scan use user locale when scanning numeric values (wow!)

Disadvantages:
- Currently awkward in Swift, you'll want to use [an extension](https://gist.github.com/natecook1000/59bb0c9117b555f5d40d)
- Can get clunky when you don't know the structure of the data you're scanning
- You'll need to grab value of `scanLocation` before and after scanning to return the range of a match

Here's an example set up for scanning doubles from text:

````Swift
import foundation

let str = "his cat slept on 3 mats over 2 hours"

let numberScanner = Scanner(string: str)
let numberScanner.charactersToBeSkipped = CharacterSet.decimalDigits.inverted

let firstNumber = scanner.scanDouble()
// firstNumber -> 3.0

let firstNumber = scanner.scanDouble()
// secondNumber -> 2.0
````

Using a scanner to scan for different types of values gets a little clunky since if you don't match one
of the types you're scanning for you'll need to manually increment the scan position to skip to the
next character:

````Swift

import foundation

let str = "his cat slept on 3 mats over 2 hours"
let scanner = Scanner(string: str)

while !scanner.isAtEnd {

    let start = scanner.scanLocation
    if let word = scanner.scanCharactersFromSet(set: .letters){
        print(word)
    }
    else if let number = scanner.scanDouble() {
        print(number)
    }
    else {
        scanner.scanLocation += 1
    }
}

// prints ->
// his
// cat
// sat
// on
// 3.0
// mats
// over
// 2.0
// hours

````

Apple gives a [specific note](https://developer.apple.com/reference/foundation/scanner/1410204-characterstobeskipped) around use of the scenario of setting the `charactersToBeSkipped` property to include characters that may be encountered during a scan:

> Characters to be skipped are skipped prior to the scanner examining the target. For example, if a scanner ignores spaces and you send it a scanInt32(_:) message, it skips spaces until it finds a decimal digit or other character. While an element is being scanned, no characters are skipped. If you scan for something made of characters in the set to be skipped (for example, using scanInt32(_:) when the set of characters to be skipped is the decimal digits), the result is undefined.

Here's an experiment to test that scenario:

````Swift
import Foundation

let numberScanner = Scanner(string: "so... I went swimming today for 3.5 hours...")
numberScanner.charactersToBeSkipped = CharacterSet.letters.union(.whitespaces).union(.punctuationCharacters)

let number = numberScanner.scanDouble()
// number -> 3.5
````

For me, this works as expected, but it doesn't give you confidence that it won't introduce a hard-to-diagnose bug in the future.

### Refs

- https://developer.apple.com/reference/foundation/scanner
- http://nshipster.com/nsscanner/

## Regular expressions

Regular expressions have a steep learning curve, but are extremely powerful, and since they use a standard format that's shared across many programming languages, if you're trying to do something common like match an date, email address, or phone number format, then someone's probably already written and tested a regular expression that's going to do that for you.

As of Swift 3 there's still lots of boilerplate to use regular expressions in Swift, but it's possible that greater support will come in a future version of Swift.

Regular expressions are their own separate language, you'll probably want to keep a [cheat-sheet](http://web.mit.edu/hackl/www/lab/turkshop/slides/regex-cheatsheet.pdf) handy.

To match the first occurrence of one or more digits:

````Swift
import Foundation

let str = "his cat slept on 3 mats over 2 hours"
let numberPattern = "\\d+"

if let typeRange = str.range(of: numberPattern, options: .regularExpression) {
    print(str[typeRange])
    // prints -> 3
}

````

To match all matches that match either one or more digits, or one or more words:

````Swift
import Foundation

let str = "his cat slept on 3 mats over 2 hours"

// Note: these regular expression examples use String extension from http://nshipster.com/nsregularexpression/
let pattern = "\\d+|\\w+"
let formatter = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
let matches = formatter.matches(in: str, options: [], range: str.nsrange)
// matches.count -> 9

for match in matches {
    print(str.substring(with: match.rangeAt(0))!)
}
// prints ->
// his
// cat
// sat
// on
// 3
// mats
// over
// 2
// hours

````

Advantages:
- Flexible and powerful pattern matching
- Perfect for when you want to replace matches with new/altered values
- Options for case sensitivity

Disadvantages:
- Matching numbers can get tricky
- More boilerplate for simple matches
- Harder to learn
- Use NSRange, so you'll want to use [an extension](http://nshipster.com/nsregularexpression/)

### Refs

- http://nshipster.com/nsregularexpression/

## Sequence operations

Sometimes the actual content of the text doesn't matter and you don't want to approach getting substrings by pattern matching, but instead by some other criteria.

In this case, it might be best to just use built in features of `Sequence`.

Here's an example of splitting text into groups of 10 characters:

```` Swift

let sequence = "ACAAGATGCCATTGTCCCCCGGCCTCCTGCTGCTGCTGCTCTCCGGGGCCACGGCCACCGCTGCCCTGCCCCGGAGGGTGGCCCCACCGGCCGAGACAGCGAGCATATGCAGGAAGCGGCAGGAATAAGGAAAAGCAGCCTCCTGACTTTCCTCGCTTGGTGGTTTGAGTGGACCTCCCAGGCCAGTGCCGGGCCCCTCATAGGAGAGGAAGCTCGGGAGGTGGCCAGGCGGCAGGAAGGCGCACCCCCCCAGCAATCCGCGCGCCGGGACAGAATGCCCTGCAGGAACTTCTTCTGGAAGACCTTCTCCTCCTGCAAATAAAACCTCACCCATGAATGCTCACGCAAGTTTAATTACAGACCTGAA"

// (via http://stackoverflow.com/questions/32212220/how-to-split-a-string-into-substrings-of-equal-length)
func split(_ str: String, _ count: Int) -> [String] {
    return stride(from: 0, to: str.characters.count, by: count).map { i -> String in
        let startIndex = str.index(str.startIndex, offsetBy: i)
        let endIndex   = str.index(startIndex, offsetBy: count, limitedBy: str.endIndex) ?? str.endIndex
        return str[startIndex..<endIndex]
    }
}

let chunks = split(sequence, 10)
// chunks.count -> 37
// chunks -> ["ACAAGATGCC", "ATTGTCCCCC", "GGCCTCCTGC", ... ]
````
