//
//  DebuggingSceneDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

#if DEBUG
import UIKit
import ITGWorkoutKit

class DebuggingSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }

        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteHTTPClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteHTTPClient()
    }
    
    
    override func makeRemoteClient() -> Client {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingClient()
        }
        return super.makeRemoteClient()
    }
    
}

private class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}

private class AlwaysFailingClient: Client {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from path: String, completion: @escaping (Client.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
#endif
