//
//  DetailViewController.swift
//  MaNote
//
//  Created by admin on 04/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var PhotoPrise: UIImageView!
    
    var textFiled: UITextField?
    var annotations = [Annotation]()
    var tagId: Int = 0
    var chosenImage: UIImage? = nil
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.timestamp!.description
            }
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchPhoto(touch:)))
        tapRecognizer.numberOfTapsRequired = 1
        PhotoPrise.isUserInteractionEnabled = true
        PhotoPrise.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        let saveAnnotButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveImage(_:)))
        self.navigationItem.rightBarButtonItem = saveAnnotButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // Création de l'EditText pour l'annotation
    func createAnnotation(position: CGPoint) {
        let annotation = Annotation()
        
        annotation.field = self.createTextField(position: position)
        annotation.position = position
        
        self.view.layoutIfNeeded() // if you use Auto layout
        self.view.addSubview(annotation.field)
        
        annotations.append(annotation)
    }
    
    private func createTextField(position: CGPoint) -> UITextField {
        let sampleTextField = UITextField(frame: CGRect(x: position.x, y: position.y, width: getWidth(text: "Votre annotation ici"), height: 40))
        
        sampleTextField.placeholder = "Votre annotation ici"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        sampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        sampleTextField.delegate = self
        tagId = tagId + 1
        sampleTextField.tag = tagId
        
        return sampleTextField
    }
    
    func getWidth(text: String) -> CGFloat {
        let txtField = UITextField(frame: .zero)
        txtField.text = text
        txtField.sizeToFit()
        return txtField.frame.size.width
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        textField.frame.size.width = getWidth(text: textField.text!) + 55
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.isHidden = true
        annotations.remove(at: (textField.tag - 1))
        return false
    }
    
    func touchPhoto(touch: UITapGestureRecognizer) {
        if (PhotoPrise.image != nil) {
            self.createAnnotation(position: touch.location(in: PhotoPrise) as CGPoint)
        }
    }
    
    func imageFrom(text: String , position: CGPoint, size:CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)!, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: paragraphStyle, NSBackgroundColorAttributeName: UIColor.darkGray]
            text.draw(with: CGRect(x: (position.x - 100), y: (position.y), width: size.width, height: (size.height+100)), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return img
    }
    
        
        @IBAction func openGallery() {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let PhotoPrise = UIImagePickerController()
                
                PhotoPrise.delegate = self
                PhotoPrise.sourceType = .photoLibrary;
                PhotoPrise.allowsEditing = false
                
                self.present(PhotoPrise, animated: true, completion: nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.chosenImage = image
                PhotoPrise.image = image
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        func saveImage(_ sender: Any) {
            if (self.chosenImage != nil) {
                let directoryPath =  NSHomeDirectory().appending("/Documents/")
                
                if !FileManager.default.fileExists(atPath: directoryPath) {
                    do {
                        try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print(error)
                    }
                }
                
                let filename = NSUUID().uuidString
                let filepath = directoryPath.appending(filename)
                let url = NSURL.fileURL(withPath: filepath)
                
                do {
                    try UIImageJPEGRepresentation(self.chosenImage!, 1.0)?.write(to: url, options: .atomic)
                    print(filepath)
                } catch {
                    print(error)
                    print("file cant not be save at path \(filepath), with error : \(error)");
                }
                
            }
        }
}

