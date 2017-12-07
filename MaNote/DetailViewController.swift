//
//  DetailViewController.swift
//  MaNote
//
//  Created by admin on 04/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import CoreData
import MessageUI


class DetailViewController: UIViewController,
                            UINavigationControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UIGestureRecognizerDelegate,
                            UITextFieldDelegate,
                            MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var PhotoPrise: UIImageView!
    
    var textFiled: UITextField?
    var annotations = [AnnotationData]()
    var text_annotations = [UIImageView]()
    var tagId: Int = 0
    var id_loaded: String = ""
    
    @IBOutlet weak var saveEditButton: UIButton!
    
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
    
    private func removeAllAnnotation() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Annotation")
        fetchRequest.predicate = NSPredicate(format: "ticket_id = %@", id_loaded)
        do
        {
            let models = try context.fetch(fetchRequest) as! [Annotation]
            for model in models {
                context.delete(model)
            }
        }
        catch
        {
            print(error)
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

        let saveAnnotButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendMail(_:)))
        self.navigationItem.rightBarButtonItem = saveAnnotButton
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Annotation")
        fetchRequest.predicate = NSPredicate(format: "ticket_id = %@", id_loaded)
        do
        {
            let models = try managedContext.fetch(fetchRequest) as! [Annotation]
            for model in models {
                createAnnotation(position: CGPoint(x: model.positionX, y: model.positionY), text: model.label)
            }
        }
        catch
        {
            print(error)
        }
        
        if(annotations.count > 0){
            saveEditButton.setTitle("Save", for: .normal)
        }
        self.manageAnnotations(saveEditButton)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        annotations = [AnnotationData]()
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
    func createAnnotation(position: CGPoint, text: String? = "") {
        let annotation = AnnotationData()
        
        annotation.field = self.createTextField(position: position, text: text)
        annotation.position = position
        
        self.view.layoutIfNeeded() // if you use Auto layout
        self.view.addSubview(annotation.field)
        
        annotations.append(annotation)
    }
    
    private func createTextField(position: CGPoint, text: String? = "") -> UITextField {
        let sampleTextField = UITextField(frame: CGRect(x: position.x, y: position.y, width: getWidth(text: "Votre annotation ici"), height: 40))
        
        sampleTextField.placeholder = "Votre annotation ici"
        sampleTextField.font = UIFont.systemFont(ofSize: 16)
        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextFieldViewMode.always;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        sampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        sampleTextField.delegate = self
        tagId = tagId + 1
        sampleTextField.tag = tagId
        sampleTextField.text = text
        //sampleTextField.becomeFirstResponder()
        return sampleTextField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
        if (PhotoPrise.image != nil && saveEditButton.title(for: .normal) == "Save") {
            self.createAnnotation(position: touch.location(in: PhotoPrise) as CGPoint)
        }else{
            let alert = UIAlertController(title: "Action refusée", message: "Veuillez passer en mode Edit pour ajouter de nouvelles annotations", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func openGallery() {
        let PhotoPrise = UIImagePickerController()
        PhotoPrise.delegate = self
        PhotoPrise.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            PhotoPrise.sourceType = .camera;
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PhotoPrise.sourceType = .photoLibrary;
        }
        
        self.present(PhotoPrise, animated: true, completion: nil)
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
            self.saveInDb(imageSrc: filename)
        }
    }
    
    private func saveInDb(imageSrc: String){
        removeAllAnnotation()
        
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
                
                for annotation in annotations {
                    let annotationModel = Annotation(context: managedContext)
                    
                    // If appropriate, configure the new managed object.
                    annotationModel.setValue(NSUUID().uuidString, forKey: "id")
                    annotationModel.setValue(Double(annotation.position.x), forKey: "positionX")
                    annotationModel.setValue(Double(annotation.position.y), forKey: "positionY")
                    annotationModel.setValue(ticketObject.value(forKey: "id"), forKey: "ticket_id")
                    annotationModel.setValue(annotation.field.text, forKey: "label")
                }
                
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
            self.manageAnnotations(sender)
        }
    }
    
    private func manageAnnotations(_ sender: UIButton){
        if (sender.title(for: .normal) == "Edit") {
            for annotation in annotations {
                annotation.field.isHidden = false
            }
            sender.setTitle("Save", for: .normal)
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
            saveImage(_: (Any).self)
            
            sender.setTitle("Edit", for: .normal)
        }
    }
    
    private func imageFrom(text: String , position: CGPoint, size:CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSFontAttributeName: UIFont(name: "Trebuchet MS", size: 20)!, NSForegroundColorAttributeName: UIColor.red, NSParagraphStyleAttributeName: paragraphStyle, NSBackgroundColorAttributeName: UIColor.clear]
            text.draw(with: CGRect(x: (position.x), y: (position.y + 16), width: size.width, height: (size.height+100)), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return img
    }
    
    func sendMail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let image_with_text = self.screenShotImageWithText()
            let imageData: NSData = UIImagePNGRepresentation(image_with_text)! as NSData
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setSubject("Note de frais")
            composeVC.setMessageBody("Bonjour, voici ma note de frais.", isHTML: true)
            composeVC.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName.png  ")
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Not working on simulator")
            let alert = UIAlertController(title: "Action impossible", message: "L'envoi de mail n'est pas disponible sur l'émulateur", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Create the UIImage with all annotations
    private func screenShotImageWithText() -> UIImage{
        UIGraphicsBeginImageContext(self.PhotoPrise.frame.size)
        self.PhotoPrise.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func clearImage(_ sender: UIButton) {
        removeAllAnnotation()
        
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
