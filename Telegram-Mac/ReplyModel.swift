//
//  ReplyModel.swift
//  Telegram-Mac
//
//  Created by keepcoder on 21/09/16.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import TelegramCoreMac
import SwiftSignalKitMac
import PostboxMac
class ReplyModel: ChatAccessoryModel {

    private var account:Account
    private(set) var replyMessage:Message?
    private var disposable:MetaDisposable = MetaDisposable()
    private let isPinned:Bool
    private var previousMedia: Media?
    private var isLoading: Bool = false
    private let fetchDisposable = MetaDisposable()
    init(replyMessageId:MessageId, account:Account, replyMessage:Message? = nil, isPinned: Bool = false, presentation: ChatAccessoryPresentation? = nil) {
        self.isPinned = isPinned
        self.account = account
        self.replyMessage = replyMessage
        super.init(presentation: presentation)
        if let replyMessage = replyMessage {
            make(with :replyMessage, display: false)
            nodeReady.set(.single(true))
        } else {
            
            make(with: nil, display: false)
            nodeReady.set( account.postbox.messageView(replyMessageId) |> mapToSignal { view -> Signal<Message?, Void> in
                if let message = view.message {
                    return .single(message)
                }
                return getMessagesLoadIfNecessary([view.messageId], postbox: account.postbox, network: account.network) |> map {$0.first}
            } |> deliverOn(Queue.mainQueue().isCurrent() ? Queue.mainQueue() : prepareQueue) |> map { [weak self] message -> Bool in
                 self?.make(with: message, isLoading: false, display: true)
                 return message != nil
             })
        }
    }
    
    override var view: ChatAccessoryView? {
        didSet {
            updateImageIfNeeded()
        }
    }
    
    override var frame: NSRect {
        didSet {
            updateImageIfNeeded()
        }
    }
    
    override var leftInset: CGFloat {
        var imageDimensions: CGSize?
        if let message = replyMessage {
            for media in message.media {
                if let image = media as? TelegramMediaImage {
                    if let representation = largestRepresentationForPhoto(image) {
                        imageDimensions = representation.dimensions
                    }
                    break
                }
//                else if let file = media as? TelegramMediaFile {
//                    if let representation = largestImageRepresentation(file.previewRepresentations), !file.isSticker {
//                        imageDimensions = representation.dimensions
//                    }
//                    break
//                }
            }
            
            if let _ = imageDimensions {
                return 30 + super.leftInset * 2
            }
        }
        
        return super.leftInset
    }
    
    deinit {
        disposable.dispose()
        fetchDisposable.dispose()
    }
    
    func update() {
        self.make(with: replyMessage, isLoading: isLoading, display: true)
    }
    
    private func updateImageIfNeeded() {
        Queue.mainQueue().async {
            if let message = self.replyMessage, let view = self.view, view.frame != NSZeroRect {
                var updatedMedia: Media?
                var imageDimensions: CGSize?
                for media in message.media {
                    if let image = media as? TelegramMediaImage {
                        updatedMedia = image
                        if let representation = largestRepresentationForPhoto(image) {
                            imageDimensions = representation.dimensions
                        }
                        break
                    }
                }
                
                if let imageDimensions = imageDimensions {
                    let boundingSize = CGSize(width: 30.0, height: 30.0)
                    let arguments = TransformImageArguments(corners: ImageCorners(radius: 2.0), imageSize: imageDimensions.aspectFilled(boundingSize), boundingSize: boundingSize, intrinsicInsets: NSEdgeInsets())
                    
                    if view.imageView == nil {
                        view.imageView = TransformImageView()
                    }
                    view.imageView?.setFrameSize(boundingSize)
                    view.addSubview(view.imageView!)
                    view.imageView?.centerY(x: super.leftInset + (self.isSideAccessory ? 10 : 0))
                    
                    
                    let mediaUpdated = true
                    
                    
                    var updateImageSignal: Signal<(TransformImageArguments) -> DrawingContext?, NoError>?
                    if mediaUpdated {
                        if let image = updatedMedia as? TelegramMediaImage {
                            updateImageSignal = chatMessagePhotoThumbnail(account: self.account, photo: image, scale: view.backingScaleFactor)
                        } else if let file = updatedMedia as? TelegramMediaFile {
                            
                        }
                    }
                    
                    if let updateImageSignal = updateImageSignal, let media = updatedMedia {
                        
                        view.imageView?.setSignal(signal: cachedMedia(media: media, size: arguments.imageSize, scale: view.backingScaleFactor))
                        
                        if view.imageView?.layer?.contents == nil {
                            view.imageView?.setSignal(updateImageSignal, animate: true, cacheImage: { image in
                                return cacheMedia(signal: image, media: media, size: arguments.imageSize, scale: System.backingScale)
                            })
                            if let media = media as? TelegramMediaImage {
                                self.fetchDisposable.set(chatMessagePhotoInteractiveFetched(account: self.account, photo: media).start())
                            }
                        }
                        
                        view.imageView?.set(arguments: arguments)
                    }
                } else {
                    view.imageView?.removeFromSuperview()
                    view.imageView = nil
                }
                
                self.previousMedia = updatedMedia
            } else {
                self.view?.imageView?.removeFromSuperview()
                self.view?.imageView = nil
            }
        }
    }
    
    func make(with message:Message?, isLoading: Bool = true, display: Bool) -> Void {
        self.replyMessage = message
        self.isLoading = isLoading
        
        var display: Bool = display
        updateImageIfNeeded()

        if let message = message {
            
            var peer = message.author
        
            for attr in message.attributes {
                if let _ = attr as? SourceReferenceMessageAttribute {
                    if let info = message.forwardInfo {
                        peer = info.author
                    }
                    break
                }
            }
            
            
            var text = pullText(from:message, attachEmoji: false) as String
            if text.isEmpty {
                text = serviceMessageText(message, account: account)
            }
            self.headerAttr = .initialize(string: !isPinned ? peer?.displayTitle : tr(.chatHeaderPinnedMessage), color: presentation.title, font: .medium(.text))
            self.messageAttr = .initialize(string: text, color: message.media.isEmpty || message.media.first is TelegramMediaWebpage ? presentation.enabledText : presentation.disabledText, font: .normal(.text))
        } else {
            self.headerAttr = nil
            self.messageAttr = .initialize(string: isLoading ? tr(.messagesReplyLoadingLoading) : tr(.messagesDeletedMessage), color: presentation.disabledText, font: .normal(.text))
            display = true
        }
        
        if !isLoading {
            measureSize(width, sizeToFit: sizeToFit)
            display = true
        }
        if display {
            Queue.mainQueue().async {
                self.view?.setFrameSize(self.size)
                self.setNeedDisplay()
            }
        }
    }

    
}
