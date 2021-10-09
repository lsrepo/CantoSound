//
//  CameraView.swift
//  CantoSound
//
//  Created by Pak Lau on 20/9/2020.
//

import SwiftUI
import AVFoundation


struct CameraView : UIViewControllerRepresentable {
    let controller = CameraViewController()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIViewController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraView.UIViewControllerType, context: UIViewControllerRepresentableContext<CameraView>) {
    }

}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
           ForEach(ColorScheme.allCases, id: \.self, content: CameraView().preferredColorScheme)
       }
}



class CameraViewController : UIViewController {
    var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreview: AVCaptureVideoPreviewLayer?
    lazy var avSession = AVCaptureSession()
    lazy var session = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .back
    )
    lazy var camera = session.devices.first

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try self.configureDeviceInputs()
            try self.configurePhotoOutput()
        }
        catch {}
    }
    
    
    func configureDeviceInputs() throws {
        guard camera != nil else { throw CameraControllerError.noCamerasAvailable }
        guard let input = try? AVCaptureDeviceInput(device : camera!) else { return }
        
        cameraPreview = AVCaptureVideoPreviewLayer(session: avSession)
   
        guard let cameraPreview = cameraPreview  else {return}
        
        view.layer.addSublayer(cameraPreview)
        cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let bounds = view.layer.bounds
        cameraPreview.bounds = bounds
        cameraPreview.position = CGPoint(x:bounds.midX, y:bounds.midY)
        
        let maskLayer = CALayer()
        maskLayer.masksToBounds = true
        maskLayer.frame = CGRect(x: 0,y: 0,width: cameraPreview.frame.width ,height: cameraPreview.frame.height / 3)
        maskLayer.backgroundColor = UIColor.black.cgColor
        cameraPreview.mask = maskLayer
        
        if (avSession.canAddInput(input)){
            avSession.addInput(input)
            avSession.startRunning()
        }
    }
    
    func configurePhotoOutput() throws {
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
        guard let photoOutput = self.photoOutput else {return}
        
        if (avSession.canAddOutput(photoOutput)){
            avSession.addOutput(photoOutput)
        }
    }
    
    func capturePhoto() {
        let capturePhotoSettings = AVCapturePhotoSettings()
        capturePhotoSettings.flashMode = .off
        
        photoOutput?.capturePhoto(with: capturePhotoSettings, delegate: self)
        
    }

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let photoCaptureCompletionBlock = self.photoCaptureCompletionBlock else {
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        guard let photoImage = UIImage(data: photoData) else {
            return
        }
        let resiezed = (photoImage).scaleImage(toWidth: UIScreen.main.bounds.size.width)
        
        
        let cropped = resiezed.cropImage(toRect: CGRect(
          x: 0,
          y: 0,
          width: cameraPreview!.frame.width * resiezed.scale,
          height: cameraPreview!.frame.height / 3 * resiezed.scale
        ))
        
        photoCaptureCompletionBlock(cropped)
    }
}

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}


