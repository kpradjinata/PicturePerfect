//
//  ViewController.swift
//  theyCallMeSIGABRT
//
//  Created by Kevin Pradjinata on 1/15/21.
//

import UIKit
import Speech
import CorePlot

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var done: UIButton!
    
    @IBAction func soojue(_ sender: UIButton) {
        performSegue(withIdentifier: "Soojue", sender: sender)
    }
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    static var cum: Double = 0.0 // CUMMULATIVE TIME
    static var someCum = [Int]() // WORDCOUNT
    static var dicCum = [Int: Double]() // WORDCOUNT : TIM-ELA
    static var pubicHair = [Double]() // TIME-ELA
    static var assHair = [Double]() // TIME-DIFF
    static var daddy = [Double]() // WPM
    
    static var sTime = CFAbsoluteTimeGetCurrent()
    
    
//    let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
//        //print("Timer fired!")
//        cum+=1
//       // print(cum)
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Soojue" {
                let destinationVC = segue.destination as! GraphViewController
                destinationVC.wpm = ViewController.daddy
                destinationVC.totTime = ViewController.pubicHair    
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        microphoneButton.isEnabled = false
            
        speechRecognizer?.delegate = self  //created a question mark here
            
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                
                var isButtonEnabled = false
                
                switch authStatus {
                case .authorized:
                    isButtonEnabled = true
                    
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                    
                case .restricted:
                    isButtonEnabled = false
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    isButtonEnabled = false
                    print("Speech recognition not yet authorized")
                }
                
                OperationQueue.main.addOperation() {
                    self.microphoneButton.isEnabled = isButtonEnabled
                }
            }
    }
    
    
        
    func subtract() {
        ViewController.pubicHair.append(ViewController.dicCum[ViewController.someCum[1]]!)
        for wordCount in ViewController.someCum {
            let diff = ViewController.dicCum[wordCount]
            ViewController.pubicHair.append(diff!)
        }
        print(ViewController.pubicHair)
        ViewController.pubicHair = Array(Set(ViewController.pubicHair)).sorted()
        print(ViewController.pubicHair)
    
        for crust in 1...ViewController.pubicHair.count-2{
            ViewController.assHair.append(ViewController.pubicHair[crust+1]-ViewController.pubicHair[crust])
        }
        //print(ViewController.pubicHair)
        //print(ViewController.assHair)
        for penis in ViewController.assHair {
            ViewController.daddy.append(abs(1/(penis/1000)*60))
        }
        print(ViewController.daddy)
//        return ViewController.daddy
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                microphoneButton.isEnabled = false
                microphoneButton.setTitle("Start Recording", for: .normal)
            
            } else {
                startRecording()
                microphoneButton.setTitle("Stop Recording", for: .normal)
            }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let text = textView.text else {return}
        print(text)
        subtract()
        print("WC-TIME-ELA: \(ViewController.dicCum)")
        print("CUMM-TIME: \(ViewController.cum)")
        print("WORD COUNT: \(ViewController.someCum)")
        print("TIME-ELA: \(ViewController.pubicHair)")
        print("TIME-DIFF: \(ViewController.assHair)")
        print("WPM: \(ViewController.daddy)")
        
    }
    
    
    
    func spaceCounter(_ s: String) -> Int{
            let c =  s.components(separatedBy:" ")
            return c.count
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
       let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in //added question mark here
            
            var isFinal = false
            
            if result != nil {
                var cTime = CFAbsoluteTimeGetCurrent()
                ViewController.cum = (cTime - ViewController.sTime) * 1000
                self.textView.text = result?.bestTranscription.formattedString //bestTranscriptiuon is black
                isFinal = (result?.isFinal)!
                if ViewController.someCum.count==0 {
                    ViewController.someCum.append(self.spaceCounter(self.textView.text))
                    ViewController.dicCum[ViewController.someCum.last!] = 0
                }
                else{
                    if let oldText = ViewController.someCum.last {
                        if oldText - self.spaceCounter(self.textView.text) != 0 {
                            ViewController.someCum.append(self.spaceCounter(self.textView.text))
                            ViewController.dicCum[ViewController.someCum.last!] = ViewController.cum
                            //print(ViewController.someCum)
                        }
                    }
                    
                }
                //print(ViewController.someCum)
                //print("Te:\(self.textView.text) T: \(ViewController.cum)")
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {(buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        textView.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    


}

