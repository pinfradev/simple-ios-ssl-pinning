//
//  ServiceManager.swift
//  pinning-prueba
//
//  Created by Fray Pineda on 27/12/21.
//

import Foundation

class ServiceManager: NSObject {
    
    private var isCertificatePinning = false
    
    func callAPI(
        withURL url: URL,
        isCertificatePinning: Bool,
        completion: @escaping (String) -> ()) {
        
            let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
            
            self.isCertificatePinning = isCertificatePinning
            
            var responseMessage = ""
            
            let task = session.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    print("error: \(error?.localizedDescription): \(error!)")
                    
                    responseMessage = "Pinning failed"
                } else if data != nil {
                    let str = String(decoding: data!, as: UTF8.self)
                    
                    print("Receiverd data: \n\(str)")
                    
                    if isCertificatePinning {
                        responseMessage = "Certificate pinning is successfully completed"
                    } else {
                        responseMessage = "Public key pinning is successfully completed"
                    }
                }
                
                DispatchQueue.main.async {
                    completion(responseMessage)
                }
            }
            
            task.resume()
    }
}

extension ServiceManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if isCertificatePinning {
            var certificate: SecCertificate?
            

           
            if #available(iOS 15, *) {
                let certs = SecTrustCopyCertificateChain(serverTrust)! as NSArray as? [SecCertificate]
                let cert = certs?[0]
                certificate = cert
            } else {
                certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            }
            //SSL Policies for domain name check? para que
            
            let policy = NSMutableArray()
            
            policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
            
            //evaluate server certificate
            
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            
            //Local and remote certificate Data
            
            let remoteCetificateData: NSData = SecCertificateCopyData(certificate!)
            
                //Local certificate
            
            let pathToCertificate = Bundle.main.path(forResource: "google", ofType: "cer")!
            
            let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate)!
            
            //Comparting certificates
            
            if (isServerTrusted && remoteCetificateData.isEqual(to: localCertificateData as Data)) {
                
                let credential: URLCredential = URLCredential(trust: serverTrust)
                
                print("Certificate pinning is succesfully complete")
                
                completionHandler(.useCredential, credential)
            
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }

        }
    }
    
}
