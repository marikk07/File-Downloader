//
//  ViewController.swift
//  Download Animation
//
//  Created by pasichniak maryan on 4/13/18.
//  Copyright © 2018 pasichniak maryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    
    var shapeLayer: CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupCircle()
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        view.addSubview(percentageLabel)
        
        setupNotificationObservers()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    private func setupCircle() {

        // Custom
        pulsatingLayer = createCircleShapeLayer(strokeColor: UIColor.clear, fillColor: UIColor.red.withAlphaComponent(0.7))
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()

        trackLayer = createCircleShapeLayer(strokeColor: UIColor.darkGray, fillColor: UIColor.black)
        view.layer.addSublayer(trackLayer)

        shapeLayer = createCircleShapeLayer(strokeColor: UIColor.red, fillColor: UIColor.clear)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        ///
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = view.center
        return layer
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.5
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func beginDownloadFile() {
        shapeLayer.strokeEnd = 0
        let urlStr = "https://firebasestorage.googleapis.com/v0/b/downloadanimation-b00df.appspot.com/o/videoplayback.mp4?alt=media&token=5dc336eb-c8ff-4ddc-8ae2-de0b0342cdae"
        let configuration = URLSessionConfiguration.default
        let queue = OperationQueue()
        let urlsession = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        guard let url = URL(string: urlStr) else { return }
        let downloadTask = urlsession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    private func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    @objc private func handleTap () {
        beginDownloadFile()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finish")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = percentage
            self.percentageLabel.text = "\(Int(percentage * 100))%"
        }
        print(percentage)
    }
    

}

