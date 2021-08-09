//
//  ViewController.swift
//  SocialShareKit
//
//  Created by Charitha Rajapakse on 2021-08-02.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import FacebookShare
import TwitterKit

class ViewController: UIViewController {
    
    
    @IBOutlet var vc: UIView!
    let image = #imageLiteral(resourceName: "instabackground")
    var documentInteractionController:UIDocumentInteractionController!
    let base64StringImage = #imageLiteral(resourceName: "instabackground").jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
  
    //Share Image whatsapp using UIController
    func shareImageViaWhatsapp(image: UIImage, onView: UIView) {
            let urlWhats = "whatsapp://app"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                        guard let imageData = image.pngData() else { debugPrint("Cannot convert image to data!")
                            return }

                        let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/image.wai")
                        do {
                            try imageData.write(to: tempFile, options: .atomic)
                            documentInteractionController = UIDocumentInteractionController(url: tempFile)
                            documentInteractionController?.uti = "net.whatsapp.image"
                            documentInteractionController?.presentOpenInMenu(from: CGRect.zero, in: onView, animated: true)

                        } catch {
                            print("There was an error while processing.")
                            return
                        }

                    } else {
                        print("Cannot open Whatsapp, make sure Whatsapp is installed on your device")
                    }
                }
            }
        }
    
    //Share whatsapp image URL
    func shareWhatsappURLImage(imageURL: String){
        
        let urlWhats = imageURL // Test URL - "whatsapp://send?text=http://eyesofwild.com/wp-content/uploads/2019/04/wil18-11.jpg"
                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    if let whatsappURL = NSURL(string: urlString) {
                        if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                            UIApplication.shared.openURL(whatsappURL as URL)
                        } else {

                            let alert = UIAlertController(title: NSLocalizedString("Whatsapp not found", comment: "Error message"),
                                                          message: NSLocalizedString("Could not found a installed app 'Whatsapp' to proceed with sharing.", comment: "Error description"),
                                                          preferredStyle: UIAlertController.Style.alert)

                            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Alert button"), style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
                            }))

                            self.present(alert, animated: true, completion:nil)
                            // Cannot open whatsapp
                        }
                    }
                }
    }
    
    @IBAction func whatsappbtnPressed(_ sender: Any) {
        
        shareWhatsappText(phoneNumber: 94710621042, text: "hey")
        
    }
   
    func shareWhatsappText(phoneNumber: Int, text: String){
        let whatsAppUrl = NSURL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)&text=\(text)")
        if UIApplication.shared.canOpenURL(whatsAppUrl! as URL) {
            UIApplication.shared.openURL(whatsAppUrl! as URL)
        } else {
            let errorAlert = UIAlertView(title: "Sorry", message: "You can't send a message to this number", delegate: self, cancelButtonTitle:"Ok")
            errorAlert.show()
        }
    }
    
    @IBAction func whatsappImgeBtnPressed(_ sender: Any) {
        shareImageViaWhatsapp(image: image, onView: vc)
    }
    
    
    @IBAction func fbBtnPressed(_ sender: Any) {
        
        shareFacebookURLWithQuote(url: "https://www.facebook.com/", hashTag: "#FeelingGood", quote: "Sample Quote")
        
    }
    
    func shareFacebookURLWithQuote(url: String, hashTag: String, quote: String){
        //URL with quote and Hashtag
        let content = ShareLinkContent()
        content.contentURL = URL(string: url)!
        content.hashtag = Hashtag(hashTag)
        content.quote = quote
        

        let dialog = ShareDialog()
        dialog.fromViewController = self

        dialog.shareContent = content
        dialog.mode = ShareDialog.Mode.shareSheet
        if !dialog.canShow {
            dialog.mode = ShareDialog.Mode.automatic
        }
        dialog.show()
    }
    
    @IBAction func fbImageBtnPressed(_ sender: Any) {
        shareFacebookImage(image: #imageLiteral(resourceName: "instabackground"))
    }
    
    func shareFacebookImage(image : UIImage){
        let shareImage = SharePhoto()
          shareImage.image = image
          shareImage.caption = "post"
          shareImage.isUserGenerated = true

          let content = SharePhotoContent()
          content.photos = [shareImage]

          let sharedDialoge = ShareDialog()
          sharedDialoge.shareContent = content

          sharedDialoge.fromViewController = self
          sharedDialoge.mode = .automatic


          if(sharedDialoge.canShow){
            sharedDialoge.show()
          } else {
            print("Install Facebook client app to share image")
          }
    }
    
    @IBAction func instaBtnPressed(_ sender: Any) {
        postImage(image: image)
    }
    
    func postImage(image: UIImage, result:((Bool)->Void)? = nil) {
    guard let instagramURL = NSURL(string: "instagram://app") else {
        if let result = result {
            result(false)
        }
        return
    }


    do {
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)

            let assetID = request.placeholderForCreatedAsset?.localIdentifier ?? ""
            let shareURL = "instagram://library?LocalIdentifier=" + assetID

            if UIApplication.shared.canOpenURL(instagramURL as URL) {
                if let urlForRedirect = NSURL(string: shareURL) {
                    UIApplication.shared.open(urlForRedirect as URL)
                }
            }
        }
    } catch {
        if let result = result {
            result(false)
        }
    }
    }
    
    @IBAction func twitterBtnPressed(_ sender: Any) {
        
        shareTwitterURLText(url: "http://stackoverflow.com/", text: "your text")
        
    }
    
    func shareTwitterURLText(url: String, text: String){
       
        let shareString = "https://twitter.com/intent/tweet?text=\(text)&url=\(url)"

        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        // cast to an url
        let url = URL(string: escapedShareString)

        // open in safari
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func twitterImageUploadBtnPressed(_ sender: Any) {
        
        
    }
    
//    func post(tweetString: String, tweetImage: Data ,withUserID :String) {
//
//        let uploadUrl = "https://upload.twitter.com/1.1/media/upload.json"
//        let updateUrl = "https://api.twitter.com/1.1/statuses/update.json"
//        let imageString = tweetImage.base64EncodedString(options: NSData.Base64EncodingOptions())
//
//        let client = TWTRAPIClient.init(userID: withUserID)
//
//        let requestUploadUrl = client.urlRequest(withMethod: "POST", urlString: uploadUrl, parameters: ["media": imageString], error: nil)
//
//        client.sendTwitterRequest(requestUploadUrl) { (urlResponse, data, connectionError) -> Void in
//            if connectionError == nil {
//                if let mediaDict = self.nsDataToJson(data: (data! as NSData) as Data) as? [String : Any] {
//                    let media_id = mediaDict["media_id_string"] as! String
//                    let message = ["status": tweetString, "media_ids": media_id]
//
//                    let requestUpdateUrl = client.urlRequest(withMethod: "POST", urlString: updateUrl, parameters: message, error: nil)
//
//                    client.sendTwitterRequest(requestUpdateUrl, completion: { (urlResponse, data, connectionError) -> Void in
//                        if connectionError == nil {
//                            if let _ = self.nsDataToJson(data: (data! as NSData) as Data) as? [String : Any] {
//                                print("Upload suceess to Twitter")
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
//
//    func nsDataToJson (data: Data) -> AnyObject? {
//        do {
//            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
//        } catch let myJSONError {
//            print(myJSONError)
//        }
//        return nil
//    }
    
}

