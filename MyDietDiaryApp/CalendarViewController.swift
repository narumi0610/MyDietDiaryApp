//
//  CalenderViewController.swift
//  MyDietDiaryApp
//
//  Created by mac on 2023/03/17.
//

import UIKit
import FSCalendar
import RealmSwift

class CalenderViewController: UIViewController {
    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    
    // ボタンを押したときの処理
    @IBAction func addButton(_ sender: Any) {
        transitionToEditorView()
    }
    
    var recordList: [WeightRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
        configureButton()
        // FSCalendarDataSourceを有効化
        calendarView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecord()
        calenderView.reloadData()
    }
    
    func configureCalendar() {
        // ヘッダーの日付フォーマットを変更
        calenderView.appearance.headerDateFormat = "yyyy年MM月dd日"
        
        // 曜日と今日の色を指定
        calenderView.appearance.todayColor = .orange
        calenderView.appearance.headerTitleColor = .orange
        calenderView.appearance.weekdayTextColor = .black
        
        // 曜日表示内容を変更
        calenderView.calendarWeekdayView.weekdayLabels[0].text = "日"
        calenderView.calendarWeekdayView.weekdayLabels[1].text = "月"
        calenderView.calendarWeekdayView.weekdayLabels[2].text = "火"
        calenderView.calendarWeekdayView.weekdayLabels[3].text = "水"
        calenderView.calendarWeekdayView.weekdayLabels[4].text = "木"
        calenderView.calendarWeekdayView.weekdayLabels[5].text = "金"
        calenderView.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        // 土日の色を変更
        calenderView.calendarWeekdayView.weekdayLabels[0].textColor = .red
        calenderView.calendarWeekdayView.weekdayLabels[6].textColor = .blue
    }
    
    func configureButton() {
        addButton.layer.cornerRadius = 5 // TODO なぜか角丸にならない
     }
    
    func transitionToEditorView() {
        let storyboad = UIStoryboard(name: "EditorViewController", bundle: nil)
        
        guard let editorViewController = storyboad.instantiateInitialViewController() as?
        EditorViewController else { return }
        present(editorViewController, animated: true) // 画面遷移させる
    }
    
    func getRecord() {
        let realm = try! Realm()
        recordList = Array(realm.objects(WeightRecord.self))
    }
 }

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calandar: FSCalendar, numberOfEventsFor date: Date) -> Int {
          return 1
    }
}
