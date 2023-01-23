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
import GoogleSignIn

@objc(SignInViewController)
class SignInViewController: UIViewController {
    @IBOutlet weak var signInButton: GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
                MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: self)
                
            }
        }
    }
    
    @objc func googleSignIn(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self){ result, error in
            guard error == nil else {
                fatalError("Error signing in with google : \(String(describing: error?.localizedDescription))")
            }
            let credential = GoogleAuthProvider.credential(withIDToken: (result?.user.idToken!.tokenString)!, accessToken: (result?.user.accessToken.tokenString)!)
            // result unused
            FirebaseAuth.Auth.auth().signIn(with: credential)
        }
    }
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
