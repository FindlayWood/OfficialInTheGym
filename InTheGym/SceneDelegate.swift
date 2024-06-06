//
//  SceneDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit
import CoreData
import ITGWorkoutKit
import ITGWorkoutKitiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var coordinator: MainCoordinator?
    var baseController: BaseController?
    var navigationController: UINavigationController = UINavigationController()
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            launchEssentialFeed()
        }
        
    }
    
    func launchEssentialFeed() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let remoteClient = makeRemoteClient()
        let imageClient = makeRemoteHTTPClient()
        let remoteFeedLoader = RemoteLoader(client: remoteClient, path: remoteURL.absoluteString, mapper: WorkoutItemsMapper.map)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: imageClient)
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")

        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        window?.rootViewController = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)))
        
        
        window?.makeKeyAndVisible()
    }
    
    func onBoard() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = OnBoardMainViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func launchScreen() {
        navigationController = UINavigationController()
        baseController = makeBaseCoordinator()
        baseController?.start()
        guard let window else {return}
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func makeBaseCoordinator() -> BaseController {

        let controller = BaseController(navigationController: navigationController)
        
        let cache = UserCacheServiceAdapter()
        let cacheSaver = UserDefaultsCacheUserSaver()
        
        let subscriptionManager = SubscriptionManager.shared
        
        let api = UserAPIServiceAdapter(
            authService: FirebaseAuthManager.shared,
            firestoreService: FirestoreManager.shared)
        
        let loginKitComposer = LoginComposerAdapter(
            navigationController: navigationController) { [weak controller] in
                controller?.loadUser()
            }
        
        let accountCreationComposer = AccountCreationComposerAdapter(
            navigationController: navigationController) {
                [weak controller] in
                controller?.reloadUser()
            } signedOut: { [ weak controller] in
                controller?.loadUser()
            }

        
        let flow = BasicBaseFlow(
            navigationController: navigationController,
            loginKitComposer: loginKitComposer,
            accountCreationComposer: accountCreationComposer) { [weak controller] in
                controller?.reloadUser()
            } userLoggedIn: { [weak controller] in
                controller?.loadUser()
            } userSignedOut: { [weak controller] in
                controller?.loadUser()
            }
        
        #if EMULATOR
        controller.userService = api
        #else
        controller.userService = cache.fallback(api)
        #endif
//        controller.userService = cache.fallback(api)
        controller.cacheSaver = cacheSaver
        controller.baseFlow = flow
        controller.subscriptionManager = subscriptionManager
        
        return controller
    }
    
    
    private func makeRemoteHTTPClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()

        default:
            return URLSessionHTTPClient2(session: URLSession(configuration: .ephemeral))
        }
    }
    
    
    private func makeRemoteClient() -> Client {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingClient()

        default:
            return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        }
    }
}

extension RemoteLoader: ITGWorkoutKit.WorkoutLoader where Resource == [WorkoutItem] {}

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
