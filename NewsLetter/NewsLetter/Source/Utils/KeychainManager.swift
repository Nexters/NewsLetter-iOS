//
//  KeychainManager.swift
//  CoreKit
//
//  Created by 이원빈 on 11/1/24.
//

import Foundation

/*
 MARK: 사용 전 세팅
 
 Signing & Capabilities 에서 Keychain Sharing 옵션 활성화를 해야 사용가능
 
 앱을 삭제해도 데이터가 남아있음

 */

public protocol KeychainManagerProtocol {
    func save(data: Data, forKey key: String)
    func retrieve(forKey key: String) -> Data?
    func update(data: Data, forKey key: String)
    func delete(forKey key: String)
    func clearAll()
}

public final class KeychainManager: KeychainManagerProtocol {
  public static let shared: KeychainManager = KeychainManager()
  private var serviceName = Bundle.main.bundleIdentifier ?? "No BundleIdentifier"
  
  private init() { }
  
  public func save(data: Data, forKey key: String) {
    delete(forKey: key)
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName,
      kSecAttrAccount as String: key,
      kSecValueData as String: data
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    assert(status == errSecSuccess, "fail to save data")
  }
  
  public func retrieve(forKey key: String) -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == errSecSuccess {
      return dataTypeRef as? Data
    }
    return nil
  }
  
  public func update(data: Data, forKey key: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName,
      kSecAttrAccount as String: key
    ]
    
    let attributes: [String: Any] = [
      kSecValueData as String: data
    ]
    
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    assert(status == errSecSuccess, "fail to update data")
  }
  
  public func delete(forKey key: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName,
      kSecAttrAccount as String: key
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    assert(status == errSecSuccess || status == errSecItemNotFound, "fail to delete data")
  }
  
  public func clearAll() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: serviceName
    ]
    
    SecItemDelete(query as CFDictionary)
  }
  
  // MARK: - Convenience Methods For String
  
  public func saveString(_ value: String, forKey key: String) {
    if let data = value.data(using: .utf8) {
      save(data: data, forKey: key)
    } else {
      assertionFailure("fail to saveString")
    }
  }
  
  public func retrieveString(forKey key: String) -> String? {
    if let data = retrieve(forKey: key),
       let value = String(data: data, encoding: .utf8) {
      return value
    }
    return nil
  }
  
  public func updateString(data: String, forKey key: String) {
    if let encoded = data.data(using: .utf8) {
      update(data: encoded, forKey: key)
    } else {
      assertionFailure("fail to updateString")
    }
  }
}

