import Foundation
import Security

struct StringObfuscator {
    private let key: [UInt8]
    
    init(salt: String) {
        let saltBytes = Array(salt.utf8)
        if saltBytes.isEmpty {
            // Default key if salt is empty
            self.key = [0x42, 0x37, 0xAB, 0x19]
        } else {
            self.key = saltBytes
        }
    }
    
    func obfuscate(_ plain: String) -> String {
        let plainBytes = Array(plain.utf8)
        var obfuscatedBytes = [UInt8]()
        obfuscatedBytes.reserveCapacity(plainBytes.count)
        
        for (index, byte) in plainBytes.enumerated() {
            obfuscatedBytes.append(byte ^ key[index % key.count])
        }
        
        let data = Data(obfuscatedBytes)
        return data.base64EncodedString()
    }
    
    func reveal(_ obfuscatedBase64: String) -> String? {
        guard let data = Data(base64Encoded: obfuscatedBase64) else {
            return nil
        }
        let obfuscatedBytes = [UInt8](data)
        var plainBytes = [UInt8]()
        plainBytes.reserveCapacity(obfuscatedBytes.count)
        
        for (index, byte) in obfuscatedBytes.enumerated() {
            plainBytes.append(byte ^ key[index % key.count])
        }
        
        return String(bytes: plainBytes, encoding: .utf8)
    }
}

enum Keychain {
    enum KeychainError: Error {
        case unexpectedStatus(OSStatus)
    }

    static func store(_ value: Data, account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let updateAttributes: [String: Any] = [
            kSecValueData as String: value
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            // Item exists, update it
            let updateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        case errSecItemNotFound:
            // Item does not exist, add it
            var addQuery = query
            addQuery[kSecValueData as String] = value
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(addStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func read(account: String, service: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

/*
 Usage example:

 let obfuscator = StringObfuscator(salt: "com.example.myapp.salt")

 // Obfuscate the compile-time string (e.g., your secret key)
 // Run this once and store the obfuscated string in your source code:
 let obfuscatedKey = obfuscator.obfuscate("sk_live_1234567890abcdef")
 // Store the string 'obfuscatedKey' in your source code as a constant

 // At runtime, reveal the key:
 if let revealedKey = obfuscator.reveal(obfuscatedKey) {
     // Store the revealed key securely in Keychain
     do {
         try Keychain.store(Data(revealedKey.utf8), account: "liveSecretKey", service: "com.example.myapp")
     } catch {
         print("Keychain store error: \(error)")
     }
     
     // Clear plaintext variable if needed
     // revealedKey = nil // (if it was a var)
 }

*/
