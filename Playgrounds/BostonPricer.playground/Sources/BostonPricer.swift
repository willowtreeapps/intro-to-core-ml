//
// BostonPricer.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class BostonPricerInput : MLFeatureProvider {
    
    /// crime as double value
    public var crime: Double
    
    /// rooms as double value
    public var rooms: Double
    
    public var featureNames: Set<String> {
        get {
            return ["crime", "rooms"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "crime") {
            return MLFeatureValue(double: crime)
        }
        if (featureName == "rooms") {
            return MLFeatureValue(double: rooms)
        }
        return nil
    }
    
    public init(crime: Double, rooms: Double) {
        self.crime = crime
        self.rooms = rooms
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class BostonPricerOutput : MLFeatureProvider {
    
    /// price as double value
    public let price: Double
    
    public var featureNames: Set<String> {
        get {
            return ["price"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "price") {
            return MLFeatureValue(double: price)
        }
        return nil
    }
    
    public init(price: Double) {
        self.price = price
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class BostonPricer {
    public var model: MLModel
    
    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    public init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
        let bundle = Bundle(for: BostonPricer.self)
        let assetPath = bundle.url(forResource: "BostonPricer", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as BostonPricerInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as BostonPricerOutput
     */
    public func prediction(input: BostonPricerInput) throws -> BostonPricerOutput {
        let outFeatures = try model.prediction(from: input)
        let result = BostonPricerOutput(price: outFeatures.featureValue(for: "price")!.doubleValue)
        return result
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - crime as double value
     - rooms as double value
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as BostonPricerOutput
     */
    public func prediction(crime: Double, rooms: Double) throws -> BostonPricerOutput {
        let input_ = BostonPricerInput(crime: crime, rooms: rooms)
        return try self.prediction(input: input_)
    }
}

