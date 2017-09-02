//
//  ViewController.swift
//  OpenLibraryJson
//
//  Created by Erik Basto Segovia on 01/09/17.
//  Copyright © 2017 Erik Basto Segovia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var isbnTextField: UITextField!
    
    @IBOutlet weak var autoresLabel: UILabel!
    @IBOutlet weak var tituloLabel: UILabel!
    
    @IBOutlet weak var portadaImageView: UIImageView!
    
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        isbnTextField.delegate  = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let isbnValue = isbnTextField.text
        if(isStringEmpty(stringValue: isbnValue!))
        {
            let alert = UIAlertController(title: "Aviso", message: "No se ha proporcionado un ISBN a buscar.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else
        {
            if Reachability.isConnectedToNetwork() == true
            {
                ClearFields()
                BusquedaISBN(isbn: isbnValue!)
                return true
            }
            else{
                let alert = UIAlertController(title: "Aviso", message: "No cuenta con acceso a la red, favor de reintentar posteriormente.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
        }
    }
    
    
    func isStringEmpty( stringValue:String) -> Bool
    {
        var stringValue = stringValue
        var returnValue = false
        
        if stringValue.isEmpty  == true
        {
            returnValue = true
            return returnValue
        }
        stringValue = stringValue.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if(stringValue.isEmpty == true)
        {
            returnValue = true
            return returnValue
            
        }
        return returnValue
        
    }
    
    func BusquedaISBN(isbn: String)
    {
        let url:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        let urlToSearch = NSURL(string: url)
        let contentData:NSData? = NSData(contentsOf: urlToSearch! as URL)
        if(contentData != nil)
        {
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with: contentData! as Data, options: []) as! NSDictionary
                if(jsonResponse.count > 0 )
                {
                    let bookInfo = jsonResponse["ISBN:" + isbn] as! NSDictionary
                
                    tituloLabel.text = bookInfo["title"] as? String
                
                    let authors = (bookInfo["authors"] as! NSArray).mutableCopy() as! NSMutableArray
                    var authorsName: String = ""
                    for index in 0...authors.count-1
                    {
                        let author = authors[index] as! NSDictionary
                        let name = author["name"] as? String
                        authorsName = authorsName + name! + "\r\n"
                    }
                    autoresLabel.text = authorsName
                    let covers = bookInfo["cover"] as! NSDictionary
                    if(covers.count > 0)
                    {
                        let coverImage = covers["medium"] as! NSString
                        portadaImageView.image = GetBookCover(imageUrl: coverImage as String)
                        portadaImageView.isHidden = false
                    }
                    else{
                        portadaImageView.isHidden = true
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Aviso", message: "No se ha encontrado un libro con el ISBN proporcionado.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            catch{
                ClearFields()
            }
         }
        else
        {
            let alert = UIAlertController(title: "Aviso", message: "No se ha podido conectar al servicio. Favor de reintentar más tarde", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func GetBookCover(imageUrl: String) -> UIImage {
        let url = NSURL(string: imageUrl)
        let imageContentData:NSData? = NSData(contentsOf: url! as URL)
        let image = UIImage(data:imageContentData! as Data)
        
        return image!
    }
    
    func ClearFields()
    {
        autoresLabel.text = ""
        tituloLabel.text = ""
        portadaImageView.isHidden = true
    }

}

