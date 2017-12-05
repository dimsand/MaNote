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
    
    var textFiled: UITextField? = nil;
    var annotations = [UITextField]()
    var xValue = CGFloat()
    var yValue = CGFloat()
    var tagId: Int = 0;

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
        
        PhotoPrise.image = UIImage(named: "ticket");
        
        let saveAnnotButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(save(_:)))
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
    
    func save(_ sender: Any){
        
        print("save")
        print(annotations)
    }
    
    // Création de l'EditText pour l'annotation
    func createAnnotation(){
        let sampleTextField = UITextField(frame: CGRect(x: xValue, y: yValue, width: getWidth(text: "Votre annotation ici"), height: 40))
        sampleTextField.placeholder = "Votre annotation ici"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        sampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tagId = tagId + 1
        sampleTextField.tag = tagId
        self.view.layoutIfNeeded() // if you use Auto layout
        sampleTextField.delegate = self
        self.view.addSubview(sampleTextField)
        annotations.append(sampleTextField)
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
        let touchPoint = touch.location(in: PhotoPrise) as CGPoint
        xValue = touchPoint.x
        yValue = touchPoint.y
        self.createAnnotation()
    }
    
    func imageFrom(text: String , size:CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)!, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: paragraphStyle, NSBackgroundColorAttributeName: UIColor.darkGray]
            text.draw(with: CGRect(x: (xValue - 100), y: (yValue), width: size.width, height: (size.height+100)), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return img
    }
    
}

