//
//  ViewController.swift
//  WasteMem
//
//  Created by Jorge Bernal Ordovas on 24/01/2017.
//  Copyright © 2017 Jorge Bernal. All rights reserved.
//

import UIKit

private let bytesInAMegabyte = 1048576

class ViewController: UIViewController {
    @IBOutlet var usedLabel: UILabel!
    @IBOutlet var freeLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var logTextView: UITextView!
    @IBOutlet var button: UIButton!

    var running = false;

    var timer: Timer!
    var data: Data = Data()

    deinit {
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        log("⚠️ Memory warning");
    }

    func allocate() {
        // Allocate 100 MB
        let size = 100 * bytesInAMegabyte
        let sizeFormatted = formatMemory(size)
        log("👾 Allocating \(sizeFormatted)")
        guard let handle = FileHandle(forReadingAtPath: "/dev/zero") else {
            log("🚨 Can't open /dev/zero")
            return
        }
        let chunk = handle.readData(ofLength: Int(size))
        data.append(chunk)
//        let actualSize = Memory.allocateBytes(size)
        log("👾 Allocated \(formatMemory(chunk.count))")
    }

    @IBAction func buttonPressed() {
        if running {
            stop()
        } else {
            start()
        }
    }

    func formatMemory(_ size: Int) -> String {
        return "\(size/bytesInAMegabyte) MB"
    }

    func start() {
        guard !running else { return }
        log("👉 Start")
        button.setTitle("Stop", for: .normal)
        running = true
    }

    func stop() {
        guard running else { return }
        log("✋ Stop")
        button.setTitle("Start", for: .normal)
        running = false
//        let freedFormatted = formatMemory(Memory.freeAllTheThings())
        let freedFormatted = formatMemory(data.count)
        data.removeAll()
        log("😌 Freed \(freedFormatted)")
    }

    func timerFired() {
        let stats = Memory.stats()
        usedLabel.text = formatMemory(stats.used)
        freeLabel.text = formatMemory(stats.free)
        totalLabel.text = formatMemory(stats.total)
        if running {
            allocate()
        }
    }

    func log(_ msg: String) {
        logTextView.text.append("\(msg)\n")
    }
}

