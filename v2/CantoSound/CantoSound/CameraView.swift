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
        CameraView()
    }
}



class CameraViewController : UIViewController {
    
    var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreview: AVCaptureVideoPreviewLayer?
    lazy var avSession = AVCaptureSession()
    lazy var session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    lazy var  camera = session.devices.first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
//            self.view.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
            try self.configureDeviceInputs()
            try self.configurePhotoOutput()
        }
        catch {
            
        }
    }
    
    
    func configureDeviceInputs() throws {
        guard camera != nil else { throw CameraControllerError.noCamerasAvailable }
        guard let input = try? AVCaptureDeviceInput(device : camera!) else { return }
        
        cameraPreview = AVCaptureVideoPreviewLayer(session: avSession)
        let bounds = view.layer.bounds
        
        guard let cameraPreview = cameraPreview  else {return}
        
//        cameraPreview.metadataOutputRectConverted(fromLayerRect: CGRect(x: 0,y: 0,width: 375,height: 200))
        
        view.layer.addSublayer(cameraPreview)
        cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreview.bounds = bounds
        cameraPreview.position = CGPoint(x:bounds.midX, y:bounds.midY)
        
        let maskLayer = CALayer()
        maskLayer.masksToBounds = true
        
        maskLayer.frame = CGRect(x: 0,y: 0,width: 375,height: 200)
        maskLayer.backgroundColor = UIColor.black.cgColor
        cameraPreview.mask = maskLayer
        
        print(" cameraPreview.frame ",  cameraPreview.frame )
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
        
        print("cap: frame", self.view.frame)
        print("cap: bounds", self.view.bounds)
        
        print("cap: cam frame", self.cameraPreview?.frame)
        print("cap: cam bounds", self.cameraPreview?.bounds)
        photoOutput?.capturePhoto(with: capturePhotoSettings, delegate: self)
        
    }
    // TODO: move to extension
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
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
        
        
        let cropped = cropImage(imageToCrop: resiezed, toRect: CGRect(x: 0,y: 0,width: 375 * resiezed.scale, height: 200 * resiezed.scale))
        
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




extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}


extension UIImage {
    func scaleImage(toWidth newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let image = renderer.image { (context) in
            self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        }
        return image
    }
}
