//
//  Gaia.swift
//  Blockstack
//
//  Created by Yukan Liao on 2018-04-15.
//

import Foundation

public struct GaiaConfig: Codable {
    let URLPrefix: String?
    let address: String?
    let token: String?
    let server: String?
}

public struct GaiaHubInfo: Codable {
    let challengeText: String?
    let readURLPrefix: String?
    
    enum CodingKeys: String, CodingKey {
        case challengeText = "challenge_text"
        case readURLPrefix = "read_url_prefix"
    }
}

public class Gaia {
    
    static func getOrSetLocalHubConnection() {
        if (retrieveConfig() == nil) {
            setLocalHubConnection()
        }
    }
 
    static func setLocalHubConnection() {
        let userData = ProfileHelper.retrieveProfile()
        let hubURL = userData?.hubURL ?? BlockstackConstants.DefaultGaiaHubURL
        let appPrivateKey = userData?.privateKey
        
        connectToHub(hubURL: hubURL, challengeSignerHex: appPrivateKey!)
    }
    
    static func connectToHub(hubURL: String, challengeSignerHex: String) {
        getHubInfo(hubURL: hubURL) { (hubInfo, error) in
            
        }
    }
    
    static func getHubInfo(hubURL: String, completion: @escaping (GaiaHubInfo?, Error?) -> Void) {
        let hubInfoURL = URL(string: "\(hubURL)/hub_info")
        let task = URLSession.shared.dataTask(with: hubInfoURL!) { data, response, error in
            guard let data = data, error == nil else {
                print("Error connecting to Gaia hub")
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let hubInfo = try jsonDecoder.decode(GaiaHubInfo.self, from: data)
                completion(hubInfo, nil)
            } catch {
                completion(nil, error)
            }
            
        }
        task.resume()
    }
    
    static func storeConfig(_ config: GaiaConfig) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(config),
                                  forKey: BlockstackConstants.GaiaHubConfigUserDefaultLabel)
    }
    
    static func retrieveConfig() -> GaiaConfig? {
        if let data = UserDefaults.standard.value(forKey:BlockstackConstants.GaiaHubConfigUserDefaultLabel) as? Data {
            return try? PropertyListDecoder().decode(GaiaConfig.self, from: data)
        } else {
            return nil
        }
    }
    
}
