/*:
 # Boston Pricer
 
 Given the crime rate percentage (represented as a Double) and the number of rooms a house may have, predict how much will the house price be.
 This illustrates the simplest way to use a Core ML model.
 
 The model was trained from a script provided by the [Big Nerd Ranch](https://www.bignerdranch.com/blog/machine-learning-in-ios-using-core-ml/).

 */

//: Construct the ML model object.
let pricer = BostonPricer()
//: Provide some input
let input = BostonPricerInput(crime: 0.05, rooms: 4)
//: Make prediction
let output = try pricer.prediction(input: input)
//: Print the price (in thousands of dollars)
print("price: \(output.price)")
