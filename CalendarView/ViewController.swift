//
//  ViewController.swift
//  CalendarView
//
//  Created by Yogesh Bharate on 09/08/16.
//  Copyright © 2016 Yogesh Bharate. All rights reserved.
//

import UIKit
import DDCalendarView

class ViewController: UIViewController {

  // IBOutlets
  @IBOutlet var calendarView: DDCalendarView!

  // Variables
  var ddEvents = [DDCalendarEvent]()
  var dict = Dictionary<Int, [DDCalendarEvent]>()


  // MARK:- View Controller Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewWillAppear(animated: Bool) {
    loadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension ViewController: DDCalendarViewDelegate, DDCalendarViewDataSource {
  func calendarView(view: DDCalendarView, focussedOnDay date: NSDate) {
    let days = date.daysFromDate(NSDate())
    self.loadCachedEvents(days) { (events) -> Void in
      self.calendarView.reloadData()
      print("DAY: \(days)")
    }
  }

  // dataSource
  func calendarView(view: DDCalendarView, eventsForDay date: NSDate) -> [AnyObject]? {
    return dict[date.daysFromDate(NSDate())]
  }

  // helper
  func loadCachedEvents(day:Int, handler:([DDCalendarEvent])->Void) {
    self.dict[day] = ddEvents
    handler(ddEvents)
  }
}

// MARK: Load data
extension ViewController {
  private func loadData() {
    if let path = NSBundle.mainBundle().pathForResource("Data", ofType: "json") {
      do {
        let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        do {
          let result = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
          if let appointment = result["appointments"] as? NSArray {
            print("DATA: \(appointment)")
            fillEvents(appointment)
          }
        } catch {}
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
  }

  private func fillEvents(events: NSArray) {
    for i in 0 ..< events.count {
      var userInfo:[NSObject: AnyObject] = [:]
      let ddEvent = DDCalendarEvent()
      if let patientFirstName = events[i]["patientFirstName"] as? String{
        var name: String!
        // Appointment id
        if let id = events[i]["id"] as? Int {
          userInfo["appointmentId"] = id
        }
        if let status = events[i]["status"] as? String {
          userInfo["status"] = status
        }
        if let duration = events[i]["durationInMins"] as? Int {
          userInfo["duration"] = duration
        }
        if let start = events[i]["startDate"] as? String {
          let startDate = convertUTCStringToNSDate(start)
          userInfo["startDate"] = startDate
          ddEvent.dateBegin = startDate
        }
        if let end = events[i]["endDate"] as? String {
          let endDate = convertUTCStringToNSDate(end)
          userInfo["endDate"] = endDate
          ddEvent.dateEnd = endDate
        }
        // Patient Details
        if let patientLastName = events[i]["patientLastName"] as? String {
          name = patientFirstName + " " +  patientLastName
          userInfo["patientName"] = name
          ddEvent.title = name
        }
        if let id = events[i]["patientId"] as? Int {
          userInfo["patientId"] = id
        }
        // Room
        if let id = events[i]["roomId"] as? Int {
          userInfo["roomId"] = id
        }
        if let room = events[i]["roomTitle"] as? String {
          userInfo["roomTitle"] = room
        }
        ddEvent.userInfo = userInfo
      }
      ddEvents.append(ddEvent)
      print("Events: \(ddEvents)")
    }
    assert(NSThread.isMainThread())
    showData()
  }

  private func showData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.calendarView.reloadData()
    }
  }

  private func convertUTCStringToNSDate(date:String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let date = dateFormatter.dateFromString(date)
    print("date: \(date)")
    return date!
  }
}



