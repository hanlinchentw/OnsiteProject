//
//  AlertPresentation.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/11/2.
//

import UIKit

protocol AlertPresentation{
    func showAlert(title: String, subTitle: String, firstAction: UIAlertAction?, secondAction: UIAlertAction?)
    func showApiRequestErrorAlert(error: APIRequestError)
}

extension AlertPresentation where Self: UIViewController{
    func showAlert(title: String, subTitle: String, firstAction: UIAlertAction? = nil, secondAction: UIAlertAction? = nil){
        let alertVC = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        if let firstAction = firstAction {
            alertVC.addAction(firstAction)
        }
        if let secondAction = secondAction {
            alertVC.addAction(secondAction)
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    func showApiRequestErrorAlert(error: APIRequestError) {
        switch error {
        case .noInternetError:
            let settingAction = UIAlertAction(title: "Setting", style: .default) { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }

                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
            }
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.showAlert(title: "No internet", subTitle: "Please turn on internet", firstAction: settingAction, secondAction: okAction)
        case .serverError:
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.showAlert(title: "Server error", subTitle: "Please try it later", firstAction: okAction)
        case .dataNull:
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.showAlert(title: "Empty data", subTitle: "Please try it later", firstAction: okAction)
        default:
            break
        }
    }
}
