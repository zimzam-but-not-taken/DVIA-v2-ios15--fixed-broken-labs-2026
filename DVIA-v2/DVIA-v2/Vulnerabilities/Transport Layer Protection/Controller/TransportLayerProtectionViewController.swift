//
//  TransportLayerProtectionViewController.swift
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
import Foundation

/// Network layer security: plain HTTP, HTTPS, certificate pinning and public
/// key pinning against https://example.com.
///
/// example.com is served by Cloudflare and its leaf certificate is rotated
/// roughly every 90 days, so pinning is done against the issuing CA chain
/// instead of the leaf. The pins below were generated on 15 Oct 2026 with
/// `update-pins.sh` (next to the Podfile); re-run that script if the
/// "Certificate validation failed" alert starts showing up without a proxy.
class TransportLayerProtectionViewController: UIViewController {

    @IBOutlet var cardNumberTextField: UITextField!
    @IBOutlet var CVVTextField: UITextField!
    @IBOutlet var nameOnCardTextField: UITextField!

    let pinnedHost = "https://example.com/"

    /// SHA-256 of the SubjectPublicKeyInfo, base64 encoded (same format as
    /// HPKP / TrustKit). Any match anywhere in the served chain is accepted.
    let pinnedPublicKeyHashes: Set<String> = [
        "44viFzTC+h/L+3OHRg4Rs5v4+AcpzHZvI9Tne2RDNGk=", // Cloudflare TLS Issuing ECC CA 3 (exp. 2035)
        "OXyj9ngbqO9cjLeO/+t9Ggl2EP4JTnVWHq4LEwhFM9w=", // SSL.com TLS Transit ECC CA R2 (exp. 2037)
    ]

    /// DER encoded certificates used for certificate pinning, in addition to
    /// example.der in the app bundle.
    let pinnedCertificatesBase64: [String] = [
        // Cloudflare TLS Issuing ECC CA 3
        "MIIC4jCCAmmgAwIBAgIQMe7oivuHzZ74M2YEdD+bJzAKBggqhkjOPQQDAzBPMQswCQYDVQQGEwJVUzEYMBYGA1UECgwPU1NMIENvcnBvcmF0aW9uMSYwJAYDVQQDDB1TU0wuY29tIFRMUyBUcmFuc2l0IEVDQyBDQSBSMjAeFw0yNTA1MjkxOTQ5NDVaFw0zNTA1MjcxOTQ5NDRaMFExCzAJBgNVBAYTAlVTMRgwFgYDVQQKDA9TU0wgQ29ycG9yYXRpb24xKDAmBgNVBAMMH0Nsb3VkZmxhcmUgVExTIElzc3VpbmcgRUNDIENBIDMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT9HRQUjiNCkybPcNCJ17Eecqw+XVlSgd8c9dYludZ3B4ULjRKxKz9AuR9yBuD/QFIKk0n4yXGwfu7go0VRGER0o4IBIzCCAR8wEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBQyosfYWIv/f8A88lVpM+zOzB+8lzBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAKGLGh0dHA6Ly9jZXJ0LnNzbC5jb20vU1NMLmNvbS1UTFMtVC1FQ0MtUjIuY2VyMBEGA1UdIAQKMAgwBgYEVR0gADAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwEwPQYDVR0fBDYwNDAyoDCgLoYsaHR0cDovL2NybHMuc3NsLmNvbS9TU0wuY29tLVRMUy1ULUVDQy1SMi5jcmwwHQYDVR0OBBYEFIMD/ef29UpNFUH07SIW0zIKPspmMA4GA1UdDwEB/wQEAwIBhjAKBggqhkjOPQQDAwNnADBkAjBkW/dgTArl36px6LVMWzfHLv0pFD+P9BoOYzirZ2aS2IwsQPHb0rQdZMY5NghTTk4CMCiwDU71fhtYVRulUc575HJroLXgj+BkpkBubdHnb2+aPpCH7LP6QNQ/Xm9NiqdxAw==",
        // SSL.com TLS Transit ECC CA R2
        "MIIDNDCCArmgAwIBAgIQYE2K+NALqHSLlVhTFyxfLjAKBggqhkjOPQQDAzBOMQswCQYDVQQGEwJVUzEYMBYGA1UECgwPU1NMIENvcnBvcmF0aW9uMSUwIwYDVQQDDBxTU0wuY29tIFRMUyBFQ0MgUm9vdCBDQSAyMDIyMB4XDTIyMTAyMTE3MDIyM1oXDTM3MTAxNzE3MDIyMlowTzELMAkGA1UEBhMCVVMxGDAWBgNVBAoMD1NTTCBDb3Jwb3JhdGlvbjEmMCQGA1UEAwwdU1NMLmNvbSBUTFMgVHJhbnNpdCBFQ0MgQ0EgUjIwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAARk532ZA1NckR7q+NgjraG/LOJjie8oaPbt1/Dsq2iudyvkdpcbUOvbWSgtb7g2uauNl8pMIp7uidkCP/16czqQjSvMLzo3g9oNtC1FG3NyCWVfeCE954tmP0f9CSnWFA+jggFZMIIBVTASBgNVHRMBAf8ECDAGAQH/AgEBMB8GA1UdIwQYMBaAFImPL6PoK6AUVHvzVrgmX2c4C5zQMEwGCCsGAQUFBwEBBEAwPjA8BggrBgEFBQcwAoYwaHR0cDovL2NlcnQuc3NsLmNvbS9TU0xjb20tVExTLVJvb3QtMjAyMi1FQ0MuY2VyMD8GA1UdIAQ4MDYwNAYEVR0gADAsMCoGCCsGAQUFBwIBFh5odHRwczovL3d3dy5zc2wuY29tL3JlcG9zaXRvcnkwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMEEGA1UdHwQ6MDgwNqA0oDKGMGh0dHA6Ly9jcmxzLnNzbC5jb20vU1NMY29tLVRMUy1Sb290LTIwMjItRUNDLmNybDAdBgNVHQ4EFgQUMqLH2FiL/3/APPJVaTPszswfvJcwDgYDVR0PAQH/BAQDAgGGMAoGCCqGSM49BAMDA2kAMGYCMQC4SkI+e2cts1nTN9MCRil97z624WxLAp94hT7tNZGPZLe9YiLIyzgKqW/bE0b2h9ACMQCvV5XMRcunAylQaCQc4J/GwR1p7yrPC0DRWWeyLAkQWi5Ylta9DxlX74QFFksFCP0=",
    ]

    // ASN.1 SubjectPublicKeyInfo headers, prepended to the raw key that
    // SecKeyCopyExternalRepresentation returns.
    let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    let rsa4096Asn1Header: [UInt8] = [
        0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
    ]
    let ecP256Asn1Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]
    let ecP384Asn1Header: [UInt8] = [
        0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
    ]

    enum PinningMode {
        case none
        case certificate
        case publicKey
    }
    var pinningMode: PinningMode = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        nameOnCardTextField.delegate = self
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "menu.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(menuTapped(_:)), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Network Layer Security"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = " "
    }

    @IBAction func checkATS(_ sender: Any) {
        DVIAUtilities.showAlert(title: "App Transport Security", message: "ATS establishes best-practice policies for secure network communications. Check whether the app follows these best practices or whether it ignore them. Look at the info.plist file", viewController: self)
    }
    @IBAction func menuTapped(_ sender: Any) {
        mainViewController?.toogle()
    }

    @IBAction func readArticleTapped(_ sender: Any) {
        DVIAUtilities.loadWebView(withURL: UrlLinks.transportLayerArticle.url, viewController: self)
    }

    @IBAction func sendOverHTTPTapped(_ sender: Any) {
        guard let url = URL(string: "http://example.com/") else { return }
        sendRequestOverUrl(url)
    }

    @IBAction func sendOverHTTPSTapped(_ sender: Any) {
        guard let url = URL(string: "https://example.com/") else { return }
        sendRequestOverUrl(url)
    }

    private func validateInput() -> Bool {
        if cardNumberTextField.text?.isEmpty ?? true || nameOnCardTextField.text?.isEmpty ?? true || CVVTextField.text?.isEmpty ?? true {
            DVIAUtilities.showAlert(title: "Error", message: "One or more input fields is empty.", viewController: self)
            return false
        }
        if(!Reachability.isConnectedToNetwork()){
            DVIAUtilities.showAlert(title: "Error", message: "Make sure you are connected to the internet.", viewController: self)
            return false
        }
        return true
    }

    private func cardRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url.standardized, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let postDictionary = [
            "card_number" : cardNumberTextField.text ?? "",
            "card_name" : nameOnCardTextField.text ?? "",
            "card_cvv" : CVVTextField.text ?? ""
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: postDictionary, options: .prettyPrinted)
        return request
    }

    func sendRequestOverUrl(_ url: URL) {
        guard validateInput() else { return }
        let request = cardRequest(for: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString) )")
        }
        task.resume()
        DVIAUtilities.showAlert(title: "", message: "Request Sent, lookout!", viewController: self)
    }

    // MARK: - Pinning helpers

    private func certificates(in trust: SecTrust) -> [SecCertificate] {
        if #available(iOS 15.0, *) {
            return (SecTrustCopyCertificateChain(trust) as? [SecCertificate]) ?? []
        }
        var certificates: [SecCertificate] = []
        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        return certificates
    }

    private func pinnedCertificateData() -> [Data] {
        var pinned: [Data] = []
        if let path = Bundle.main.path(forResource: "example", ofType: "der"),
           let data = FileManager.default.contents(atPath: path) {
            pinned.append(data)
        }
        for base64 in pinnedCertificatesBase64 {
            if let data = Data(base64Encoded: base64) {
                pinned.append(data)
            }
        }
        return pinned
    }

    /// Base64(SHA-256(SubjectPublicKeyInfo)) of the certificate's key.
    private func publicKeyHash(of certificate: SecCertificate) -> String? {
        guard let key = SecCertificateCopyKey(certificate),
              let attributes = SecKeyCopyAttributes(key) as? [String: Any],
              let keyType = attributes[kSecAttrKeyType as String] as? String,
              let keySize = attributes[kSecAttrKeySizeInBits as String] as? Int,
              let keyData = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
            return nil
        }

        let header: [UInt8]
        if keyType == (kSecAttrKeyTypeRSA as String) && keySize == 2048 {
            header = rsa2048Asn1Header
        } else if keyType == (kSecAttrKeyTypeRSA as String) && keySize == 4096 {
            header = rsa4096Asn1Header
        } else if keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) && keySize == 256 {
            header = ecP256Asn1Header
        } else if keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) && keySize == 384 {
            header = ecP384Asn1Header
        } else {
            return nil
        }

        var spki = Data(header)
        spki.append(keyData)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        spki.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(spki.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }

    func chainMatchesPinnedCertificate(_ trust: SecTrust) -> Bool {
        let pinned = pinnedCertificateData()
        for certificate in certificates(in: trust) {
            let remote = SecCertificateCopyData(certificate) as Data
            if pinned.contains(remote) {
                return true
            }
        }
        return false
    }

    func chainMatchesPinnedPublicKey(_ trust: SecTrust) -> Bool {
        for certificate in certificates(in: trust) {
            if let hash = publicKeyHash(of: certificate) {
                print("Public key pin candidate: \(hash)")
                if pinnedPublicKeyHashes.contains(hash) {
                    return true
                }
            }
        }
        return false
    }
}

extension TransportLayerProtectionViewController: UITextFieldDelegate, NSURLConnectionDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func send(usingSSLPinning sender: Any) {
        guard validateInput() else { return }
        pinningMode = .certificate
        let request = cardRequest(for: URL(string: pinnedHost)!)
        let connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
    }

    @IBAction func send(usingPublicKeyPinning sender: Any) {
        guard validateInput() else { return }
        pinningMode = .publicKey
        let request = cardRequest(for: URL(string: pinnedHost)!)
        let connection = NSURLConnection(request: request, delegate: self)
        connection?.start()
    }

    // MARK: NSURLConnection Delegate Methods

    func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
        // Return nil to indicate not necessary to store a cached response for this connection
        return nil
    }

    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        pinningMode = .none
    }

    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Pinned request failed: \(error)")
        pinningMode = .none
    }

    func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            challenge.sender?.performDefaultHandling?(for: challenge)
            return
        }

        switch pinningMode {
        case .certificate:
            if chainMatchesPinnedCertificate(serverTrust) {
                DVIAUtilities.showAlert(title: "", message: "Request Sent using Certificate pinning, lookout!", viewController: self)
                challenge.sender?.use(URLCredential(trust: serverTrust), for: challenge)
            } else {
                DVIAUtilities.showAlert(title: "", message: "Certificate validation failed. You will have to do better than this!!", viewController: self)
                challenge.sender?.cancel(challenge)
            }
        case .publicKey:
            if chainMatchesPinnedPublicKey(serverTrust) {
                DVIAUtilities.showAlert(title: "", message: "Request Sent using Public Key Pinning, lookout!", viewController: self)
                challenge.sender?.use(URLCredential(trust: serverTrust), for: challenge)
            } else {
                DVIAUtilities.showAlert(title: "", message: "Certificate validation failed. You will have to do better than this!!", viewController: self)
                challenge.sender?.cancel(challenge)
            }
        case .none:
            challenge.sender?.performDefaultHandling?(for: challenge)
        }
    }
}
