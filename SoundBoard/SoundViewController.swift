//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Emerson on 6/21/20.
//  Copyright © 2020 Emerson. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var timeFinal: UILabel!
    @IBOutlet weak var controlVolumen: UISlider!
    @IBOutlet weak var valueVolumen: UILabel!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var time:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeFinal.isHidden = true
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        currentTime.text = "\(grabarAudio!.currentTime)"
        controlVolumen.minimumValue = 0.0
        controlVolumen.maximumValue = 1.0
        controlVolumen.value = 0.5
        valueVolumen.text = "\(controlVolumen.value)"
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer) in self.currentTime.text = "\(round(self.grabarAudio!.currentTime*10)/10)"
        })
        
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.pause()
            time = "\(round(self.grabarAudio!.currentTime*10)/10)"
            grabarAudio?.stop()
            print(time!)
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            currentTime.isHidden = true
            timeFinal.isHidden = false
            timeFinal.text = "\(time!)"
        }else{
            time = "0"
            timeFinal.isHidden = true
            currentTime.isHidden = false
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            reproducirAudio!.volume = controlVolumen.value
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    @IBAction func valueChange(_ sender: UISlider) {
        valueVolumen.text = "\(round(controlVolumen.value*10)/10)"
        reproducirAudio!.volume = controlVolumen.value
    }
    
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session .setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("*******************")
            print(audioURL!)
            print("*******************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings:settings)
            grabarAudio!.prepareToRecord()
            
            
        } catch let error as NSError {
            print(error)
        }
    }
    

}
