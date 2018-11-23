//
//  ViewController.swift
//  ImageProcessing
//
//  Created by 綦帅鹏 on 2018/11/23.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var resetB: UIButton!
    var optionsB: Array<UIButton> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr = ["高斯模糊"]
        for str: String in arr {
            let strObj = NSString(string: str)
            let optionB = UIButton(type: UIButton.ButtonType.system)
            optionB.setTitle(str, for: UIControl.State.normal)
            optionB.frame = CGRect(x: self.resetB.frame.origin.x + self.resetB.frame.size.width + 8, y: self.resetB.frame.origin.y, width: strObj.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: optionB.titleLabel!.font], context: nil).width, height: self.resetB.frame.size.height)
            self.view.addSubview(optionB)
            self.optionsB.append(optionB)
        }
        self.imageV.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = keyPath?.elementsEqual("image") {
            if let _ = object {
                self.imageV.backgroundColor = UIColor.darkText
                self.resetB.isEnabled = true
            } else {
                self.imageV.backgroundColor = UIColor.white
                self.resetB.isEnabled = false
            }
        }
    }
    func openSetting() {
        let url = URL(string: UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    @IBAction func imageAction(_ sender: UIBarButtonItem) {
        let alert: UIAlertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraA: UIAlertAction = UIAlertAction(title: "相机", style: UIAlertAction.Style.default) { _ in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == AVAuthorizationStatus.restricted || status == AVAuthorizationStatus.denied) {//收限或拒绝
                self.openSetting()
            } else {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (success) in
                    DispatchQueue.main.async {
                        if success {
                            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                                let imagePickerC: UIImagePickerController = UIImagePickerController()
                                imagePickerC.allowsEditing = true
                                imagePickerC.delegate = self
                                imagePickerC.sourceType = UIImagePickerController.SourceType.camera
                                self.present(imagePickerC, animated: true, completion: nil)
                            } else {
                                let alert = UIAlertController(title: "提示", message: "设备没有相机", preferredStyle: UIAlertController.Style.alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            self.openSetting()
                        }
                    }
                })
            }
        }
        alert.addAction(cameraA)
        let photoA: UIAlertAction = UIAlertAction(title: "相册", style: UIAlertAction.Style.default) { _ in
            let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            if (status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied) {
                self.openSetting()
            } else {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.async {
                        if status == PHAuthorizationStatus.authorized {
                            let imagePickerC: UIImagePickerController = UIImagePickerController()
                            imagePickerC.allowsEditing = false
                            imagePickerC.delegate = self
                            imagePickerC.sourceType = UIImagePickerController.SourceType.photoLibrary
                            self.present(imagePickerC, animated: true, completion: nil)
                        } else {
                            self.openSetting()
                        }
                    }
                })
            }
        }
        alert.addAction(photoA)
        if ((imageV?.image) != nil) {
            let removeA: UIAlertAction = UIAlertAction(title: "移除", style: UIAlertAction.Style.default) { _ in
                
            }
            alert.addAction(removeA)
        }
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func resetAction(_ sender: UIButton) {
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        self.imageV.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
}

