//
//  DeviceLogsViewController.swift
//  Created by Prateek Gianchandani on 14/12/17.
//  DVIA - Damn Vulnerable iOS App (damnvulnerableiosapp.com)
//  Copyright © 2018 HighAltitudeHacks. All rights reserved.
//  You are free to use this app for commercial or non-commercial purposes
//  You are also allowed to use this in trainings
//  However, if you benefit from this project and want to make a contribution, please consider making a donation to The Juniper Fund (www.thejuniperfund.org/)
//  The Juniper fund is focusing on Nepali workers involved with climbing and expedition support in the high mountains of Nepal. When a high altitude worker has an accident (death or debilitating injury), the impact to the family is huge. The juniper fund provides funds to the affected families and help them set up a sustainable business.
//  For more information,  visit www.thejuniperfund.org
//  Or watch this video https://www.youtube.com/watch?v=HsV6jaA5J2I
//  And this https://www.youtube.com/watch?v=6dHXcoF590E


import UIKit
import os.log

/// Side channel data leakage: sensitive data written to the device logs.
///
/// The original implementation saved the user through the Parse SDK, but
/// Parse was never initialised in the AppDelegate (there is no backend), so
/// `saveInBackground` crashed the app. The sign-up now only logs the data,
/// which is what the exercise is about anyway.
class DeviceLogsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var phoneNoTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!

    private let log = OSLog(subsystem: "com.highaltitudehacks.DVIAswiftv2", category: "signup")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Device Logs"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }

    @IBAction func signupTapped(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let phone = phoneNoTextField.text, !phone.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            DVIAUtilities.showAlert(title: "Error", message: "One or more input fields is empty.", viewController: self)
            return
        }
        signUpButton.setTitle("Signing Up ...", for: .normal)

        let user: [String: String] = ["name": name, "password": password, "phone": phone, "email": email]

        // Three different logging APIs, all of which end up in the unified log
        // (visible with Console.app, `idevicesyslog`, or `log stream`).
        print("user saved: \(user)")
        NSLog("Saved user info: %@", user.description)
        // %{public} makes the values visible without a debugger attached.
        os_log("Saved user info: name=%{public}@ password=%{public}@ phone=%{public}@ email=%{public}@",
               log: log, type: .info, name, password, phone, email)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.signUpButton.setTitle("Sign Up", for: .normal)
            DVIAUtilities.showAlert(title: "Success", message: "User signed up successfully, look for the logs now", viewController: self)
        }
    }
}
