//
//  add_noteViewController.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit
import AVFoundation

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}

class add_noteViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate {

    
    
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteDescription: UITextView!
    @IBOutlet weak var recordButton: UIButton!
   // @IBOutlet var photoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    var imagePicker: ImagePicker!
    var bPhotoSelected = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var bAudioRecorded = false
    var nNow = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            // failed to record!
        }
        
        nNow = Int(Date().timeIntervalSince1970)

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    
    
    @IBAction func cancel_btn_pressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func map_btn_pressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    @IBAction func save_btn_pressed(_ sender: UIBarButtonItem) {
        
        if noteTitle.text == "" || noteDescription.text == "" || !bAudioRecorded || !bPhotoSelected  {
               return
           }
        
           let noteDic = NSMutableDictionary()
           noteDic.setValue(noteTitle.text, forKey: "title")
           noteDic.setValue(noteDescription.text, forKey: "description")
           noteDic.setValue(Int(Date().timeIntervalSince1970), forKey: "time")
           noteDic.setValue(String(format: "%d_recording.m4a", nNow), forKey: "audioURL")
           noteDic.setValue(String(format: "%d_photo.png", nNow), forKey: "photoURL")
           
           let defaults = UserDefaults.standard
           
           if defaults.value(forKey: "noteSavedArray") != nil { // array is already existing
               let savedData = defaults.value(forKey: "noteSavedArray") as! NSArray
               let savedArray = savedData.mutableCopy() as! NSMutableArray
               savedArray.add(noteDic)
               print(savedArray)
               DispatchQueue.main.async {
                   defaults.setValue(savedArray, forKey: "noteSavedArray")
               }
               
               
           } else { // first time, so array is not existing
               let savedArray = NSMutableArray()
               savedArray.add(noteDic)
               print(savedArray)
               DispatchQueue.main.async {
                   defaults.setValue(savedArray, forKey: "noteSavedArray")
               }
           }
           self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func add_image_btn(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    @IBAction func record_sudio_btn(_ sender: Any) {
        
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent(String(format: "%d_recording.m4a", nNow))

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(String(format: "%d_photo.png", nNow))!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

extension add_noteViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.photoButton.setImage(image, for: .normal)
        bPhotoSelected = saveImage(image: image!)
    }
}
