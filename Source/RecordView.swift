//
//  RecordView.swift
//  iRecordView
//
//  Created by Devlomi on 8/3/19.
//  Copyright © 2019 Devlomi. All rights reserved.
//

import UIKit

public class RecordView: UIView, CAAnimationDelegate {

    private var isSwiped = false
    private var bucketImageView: BucketImageView!

    private var timer: Timer?
    private var duration: CGFloat = 0
    private var mTransform: CGAffineTransform!
    private var audioPlayer: AudioPlayer!
    
    private var timerStackView: UIStackView!
    private var slideToCancelStackVIew: UIStackView!
    private var slideToLockStackVIew: UIStackView!

    public weak var delegate: RecordViewDelegate?
    public var offset: CGFloat = 20
    public var isSoundEnabled = true
    private var isLockRecord: Bool = false

    public var slideToCancelText: String! {
        didSet {
            slideLabel.text = slideToCancelText
        }
    }

    public var slideToCancelTextColor: UIColor! {
        didSet {
            slideLabel.textColor = slideToCancelTextColor
        }
    }

    public var slideToCancelArrowImage: UIImage! {
        didSet {
            arrow.image = slideToCancelArrowImage
        }
    }

    public var smallMicImage: UIImage! {
        didSet {
            bucketImageView.smallMicImage = smallMicImage
        }
    }

    public var durationTimerColor: UIColor! {
        didSet {
            timerLabel.textColor = durationTimerColor
        }
    }


    private let arrow: UIImageView = {
        let arrowView = UIImageView()
        arrowView.image = UIImage.fromPod("arrow")
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.tintColor = .black
        return arrowView
    }()

    private let arrowUp: UIImageView = {
        let arrowView = UIImageView()
        arrowView.image = UIImage.fromPod("arrowUp")
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.tintColor = .black
        return arrowView
    }()

    private let lockdown: UIImageView = {
        let arrowView = UIImageView()
        arrowView.image = UIImage.fromPod("lockdown")
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.tintColor = .black
        return arrowView
    }()

    private let slideLabel: UILabel = {
        let slide = UILabel()
        slide.text = "Slide To Cancel"
        slide.translatesAutoresizingMaskIntoConstraints = false
        slide.font = slide.font.withSize(12)
        return slide
    }()

    private var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var cancelActionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.red, for: [])
        button.setTitle("Cancel", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onSwipe(recordButton:)), for: .touchUpInside)
        return button
    }()

    private func setup() {
        print("test setup")
        bucketImageView = BucketImageView(frame: frame)
        bucketImageView.animationDelegate = self
        bucketImageView.translatesAutoresizingMaskIntoConstraints = false
        bucketImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        bucketImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true


        timerStackView = UIStackView(arrangedSubviews: [bucketImageView, timerLabel])
        timerStackView.translatesAutoresizingMaskIntoConstraints = false
        timerStackView.alignment = .center
        timerStackView.isHidden = true
        timerStackView.spacing = 5


        slideToCancelStackVIew = UIStackView(arrangedSubviews: [arrow, slideLabel])
        slideToCancelStackVIew.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelStackVIew.alignment = .center
        slideToCancelStackVIew.isHidden = true


        addSubview(timerStackView)
        addSubview(slideToCancelStackVIew)


        arrow.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 15).isActive = true

        slideToCancelStackVIew.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        slideToCancelStackVIew.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        slideToCancelStackVIew.topAnchor.constraint(equalTo: self.topAnchor).isActive = true


        timerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        timerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        timerStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true


        mTransform = CGAffineTransform(scaleX: 2.0, y: 2.0)

        addSubview(cancelActionButton)
        cancelActionButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cancelActionButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancelActionButton.isHidden = true
        
        audioPlayer = AudioPlayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func onTouchDown(recordButton: RecordButton) {
        if isLockRecord {
            onFinish(recordButton: recordButton)
        } else {
            onStart(recordButton: recordButton)
        }
    }

    func onTouchUp(recordButton: RecordButton) {
        if !isLockRecord {
            onFinish(recordButton: recordButton)
        }
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    @objc private func updateDuration() {
        duration += 1
        timerLabel.text = duration.fromatSecondsFromTimer()
    }

    func createLockRecordView(recordButton: RecordButton) -> UIView {
        
        let recordButtonFrame = convert(recordButton.frame, to: self)
        let heightOfLockView: CGFloat = 74
        let lockViewFrame = CGRect(
            x: recordButtonFrame.origin.x - 4,
            y: -heightOfLockView,
            width: recordButtonFrame.width,
            height: heightOfLockView
        )
        let lockdownView = UIView(frame: .zero)
        lockdownView.backgroundColor = .white
        lockdownView.layer.cornerRadius = 12
        lockdownView.clipsToBounds = true
        addSubview(lockdownView)
        
        lockdown.widthAnchor.constraint(equalToConstant: 24).isActive = true
        lockdown.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        arrowUp.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrowUp.heightAnchor.constraint(equalToConstant: 15).isActive = true

        slideToLockStackVIew = UIStackView(arrangedSubviews: [lockdown, arrowUp])
        slideToLockStackVIew.axis = .vertical
        slideToLockStackVIew.distribution = .equalSpacing
        slideToLockStackVIew.spacing = 12
        slideToLockStackVIew.alignment = .center
        slideToLockStackVIew.translatesAutoresizingMaskIntoConstraints = false
        slideToLockStackVIew.isHidden = false
        lockdownView.addSubview(slideToLockStackVIew)
        lockdownView.frame = lockViewFrame
        
        slideToLockStackVIew.leadingAnchor.constraint(equalTo: lockdownView.leadingAnchor).isActive = true
        slideToLockStackVIew.trailingAnchor.constraint(equalTo: lockdownView.trailingAnchor).isActive = true
        slideToLockStackVIew.topAnchor.constraint(equalTo: lockdownView.topAnchor).isActive = true

        return lockdownView
    }
    
    private var lockdownView: UIView!
    //this will be called when user starts tapping the button
    private func onStart(recordButton: RecordButton) {
        resetTimer()
        if lockdownView == nil {
            lockdownView = createLockRecordView(recordButton: recordButton)
        }
        isSwiped = false
        //start timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)


        //reset all views to default
        slideToCancelStackVIew.transform = .identity
        recordButton.transform = .identity

        //animate button to scale up
        UIView.animate(withDuration: 0.2) {
            recordButton.transform = self.mTransform
        }


        slideToCancelStackVIew.isHidden = false
        timerStackView.isHidden = false
        timerLabel.isHidden = false
        bucketImageView.isHidden = false
        bucketImageView.resetAnimations()
        bucketImageView.animateAlpha()

        if isSoundEnabled {
            audioPlayer.playAudioFile(soundType: .start)
        }

        delegate?.onStart()

    }
    private var _recordButton: UIButton?
    
    //this will be called when user swipes to the left and cancel the record
    private func onLockRecord(recordButton: RecordButton) {
        slideToCancelStackVIew.isHidden = true
        isLockRecord = true
        lockdownView.isHidden = true
        cancelActionButton.isHidden = false

        recordButton.isUserInteractionEnabled = false
        recordButton.isUserInteractionEnabled = true
        recordButton.isEnabled = false
        recordButton.isEnabled = true
        _recordButton = recordButton
    }
    
    @objc private func onSwipe(recordButton: RecordButton) {
        isSwiped = true
        isLockRecord = false
        cancelActionButton.isHidden = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
            self._recordButton?.transform = .identity
        })
        _recordButton = nil

        slideToCancelStackVIew.isHidden = true
        timerLabel.isHidden = true

        if !isLessThanOneSecond() {
            bucketImageView.animateBucketAndMic()

        } else {
            bucketImageView.isHidden = true
            delegate?.onAnimationEnd?()
        }

        resetTimer()

        delegate?.onCancel()
    }

    private func resetTimer() {
        timer?.invalidate()
        timerLabel.text = "00:00"
        duration = 0
    }

    //this will be called when user lift his finger
    private func onFinish(recordButton: RecordButton) {
        isSwiped = false
        isLockRecord = false
        recordButton.isUserInteractionEnabled = false
        recordButton.isUserInteractionEnabled = true
        cancelActionButton.isHidden = true
        if lockdownView != nil {
            lockdownView.isHidden = true
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
        })


        slideToCancelStackVIew.isHidden = true
        timerStackView.isHidden = true

        timerLabel.isHidden = true


        if isLessThanOneSecond() {
            if isSoundEnabled {
                audioPlayer.playAudioFile(soundType: .error)
            }
        } else {
            if isSoundEnabled {

                audioPlayer.playAudioFile(soundType: .end)
            }
        }

        delegate?.onFinished(duration: duration)

        resetTimer()

    }


    //this will be called when user starts to move his finger
    func touchMoved(recordButton: RecordButton, sender: UIPanGestureRecognizer) {

        if isSwiped || isLockRecord {
            return
        }

        let button = sender.view!
        let translation = sender.translation(in: button)

        switch sender.state {
        case .changed:
            
            //prevent swiping the button outside the bounds
            print("*********TRANSLATION.X: \(translation.x)")
            print("*********TRANSLATION.Y: \(translation.y)")
            if isLockRecord { return }
            if translation.y < -5 && translation.x > -5 { //Ignore lock if you alredy sliding left / right
                lockdownView.isHidden = false
                let transform: CGAffineTransform!
                if translation.y < -50 {
                    onLockRecord(recordButton: recordButton)
                    transform = mTransform.translatedBy(x: 0, y: 0)
                } else {
                    transform = mTransform.translatedBy(x: 0, y: translation.y)
                }
                button.transform = transform
            } else
                if translation.x < 0 {
                    lockdownView.isHidden = true
                    //start move the views
                    let transform = mTransform.translatedBy(x: translation.x, y: 0)
                    button.transform = transform
                    slideToCancelStackVIew.transform = transform.scaledBy(x: 0.5, y: 0.5)
                    
                    if slideToCancelStackVIew.frame.intersects(timerStackView.frame.offsetBy(dx: offset, dy: 0)) {
                        onSwipe(recordButton: recordButton)
                    }
            }
        case .ended:
            if !isLockRecord {
                onFinish(recordButton: recordButton)
            }
        default:
            break
        }

    }


}


extension RecordView: AnimationFinishedDelegate {
    func animationFinished() {
        slideToCancelStackVIew.isHidden = true
        timerStackView.isHidden = false
        timerLabel.isHidden = true
        delegate?.onAnimationEnd?()
    }
}

private extension RecordView {
    func isLessThanOneSecond() -> Bool {
        return duration < 1
    }
}


