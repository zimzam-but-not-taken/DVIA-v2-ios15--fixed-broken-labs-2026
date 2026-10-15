//
//  JailbreakDetectionViewController.swift
//  Created by Prateek Gianchandani on 23/11/17.
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

/// Five jailbreak checks, each implemented slightly differently so that they
/// have to be bypassed in different ways:
///   1. a plain Swift method (hook it)
///   2. an Objective-C class method (swizzle it)
///   3. an inlined function (patch the binary)
///   4. a check that exits the app a few seconds after detection
///   5. the same check with obfuscated strings
///
/// All of them know about both rootful (/) and rootless (/var/jb) layouts,
/// so they work on modern jailbreaks such as Dopamine, palera1n and
/// unc0ver/Taurine as well as the classic Cydia-based ones.
class JailbreakDetectionViewController: UIViewController {
    let o = Obfuscator(withSalt: [AppDelegate.self, NSObject.self, NSString.self])

    struct Constants {
        /*Original /Applications/Cydia.app*/
        static let everest: [UInt8] = [116, 5, 38, 57, 45, 54, 21, 83, 90, 40, 31, 30, 55, 74, 47, 28, 3, 8, 21, 75, 77, 80, 62]
        /*Original /Library/MobileSubstrate/MobileSubstrate.dylib*/
        static let k2: [UInt8] = [116, 8, 63, 43, 51, 62, 4, 75, 1, 12, 31, 18, 45, 9, 9, 54, 18, 3, 7, 17, 94, 65, 58, 54, 96, 47, 5, 7, 10, 24, 73, 115, 59, 49, 32, 0, 0, 8, 26, 2, 115, 63, 61, 58, 32, 35]
        /*Original /bin/bash*/
        static let Kangchenjunga: [UInt8] = [116, 38, 63, 39, 110, 61, 23, 65, 70]
        /*Original /usr/sbin/sshd*/
        static let Lhotse: [UInt8] = [116, 49, 37, 59, 110, 44, 20, 91, 64, 110, 3, 3, 44, 1]
        /*Original /etc/apt*/
        static let Makalu: [UInt8] = [116, 33, 34, 42, 110, 62, 6, 70]
        /*Original /private/jailbreak.txt*/
        static let ChoOyu: [UInt8] = [116, 52, 36, 32, 55, 62, 2, 87, 1, 43, 17, 25, 40, 7, 30, 0, 6, 10, 90, 17, 84, 84]
        /*Original cydia://package/com.example.package*/
        static let Dhaulagiri: [UInt8] = [56, 61, 50, 32, 32, 101, 89, 29, 94, 32, 19, 27, 37, 2, 9, 74, 4, 14, 25, 75, 73, 88, 47, 62, 63, 14, 15, 75, 19, 21, 79, 75, 47, 52, 54]
        /*Original /var/jb/Applications/Sileo.app*/
        static let Annapurna: [UInt8] = [116, 50, 55, 59, 110, 53, 20, 29, 111, 49, 0, 28, 45, 6, 13, 17, 14, 14, 26, 22, 3, 115, 39, 63, 42, 13, 68, 4, 19, 4]
        /*Original /var/jb/Library/MobileSubstrate/MobileSubstrate.dylib*/
        static let Manaslu: [UInt8] = [116, 50, 55, 59, 110, 53, 20, 29, 98, 40, 18, 2, 37, 23, 21, 74, 42, 14, 22, 12, 64, 69, 29, 38, 45, 17, 30, 23, 2, 0, 73, 15, 3, 60, 49, 29, 30, 12, 61, 18, 63, 40, 48, 36, 40, 53, 58, 88, 86, 87, 45, 25, 18]
        /*Original /var/jb/usr/lib/libellekit.dylib*/
        static let NangaParbat: [UInt8] = [116, 50, 55, 59, 110, 53, 20, 29, 91, 50, 2, 95, 40, 12, 14, 74, 11, 8, 22, 0, 64, 76, 43, 56, 38, 22, 68, 1, 26, 24, 69, 66]
        /*Original /var/jb/usr/bin/ssh*/
        static let Gasherbrum: [UInt8] = [116, 50, 55, 59, 110, 53, 20, 29, 91, 50, 2, 95, 38, 12, 2, 74, 20, 18, 28]
        /*Original /var/jb/etc/apt*/
        static let BroadPeak: [UInt8] = [116, 50, 55, 59, 110, 53, 20, 29, 75, 53, 19, 95, 37, 21, 24]
        /*Original sileo://package/com.example.package*/
        static let Shishapangma: [UInt8] = [40, 45, 58, 44, 46, 101, 89, 29, 94, 32, 19, 27, 37, 2, 9, 74, 4, 14, 25, 75, 73, 88, 47, 62, 63, 14, 15, 75, 19, 21, 79, 75, 47, 52, 54]
        /*Original /Applications/Sileo.app*/
        static let Nuptse: [UInt8] = [116, 5, 38, 57, 45, 54, 21, 83, 90, 40, 31, 30, 55, 74, 63, 12, 11, 4, 27, 75, 77, 80, 62]
        /*Original /.installed_palera1n*/
        static let Pumori: [UInt8] = [116, 106, 63, 39, 50, 43, 23, 94, 66, 36, 20, 47, 52, 4, 0, 0, 21, 0, 69, 11]
    }

    // To regenerate the byte arrays above:
    //   let bytes = o.bytesByObfuscatingString(string: "/some/path")
    //   print(bytes)

    /// Files and directories that only exist on a jailbroken device.
    static let jailbreakPaths: [String] = [
        // Rootful (classic) layout
        "/Applications/Cydia.app",
        "/Applications/Sileo.app",
        "/Applications/Zebra.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/Library/MobileSubstrate/DynamicLibraries",
        "/usr/lib/libhooker.dylib",
        "/usr/lib/libsubstitute.dylib",
        "/usr/lib/substrate",
        "/usr/lib/TweakInject",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/usr/bin/ssh",
        "/etc/apt",
        "/private/var/lib/apt",
        "/.installed_unc0ver",
        "/.bootstrapped_electra",
        // Rootless layout (Dopamine, palera1n rootless, ...)
        "/var/jb",
        "/var/jb/Applications/Sileo.app",
        "/var/jb/Applications/Zebra.app",
        "/var/jb/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/var/jb/Library/MobileSubstrate/DynamicLibraries",
        "/var/jb/usr/lib/libellekit.dylib",
        "/var/jb/usr/lib/libhooker.dylib",
        "/var/jb/usr/lib/libsubstrate.dylib",
        "/var/jb/usr/bin/ssh",
        "/var/jb/usr/sbin/sshd",
        "/var/jb/etc/apt",
        "/var/jb/.installed_dopamine",
        "/.installed_palera1n",
        "/var/mobile/Library/palera1n",
        "/cores/binpack",            // palera1n bootstrap
        "/var/jb/basebin/jailbreakd"  // Dopamine
    ]

    /// URL schemes registered by package managers. They must also be listed
    /// under LSApplicationQueriesSchemes in Info.plist, otherwise canOpenURL
    /// always returns false.
    static let jailbreakURLSchemes: [String] = [
        "cydia://package/com.example.package",
        "sileo://package/com.example.package",
        "zbra://",
        "filza://",
        "undecimus://"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        //Bug Fix if view goes under the navigation bar
        self.edgesForExtendedLayout = []
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "menu.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(menuTapped(_:)), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        button.widthAnchor.constraint(equalToConstant: 28).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Jailbreak Detection"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = " "
    }

    @IBAction func menuTapped(_ sender: Any) {
        mainViewController?.toogle()
    }

    @IBAction func readArticleTapped(_ sender: Any) {
        let url = UrlLinks.jailbreakDetetionArticle.url
        DVIAUtilities.loadWebView(withURL: url, viewController: self)
    }

    // MARK: - Test 1: plain Swift method

    @IBAction func jailbreakTest1Tapped(_ sender: Any) {
        DVIAUtilities.showAlert(forJailbreakTestIsJailbroken: isJailbroken(), viewController: self)
    }

    func isJailbroken() -> Bool {
        #if !targetEnvironment(simulator)
            let fileManager = FileManager.default
            for path in JailbreakDetectionViewController.jailbreakPaths {
                if fileManager.fileExists(atPath: path) {
                    return true
                }
            }

            // Can we write outside the sandbox?
            let stringToBeWritten = "This is a test."
            do {
                try stringToBeWritten.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
                try? fileManager.removeItem(atPath: "/private/jailbreak.txt")
                return true
            } catch {
                // expected on a non-jailbroken device
            }

            // Is a package manager installed?
            for scheme in JailbreakDetectionViewController.jailbreakURLSchemes {
                if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                    return true
                }
            }
        #endif
        //All checks have failed. Most probably, the device is not jailbroken
        return false
    }

    // MARK: - Test 2: Objective-C class method

    @IBAction func jailbreakTest2Tapped(_ sender: Any) {
        DVIAUtilities.showAlert(forJailbreakTestIsJailbroken: JailbreakDetection.isJailbroken(), viewController: self)
    }

    // MARK: - Test 3: inlined check

    @IBAction func jailbreakTest3Tapped(_ sender: Any) {
        jailbreakTest3()
    }

    @inline(__always) func jailbreakTest3() {
        var isJailbroken: Bool = false
        #if !targetEnvironment(simulator)
            for path in JailbreakDetectionViewController.jailbreakPaths {
                if FileManager.default.fileExists(atPath: path) {
                    isJailbroken = true
                    break
                }
            }

            var error: Error?
            let stringToBeWritten = "This is a test."
            do {
                try stringToBeWritten.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
            } catch let err {
                error = err
            }

            if error == nil {
                //Device is jailbroken
                isJailbroken = true
                try? FileManager.default.removeItem(atPath: "/private/jailbreak.txt")
            }
            for scheme in JailbreakDetectionViewController.jailbreakURLSchemes {
                if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                    isJailbroken = true
                }
            }
        #endif

        if isJailbroken {
            let alertController = UIAlertController(title: "", message: "Device is Jailbroken, the application will now exit", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "", message: "Device is Not Jailbroken", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Test 4: exits the application

    @IBAction func jailbreakTest4Tapped(_ sender: Any) {
        var isJailbroken: Bool = false
        #if !targetEnvironment(simulator)
            for path in JailbreakDetectionViewController.jailbreakPaths {
                if FileManager.default.fileExists(atPath: path) {
                    isJailbroken = true
                    break
                }
            }

            var error: Error?
            let stringToBeWritten = "This is a test."
            do {
                try stringToBeWritten.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
            } catch let err {
                error = err
            }

            if error == nil {
                //Device is jailbroken
                isJailbroken = true
                try? FileManager.default.removeItem(atPath: "/private/jailbreak.txt")
            }
            for scheme in JailbreakDetectionViewController.jailbreakURLSchemes {
                if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                    isJailbroken = true
                }
            }
        #endif

        if isJailbroken {
            let alertController = UIAlertController(title: "", message: "Device is Jailbroken, Exiting !", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                exit(0)
            })
        }
        else {
            let alertController = UIAlertController(title: "", message: "Device is Not Jailbroken", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Test 5: obfuscated strings

    @IBAction func jailbreakTest5Tapped(_ sender: Any) {
        var fontColor: Bool = false
        #if !targetEnvironment(simulator)
            let peaks: [[UInt8]] = [
                Constants.everest, Constants.k2, Constants.Kangchenjunga, Constants.Lhotse, Constants.Makalu,
                Constants.Annapurna, Constants.Manaslu, Constants.NangaParbat, Constants.Gasherbrum,
                Constants.BroadPeak, Constants.Nuptse, Constants.Pumori
            ]
            for peak in peaks where FileManager.default.fileExists(atPath: o.reveal(key: peak)) {
                fontColor = true
                break
            }

            var error: Error?
            let stringToBeWritten = "77008hbggfhvg"
            do {
                try stringToBeWritten.write(toFile: o.reveal(key: Constants.ChoOyu), atomically: true, encoding: .utf8)
            } catch let err {
                error = err
            }

            if error == nil {
                //Device is jailbroken
                fontColor = true
                try? FileManager.default.removeItem(atPath: o.reveal(key: Constants.ChoOyu))
            }
            for scheme in [Constants.Dhaulagiri, Constants.Shishapangma] {
                if let url = URL(string: o.reveal(key: scheme)), UIApplication.shared.canOpenURL(url) {
                    //Device is jailbroken
                    fontColor = true
                }
            }
        #endif

        if fontColor {
            let alertController = UIAlertController(title: "", message: "Oops, something went wrong, the application will now exit!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                exit(0)
            })
        }
        else {
            let alertController = UIAlertController(title: "", message: "Device is Not Jailbroken", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }

}
