//
//  DetailViewController.swift
//  MaNote
//
//  Created by admin on 04/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var PhotoPrise: UIImageView!
    
    var textFiled: UITextField?
    var annotations = [AnnotationData]()
    var text_annotations = [UIImageView]()
    var tagId: Int = 0
    var id_loaded: String = ""
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            self.id_loaded = detail.value(forKey: "id") as! String
            self.title = detail.value(forKey: "id") as! String
            if(detail.value(forKey: "image_src") != nil){
                PhotoPrise?.image = self.load(fileName: detail.value(forKey: "image_src") as! String)
            }
        }
    }
    
    private func load(fileName: String) -> UIImage! {
        let fileURL = documentsUrl.appendingPathComponent("\(fileName)")
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let image = UIImage(data: imageData) {
                return image
            }
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
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
    
    var detailItem: Ticket? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // Création de l'EditText pour l'annotation
    func createAnnotation(position: CGPoint) {
        let annotation = AnnotationData()
        
        annotation.field = self.createTextField(position: position)
        annotation.position = position
        
        self.view.layoutIfNeeded() // if you use Auto layout
        self.view.addSubview(annotation.field)
        
        annotations.append(annotation)
    }
    
    private func createTextField(position: CGPoint) -> UITextField {
        let sampleTextField = UITextField(frame: CGRect(x: position.x, y: position.y, width: getWidth(text: "Votre annotation ici"), height: 40))
        
        sampleTextField.placeholder = "Votre annotation ici"
        sampleTextField.font = UIFont.systemFont(ofSize: 16)
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
        
        for (index, annotation) in annotations.enumerated() {
            if (annotation.field.tag == textField.tag) {
                annotations.remove(at: (index))
            }
        }
        
        return true
    }
    
    func touchPhoto(touch: UITapGestureRecognizer) {
        if (PhotoPrise.image != nil) {
            self.createAnnotation(position: touch.location(in: PhotoPrise) as CGPoint)
        }
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
            PhotoPrise.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(_ sender: Any) {
        if (self.PhotoPrise.image != nil) {
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
                try UIImageJPEGRepresentation(self.PhotoPrise.image!, 1.0)?.write(to: url, options: .atomic)
            } catch {
                print(error)
                print("file cant not be save at path \(filepath), with error : \(error)");
            }
            
            // Save annotations in CoreData
            for a in annotations{
                self.saveInDb(annotation: a, imageSrc: filename)
            }
        }
    }
    
    private func saveInDb(annotation: AnnotationData, imageSrc: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Ticket")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.id_loaded)
        do
        {
            let ticket = try managedContext.fetch(fetchRequest)
            if ticket.count == 1
            {
                let ticketObject = ticket[0] as! NSManagedObject
                ticketObject.setValue(Date(), forKeyPath: "timestamp")
                ticketObject.setValue(imageSrc, forKeyPath: "image_src")
                do{
                    try managedContext.save()
                }
                catch
                {
                    print(error)
                }
           }
            
        }
        catch
        {
            print(error)
        }
    }
    
    @IBAction func send(_ sender: UIButton) {
        if (PhotoPrise.image != nil) {
            if (sender.title(for: .normal) == "Edit") {
                for annotation in annotations {
                    annotation.field.isHidden = false
                }
                
                sender.setTitle("Render", for: .normal)
            } else {
                let render: UIImageView = self.PhotoPrise
                let frame: CGRect = self.PhotoPrise.frame;
                let size: CGSize = self.PhotoPrise.frame.size
                
                for annotation in annotations {
                    let textImgView = UIImageView(frame: frame)
                    
                    textImgView.image = self.imageFrom(text: annotation.field.text!, position: annotation.position, size: size)
                    render.addSubview(textImgView)
                    text_annotations.append(textImgView)
                    annotation.field.isHidden = true
                }
                
                self.PhotoPrise.image = render.image
                
                sender.setTitle("Edit", for: .normal)
            }
        }
    }
    
    private func imageFrom(text: String , position: CGPoint, size:CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!, NSForegroundColorAttributeName: UIColor.red, NSParagraphStyleAttributeName: paragraphStyle]
            text.draw(with: CGRect(x: (position.x), y: (position.y + 16), width: size.width, height: (size.height+100)), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        

        return img
    }
    
    @IBAction func clearImage(_ sender: UIButton) {
        print("CLEAR")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Ticket")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.id_loaded)
        do
        {
            let ticket = try managedContext.fetch(fetchRequest)
            if ticket.count == 1
            {
                let ticketObject = ticket[0] as! NSManagedObject
                print(ticketObject);

                self.PhotoPrise.image = self.load(fileName: ticketObject.value(forKey: "image_src") as! String)
                for annotation in annotations{
                    annotation.field.removeFromSuperview()
                }
                for text_annotation in text_annotations{
                    text_annotation.removeFromSuperview()
                }
                annotations.removeAll()
                text_annotations.removeAll()
            }
        }
        catch
        {
            print(error)
        }
    }
}

