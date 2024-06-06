//
//  SceneDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var coordinator: MainCoordinator?
    var baseController: BaseController?
    var navigationController: UINavigationController = UINavigationController()
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            launchScreen()
        }
        
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

