//
//  ARManager.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 10/2/24.
//
import SwiftUI

struct GameConfig: Codable {
    let id: String
    let imageTargetNames: [String]
}

class ARManager: ObservableObject {
    static let shared = ARManager()
    private let baseURL = "https://instabao-be.pages.dev"

    private var activeId: String?
    @Published var config: GameConfig?
    
    init() {
        fetchActiveConfig()
    }
    
    func fetchActiveConfig() {
        guard let url = URL(string: "\(baseURL)/ar") else {
            print("Invalid URL")
            return
        }
        print("Fetching from \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching config: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                print(data)
                let config = try decoder.decode(GameConfig.self, from: data)
                
                DispatchQueue.main.async {
                    self?.activeId = config.id
                    self?.config = config
                    print("Config has been fetched: \(config)")
                }
            } catch {
                print("fetchActiveConfig Error decoding config: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchActiveId() {
        guard let url = URL(string: "\(baseURL)/ar") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching config: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let activeId = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.activeId = activeId
                    print("activeId has been set to \(activeId)")
                }
            } else {
                print("Error converting data to string")
            }
        }.resume()
    }
    
    
    
    func fetchConfig() {
        print("Fetching AR Config")
        guard let activeId = activeId else {
            print("No activeId")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/ar/\(activeId)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching config: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let config = try decoder.decode(GameConfig.self, from: data)
                
                DispatchQueue.main.async {
                    self?.config = config
                    print("Config has been fetched: \(config)")
                }
            } catch {
                print("Error decoding config: \(error.localizedDescription)")
            }
        }.resume()
    }

}
