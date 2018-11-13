//
//  ViewController.swift
//  VjTakagiVoice
//
//  Created by rgbkids on 2018/11/13.
//  Copyright © 2018年 rgbkids. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 44100.0, channels: 1, interleaved: true)
    
    var audioEngine : AVAudioEngine!
    var mixer : AVAudioMixerNode!
    
    @IBOutlet var button: UIButton!
    @IBAction func buttonOnClick(_ sender: UIButton) {
        if (self.audioEngine.isRunning) {
            self.audioEngine.stop()
            button.setTitle("off", for: .normal)
        } else {
            startVoiceChanger()
            button.setTitle("on", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioEngine = AVAudioEngine()
        self.mixer = AVAudioMixerNode()
        self.audioEngine.attach(mixer)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.audioEngine != nil && self.audioEngine.isRunning) {
            button.setTitle("on", for: .normal)
        } else {
            button.setTitle("off", for: .normal)
        }
    }

    func startVoiceChanger() {
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        // Distortion
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.drumsLoFi)
        audioEngine.attach(distortion)
        
        self.audioEngine.connect(self.audioEngine.inputNode, to: distortion, format: self.audioEngine.inputNode.inputFormat(forBus: 0))
        self.audioEngine.connect(distortion, to: self.mixer, format: self.audioEngine.inputNode.inputFormat(forBus: 0))
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: format)
      
        self.mixer.installTap(onBus: 0, bufferSize: 44100, format: format,block: {(buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
        })
        
        try! self.audioEngine.start()
    }
}
