//
//  SceneDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var coordinator: MainCoordinator?
    var baseController: BaseController?
    var navigationController: UINavigationController = UINavigationController()
    
    var window: UIWindow?
    
    private lazy var purchaseManager: PurchaseManager = {
#if EMULATOR
        return EmulatorPurchaseManager()
#else
        return StoreKitPurchaseManager()
#endif
    }()

    /// The app's one analytics write — see `AppOpenRecorder`.
    private lazy var appOpenRecorder: AppOpenRecorder = {
        let currentUserId = { Auth.auth().currentUser?.uid }
        return OncePerDayAppOpenRecorder(
            wrapping: FirestoreAppOpenRecorder(currentUserId: currentUserId),
            currentUserId: currentUserId)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        
        launchScreen()
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
        
//        let subscriptionManager = SubscriptionManager.shared
        
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
            accountCreationComposer: accountCreationComposer,
            subscriptionManager: purchaseManager) { [weak controller] in
                controller?.reloadUser()
            } userLoggedIn: { [weak controller, weak self] in
                controller?.loadUser()
                // Signing in is opening the app for this account, and the
                // scene was already active, so sceneDidBecomeActive missed it.
                self?.recordAppOpen()
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
//        controller.subscriptionManager = subscriptionManager
        
        return controller
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        recordAppOpen()
    }

    private func recordAppOpen() {
        Task { [appOpenRecorder] in
            do {
                try await appOpenRecorder.recordOpen()
            } catch {
                // Not remembered, so the next open tries again.
                print("❌ Recording app open: \(error)")
            }
        }
    }
}
