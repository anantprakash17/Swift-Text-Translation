//
//  BarcodeViewController.swift
//  Barcode Scanner Class
//
//  Created by Anant Prakash on 2019-06-12.
//

import UIKit
import Firebase

/// This struct is used to fetch data from the JSON database.
struct Product:Decodable {
    var products: [Name]
}

/// This struct is made to fetch the product name in the JSON Database
struct Name:Decodable {
  var product_name: String
}

class BarcodeViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var scanImage: UIImageView!
    
    var productName = ""
    lazy var vision = Vision.vision()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhotoButtonBarcode(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraUse = UIImagePickerController()
            cameraUse.delegate = self
            cameraUse.sourceType = .camera;
            cameraUse.allowsEditing = true
            self.present(cameraUse, animated: true, completion: nil)
        }
    }

    
    /// This button invokes the detectBarcodes() function.
    ///
    /// - Parameter sender: this parameter is for identifing what can invoke this button function.
    @IBAction func findBarcodeButton(_ sender: Any) {
        if scanImage.image != nil {
    detectBarcodes(image: scanImage.image!.fixedOrientation())
        } else {
            let noImageTextAlert = UIAlertController(title: "No Image Found", message: "Please use the 'Take Photo' button to take a photo before trying to find a barcode" , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
            noImageTextAlert.addAction(action)
            self.present(noImageTextAlert, animated: true , completion: nil)
        }
    }
    
    
    /// This function detects barcodes present in an image
    ///
    /// - Parameter image: This is the image that the function looks for the barcode in.
    func detectBarcodes(image: UIImage?) {
        let format = VisionBarcodeFormat.ArrayLiteralElement(arrayLiteral: .EAN13 , .EAN8 , .UPCA , .UPCE)
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = .topLeft
        let visionImage = VisionImage(image: image!)
        visionImage.metadata = imageMetadata
        barcodeDetector.detect(in: visionImage) { features, error in
            guard error == nil, let features = features, !features.isEmpty else {
               print(error!)
                let noBarcodeAlert = UIAlertController(title: "No Barcode Found", message: "Please take a better photo and ensure that the barcode is in the right format." , preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                noBarcodeAlert.addAction(action)
                self.present(noBarcodeAlert, animated: true , completion: nil)
                return
            }
            features.forEach { feature in
                print(feature.rawValue!)
                self.parseItemName(barcode: feature.rawValue!)
            }
        }
    }
    
    
    
    /// This function fetches product infromation from the Barcodelookup JSON database.
    ///
    /// - Parameter barcode: this is the barcode number sent into the fuction to look for the item.
    func parseItemName (barcode: String) {
        let url = "https://api.barcodelookup.com/v2/products?barcode=\(barcode)&formatted=y&key=" //Removed key as it was my own.
        let urlToFetch = URL(string: url)
        URLSession.shared.dataTask(with: urlToFetch!) { (data, response , error) in
            do {
                let products = try JSONDecoder().decode(Product.self, from: data!)
                for product in products.products {
                    self.productName = product.product_name
                }
                print(self.productName)
                let foundItemAlert = UIAlertController(title: "Item Found", message: "Found an item: \(self.productName)" , preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                foundItemAlert.addAction(action)
                self.present(foundItemAlert, animated: true , completion: nil)
                
            } catch {
                let noDataFound = UIAlertController(title: "Item Not Found", message: "Found a barcode in the image but the item is not in the database." , preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style:UIAlertAction.Style.default)
                noDataFound.addAction(action)
                self.present(noDataFound, animated: true , completion: nil)
                print(error)
                            }
        } .resume()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            scanImage.image = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            scanImage.image = image
        }
        dismiss(animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ViewSwitch = segue.destination as! PriceSearchWebViewController
        ViewSwitch.itemName = self.productName
    }
}
