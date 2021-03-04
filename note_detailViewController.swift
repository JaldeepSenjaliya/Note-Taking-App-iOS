//
//  note_detailViewController.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit
import AVFoundation

class note_detailViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var note_title: UILabel!
    @IBOutlet weak var note_description: UILabel!
    @IBOutlet weak var note_date: UILabel!
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    var noteData : NSDictionary = NSDictionary()
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        note_title.text = noteData["title"] as? String
        note_description.text = noteData["description"] as? String
        let nTime = noteData["time"] as? Int
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(nTime!)) as Date)
        note_date.text = dateString
        
        let strImage = (noteData["photoURL"] as? String)!
        if let image = getSavedImage(named: strImage) {
            image_view.image = image
        }
         preparePlayer()
        
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent((noteData["audioURL"] as? String)!)
        return path as URL
    }
    
    @IBAction func play_audio_btn(_ sender: UIButton) {
        
        if (sender.titleLabel?.text == "Tap to Play"){
            sender.setTitle("Tap to Stop", for: .normal)
            preparePlayer()
            audioPlayer!.play()
        } else {
            audioPlayer!.stop()
            sender.setTitle("Tap to Play", for: .normal)
        }
    }
    
    func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 10.0
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Tap to Play", for: .normal)
    }
    
    @IBAction func map_view(_ sender: Any) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
}
