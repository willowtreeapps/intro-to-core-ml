//
//  CaptureViewController.swift
//  DogeML
//
//  Created by Michael Thomas on 8/20/17.
//  Copyright © 2017 WillowTree, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CaptureViewController: UIViewController {

    @IBOutlet private weak var previewView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    
    // Capture Session Properties
    private var captureSession: AVCaptureSession!
    lazy var previewLayer: AVCaptureVideoPreviewLayer! = {
        guard let captureSession = self.captureSession else { return nil }
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }()
    
    var camera: AVCaptureDevice? = {
        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }()
    
    // Vision Properties
    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceDetectionHandler = VNSequenceRequestHandler()
    
    let dogeModel = Doge()
    lazy var dogeDetection: VNCoreMLRequest = {
        guard let visionModel = try? VNCoreMLModel(for: dogeModel.model) else {
            fatalError("Can't load Doge model!")
        }
        
        return VNCoreMLRequest(model: visionModel)
    }()
    let dogeDetectionHandler = VNSequenceRequestHandler()
    
    // Other Properties
    var processing = false
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.text = "Searching for faces ..."

        // Setup AVCaptureSession & Go!
        setupSession()
        captureSession?.startRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    // MARK: Setup
    
    func setupSession() {
        captureSession = AVCaptureSession()
        guard let captureDevice = camera else { return }
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.beginConfiguration()
            
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            
            output.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            captureSession.commitConfiguration()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.willowtree.SampleBufferQueue"))
            
            // Setup output layer
            previewView.layer.addSublayer(previewLayer)
        } catch {
            fatalError("Unable to setup AVCaptureSession!")
        }
    }
}

// MARK: Vision

extension CaptureViewController {
    
    func detectFace(on image: CIImage) {
        try? faceDetectionHandler.perform([faceDetection], on: image)
        
        guard let results = faceDetection.results as? [VNFaceObservation], results.count == 1 else {
            processing = false
            return
        }
        
        // TODO: how much of my face takes up the screen
        // AND: what's a good amount of face to take up the screen
        
        DispatchQueue.main.async {
            self.detectDogBreed(on: image)
        }
    }

    func detectDogBreed(on image: CIImage) {
        try? dogeDetectionHandler.perform([dogeDetection], on: image)
        
        guard let results = dogeDetection.results,
            !results.isEmpty else {
                processing = false
                return
        }
        
        let dogBreeds = results.flatMap({ $0 as? VNClassificationObservation })
        
        guard let dogBreed = dogBreeds.first else {
            processing = false
            return
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Detected dog type: " + dogBreed.identifier + "!"
            
            // Start again!
            self.processing = false
        }
    }
    
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), !processing else {
            return
        }
        
        processing = true
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: attachments as! [String : Any]?)
        let imageWithOrientation = ciImage.oriented(.leftMirrored)
        detectFace(on: imageWithOrientation)
    }
    
}

// MARK: Helpers

extension CaptureViewController {
    
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage? {
        var rect = rect
        rect.size.width = rect.width * image.scale
        rect.size.height = rect.height * image.scale
        
        guard let imageRef = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
}
