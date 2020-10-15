//
//  ViewController.swift
//  Sketch App
//
//  Created by mac on 2020/10/15.
//  Copyright © 2020 Iwan Buchler. All rights reserved.
//

import UIKit
import PhotosUI
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver{

    @IBOutlet var pencilButton: UIBarButtonItem!
    @IBOutlet var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasScroll: CGFloat = 400
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window){
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateSize()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func switchDrawMode(_ sender: Any){
        canvasView.allowsFingerDrawing.toggle()
        pencilButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
        
    }

    @IBAction func saveDrawing(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {sucess, error in
                // executed or failed 
                
            })
        }
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateSize()
    }
    
    func updateSize() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull{
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasScroll) * canvasView.zoomScale)
        }
            
        else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
    }
    
}

