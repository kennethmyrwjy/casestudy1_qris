//
//  UserRepository.swift
//  casestudy1_qris
//
//  Created by Kenneth Mayer on 20/05/26.
//

import Foundation

protocol UserRepository {
    func currentUser() -> UserProfile
    // can come from keychain or userdefaults
}

// userprofile from from userdefaults and account number from keychain, seed storage on first launch with 'seed'
// we dont use dispatchqueue because while balancerepository is updated by deduct(), userrepository is read only, if we add edit feature, add dispatchqueue
final class DefaultUserRepository: UserRepository {
    
    private let defaults: UserDefaults
    private let keychain: KeychainStore
    private let defaultsKey = "user.profile.v1"
    private let accountNumberKey = "accountNumber"
    
    // cached so we dont hit keychain and decode on every home appear, set once in init and never updated
    private var cached: UserProfile
    
    init(defaults: UserDefaults, keychain: KeychainStore, seed: UserProfile) {
        self.defaults = defaults
        self.keychain = keychain
        
        // try load existing data, if any part of data is missing or corrupt then seed it
        if let storedDefaultsData = defaults.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(StoredFields.self, from: storedDefaultsData),
           let accountData = keychain.data(for: accountNumberKey),
           let accountNumber = String(data: accountData, encoding: .utf8) {
            self.cached = UserProfile(
                fullName: decoded.fullName,
                accountType: decoded.accountType,
                accountNumber: accountNumber
            )
        } else {
            // first launch or data is corrupted
            self.cached = seed
            Self.persist(seed, defaults: defaults, defaultsKey: defaultsKey, keychain: keychain, accountNumberKey: accountNumberKey)
        }
    }
    
    func currentUser() -> UserProfile {
        cached
    }
    
    /// Persists a profile to its split storage. Static so we can call it from
    /// `init` without referring to `self` before all properties are set.
    ///  need to explain further
    private static func persist(
        _ profile: UserProfile,
        defaults: UserDefaults,
        defaultsKey: String,
        keychain: KeychainStore,
        accountNumberKey: String
    ) {
        let stored = StoredFields(fullName: profile.fullName, accountType: profile.accountType)
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: defaultsKey)
        }
        if let data = profile.accountNumber.data(using: .utf8) {
            keychain.setData(data, for: accountNumberKey)
        }
    }
    
    // separate inner struct, wire format type, in order to not store data in plaintext in userdefaults (not encrypted)
    // need to explain further
    private struct StoredFields: Codable {
        let fullName: String
        let accountType: String
    }
}
