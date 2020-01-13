
//  TranslatorCameraViewController.swift
//  Swift Text Translation
//
//  Created by Anant Prakash on 2019-06-09.
//

import UIKit
import Firebase
import FirebaseMLVision
import FirebaseMLCommon
import FirebaseMLNLLanguageID
class TranslatorCameraViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var langCodeBox: UITextView!



    
    var textRecognizer: VisionTextRecognizer!
    lazy var languageIdentifier = NaturalLanguage.naturalLanguage().languageIdentification()
    var textFound: String = ""
    public var textToDisplay = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let tabBarController = self.tabBarController?.tabBar else { return }
        tabBarController.tintColor = UIColor.white
        tabBarController.barTintColor = UIColor.black
        tabBarController.unselectedItemTintColor = UIColor.white
        guard let tabBarItem = self.tabBarItem else { return }
        tabBarItem.badgeValue = "123"
        tabBarItem.badgeColor = UIColor.orange
        
        let vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()

       
        // Do any additional setup after loading the view.
    }
   
    @IBAction func translateButton(_ sender: UIButton) {
        if langCodeBox.text == "Language" || langCodeBox.text == "en" {
            let noTextAlert = UIAlertController(title: "Error", message: "The text scanned is unidentified or is already in English, please try again." , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
            noTextAlert.addAction(action)
            self.present(noTextAlert, animated: true , completion: nil)
        } else {
            runTranslate()
        }
    }

    /// This function translates the text that was detected by the textRecognizer.
    func runTranslate() {
        print(textFound)
        let language = TranslateLanguage.fromLanguageCode(langCodeBox.text!)
        print(language.toLanguageCode())
        let translatorOptions = TranslatorOptions(sourceLanguage: language  , targetLanguage: .en)
        let translator = NaturalLanguage.naturalLanguage().translator(options: translatorOptions)
        let conditions = ModelDownloadConditions( allowsCellularAccess: false , allowsBackgroundDownloading: true)
        let downloadAlert = UIAlertController(title: nil, message: "Downloading Model...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        downloadAlert.view.addSubview(loadingIndicator)
        present(downloadAlert, animated: true, completion: nil)
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else {
                print(error!)
                return }
            print("downloaded the model")
            self.dismiss(animated: false, completion: nil)
            translator.translate(self.textFound) { translatedText, error in
                guard error == nil, let translatedText = translatedText else { return }
                print(translatedText)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                    let textAlert = UIAlertController(title: "Translated Text", message: translatedText , preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                    textAlert.addAction(action)
                    self.present(textAlert, animated: true , completion: nil)
                }
            }
        }
    }

    /// This button calls the Firebase API to look for text within the image.
    ///
    /// - Parameter sender: This button function gets called by the sender(UIButton in this case).
    @IBAction func findTextButton(_ sender: UIButton) {
        if showImage.image != nil {
            let imageToProcess = VisionImage(image: showImage.image!.fixedOrientation()!)
            textRecognizer.process(imageToProcess) { foundText, error in
                guard error == nil, let foundText = foundText else {
                    return
                }
                self.languageDetector(text: foundText.text)
                self.textFound = foundText.text
                let textAlert = UIAlertController(title: "Recognized Text", message: foundText.text , preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                textAlert.addAction(action)
                self.present(textAlert, animated: true , completion: nil)
    }
        } else {
            let noImageTextAlert = UIAlertController(title: "No Image Found", message: "Please use the 'Take Photo' button to take a photo before trying to find text" , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
            noImageTextAlert.addAction(action)
            self.present(noImageTextAlert, animated: true , completion: nil)
        }
    }
    
    @IBOutlet weak var showImage: UIImageView!
    /// Calss the camera to take a photo
    ///
    /// - Parameter sender: This button function gets called by the specific sender(UIButton in this case).
    @IBAction func takePhotoButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraUse = UIImagePickerController()
            cameraUse.delegate = self
            cameraUse.sourceType = .camera;
            cameraUse.allowsEditing = true
            self.present(cameraUse, animated: true, completion: nil)
        }
    }
    

    
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            showImage.image = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            showImage.image = image
        }
        dismiss(animated:true)
    }
    
    /// This function identifies language the text is written in
    ///
    /// - Parameter text: the text that the language is identified for.
    func languageDetector(text: String) {
        languageIdentifier.identifyLanguage(for: text) { (languageCode, error) in
            if let error = error {
                print(error)
                return
            }
            if let languageCode = languageCode, languageCode != "und" {
                print(languageCode)
                self.langCodeBox.text = languageCode
            } else {
                print("No language was identified")
                let noRecognizedTextAlert = UIAlertController(title: "No Text Identified", message: "Unable to detect text in photo. Please make sure your photo is in portrait and not landscape." , preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                noRecognizedTextAlert.addAction(action)
                self.present(noRecognizedTextAlert, animated: true , completion: nil)
            }
        }
    }
    
}

// This extention is written by Haikieu on the following link: https://gist.github.com/schickling/b5d86cb070130f80bb40
//It orients the image correctly so the textRecognizer can properly look for text in the UIImage.

extension UIImage {
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
