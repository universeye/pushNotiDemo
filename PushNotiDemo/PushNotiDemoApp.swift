//
//  PushNotiDemoApp.swift
//  PushNotiDemo
//
//  Created by Terry Kuo on 2022/4/14.
//

import SwiftUI
import Firebase
import FirebaseMessaging

@main
struct PushNotiDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


//MARK: - AppDelegate
//Initializing Firebase And Cloud Messaging...

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    //MARK: didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        //Setting Up Cloud Messaging...
        
        Messaging.messaging().delegate = self
        
        //Setting Up Notifications..
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        return true
    }
    
    //MARK: didReceiveRemoteNotification
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //Do something with message Data Here...
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //MARK: didFailToRegisterForRemoteNotificationsWithError
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    //MARK: didRegisterForRemoteNotificationsWithDeviceToken
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Messaging.messaging().apnsToken = deviceToken;
    }
    
}

//MARK: - Cloud Messaging...
extension AppDelegate: MessagingDelegate {
    
    //MARK: didReceiveRegistrationToken
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
        
        //Store token in Firestore For Sending Notifications From server in the Future...
        
        print(dataDict)
        
        Messaging.messaging().subscribe(toTopic: "GA2000") { err in
            if let err = err {
                print(err.localizedDescription)
            }
            
            print("Subscribed to Topic")
        }
    }
    
}

//MARK: - User Notifications...[AKA InApp Notifications]
extension AppDelegate: UNUserNotificationCenterDelegate {
    //MARK: userNotificationCenter - willPresent
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner,.badge, .sound]])
    }
    
    //MARK: userNotificationCenter - didReceive
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
    
    //    func application(_ application: UIApplication,
    //    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    //       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //      Messaging.messaging().appDidReceiveMessage(userInfo) //To pass notification reciept information to Analytics,
    //      completionHandler(.noData)
    //    }
}

