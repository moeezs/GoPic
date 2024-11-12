//
//  ViewController.swift
//  GoPic
//
//  Created by Moeez Shaikh on 2023-07-18.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var arrivalTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        
        //apiCallSkyscannerCrawler(arrival: arrivalTextField.text!, destination: destinationTextField.text!, date: dateString)
        
        let file = "FlightDataTemp"
        var dataWithDupe = readFileAndSendData(fileLocation: file)
        
        print(removeDupe(dataWithDupe: dataWithDupe))
    }
    
    func apiCallSkyscannerCrawler(arrival: String, destination: String, date: String) {

        let headers = [
            "X-RapidAPI-Key": "e0289f153fmsh5c7eff72f17ab43p1515fcjsnb3ef5b94039c",
            "X-RapidAPI-Host": "skyscanner44.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://skyscanner44.p.rapidapi.com/search?adults=1&origin=\(arrival)&destination=\(destination)&departureDate=\(date)&returnDate=2023-08-15&cabinClass=economy&currency=CAD&locale=en-GB&market=CA")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                
                let jsonDecoder = JSONDecoder()
                
                do {
                    let responseModel = try jsonDecoder.decode(Json4Swift_Base.self, from: data!)
                    
                    let bucketTest = responseModel.itineraries?.buckets
                    
                    for dataItem in bucketTest! {
                        print(dataItem.id!)
                        for dataItemTwo in dataItem.items! {
                            for leg in dataItemTwo.legs! {
                                for compDetails in leg.carriers?.marketing ?? [] {
                                    for priceOption in dataItemTwo.pricingOptions! {
                                        print(priceOption.price?.amount ?? "amount2 in nil")
                                        print(dataItemTwo.price?.amount ?? "amount in nil")
                                        print(dataItemTwo.price?.formatted ?? "format in nil")
                                        print(dataItemTwo.deeplink ?? "link in nil")
                                        print(compDetails.name ?? "name in nil")
                                        print(compDetails.logoUrl ?? "logourl in nil")
                                    }
                                }
                                
                            }
                        }
                    }
                }
                catch {
                    print("Error parsing JSON")
                }
            }
        })

        dataTask.resume()
    }
    
    func readFileAndSendData(fileLocation: String) -> [[String]] {
        
        var allThings = [[String]]()
        var tempThings = [String]()
        
        print("function started")
       
        let decoder = JSONDecoder()
        
        do {
            
            if let bundlePath = Bundle.main.path(forResource: fileLocation, ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let responseModel = try decoder.decode(Json4Swift_Base.self, from: jsonData)
                
                let bucketTest = responseModel.itineraries?.buckets
                
                for dataItem in bucketTest! {
                    print(dataItem.id!)
                    for dataItemTwo in dataItem.items! {
                        for leg in dataItemTwo.legs! {
                            for compDetails in leg.carriers?.marketing ?? [] {
                                for priceOption in dataItemTwo.pricingOptions! {
                                    print(priceOption.price?.amount ?? "amount2 in nil")
                                    print(dataItemTwo.price?.amount ?? "amount in nil")
                                    print(dataItemTwo.price?.formatted ?? "format in nil")
                                    print(dataItemTwo.deeplink ?? "link in nil")
                                    print(compDetails.name ?? "name in nil")
                                    print(compDetails.logoUrl ?? "logourl in nil")
                                    
                                    tempThings.append(dataItem.id!)
                                    //tempThings.append(priceOption.price?.amount ?? "amount2 in nil")
                                    tempThings.append(dataItemTwo.price?.formatted ?? "format in nil")
                                    tempThings.append(dataItemTwo.deeplink ?? "link in nil")
                                    tempThings.append(compDetails.name ?? "name in nil")
                                    tempThings.append(compDetails.logoUrl ?? "logourl in nil")
                                    
                                    allThings.append(tempThings)
                                    
                                    tempThings = []
                                }
                            }
                            
                        }
                    }
                }
            }
            
        } catch {
            print("error in reading")
        }
        
        print(allThings)
        
        return(allThings)
    }
    
    func removeDupe(dataWithDupe: [[String]]) -> [[String]] {
        
        var dataWithoutDupe = [[String]]()
        
        for x in dataWithDupe {
            if dataWithoutDupe.contains(x) {
                continue
            } else {
                dataWithoutDupe.append(x)
            }
        }
        
        return dataWithoutDupe
    }
}
    


