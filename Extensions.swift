//
//  Extensions.swift
//
//  Created by Anton Mansvelt on 2016/07/14.
//  Copyright © 2016 Anton Mansvelt. All rights reserved.
//

import UIKit

let animationDuration : TimeInterval = 0.5
class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: animationDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
                                   completion: { finished in
                                    src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
class SegueFromRight: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
extension NSLayoutManager {
//    https://github.com/ilyapuchka/ReadMoreTextView/blob/master/Sources/UITextView%2BExtensions.swift
    /**
     Returns characters range that completely fits into container.
     */
    public func characterRangeThatFits(textContainer container: NSTextContainer) -> NSRange {
        var rangeThatFits = self.glyphRange(for: container)
        rangeThatFits = self.characterRange(forGlyphRange: rangeThatFits, actualGlyphRange: nil)
        return rangeThatFits
    }
    
    /**
     Returns bounding rect in provided container for characters in provided range.
     */
    public func boundingRectForCharacterRange(range aRange: NSRange, inTextContainer container: NSTextContainer) -> CGRect {
        let glyphRange = self.glyphRange(forCharacterRange: aRange, actualCharacterRange: nil)
        let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: container)
        return boundingRect
    }
}

extension UITextView {
//    https://github.com/ilyapuchka/ReadMoreTextView/blob/master/Sources/UITextView%2BExtensions.swift
    /**
     Calls provided `test` block if point is in gliph range and there is no link detected at this point.
     Will pass in to `test` a character index that corresponds to `point`.
     Return `self` in `test` if text view should intercept the touch event or `nil` otherwise.
     */
    public func hitTest(pointInGliphRange aPoint: CGPoint, event: UIEvent?, test: (Int) -> UIView?) -> UIView? {
        guard let charIndex = charIndexForPointInGlyphRect(point: aPoint) else {
            return super.hitTest(aPoint, with: event)
        }
        guard textStorage.attribute(NSLinkAttributeName, at: charIndex, effectiveRange: nil) == nil else {
            return super.hitTest(aPoint, with: event)
        }
        return test(charIndex)
    }
    
    /**
     Returns true if point is in text bounding rect adjusted with padding.
     Bounding rect will be enlarged with positive padding values and decreased with negative values.
     */
    public func pointIsInTextRange(point aPoint: CGPoint, range: NSRange, padding: UIEdgeInsets) -> Bool {
        var boundingRect = layoutManager.boundingRectForCharacterRange(range: range, inTextContainer: textContainer)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(padding.left + padding.right), dy: -(padding.top + padding.bottom))
        return boundingRect.contains(aPoint)
    }
    
    /**
     Returns index of character for glyph at provided point. Returns `nil` if point is out of any glyph.
     */
    public func charIndexForPointInGlyphRect(point aPoint: CGPoint) -> Int? {
        let point = CGPoint(x: aPoint.x, y: aPoint.y - textContainerInset.top)
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(glyphIndex, 1), in: textContainer)
        if glyphRect.contains(point) {
            return layoutManager.characterIndexForGlyph(at: glyphIndex)
        } else {
            return nil
        }
    }
    
}
//This needs work 
/*
extension UIBarButtonItem{
    var isHidden : Bool{
        if self.isEnabled == false && self.tintColor == UIColor.clear {
            return true
        }
        return false
    }
    
    func setHidden(){
        if self.isHidden{
            self.isEnabled = false
            self.tintColor = UIColor.clear
        }
        else {
            self.isEnabled = true
            self.tintColor = UIColor.white
        }
    }
}*/

extension Date {
    func ToLocalStringWithFormat(_ dateFormat: String) -> String {
        // change to a readable time format and change to local time zone
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let timeStamp = dateFormatter.string(from: self)
        
        return timeStamp
    }
    
//    http://stackoverflow.com/questions/25533147/get-day-of-week-using-nsdate-swift/25533357#25533357
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        //EEEEE and EEEEEE gives you short forms of the days, e.g. Wed, Th, Fr 
        return dateFormatter.string(from: self).uppercased()
    }
    
    func dateArrayFromTwoDates(_ startDate: Date) -> [String]{
        var arrayOfDates = [String]()
        var oneDate = startDate
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        while oneDate <= self {
            arrayOfDates.append(oneDate.ToLocalStringWithFormat("yyyy-MM-dd"))
            oneDate = calendar.date(byAdding: .day, value: 1, to:oneDate)!
        }
        return arrayOfDates
    }
    
    //returns a date from a given amount of days before the used date(self)
    func dateFromDays(days:Int) -> Date{
        let seconds = days * -86400 //86400 secs per day
        return self.addingTimeInterval(TimeInterval(seconds))
    }
    
}

extension String {
    var length: Int {
        return characters.count
    }
    
    func ToLocalDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
//        print (self)
        
        let dateFormatterPretty = DateFormatter()
        dateFormatterPretty.dateFormat = "MMM dd yyyy hh:mm"
        
        

        let date = dateFormatter.date(from: self)
        let timeStamp = dateFormatterPretty.string(from: date!)
        
        return timeStamp
    }
    
    func dateValue() -> Date{
        //Depends on format of string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let date:Date = dateFormatter.date(from: self)!
        return date
    }
    
    func formatDate() -> String{
        let dateFormatterPretty = DateFormatter()
        dateFormatterPretty.dateFormat = "MMM dd yyyy hh:mm"
        let formatted = dateFormatterPretty.string(from: self.dateValue())
        return formatted
    }
    
    //returns st nd rd after the number of the month ex: July 01st 2017 08:00
    func extendedFormat() ->String{
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "dd"
        let day = dateFormatterDay.string(from: self.dateValue())
        var extFormat = ""
        switch day{
            case "01","21","31":
                extFormat = "\(day)st"
            case "02","22":
                extFormat = "\(day)nd"
            case "03","23":
                extFormat = "\(day)rd"
            case "04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","24","25","26","27","28","29","30":
                extFormat = "\(day)th"
        default :
            print("extended Format Date had an EPIC FAIL :D")
        }
        
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.dateFormat = "MMM"
        let month = dateFormatterMonth.string(from: self.dateValue())
        
        let dateFormatterYearTime = DateFormatter()
        dateFormatterYearTime.dateFormat = "yyyy hh:mm"
        let yearTime = dateFormatterYearTime.string(from: self.dateValue())
        
        let wholeDateString = "\(month) \(extFormat) \(yearTime)"
        
        return wholeDateString
    }
}

extension UIImageView{
    
    func makeBlurImage(_ targetImageView:UIImageView?)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetImageView?.addSubview(blurEffectView)
    }
    
}

//returns an image with a colour overlay of your choice, using for tababr so that we can just have one image
extension UIImage {
    func imageWithColor(_ color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0);
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
//Adds the swipe gesture to the actual bar of the tab bar
extension UITabBarController {
    func setupSwipeGestureRecognizers(allowCyclingThoughTabs cycleThroughTabs: Bool = false) {
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: cycleThroughTabs ? #selector(handleSwipeLeftAllowingCyclingThroughTabs) : #selector(handleSwipeLeft))
        swipeLeftGestureRecognizer.direction = .left
        self.tabBar.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: cycleThroughTabs ? #selector(handleSwipeRightAllowingCyclingThroughTabs) : #selector(handleSwipeRight))
        swipeRightGestureRecognizer.direction = .right
        self.tabBar.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    @objc fileprivate func handleSwipeLeft(_ swipe: UISwipeGestureRecognizer) {
//        print("swiped Left")
        self.selectedIndex -= 1
    }
    
    @objc fileprivate func handleSwipeRight(_ swipe: UISwipeGestureRecognizer) {
//        print("swiped Left")
        self.selectedIndex += 1
    }
    
    @objc fileprivate func handleSwipeLeftAllowingCyclingThroughTabs(_ swipe: UISwipeGestureRecognizer) {
        let maxIndex = (self.viewControllers?.count ?? 0)
        let nextIndex = self.selectedIndex - 1
        self.selectedIndex = nextIndex >= 0 ? nextIndex : maxIndex - 1
        
    }
    
    @objc fileprivate func handleSwipeRightAllowingCyclingThroughTabs(_ swipe: UISwipeGestureRecognizer) {
        let maxIndex = (self.viewControllers?.count ?? 0)
        let nextIndex = self.selectedIndex + 1
        self.selectedIndex = nextIndex < maxIndex ? nextIndex : 0
    }
}

//To update the color of a searchBar
public extension UISearchBar {
    
    public func setTextColour(_ color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    public func setBackgroundColour(_ color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.backgroundColor = color
    }
}
//Lets you call a solid colour as an image with let redImage = UIImage(color: .redColor())
//http://stackoverflow.com/questions/26542035/create-uiimage-with-solid-color-in-swift
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
//To return a alphabetically sorted list of the keys in a Dictionary
public extension  Dictionary {
    public func allKeys() -> [String]{
        var keys :[String] = [String]()
        for (key,_) in self{
            let stringKey = String(describing: key)
            keys.append(stringKey)
        }
        
        return keys
    }
    
    public func sortedKeys()-> [String]{
        var keys :[String] = [String]()
        for (key,_) in self{
            let stringKey = String(describing: key)
            keys.append(stringKey)
        }
        
        return keys.sorted()
    }
    
}
//http://stackoverflow.com/questions/25738817/does-there-exist-within-swifts-api-an-easy-way-to-remove-duplicate-elements-fro //Leo Dabus
//removes duplicates but keeps the order they were in
extension Array where Element: Equatable{
    var orderedSetValue: Array  {
        return reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
}

extension Collection where Iterator.Element == String {
    //Returns the initials of an array of strings
    var initials: [String] {
        return map{ String($0.characters.prefix(1)) }
    }
    //This takes an array and returns a dictionary with keys as the first letter and a value of an array of Strings (for use with sectioned tableviews)
    public func buildIndexedDictionary() -> [String:[String]]{
        var indexedDic:[String:[String]] = [:]
        let allInitials = self.initials
        //Set removes duplicates BUT might change order
        let initials = Array(Set(allInitials))
        for one in self{
            for initial in initials{
                if String(one.characters.first!) == initial {
                    if var oneArray = indexedDic[initial] {
                        oneArray.append(one)
                        indexedDic[initial] = oneArray
                    }
                    else{
                        let oneArray = [one]
                        indexedDic[initial] = oneArray
                    }
                }
            }
        }
        return indexedDic
    }
}

//Makes an easily available reference to the max double value
extension Double {
    static var min = Double.leastNormalMagnitude
    static var max = Double.greatestFiniteMagnitude

    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

//shows in storyboard as placeHolderColor
//extension UITextField{
//@IBInspectable var placeHolderColor: UIColor? {
//get {
//    return self.placeHolderColor
//}
//set {
//    self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
//}
//}
//}

//Adds a gradient to a UIView
//extension UIView {
//    @IBInspectable var gradient : UIColor?{
//        get{
//            return self.gradient
//        }
//        set{
//            layerGradient()
//        }
//
//    }
//    func layerGradient() {
//        let layer : CAGradientLayer = CAGradientLayer()
//        layer.frame.size = self.frame.size
//        layer.frame.origin = CGPointMake(0.0,0.0)
//        layer.cornerRadius = CGFloat(frame.width / 20)
//
//        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).CGColor
//        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).CGColor
//        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).CGColor
//        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).CGColor
//        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).CGColor
//        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).CGColor
//        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).CGColor
//
//        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
//        self.layer.insertSublayer(layer, atIndex: 0)
//    }
//}
