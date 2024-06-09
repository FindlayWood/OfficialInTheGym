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
    
    private lazy var client: Client = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient2(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    convenience init(client: Client, httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.client = client
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            
            configureWindow()
        }
    }
    
    func configureWindow() {
        launchEssentialFeed()

    }
    
    func launchEssentialFeed() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

//        let remoteClient = makeRemoteClient()
//        let imageClient = makeRemoteHTTPClient()
        let remoteFeedLoader = RemoteLoader(client: client, path: remoteURL.absoluteString, mapper: WorkoutItemsMapper.map)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        

        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(
            rootViewController:
                FeedUIComposer.feedComposedWith(
                    feedLoader: FeedLoaderWithFallbackComposite(
                        primary: FeedLoaderCacheDecorator(
                            decoratee: remoteFeedLoader,
                            cache: localFeedLoader),
                        fallback: localFeedLoader),
                    imageLoader: FeedImageDataLoaderWithFallbackComposite(
                        primary: localImageLoader,
                        fallback: FeedImageDataLoaderCacheDecorator(
                            decoratee: remoteImageLoader,
                            cache: localImageLoader))))
        
        
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
}

extension RemoteLoader: ITGWorkoutKit.WorkoutLoader where Resource == [WorkoutItem] {}
