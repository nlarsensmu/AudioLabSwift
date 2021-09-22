//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal





class ViewController: UIViewController {

    struct AudioConstants{
        static let AUDIO_BUFFER_SIZE = 1024*4
    }
    
    // setup audio model
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    lazy var graph:MetalGraph? = {
        return MetalGraph(mainView: self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add in graphs for display
        graph?.addGraph(withName: "fft",
                        shouldNormalize: true,
                        numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE/2)
 
//      Removed to fit graphs better
//        graph?.addGraph(withName: "fft_zoomed",
//                        shouldNormalize: true,
//                        numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE/20)
        
        graph?.addGraph(withName: "equalize",
            shouldNormalize: true,
            numPointsInGraph: 20)
        
        graph?.addGraph(withName: "time",
            shouldNormalize: false,
            numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE)
        
        
        
        // start up the audio model here, querying microphone
//        audio.startMicrophoneProcessing(withFps: 10)  // How often should FFT update the properties

        audio.startProcessingAudioFileForPlayback(withFps: 10)
        audio.play()
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.updateGraph),
            userInfo: nil,
            repeats: true)
       
    }
    
    // periodically, update the graph with refreshed FFT Data
    @objc
    func updateGraph(){
        
        self.graph?.updateGraph(
            data: self.audio.timeData,
            forKey: "time"
        )
        
        self.graph?.updateGraph(
            data: self.audio.fftData,
            forKey: "fft"
       )
        self.graph?.updateGraph(
            data: self.audio.equalize,
            forKey: "equalize"
        )
    }
    override func viewDidDisappear(_ animated: Bool) {
      // Get the new view controller.
        super.viewDidDisappear(animated)
        self.audio.pause()
    }
}

