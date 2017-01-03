/**
 Note: To use framework in a playground, the playground must be opened in a workspace that has the framework.
 
 If you recieve the error *"Playground execution failed: error: no such module 'Mustard'"* then run Project -> Build (⌘B).
 */

import Foundation
import Mustard

// see Sources/DateTokenzier.Swift for DateTokenizer

let message = "Your reservation is confirmed for arrival on 12/01/17 and departure on 12/05/17"

// extract the date tokens from the message
let dates: [DateTokenizer.Token] = message.tokens()

// grab reference to first and second date
let arrival = dates[0].tokenizer.date
let departure = dates[1].tokenizer.date

// print message saying days of arrival and departure
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "EEEE"

print("You will arrive on \(dateFormatter.string(from: arrival)) and depart on \(dateFormatter.string(from: departure))")

// print message for number of days of visit
let secondsInDay: TimeInterval = 60 * 60 * 24
let days = Int( departure.timeIntervalSince(arrival) / secondsInDay)

print("Enjoy your stay of \(days) days")