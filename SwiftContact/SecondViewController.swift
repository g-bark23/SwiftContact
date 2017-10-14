//
//  SecondViewController.swift
//  SwiftContact
//
//  Created by Garrett Barker on 10/11/17.
//  Copyright © 2017 Garrett Barker. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI
import MapKit

class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var firstName: UITextField!
    @IBOutlet var category: UIPickerView!
    @IBOutlet var picture: UIImageView!
    @IBOutlet var address: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var lastName: UITextField!
    let imagePicker = UIImagePickerController()
    
    @IBAction func drivingDirections(_ sender: Any) {
        if !contact.isEmpty{
            if !contact[0].email.isEmpty{
                CLGeocoder().geocodeAddressString(contact[0].address, completionHandler: {(placemarks, error) in
                    if error != nil {
                        print("Geocode failed with error:\(error!.localizedDescription)")
                    } else if placemarks!.count > 0 {
                        let placemark = placemarks![0]
                        let location = placemark.location
                        let coords = location!.coordinate
                        print(coords.latitude)
                        print(coords.longitude)
                        
                        let regionDistance:CLLocationDistance = 10000
                        let coordinates = CLLocationCoordinate2DMake(coords.latitude, coords.longitude)
                        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                        let options = [
                            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                        ]
                        let place = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                        let mapItem = MKMapItem(placemark: place)
                        mapItem.name = self.contact[0].firstName + " " + self.contact[0].lastName + "'s Address"
                        mapItem.openInMaps(launchOptions: options)
                    }
                })
            }
        }
    }
    
    @IBAction func sendEmailButton(_ sender: Any) {
         if !contact.isEmpty{
            if !contact[0].email.isEmpty{
                if (MFMailComposeViewController.canSendMail()) {
                    let controller = MFMailComposeViewController()
                    controller.mailComposeDelegate = self
                    controller.setToRecipients([contact[0].email])
                    controller.setSubject("")
                    controller.setMessageBody("", isHTML: false)
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func textButton(_ sender: Any) {
         if !contact.isEmpty{
            if !contact[0].phoneNumber.isEmpty{
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = ""
                    controller.recipients = [contact[0].phoneNumber]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func callButton(_ sender: Any) {
         if !contact.isEmpty{
            if !contact[0].phoneNumber.isEmpty
            {
                if let url = URL(string: "tel://\(contact[0].phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
    @IBAction func editPicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    var contact: [Contacts] = []
    let realm = try! Realm()
    var categories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = ["Family", "Friend", "Collegue", "Other"]
        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        let saveBTN = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.save, target:self,
                                      action: #selector(saveButtonTapped(_:)))
        let deleteBTN = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.trash, target:self,
                                        action: #selector(deleteButtonTapped(_:)))
        
        self.navigationItem.rightBarButtonItems = [saveBTN, deleteBTN]
        
        imagePicker.delegate = self
        
        if !contact.isEmpty{
            firstName.text = contact[0].firstName
            lastName.text = contact[0].lastName
            phoneNumber.text = contact[0].phoneNumber
            emailAddress.text = contact[0].email
            address.text = contact[0].address
            if contact[0].picture != nil {
                let myImage = UIImage(data: contact[0].picture! as Data)
                picture.image = myImage
            }
            category.selectRow(Int(contact[0].category)!, inComponent: 0, animated: false)
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func saveButtonTapped(_ sender: UIButton){
        if !contact.isEmpty{
            try! realm.write(){
                contact[0].firstName = firstName.text!
                contact[0].lastName = lastName.text!
                contact[0].phoneNumber = phoneNumber.text!
                contact[0].email = emailAddress.text!
                contact[0].address = address.text!
                if (picture.image != nil){
                    let myImage = NSData(data: UIImageJPEGRepresentation(picture.image!,0.9)!)
                    contact[0].picture = myImage
                }
                contact[0].category = String(category.selectedRow(inComponent: 0))
                navigationController?.popViewController(animated: true)
            }
        }else{
            try! realm.write(){
                let newContact = Contacts()
                newContact.firstName = firstName.text!
                newContact.lastName = lastName.text!
                newContact.phoneNumber = phoneNumber.text!
                newContact.email = emailAddress.text!
                newContact.address = address.text!
                if (picture.image != nil){
                    let myImage = NSData(data: UIImageJPEGRepresentation(picture.image!,0.9)!)
                    newContact.picture = myImage
                }
                newContact.category = String(category.selectedRow(inComponent: 0))
                
                self.realm.add(newContact)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton){
        try! realm.write(){
            self.realm.delete(contact)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picture.contentMode = .scaleAspectFit
        picture.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
   func imagePickerControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
