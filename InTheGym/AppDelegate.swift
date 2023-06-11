 //
//  AppDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import RevenueCat
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var coordinator: MainCoordinator?
    var baseController: BaseControllerCoordinator?
    var navigationController: UINavigationController = UINavigationController()
    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.MessageID_Key"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        launchScreen()
        // setup revenue cat
        Purchases.logLevel = .debug
//        UserObserver.shared.checkForUserDefault()
//        Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)
        
        // For iOS 10 display notification (sent via APNS)
        // register for Push Notifications
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self

        return true
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
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
//        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {})
    }
    func loggedInPlayer() {
        let navController = UINavigationController()
        let mainPlayerCoordinator = MainPlayerCoordinator(navigationController: navController)
        mainPlayerCoordinator.start()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = navController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {})
    }
    func loggedInCoach() {
        let navController = UINavigationController()
        let mainCoachCoordinator = MainCoachCoordinator(navigationController: navController)
        mainCoachCoordinator.start()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = navController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {})
    }
    func nilUser() {
        let navController = UINavigationController()
        let _ = LoginComposition(navigationController: navController).loginKitInterface.compose()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = navController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {})
    }
    func accountCreation(email: String, uid: String) {
        let navController = UINavigationController()
        let _ = AccountCreationComposition(navigationController: navController, email: email, uid: uid).accountCreationKitInterface.compose()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = navController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {})
    }
    func verifyScreen() {
        let vc = VerifyAccountViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {})
    }
    func accountCreatedScreen() {
        let vc = AccountCreatedViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window else {return}
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {})
    }
    
    func makeBaseCoordinator() -> BaseControllerCoordinator {

        let coordinator = BaseControllerCoordinator(navigationController: navigationController)
        
        let cache = UserCacheServiceAdapter()
        let cacheSaver = UserDefaultsCacheUserSaver()
        
        let api = UserAPIServiceAdapter(
            authService: FirebaseAuthManager.shared,
            firestoreService: FirestoreManager.shared)
                
        let observer = UserChangeAPIServiceAdapter(
            authService: FirebaseAuthManager.shared,
            firestoreService: FirestoreManager.shared)

        coordinator.userService = cache.fallback(api)
        coordinator.observerService = observer
        coordinator.cacheSaver = cacheSaver
        
        return coordinator
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "InTheGym")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        return [[.alert, .sound, .badge]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }

}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}


protocol UserService {
    func loadUser() async throws -> Users
}

extension UserService {
    func fallback(_ fallback: UserService) -> UserService {
        UserServiceWithFallback(primary: self, fallback: fallback)
    }
}

struct UserServiceWithFallback: UserService {
    var primary: UserService
    var fallback: UserService
    
    func loadUser() async throws -> Users {
        do {
            let primary = try await primary.loadUser()
            return primary
        } catch {
            return try await fallback.loadUser()
        }
    }
}

protocol ObserveUserService {
    func observeChange(completion: @escaping (Result<Users,UserStateError>) -> Void)
}

struct UserCacheServiceAdapter: UserService {
    
    func loadUser() async throws -> Users {
        if UserDefaults.currentUser == Users.nilUser {
            throw NSError(domain: "No user in UserDefaults", code: 0)
        } else {
            return UserDefaults.currentUser
        }
    }
}

struct UserAPIServiceAdapter: UserService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func loadUser() async throws -> Users {
        let firebaseUser = try await authService.checkForCurrentUser()
        let userModel: Users = try await firestoreService.read(at: "Users/\(firebaseUser.uid)")
        return userModel
    }
}

struct UserChangeAPIServiceAdapter: ObserveUserService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func observeChange(completion: @escaping (Result<Users,UserStateError>) -> Void) {
        authService.observeCurrentUser { auth, user in
            guard let user else {
                completion(.failure(.noUser))
                return
            }
            if user.isEmailVerified {
                loadUserModel(from: user.uid, completion: completion)
            } else {
                completion(.failure(.notVerified))
            }
        }
    }
    
    private func loadUserModel(from uid: String, completion: @escaping (Result<Users,UserStateError>) -> Void) {
        Task {
            do {
                let userModel: Users = try await firestoreService.read(at: "Users/\(uid)")
                completion(.success(userModel))
            } catch {
                completion(.failure(.noAccount))
            }
        }
        
    }
}

enum UserStateError: Error {
    case noUser
    case notVerified
    case noAccount
}


protocol CacheUserSaver {
    func save(_ user: Users)
}

struct UserDefaultsCacheUserSaver: CacheUserSaver {
    
    /// save given user model to cache - UserDefaults
    /// - Parameter user: optional user model to save - nil to remove
    func save(_ user: Users) {
        UserDefaults.currentUser = user
    }
}
