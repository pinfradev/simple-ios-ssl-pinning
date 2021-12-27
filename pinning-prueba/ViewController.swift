//
//  ViewController.swift
//  pinning-prueba
//
//  Created by Fray Pineda on 27/12/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://www.google.co.uk/") else {
            return
        }
        
        ServiceManager().callAPI(
            withURL: url,
            isCertificatePinning: true) { message in
                let alert = UIAlertController(
                    title: "SSL Pinning",
                    message: message,
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil))
                
                self.present(alert,
                        animated: true,
                        completion: nil)
            }
        
        
    }


}

