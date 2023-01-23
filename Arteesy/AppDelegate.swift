//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

import Firebase
import FirebaseMessaging
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            print("\n\n Dynamic Link url : \(String(describing: dynamicLink.url)) \n\n")
            return true
        }
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            print(dynamiclink?.url ?? "no dynamic url found")
        }
        return handled
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        if let clientId = FirebaseApp.app()?.options.clientID{
            GIDSignIn.sharedInstance.configuration = GIDConfiguration.init(clientID: clientId)
        }
        
        //GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
        //GIDSignIn.sharedInstance.delegate = self
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("\n\n Firebase registration token: \(String(describing: fcmToken))\n\n")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Error \(error)")
            return
        }
        guard let authentication = user else { return }
        guard let tokenString = authentication.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: tokenString,
                                                       accessToken: authentication.accessToken.tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error \(error)")
                return
            }
        }
    }
}
