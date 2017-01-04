# Performance Comparisons

Mustard currently isn't the fastest solution, but if you're willing to trade some performance for more reusable tokenizers, and in some cases more readable code, the Mustard might still be a good fit.

I'm currently using [two benchmarks](/Tests/PerformanceTests.swift):

1. separating by whitespace (which Mustard isn't intended to be used for, but interesting comparison); and
2. separating by sequential groups of letters or digits.

Each test does 10,000 iterations.

## Benchmark 1: Separating words by whitespaces

This test takes the following text of 150 characters, and separates into 31 substrings:

> "Sing a song of sixpence, A pocket full of rye. four and twenty blackbirds, Baked in a pie. When the pie was opened The birds began to sing; Wasn't that a dainty dish, To set before the king The king was in his counting house, Counting out his money; The queen was in the parlour, Eating bread and honey. The maid was in the garden, Hanging out the clothes, When down came a blackbird And pecked off her nose. "

Here are results ordered fastest first:

````
String.Components using String(“ ”)           0.359 sec 3% STDEV
String.Components using .whitespaces          0.382 sec 1% STDEV
Regular expression matching \w+               0.888 sec 2% STDEV
Scanner by scanning upto .whitespaces         0.889 sec 1% STDEV
Scanner by scanning .letters                  1.066 sec 1% STDEV
Mustard matching .letters                     2.838 sec 3% STDEV
````

## Benchmark 2: Separating numbers and words without whitespace boundary

This test takes the following text of 150 characters, and separates into 42 substrings:

> "zero0one1two2three3four4five5six6seven7eight8nine9ten10eleven11twelve12thirteen13fourteen14fifteen15sixteen16seventeeen17eigthteen18nineteen19twenty20"

Here are results ordered fastest first:

````
Scanner scanning .letters or scan Int         1.544 sec 3% STDEV
Regular expression matching \d+|[a-zA-Z]+     1.572 sec 2% STDEV
Mustard matching .letters, .decimalDigits     3.266 sec 1% STDEV
````

Surprisingly the scanner is faster than the regular expression, but perhaps `\d+|[a-zA-Z]+` isn't the most efficient pattern.
