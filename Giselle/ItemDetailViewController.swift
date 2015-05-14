//
//  ItemDetailViewController.swift
//  Giselle
//
//  Created by Giselle Mobi on 4/9/15.
//  Copyright (c) 2015 Giselle Mobi. All rights reserved.
//

import UIKit
// API 7-Step Request process: step 1 get the parameters
// API 7-Step Request process: step 2 create the URL
let BASE_URL = "https://api.uber.com/"
let METHOD_NAME = "v1/products"
let API_KEY = "ENTER_YOUR_API_KEY_HERE"
let SERVER_TOKEN = "k1XYGi-SS27R5Higux7lJDgrZwfpNJs-hkQd8kJG"
let EXTRAS = "image"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

protocol ItemDetailViewControllerDelegate: class {
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem)
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchAlert: UILabel!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    weak var delegate: ItemDetailViewControllerDelegate?
    var itemToEdit: ChecklistItem?
    var dueDate = NSDate()
    var datePickerVisible = false
    
    @IBAction func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    @IBAction func done() {
        if let item = itemToEdit {
            item.text = textField.text
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            item.latitude = latitudeTextField.text
            item.longitude = longitudeTextField.text
            item.address = addressTextField.text
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
        } else {
            let item = ChecklistItem()
            item.text = textField.text
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            item.latitude = latitudeTextField.text
            item.longitude = longitudeTextField.text
            item.address = addressTextField.text
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        }
    }

    @IBAction func ridesByUber(sender: AnyObject) {
        //self.dismissAnyVisibleKeyboards()
        if !self.latitudeTextField.text.isEmpty && !self.longitudeTextField.text.isEmpty {
            if validLatitude() && validLongitude() {
                self.searchAlert.text = "Searching..."
                let methodArguments = [
                    "method": METHOD_NAME,
                    "server_token": SERVER_TOKEN,
                    "bbox": createBoundingBoxString(),
                    "safe_search": SAFE_SEARCH,
                    "extras": EXTRAS,
                    "format": DATA_FORMAT,
                    "nojsoncallback": NO_JSON_CALLBACK
                ]
                getProductsFromUberBySearch(methodArguments)
                // API 7-Step Request process: step 7 use the retrieved data
            } else {
                if !validLatitude() && !validLongitude() {
                    self.searchAlert.text = "Lat/Lon Invalid.\nLat should be [-90, 90].\nLon should be [-180, 180]."
                } else if !validLatitude() {
                    self.searchAlert.text = "Lat Invalid.\nLat should be [-90, 90]."
                } else {
                    self.searchAlert.text = "Lon Invalid.\nLon should be [-180, 180]."
                }
            }
        } else {
            if self.latitudeTextField.text.isEmpty && self.longitudeTextField.text.isEmpty {
                self.searchAlert.text = "Lat/Lon Empty."
            } else if self.latitudeTextField.text.isEmpty {
                self.searchAlert.text = "Lat Empty."
            } else {
                self.searchAlert.text = "Lon Empty."
            }
        }
    }
    
    func getProductsFromUberBySearch(methodArguments: [String : AnyObject]) {
        // API 7-Step Request process: step 3 get the shared NSURLSession to facilitate network activity
        let session = NSURLSession.sharedSession()
        // API 7-Step Request process: step 4 create the NSURLRequest using properly escaped URL
        //let urlString = BASE_URL + escapedParameters(methodArguments)
        let urlString = "https://api.uber.com/v1/products?latitude=37.775253&longitude=-122.417541&server_token=k1XYGi-SS27R5Higux7lJDgrZwfpNJs-hkQd8kJG"
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        // API 7-Step Request process: step 5 create NSURLSessionDataTask and completion handler
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                println("Rides by Uber: getProductsFromUberBySearch...parsedResult here: \(parsedResult)")
                if let uberProducts = parsedResult as? NSDictionary {
                    println("Rides by Uber: uberProducts now parsed object")
                    if let products = uberProducts["products"] as? NSArray {
                        println("Rides by Uber: products now parsed NSArray uberProducts")
                        if let firstProduct = products[0] as? NSDictionary {
                            println("Rides by Uber: firstProduct is: \(firstProduct)")
                            if let productName =  firstProduct["display_name"] as? NSString {
                                println("Rides by Uber first product is: \(productName)")
                                dispatch_async(dispatch_get_main_queue(), {
                                    if methodArguments["bbox"] != nil {
                                        self.searchAlert.text = "\(self.getLatLonString()) \(productName)"
                                    } else {
                                        self.searchAlert.text = "\(productName)"
                                    }
                                })
                            } else {
                                println("No first product found")
                            }
                        } else {
                              println("No array as dictionary")
                        }
                    } else {
                        println("Products not in Array")
                    }
                } else {
                    println("Not parsed as dictionary")
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "giselle logo")
        imageView.image = image
        navigationItem.titleView = imageView
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.enabled = true
            shouldRemindSwitch.on = item.shouldRemind
            dueDate = item.dueDate
            latitudeTextField.text = item.latitude
            longitudeTextField.text = item.longitude
            addressTextField.text = item.address
        }
        updateDueDateLabel()
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        DataManager.getTopUberDataFromFileWithSuccess { (data) -> Void in
            // Get the first uber product using optional binding and NSJSONSerialization
            //1
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments,
                error:&parseError)
            
            //2
            if let uberProducts = parsedObject as? NSDictionary {
                println("uberProducts is now parsed object")
                //if let products = uberProducts["products"] as? NSDictionary {
                    //println("products is now parsed uberProducts")
                    if let products = uberProducts["products"] as? NSArray {
                        println("products is now parsed NSArray uberProducts")
                        if let firstProduct = products[0] as? NSDictionary {
                            println("firstProduct is \(firstProduct)")
                            //if let displayName = firstProduct["display_name"] as? NSDictionary {
                                //println("displayName is now parsed firstProduct")
                                if let productName =  firstProduct["display_name"] as? NSString {
                                    //3
                                    println("Optional Binding: \(productName)")
                                }
                            //}
                        }
                    }
                //}
            }
        }
        
        // Get the first Uber product from Uber and SwiftyJSON
        DataManager.getTopProductFromUberWithSuccess { (uberProductData) -> Void in
            let json = JSON(data: uberProductData)
            println("getting top product now from uber api URL \(uberProductData)")
            //if let productName = json["product"]["entry"][0]["im:name"]["label"].string {
            if let productName = json["product"][0]["display_name"].string {
                println("NSURLSession: \(productName)")
            }
            // More soon...
            //1
            if let productArray = json["product"]["display_name"].array {
                //2
                var products = [UberProductModel]()
                //3
                for productDict in productArray {
                    var productName: String? = productDict["product"]["display_name"].string
                    var productDescription: String? = productDict["product"]["description"].string
                    var product = UberProductModel(uberProductType: productName, uberProductDescription: productDescription)
                    products.append(product)
                }
                //4
                println(products)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
        
        /* Add tap recognizer to dismiss keyboard */
        self.addKeyboardDismissRecognizer()
        
        /* Subscribe to keyboard events so we can adjust the view to show hidden controls */
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        /* Remove tap recognizer */
        self.removeKeyboardDismissRecognizer()
        
        /* Unsubscribe to all keyboard events */
        self.unsubscribeToKeyboardNotifications()
    }

    //* Functional stubs for handling UI problems

    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //if self.yourImageView.image != nil {
        //    self.defaultLabel.alpha = 0.0
        //}
        self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 2
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //if self.yourImageView.image == nil {
         //   self.defaultLabel.alpha = 1.0
        //}
        self.view.frame.origin.y += self.getKeyboardHeight(notification) / 2
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //extension ViewController {
    //    func dismissAnyVisibleKeyboards() {
    //        if textField.isFirstResponder() || latitudeTextField.isFirstResponder() || longitudeTextField.isFirstResponder() || addressTextField.isFirstResponder(){
    //            self.view.endEditing(true)
     //       }
     //   }
   // }
    //* ============================================================


    func createBoundingBoxString() -> String {
        
        let latitude = (self.latitudeTextField.text as NSString).doubleValue
        let longitude = (self.longitudeTextField.text as NSString).doubleValue
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* Check to make sure the latitude falls within [-90, 90] */
    func validLatitude() -> Bool {
        if let latitude : Double? = self.latitudeTextField.text.toDouble() {
            if latitude < LAT_MIN || latitude > LAT_MAX {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    /* Check to make sure the longitude falls within [-180, 180] */
    func validLongitude() -> Bool {
        if let longitude : Double? = self.longitudeTextField.text.toDouble() {
            if longitude < LON_MIN || longitude > LON_MAX {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    func getLatLonString() -> String {
        let latitude = (self.latitudeTextField.text as NSString).doubleValue
        let longitude = (self.longitudeTextField.text as NSString).doubleValue
        
        return "(\(latitude), \(longitude))"
    }

    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
        return nil
        }
    }
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 1 && indexPath.row == 2 {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }
    
  
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        doneBarButton.enabled = newText.length > 0
        return true
    }
    
    func updateDueDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        dueDateLabel.text = formatter.stringFromDate(dueDate)
    }
    
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        if let pickerCell = tableView.cellForRowAtIndexPath(indexPathDatePicker) {
            let datePicker = pickerCell.viewWithTag(100) as! UIDatePicker
            datePicker.setDate(dueDate, animated: false)
        }
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "DatePickerCell")
                cell.selectionStyle = .None
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320, height:216))
                datePicker.tag = 100
                cell.contentView.addSubview(datePicker)
                datePicker.addTarget(self, action: Selector("dateChanged:"), forControlEvents: .ValueChanged)
            }
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    func dateChanged(datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}
