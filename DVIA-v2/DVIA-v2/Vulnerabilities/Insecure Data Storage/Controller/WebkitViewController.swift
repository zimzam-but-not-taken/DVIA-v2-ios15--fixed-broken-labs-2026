//
//  WebkitViewController.swift
//  DVIA - Damn Vulnerable iOS App (damnvulnerableiosapp.com)
//  Created by Prateek Gianchandani on 14/12/17.
//  Copyright © 2018 HighAltitudeHacks. All rights reserved.
//  You are free to use this app for commercial or non-commercial purposes
//  You are also allowed to use this in trainings
//  However, if you benefit from this project and want to make a contribution, please consider making a donation to The Juniper Fund (www.thejuniperfund.org/)
//  The Juniper fund is focusing on Nepali workers involved with climbing and expedition support in the high mountains of Nepal. When a high altitude worker has an accident (death or debilitating injury), the impact to the family is huge. The juniper fund provides funds to the affected families and help them set up a sustainable business.
//  For more information,  visit www.thejuniperfund.org
//  Or watch this video https://www.youtube.com/watch?v=HsV6jaA5J2I
//  And this https://www.youtube.com/watch?v=6dHXcoF590E


import UIKit
import WebKit

/// Webkit caching challenge.
///
/// The original storyboard scene only contained a description label and the
/// controller was empty, so nothing was ever written to the cache. This
/// implementation submits the credentials as query parameters over HTTPS and
/// deliberately caches the request/response pair through the shared
/// `URLCache`. CFNetwork persists that cache to
/// `<sandbox>/Library/Caches/<bundle id>/Cache.db`, in tables whose names
/// start with `cfurl_cache_` (response, receiver_data, blob_data). The same
/// page is also rendered in a `WKWebView`, whose own cache ends up under
/// `<sandbox>/Library/Caches/WebKit/` and `<sandbox>/Library/WebKit/`.
class WebkitViewController: UIViewController, UITextFieldDelegate {

    // Any host that answers a GET with a cacheable 200 works here.
    private let loginEndpoint = "https://example.com/login"

    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "WebKit"
        self.edgesForExtendedLayout = []
        buildUserInterface()
    }

    // MARK: - UI

    private func buildUserInterface() {
        // The storyboard scene has a container view with a single description
        // label. Anchor the form below that label so the text stays readable.
        let descriptionLabel = findLabel(in: view)

        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.delegate = self

        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self

        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.addTarget(self, action: #selector(loginTapped(_:)), for: .touchUpInside)

        let form = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, loginButton])
        form.axis = .vertical
        form.spacing = 12
        form.translatesAutoresizingMaskIntoConstraints = false

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()   // persistent, on-disk store
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.borderWidth = 0.5
        webView.layer.borderColor = UIColor.lightGray.cgColor

        view.addSubview(form)
        view.addSubview(webView)

        let guide = view.safeAreaLayoutGuide
        let topAnchor: NSLayoutYAxisAnchor = descriptionLabel?.bottomAnchor ?? guide.topAnchor
        NSLayoutConstraint.activate([
            form.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            form.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            form.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            webView.topAnchor.constraint(equalTo: form.bottomAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8),
            webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8),
            webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8)
        ])
    }

    private func findLabel(in root: UIView) -> UILabel? {
        for subview in root.subviews {
            if let label = subview as? UILabel { return label }
            if let nested = findLabel(in: subview) { return nested }
        }
        return nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Actions

    @objc func loginTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            DVIAUtilities.showAlert(title: "Error", message: "One or more input fields is empty.", viewController: self)
            return
        }
        if !Reachability.isConnectedToNetwork() {
            DVIAUtilities.showAlert(title: "Error", message: "Make sure you are connected to the internet.", viewController: self)
            return
        }
        view.endEditing(true)

        // Credentials go into the query string, which is exactly what gets cached.
        var components = URLComponents(string: loginEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        guard let url = components.url else { return }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "GET"

        // 1. Render through WebKit (WebKit's own on-disk cache).
        webView.load(request)

        // 2. Fetch through CFNetwork and force the response into the shared
        //    URLCache (Library/Caches/<bundle>/Cache.db, cfurl_cache_* tables).
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    DVIAUtilities.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)", viewController: self)
                }
                return
            }
            if let data = data, let response = response {
                let cached = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowed)
                URLCache.shared.storeCachedResponse(cached, for: request)
            }
            DispatchQueue.main.async {
                DVIAUtilities.showAlert(title: "", message: "Login request sent. The response has now been cached locally.", viewController: self)
            }
        }
        task.resume()
    }
}
