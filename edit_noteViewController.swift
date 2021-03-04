//
//  edit_noteViewController.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit
import AVFoundation

class edit_noteViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var note_title: UITextField!
    @IBOutlet weak var note_description: UITextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var imagePicker: ImagePicker!
    var bPhotoSelected = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var bAudioRecorded = false
    var nNow = 0
    var dicNote:NSDictionary!
    var noteSavedArray:NSMutableArray!
    var nIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 0..<noteSavedArray.count {
            let dicIndex = noteSavedArray.object(at: index) as? NSDictionary
            let strTitle = dicIndex!["title"] as! String
            let strCurrentTitle = dicNote["title"] as! String
            if strTitle == strCurrentTitle {
                nIndex = index
                break
            }
        }
        note_title.text = dicNote!["title"] as? String
        note_description.text = dicNote!["infor"] as? String
        let strImage = (dicNote!["photoURL"] as? String)!
        if let image = getSavedImage(named: strImage) {
            // do something with image
            photoButton.setImage(image, for: .normal)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.view.addGestureRecognizer(gesture)
        self.recordButton.isHidden = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordButton.isHidden = false
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            print("Failed to Record")
        }
        
        nNow = Int(Date().timeIntervalSince1970)
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func record_btn_pressed(_ sender: UIButton) {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            bAudioRecorded = true
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent((dicNote!["audioURL"] as? String)!)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }

    @IBAction func save_btn_pressed(_ sender: UIBarButtonItem) {
        if note_title.text == "" || note_description.text == "" {
            return
        }
        let edittedNote = NSMutableDictionary()
        edittedNote.setValue(note_title.text, forKey: "title")
        edittedNote.setValue(note_description.text, forKey: "infor")
        edittedNote.setValue(Int(Date().timeIntervalSince1970), forKey: "time")
        edittedNote.setValue(dicNote["audioURL"] as? String, forKey: "audioURL")
        edittedNote.setValue(dicNote["photoURL"] as? String, forKey: "photoURL")
        
        noteSavedArray[nIndex] = edittedNote as NSDictionary
        //print(noteSavedArray!)
        
        let defaults = UserDefaults.standard
        defaults.setValue(noteSavedArray, forKey: "SavedArray")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func back_btn_pressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent((dicNote!["photoURL"] as? String)!)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

extension edit_noteViewController: ImagePickerDelegate {
        func didSelect(image: UIImage?) {
        self.photoButton.setImage(image, for: .normal)
        bPhotoSelected = saveImage(image: image!)
    }
}
