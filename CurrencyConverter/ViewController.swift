//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by rohit karyappa on 21/03/18.
//  Copyright © 2018 rohit karyappa. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var sliderCurrency: UISlider!
    @IBOutlet weak var lblDestination: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var txtCurrencyValuField: UITextField!
    @IBOutlet weak var pickerCurremcy: UIPickerView!
    @IBOutlet weak var txtDestinationCurrency: UITextField!
    @IBOutlet weak var txtBaseCurrency: UITextField!
    @IBOutlet weak var lblHint: UILabel!
    
    var arrayCurrecy:[Currency] = []
    var strBaseCurrency:String?
    var txtActiveCurrencyField:UITextField?
    var strCurrencyFrom:String?
    var strCurrencyTo:String?
    var strValueToConvert:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerCurremcy.dataSource = self
        self.pickerCurremcy.delegate = self
        self.sliderCurrency.minimumValue = 0
        self.sliderCurrency.maximumValue = 1000
        self.sliderCurrency.value = 0.0
        strValueToConvert = Double(self.sliderCurrency.value)
        self.lblHint.text = "Please enter currency From & To "
        self.lblSource.text = ""
        self.lblDestination.text = ""
        fetchLatestCurrencyRates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    func fetchLatestCurrencyRates(){
        
        let urlString = URL(string: kCurrencyConverterURL)
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error)
                } else {
                    if let usableData = data {
                        let dicData:[String:Any] = (self.dataToJSON(data: usableData) as? [String:Any])!
                        self.strBaseCurrency = dicData["base"] as? String
                        let rates = dicData["rates"]! as? [String:Double]
                        self.arrayCurrecy.removeAll()
                        var arr:[Currency] = []
                        for (key,value) in rates!{
                            let currencyObject = Currency(strCurrencyTitle:key,rateCurrency:Double (value))
                            arr.append(currencyObject)
                        }
                        self.arrayCurrecy = arr.sorted(by: { $0.strCurrencyTitle! > $1.strCurrencyTitle! })
                        DispatchQueue.main.async {
                            self.pickerCurremcy.reloadAllComponents()
                        }
                    }
                }
            }
            task.resume()
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCurrecy.count
    }
    
    // Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = (arrayCurrecy[row]).strCurrencyTitle
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let strCurrency = (arrayCurrecy[row]).strCurrencyTitle
        if txtActiveCurrencyField == txtBaseCurrency {
            strCurrencyFrom = strCurrency
            txtBaseCurrency.text = strCurrency
        }else if txtActiveCurrencyField == txtDestinationCurrency {
            strCurrencyTo = strCurrency
            txtDestinationCurrency.text = strCurrency
        }
        performCurrecyCalculation()
    }
    
    
    @IBAction func sliderCurrencyValueChange(_ sender: Any) {
        strValueToConvert = Double(self.sliderCurrency.value)
        self.txtCurrencyValuField.text = "\(self.sliderCurrency.value)"
        performCurrecyCalculation()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        
        if textField == txtBaseCurrency ||  textField == txtDestinationCurrency {
            txtActiveCurrencyField = textField
            if textField == txtBaseCurrency  {
                self.lblHint.text = "Select Base Currency"
            }
            
            if textField == txtDestinationCurrency {
                self.lblHint.text = "Select Destination Currency"
            }
            self.pickerCurremcy.reloadAllComponents()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == txtCurrencyValuField  {
            if string.isEmpty { return true }
            let currentText = textField.text ?? ""
            let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return replacementText.isValidDouble(maxDecimalPlaces: 2)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCurrencyValuField  {
            self.sliderCurrency.value = (textField.text! as NSString).floatValue
            strValueToConvert = (textField.text! as NSString).doubleValue
             performCurrecyCalculation()
        }
    }
    
    func performCurrecyCalculation(){
        if strCurrencyFrom != nil &&  strCurrencyTo != nil &&  strValueToConvert != nil {
            let convesrionBase:Currency = self.arrayCurrecy.filter { $0.strCurrencyTitle == strBaseCurrency}[0]
            let conversionFrom:Currency = self.arrayCurrecy.filter { $0.strCurrencyTitle == strCurrencyFrom }[0]
            let conversionTo:Currency = self.arrayCurrecy.filter { $0.strCurrencyTitle == strCurrencyTo}[0]
            let result = ((convesrionBase.rateCurrency!/conversionFrom.rateCurrency!)*conversionTo.rateCurrency!)*Double(strValueToConvert!)
            self.lblSource.text = "\(strCurrencyFrom!) \(strValueToConvert!)"
            self.lblDestination.text = "\(strCurrencyTo!) \(String(format: "%.2f", result))"
        }
    }
    
}

