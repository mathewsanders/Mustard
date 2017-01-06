# Performance Comparisons

Mustard isn't the fastest solution, but if you're willing to trade some performance for more reusable tokenizers and expressive tokens, and in some cases more readable code, the Mustard might still be a good fit.

I'm currently using [three benchmarks](/Tests/PerformanceTests.swift):

1. separating by whitespace (which Mustard isn't intended to be used for, but interesting comparison);
2. separating by sequential groups of letters or digits; and
3. separating by groups of characters that match a date format

Each test does 10,000 iterations.

## Benchmark 1: Separating words by whitespaces

This test takes the following text of 150 characters, and separates into 31<sup>1</sup> substrings:

> "Sing a song of sixpence, A pocket full of rye. four and twenty blackbirds, Baked in a pie. When the pie was opened The birds began to sing; Wasn't that a dainty dish, To set before the king The king was in his counting house, Counting out his money; The queen was in the parlour, Eating bread and honey. The maid was in the garden, Hanging out the clothes, When down came a blackbird And pecked off her nose. "

Here are results ordered fastest first:

````
String.Components using String(“ ”)           0.359 sec 3% STDEV (10% of the time of Mustard)
String.Components using .whitespaces          0.382 sec 1% STDEV
Regular expression matching \w+               0.888 sec 2% STDEV (37% of the time of Mustard)
Scanner by scanning upto .whitespaces         0.889 sec 1% STDEV (24% of the time of Mustard)
Scanner by scanning .letters                  1.066 sec 1% STDEV
Mustard matching .letters                     2.838 sec 3% STDEV
````

## Benchmark 2: Separating numbers and words without whitespace boundary

This test takes the following text of 150 characters, and separates into 42 substrings:

> "zero0one1two2three3four4five5six6seven7eight8nine9ten10eleven11twelve12thirteen13fourteen14fifteen15sixteen16seventeeen17eigthteen18nineteen19twenty20"

Here are results ordered fastest first:

````
Scanner scanning .letters or scan Int         1.544 sec 3% STDEV (37% of the time of Mustard)
Regular expression matching \d+|[a-zA-Z]+     1.572 sec 2% STDEV
Mustard matching .letters, .decimalDigits     3.266 sec 1% STDEV
````

Surprisingly the scanner is faster than the regular expression, but perhaps `\d+|[a-zA-Z]+` isn't the most efficient pattern.

## Benchmark 3: Separating words by date patterns

This test takes the following text of 150 characters, and separates into 6<sup>2</sup> substrings:

> Ref 01/55/99 Check in at 03/29/17, departure at 04/12/17, you have dinner reservations on 04/01/17, lunch on 04/02/17 and a show on night of 04/03/12.

`DateTokenizer` matches substrings with a `MM/dd/yy` pattern, but also validates that make sure it is a valid
date (including leap years!) and also exposes a `Date` object in the token.

`DatePatternTokenizer` and the regular expression both just match a format of digits and '/' characters.

Here are results ordered fastest first:

````
Regular expression matching [0-9]{2}/[0-9]{2}/[0-9]{2}   0.434 sec 4% STDEV  (9% of the time of DatePatternTokenizer)
Mustard matching with DatePatternTokenizer               4.579 sec 4% STDEV
Mustard matching with DateTokenizer                      6.694 sec 3% STDEV
````

<sup>1</sup>Actually 30 for scanner up to white space because it captures `Wasn't` as a single substring.
<sup>2</sup>Actually 5 for `DateTokenizer` because it excludes `01/55/99` as not a valid date.
