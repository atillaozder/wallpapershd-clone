//
//  InfoPlistManager.swift
//  Core
//
//  Created by Atilla Özder on 11.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//


import Foundation

// A class to read and decode strongly typed values in `plist` files.
public class PListFile<Value: Codable> {
    
    /// Errors.
    ///
    /// - fileNotFound: plist file not exists.
    public enum Errors: Error {
        case fileNotFound
    }
    
    /// Plist file source.
    ///
    /// - infoPlist: main bundel's Info.plist file
    /// - plist: other plist file with custom name
    public enum Source {
        case infoPlist(_: Bundle)
        case plist(_: String, _: Bundle)
        
        /// Get the raw data inside given plist file.
        ///
        /// - Returns: read data
        /// - Throws: throw an exception if it fails
        internal func data() throws -> Data {
            switch self {
            case .infoPlist(let bundle):
                guard let infoDict = bundle.infoDictionary else {
                    throw Errors.fileNotFound
                }
                return try JSONSerialization.data(withJSONObject: infoDict)
            case .plist(let filename, let bundle):
                guard let path = bundle.path(forResource: filename, ofType: "plist") else {
                    throw Errors.fileNotFound
                }
                return try Data(contentsOf: URL(fileURLWithPath: path))
            }
        }
    }
    
    /// Data read for file
    public let data: Value
    
    /// Initialize a new Plist parser with given codable structure.
    ///
    /// - Parameter file: source of the plist
    /// - Throws: throw an exception if read fails
    public init(_ file: PListFile.Source = .infoPlist(Bundle.main)) throws {
        let rawData = try file.data()
        let decoder = JSONDecoder()
        self.data = try decoder.decode(Value.self, from: rawData)
    }
    
}

public struct InfoPList: Codable {
    public struct Configuration: Codable {
        public let debugBannerUnitID: String
        public let debugInterstitialUnitID: String
        public let bannerUnitID: String
        public let interstitialUnitID: String
        public let gameName: String
    }
    
    public let configuration: Configuration
}
