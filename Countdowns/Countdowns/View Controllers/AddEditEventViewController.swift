//
//  AddEditEventViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

protocol AddEventViewControllerDelegate: UITableViewController {}

protocol EditEventViewControllerDelegate {
    func updateViews()
}

class AddEditEventViewController: UIViewController {
    // MARK: - Properties
    
    var addEventDelegate: AddEventViewControllerDelegate?
    var editEventDelegate: EditEventViewControllerDelegate?
    var event: Event?
    
    // MARK: - Outlets
    @IBOutlet weak var sceneTitleLabel: UILabel!
    @IBOutlet weak var viewSegmentedControl: UISegmentedControl!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var customTimeSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event != nil {
            resetViewForEditingEvent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Action Methods
    
    @IBAction func viewSegmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dateLabel.isHidden = false
            datePicker.isHidden = false
            timeLabel.isHidden = false
            timePicker.isHidden = !customTimeSwitch.isOn
            customTimeSwitch.isHidden = false
            
            tagsLabel.isHidden = true
            tagsField.isHidden = true
            notesLabel.isHidden = true
            notesTextView.isHidden = true
            
            if notesTextView.isFirstResponder {
                notesTextView.resignFirstResponder()
            }
        case 1:
            dateLabel.isHidden = true
            datePicker.isHidden = true
            timeLabel.isHidden = true
            timePicker.isHidden = true
            customTimeSwitch.isHidden = true
            
            tagsLabel.isHidden = false
            tagsField.isHidden = false
            notesLabel.isHidden = false
            notesTextView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func customTimeSwitchChanged(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            timePicker.isHidden = false
        case false:
            timePicker.isHidden = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let eventName = eventNameField.text, !eventName.isEmpty
            else { return }
        
        let hasCustomTime = customTimeSwitch.isOn
        
        // get date from pickers
        let eventDate: Date
        if !hasCustomTime {
            eventDate = datePicker.date
        } else {
            let date = Calendar.autoupdatingCurrent.dateComponents(
                [.year, .month, .day],
                from: datePicker.date
            )
            let time = Calendar.autoupdatingCurrent.dateComponents(
                [.hour, .minute],
                from: timePicker.date
            )
            
            let dateComponents = DateComponents(
                calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent,
                year: date.year, month: date.month, day: date.day,
                hour: time.hour, minute: time.minute
            )
            guard let dateFromComponents = dateComponents.date else { return }
            
            eventDate = dateFromComponents
        }
        
        // get tags from text field
        var tags = [Tag]()
        
        if let tagsText = tagsField.text, !tagsText.isEmpty {
            let subTags = tagsText.split(separator: .tagSeparator, omittingEmptySubsequences: true)
            for subTag in subTags {
                tags.append(String(subTag).stripMultiSpace())
            }
        }
        
        // get note
        let hasNote = !notesTextView.text.isEmpty
        let note: String = hasNote ? notesTextView.text : ""
        
        // add new event (if adding)
        if event == nil {
            EventController.shared.create(Event(
                name: eventName, dateTime: eventDate,
                tags: tags, note: note, hasTime: hasCustomTime
            ))
            
            addEventDelegate?.tableView.reloadData()
        // edit event (if editing)
        } else {
            EventController.shared.update(
                event!, with: eventName, dateTime: eventDate,
                tags: tags, note: note, hasTime: hasCustomTime
            )
            
            editEventDelegate?.updateViews()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func resetViewForEditingEvent() {
        guard let event = event else { return }
        
        sceneTitleLabel.text = "Edit event"
        eventNameField.text = event.name
        datePicker.date = event.dateTime
        timePicker.date = event.dateTime
        customTimeSwitch.isOn = event.hasTime
        tagsField.text = event.tagsText
        notesTextView.text = event.note
    }
}
