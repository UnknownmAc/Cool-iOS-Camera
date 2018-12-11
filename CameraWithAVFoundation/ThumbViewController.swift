//
//  ThumbViewController.swift
//  CameraWithAVFoundation
//
//  Created by Nishant Kumar on 30/11/18.
//  Copyright © 2018 Gabriel Alvarado. All rights reserved.
//


@objc class ThumbViewController: UIViewController {
    
    var thumbLists:Array<UIImage> = []
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImg = #imageLiteral(resourceName: "background1")
        
        if (thumbLists.count > 0) {
            var thumbWidth = CGFloat(280)
            var thumbHeight = CGFloat(280)
            
            var counter = 0
            let padding = CGFloat(20.0)
            
            // iterate and add to view
            for thumb in thumbLists {
                let uiImage = thumb
                
                let fgImage: UIImageView!
                fgImage = UIImageView(image: resizeImage(image: uiImage, targetSize: CGSize(width: thumbWidth * 0.8, height: thumbHeight * 0.8)))
                fgImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                fgImage.frame = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)
                
                let bgUIImgView: UIImageView!
                bgUIImgView = UIImageView(image: resizeImage(image: backgroundImg, targetSize: CGSize(width: thumbWidth, height: thumbWidth)))
                bgUIImgView.frame = CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight)
                
                if(uiImage.size.width > uiImage.size.height) {
                    thumbHeight = thumbWidth * (uiImage.size.height / uiImage.size.width)
                } else {
                    thumbWidth = thumbHeight * (uiImage.size.width / uiImage.size.height)
                }
                
                var leftPad = CGFloat(0.0)
                if(counter % 2 == 1) {
                    leftPad = 1.0
                }
                
                let divider = CGFloat(2.0)
                let xPos = CGFloat(padding + leftPad * thumbWidth)
                let rowNum = CGFloat(counter)
                let yPos = CGFloat(padding + thumbHeight * (rowNum / divider))
                
                let mergedImgView: UIImageView!
                var mergedImg = drawImage(image: fgImage.image!, inImage: bgUIImgView.image!, atPoint: CGPoint(x:thumbWidth * 0.4, y: thumbHeight * 0.05))
                mergedImg = textToImage(drawText: "Top Text", drawText: "Bottom Text", inImage: mergedImg, atPoint: CGPoint(x: mergedImg.size.width/2, y: 0.1))
                mergedImgView = UIImageView(image: mergedImg)
                
                mergedImgView.transform = CGAffineTransform(scaleX: -1, y: 1)
                mergedImgView.frame = CGRect(x: xPos, y: yPos, width: thumbWidth, height: thumbWidth)
               
                // add to parent view
                self.scrollView.addSubview(mergedImgView)
                
                counter += 1
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func HandleShareThumbClick(_ sender: Any) {
    }
    
    @IBAction func HandleBackButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleImageData(image: UIImage) {
        self.thumbLists.append(image)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func textToImage(drawText topText: String, drawText bottomText: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        // save the context so that it can be undone later
        context!.saveGState()
        context!.translateBy(x: 0, y: image.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let topRect = CGRect(origin: point, size: image.size)
        let bottomRect = CGRect(origin: CGPoint(x: image.size.width/0.2, y: image.size.height), size: image.size)
        topText.draw(in: topRect, withAttributes: textFontAttributes)
        bottomText.draw(in: bottomRect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // undo changes to the context
        context!.restoreGState()
        UIGraphicsEndImageContext()
    
        
        return newImage!
    }
    
    func drawImage(image foreGroundImage:UIImage, inImage backgroundImage:UIImage, atPoint point:CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect.init(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))
        foreGroundImage.draw(in: CGRect.init(x: point.x, y: point.y, width: foreGroundImage.size.width, height: foreGroundImage.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
