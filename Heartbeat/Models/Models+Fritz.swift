//
//  Models+Fritz.swift
//  Heartbeat
//
//  Created by Andrew Barba on 1/6/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//
import Fritz

extension MobileNet: SwiftIdentifiedModel {

    static let modelIdentifier = "de7974faf0d144fabcdce40c49a1d791"

    static let packagedModelVersion = 1

    static let encryptionSeed: [UInt8] = [55, 57, 97, 56, 52, 50, 52, 99, 51, 102, 54, 49, 52, 52, 100, 97]

    static let session = Session(appToken: "ada5320821864c4aaadd16105608b26a")
}

extension MNIST: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-2"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension AgeNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-3"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension GenderNet: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-4"

    static let session = Fritz.Session(appToken: "app-token-12345")
}

extension SSDMobilenetFeatureExtractor: SwiftIdentifiedModel {

    static let packagedModelVersion: Int = 1

    static let modelIdentifier: String = "model-id-5"
    
    static let session = Fritz.Session(appToken: "app-token-12345")
}
