//
//  ViewController.swift
//  ImageProcessing
//
//  Created by 綦帅鹏 on 2018/11/23.
//

import UIKit
import Photos
import AVFoundation

private var myContext = 0

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var resetB: UIButton!
    var currentI: UIImage?
    var optionsB: Array<UIButton> = []
    
    deinit {
        self.imageV.removeObserver(self, forKeyPath: "image", context: &myContext)
    }
    @objc func gaussianBlurAction(sender: UIButton) {
        let image = self.imageV.image!
        let ciImage = (image.ciImage != nil) ? image.ciImage : CIImage(image: image)
        
        self.imageV.image = UIImage(ciImage: gaussianBlur(radius: 20)(ciImage!))
    }
    @objc func colorGeneratorAction(sender: UIButton) {
        let image = self.imageV.image!
        let ciImage = (image.ciImage != nil) ? image.ciImage : CIImage(image: image)
        
        print("++++++++++++\(self.imageV.image!.size)")
        let endImage = UIImage(ciImage: colorGenerator(color: CIColor(color: UIColor.blue))(ciImage!))
        print("------------\(endImage.size)")
        
        self.imageV.image = endImage
    }
    @objc func colorOverlayAction(sender: UIButton) {
        let image = self.imageV.image!
        let ciImage = (image.ciImage != nil) ? image.ciImage : CIImage(image: image)
        
        self.imageV.image = UIImage(ciImage: colorOverlay(color: CIColor(color: UIColor.green))(ciImage!))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr: [[String: Any]] = [["title": "高斯模糊", "selector": #selector(gaussianBlurAction(sender:))], ["title": "颜色覆盖", "selector": #selector(colorGeneratorAction(sender:))], ["title": "颜色叠加", "selector": #selector(colorOverlayAction(sender:))]]
        var optionB: UIButton
        var X: CGFloat = 0
        var W: CGFloat = 0
        
        for item in arr {
            let title = item["title"] as! String
            let selector = item["selector"] as! Selector
            optionB = UIButton(type: UIButton.ButtonType.system)
            optionB.setTitle(title, for: UIControl.State.normal)
           
            optionB.addTarget(self, action: selector, for: UIControl.Event.touchUpInside)
            let button: UIButton = self.optionsB.count > 0 ? self.optionsB.last! : self.resetB
            X = button.frame.origin.x + button.frame.size.width + 8
            let strObj = NSString(string: title)
            W = strObj.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: optionB.titleLabel!.font], context: nil).width
            optionB.frame = CGRect(x: X, y: self.resetB.frame.origin.y, width: W, height: self.resetB.frame.size.height)
            self.scrollV.addSubview(optionB)
            self.optionsB.append(optionB)
        }
        self.scrollV.contentSize = CGSize(width: X + W + 8, height: self.scrollV.contentSize.height)
        self.currentI = imageV.image
        self.imageV.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let _ = keyPath?.elementsEqual("image") {
                if let _ = change?[NSKeyValueChangeKey.newKey] as? UIImage {
                    print("*************\(self.imageV.image!.size)")
                    self.resetB.isEnabled = !imageV.image!.isEqual(self.currentI)
                    self.imageV.backgroundColor = UIColor.black
                    for button in self.optionsB {
                        button.isEnabled = true
                    }
                } else {
                    self.resetB.isEnabled = false
                    self.imageV.backgroundColor = UIColor.white
                    for button in self.optionsB {
                        button.isEnabled = false
                    }
                }
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
        let cameraA: UIAlertAction = UIAlertAction(title: "相机", style: .default) { _ in
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == AVAuthorizationStatus.restricted || status == AVAuthorizationStatus.denied) {//受限或拒绝
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
        let photoA: UIAlertAction = UIAlertAction(title: "相册", style: .default) { _ in
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
            let removeA: UIAlertAction = UIAlertAction(title: "移除", style: .default) { _ in
                self.currentI = nil
                self.imageV.image = nil
            }
            alert.addAction(removeA)
        }
        let cancelA: UIAlertAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelA)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func resetAction(_ sender: UIButton) {
        self.imageV.image = self.currentI
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        self.currentI = image
        self.imageV.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
}

