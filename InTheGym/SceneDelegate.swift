//
//  SceneDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit
import Combine
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
    
    let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    
    private lazy var remoteFeedLoader = RemoteLoader(client: client, path: remoteURL.absoluteString, mapper: WorkoutItemsMapper.map)
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(client: Client, httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.client = client
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        launchEssentialFeed()

    }
    
    func launchEssentialFeed() {
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)

        let localImageLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(
            rootViewController:
                FeedUIComposer.feedComposedWith(
                    feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                    imageLoader: makeLocalImageLoaderWithRemoteFallback)
            )
        
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
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> ITGWorkoutKit.WorkoutLoader.Publisher {

         return remoteFeedLoader
             .loadPublisher()
             .caching(to: localFeedLoader)
             .fallback(to: localFeedLoader.loadPublisher)
     }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}

extension RemoteLoader: ITGWorkoutKit.WorkoutLoader where Resource == [WorkoutItem] {}

public extension ITGWorkoutKit.WorkoutLoader {
    typealias Publisher = AnyPublisher<[WorkoutItem], Error>

    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [WorkoutItem] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [WorkoutItem]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {

    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }

            action()
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>

    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
