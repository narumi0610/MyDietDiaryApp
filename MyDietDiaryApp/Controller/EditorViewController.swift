//
//  EditorViewController.swift
//  MyDietDiaryApp
//
//  Created by mac on 2023/03/27.
//

import UIKit
import RealmSwift

protocol EditorViewControllerDelegate {
    func recordUpdate()
}

class EditorViewController: UIViewController {
    @IBOutlet weak var inputWeightTextField: UITextField!
    @IBOutlet weak var inputDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButton(_ sender: UIButton) {
        deleteRecord()
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        saveRecord()
    }
    
    var record = WeightRecord()
    var delegate: EditorViewControllerDelegate?
    
    var datePicker: UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = .current
        datePicker.preferredDatePickerStyle = .wheels // ドラムロールUIを指定している
        datePicker.locale = Locale(identifier: "ja-JP")
        datePicker.date = record.date
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return datePicker
    }
    
    var toolBar: UIToolbar {
        let toolBarRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35)
        let toolBar = UIToolbar(frame: toolBarRect)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolBar.setItems([doneItem], animated: true)
        return toolBar
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = .long
        dateFormatt.timeZone = .current
        dateFormatt.locale = Locale(identifier: "ja-JP")
        return dateFormatt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeightTextField()
        configureDateTextField()
        configureSaveButton()
        let realm = try! Realm()
        let firstRecord = realm.objects(WeightRecord.self).first
        print("😀record: \(record)")
        
        
    }
    
    @objc func didTapDone() {
        view.endEditing(true) // キーボードを閉じるためのメソッド
    }
    
    func configureWeightTextField() {
        
        inputWeightTextField.inputAccessoryView = toolBar
        inputWeightTextField.text = String(record.weight)
    }
    
    func configureDateTextField() {
        inputDateTextField.inputView = datePicker
        inputDateTextField.inputAccessoryView = toolBar
        inputDateTextField.text = dateFormatter.string(from: record.date)
    }
    
    @objc func didChangeDate(picker: UIDatePicker) {
        inputDateTextField.text = dateFormatter.string(from: picker.date)
    }
    
    func configureSaveButton() {
        saveButton.layer.cornerRadius = 5
    }
    
    func saveRecord() {
        let realm = try! Realm()
        
        try! realm.write { // データ保存処理
            if let dateText = inputDateTextField.text,
                let date = dateFormatter.date(from: dateText) {
                record.date = date
            }
            
            if let weightText = inputWeightTextField.text,
               let weight = Double(weightText) {
                record.weight = weight
            }
            
            realm.add(record)
        }
        delegate?.recordUpdate()
        dismiss(animated: true) // データが保存されたら閉じる
    }
    
    func deleteRecord() {
        let calendar = Calendar(identifier: .gregorian)
        let starOfDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: record.date)!
        let endOfdate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: record.date)!
        let realm = try! Realm()
        
        // NSPredicateを使用した条件検索
        let recordList = Array(realm.objects(WeightRecord.self).filter("date BETWEEN {%@, %@}", starOfDate, endOfdate))
        recordList.forEach({ record in
            try! realm.write {
                realm.delete(record)
            }
        })
        delegate?.recordUpdate()
        dismiss(animated:true)
    }
 }
