//
//  GraphViewController.swift
//  MyDietDiaryApp
//
//  Created by mac on 2023/03/17.
//

import UIKit
import Charts
import RealmSwift

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: LineChartView!
    
    @IBOutlet weak var startDateTextField: UITextField!
    
    @IBOutlet weak var endDateTextField: UITextField!
    
    var recordList: [WeightRecord] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRecord()
        updateGraph()
        configureGraph()
        configureTextField()
    }
    
    func setRecord() {
        let realm = try! Realm()
        var result = Array(realm.objects(WeightRecord.self))
        result.sort(by: { $0.date < $1.date}) // 日付を若い順にする
        recordList = result
        if let startDateText = startDateTextField.text,
           let endDateText = endDateTextField.text,
           let startDate = dateFormatter.date(from: startDateText),
           let endDate = dateFormatter.date(from: endDateText) {
            var filterdRecord = Array(realm.objects(WeightRecord.self).filter("date BETWEEN { %@, %@ }", startDate, endDate))
            filterdRecord.sort(by: {$0.date < $1.date })
            recordList = filterdRecord
            
        }
    }
    
    func updateGraph() {
        // グラフにデータを設定するためインスタンス化
        var entry = [ChartDataEntry]()
        // enumrated()をはさむと各要素のindex番号を引数として取得できる
        recordList.enumerated().forEach({ index, record in
            let data = ChartDataEntry(x: Double(index), y: record.weight)
            entry.append(data)
        })
        let dataSet = LineChartDataSet(entries: entry, label: "体重")
        graphView.data = LineChartData(dataSet: dataSet)
        graphView.data?.notifyDataChanged()
        graphView.notifyDataSetChanged()
    }
    
    func configureGraph() {
        graphView.xAxis.labelPosition = .bottom
        let titleFormatter = GraphDateTitleFormatter()
        let dateList = recordList.map({ $0.date })
        titleFormatter.dateList = dateList
        graphView.xAxis.valueFormatter = titleFormatter
    }
    
    var datePicker: UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = .current
        datePicker.preferredDatePickerStyle = .wheels // ドラムロールUIを指定している
        datePicker.locale = Locale(identifier: "ja-JP")
        return datePicker
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = .long
        dateFormatt.timeZone = .current
        dateFormatt.locale = Locale(identifier: "ja-JP")
        return dateFormatt
    }
    
    var toolBar: UIToolbar {
        let toolBarRect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35)
        let toolBar = UIToolbar(frame: toolBarRect)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolBar.setItems([doneItem], animated: true)
        return toolBar
    }
    
    @objc func didTapDone() {
        setRecord()
        updateGraph()
        view.endEditing(true) // キーボードを閉じるためのメソッド
    }
    
    func configureTextField() {
        let startDatePicker = datePicker
        let endDatePicker = datePicker
        let today = Date()
        let pastMonth = Calendar.current.date(byAdding: .month, value: -1, to: today)!
        startDatePicker.date = pastMonth
        endDatePicker.date = today
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        startDateTextField.text = dateFormatter.string(from: pastMonth)
        endDateTextField.text = dateFormatter.string(from: today)
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
        startDatePicker.addTarget(self, action: #selector(didChangeStartDate), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(didChangeEndDate), for: .valueChanged)
        
    }
    
    @objc func didChangeStartDate(picker: UIDatePicker) {
        startDateTextField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc func didChangeEndDate(picker: UIDatePicker) {
        endDateTextField.text = dateFormatter.string(from: picker.date)
    }
}
