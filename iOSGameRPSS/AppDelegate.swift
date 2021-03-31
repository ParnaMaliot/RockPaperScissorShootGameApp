//
//  AppDelegate.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import SwiftMessages

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        Messaging.messaging().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device token: \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Getting push notification error:")
        print(error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }
    
    private func saveTokenForUser(deviceToken: String) {
        guard DataStore.shared.localUser != nil else {return}
        
        DataStore.shared.localUser?.deviceToken = deviceToken
        DataStore.shared.saveUser(user: DataStore.shared.localUser!) { (_, _) in
        }
    }
    
    func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if success {
                self.checkNotificationSettings()
            }
        }
    }
    
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings {settings in
            guard settings.authorizationStatus == .authorized else {return}
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func checkForEnabledPushNotifications(completion: @escaping(_ enabled: Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                //let enabled = completion(settings.authorizationStatus == .authorized)
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        saveTokenForUser(deviceToken: fcmToken)
    }
    
    private func showInAppNotification(requestId: String, fromUsername: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        config.dimMode = .gray(interactive: true)
        //config.duration = .seconds(seconds: 2.0)
        config.duration = .forever
        config.presentationStyle = .top
        
        view.configureContent(title: "New Game Request",
                              body: "\(fromUsername) invited you for a game",
                              iconImage: nil,
                              iconText: nil,
                              buttonImage: nil,
                              buttonTitle: "Accept") { _ in
            //Click on Accept Button handler
            SwiftMessages.hide()
            DataStore.shared.getGameRequestWithId(id: requestId) { (request, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let request = request {
                    NotificationCenter.default.post(name: Notification.Name("AcceptGameRequestNotification"),
                                                    object: nil, userInfo: ["GameRequest" : request])
                }
            }
        }
        SwiftMessages.show(config: config, view: view)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active{
            //show swift message
            guard let dict = notification.request.content.userInfo as? [String:Any],
                  let requestId = dict["id"] as? String,
                  let fromUserName = dict["fromUsername"] as? String else {
                return
            }
            showInAppNotification(requestId: requestId, fromUsername: fromUserName)
            completionHandler([.sound])
            return
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            guard let dict = response.notification.request.content.userInfo as? [String: Any] else {return}
            
            //Local VS Remote notification
//            if let aps = dict["aps"] as? [String:Any] {
//                //remote notification
//            } else {
//                //local notification
//            }
            PushNotificationManager.shared.handlePushNotification(dict: dict)
            print(dict)
            print("Did click on notification")

        default:
            break
        }
    }
}
