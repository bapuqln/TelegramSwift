//
//  Extensions.swift
//  Telegram-Mac
//
//  Created by keepcoder on 23/09/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Foundation
import TGUIKit
import SwiftSignalKitMac
import TelegramCoreMac
import PostboxMac
import LocalAuthentication
extension Message {
    
    var chatStableId:ChatHistoryEntryId {
        return ChatHistoryEntryId.message(self)
    }
}

extension MessageHistoryHole {
    
    var chatStableId:ChatHistoryEntryId {
        return ChatHistoryEntryId.hole(self)
    }
}


extension NSMutableAttributedString {
    func detectLinks(type:ParsingType, account:Account? = nil, color:NSColor = theme.colors.link, openInfo:((PeerId, Bool, MessageId?, ChatInitialAction?)->Void)? = nil, hashtag:((String)->Void)? = nil, command:((String)->Void)? = nil, applyProxy:((ProxySettings)->Void)? = nil, dotInMention: Bool = false) -> Void {
        let things = ObjcUtils.textCheckingResults(forText: self.string, highlightMentionsAndTags: type.contains(.Mentions) || type.contains(.Hashtags), highlightCommands: type.contains(.Commands), dotInMention: dotInMention)
        
        self.beginEditing()
        
        if let things = things {
            for value in things {
                
                let range = (value as! NSValue).rangeValue
                
                if range.location != NSNotFound {
                    let sublink = (self.string as NSString).substring(with: range)
                    if let account = account {
                        self.addAttribute(NSAttributedStringKey.link, value: inApp(for: sublink as NSString, account: account, openInfo: openInfo, hashtag: hashtag, command: command, applyProxy: applyProxy), range: range)
                    } else {
                        self.addAttribute(NSAttributedStringKey.link, value: inAppLink.external(link: sublink, false), range: range)
                    }
                    self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
                    self.addAttribute(.cursor, value: NSCursor.pointingHand, range: range)
                }
                
            }
        }
        self.endEditing()
        
    }
    func fixUndefinedEmojies() {
        
        func changeSymbol(_ from:String, to: String) -> Bool {
            let range = string.nsstring.range(of: from)
            if range.location != NSNotFound {
                self.replaceCharacters(in: range, with: to)
                return true
            }
            return false
        }
        
        let symbols:[(from: String, to: String)] = [(from: "✌", to: "✌️"), (from: "☺", to: "☺️"), (from: "☝", to: "☝️"), (from: "1⃣", to: "1️⃣"), (from: "2⃣", to: "2️⃣"), (from: "3⃣", to: "3️⃣"), (from: "4⃣", to: "4️⃣"), (from: "5⃣", to: "5️⃣"), (from: "6⃣", to: "6️⃣"), (from: "7⃣", to: "7️⃣"), (from: "8⃣", to: "8️⃣"), (from: "9⃣", to: "9️⃣"), (from: "0⃣", to: "0️⃣"), (from: "❤", to: "❤️"), (from: "☁", to: "☁️"), (from: "ℹ", to: "ℹ️"), (from: "✍", to: "✍️")]
        for symbol in symbols {
            while changeSymbol(symbol.from, to: symbol.to) {
                
            }
        }
    }
    
}




public extension String {
    var fixed:String {
        var str:String = self
        str = str.replacingOccurrences(of: "✌", with: "✌️")
        str = str.replacingOccurrences(of: "☺", with: "☺️")
        str = str.replacingOccurrences(of: "☝", with: "☝️")
        str = str.replacingOccurrences(of: "1⃣", with: "1️⃣")
        str = str.replacingOccurrences(of: "2⃣", with: "2️⃣")
        str = str.replacingOccurrences(of: "3⃣", with: "3️⃣")
        str = str.replacingOccurrences(of: "4⃣", with: "4️⃣")
        str = str.replacingOccurrences(of: "5⃣", with: "5️⃣")
        str = str.replacingOccurrences(of: "6⃣", with: "6️⃣")
        str = str.replacingOccurrences(of: "7⃣", with: "7️⃣")
        str = str.replacingOccurrences(of: "8⃣", with: "8️⃣")
        str = str.replacingOccurrences(of: "9⃣", with: "9️⃣")
        str = str.replacingOccurrences(of: "0⃣", with: "0️⃣")
        str = str.replacingOccurrences(of: "❤", with: "❤️")
        str = str.replacingOccurrences(of: "☁", with: "☁️")
        str = str.replacingOccurrences(of: "✍", with: "✍️")
        return str
    }
    
    static func stringForShortCallDurationSeconds(for seconds: Int32) -> String {
        if seconds < 60 {
            return tr(.callShortSecondsCountable(Int(seconds)))
        }
        else {
            let number = Int(seconds) / 60
            return tr(.callShortMinutesCountable(number))
        }
    }
    
    
    var trimmed:String {
        
        var string:String = self
        while !string.isEmpty, let index = string.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines), index.lowerBound == string.startIndex {
            string = String(string[index.upperBound..<string.endIndex])
        }
        while !string.isEmpty, let index = string.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines, options: .literal, range: string.index(string.endIndex, offsetBy: -1) ..< string.endIndex) {
            string = String(string[..<index.lowerBound])
        }
        
        return string
    }
    
    var fullTrimmed: String {
        var copy: String = self
        var index: String.Index = copy.index(after: copy.startIndex)
        
        var newLineIndexEnd: String.Index? = nil
        
        while index != copy.endIndex {
            
            if let idx = newLineIndexEnd {
                let substring = copy[index..<copy.index(after: idx)]
                let symbols = substring.filter({$0 != "\n"})
                let newLines = substring.filter({$0 == "\n"})
                if symbols.isEmpty {
                    newLineIndexEnd = copy.index(after: idx)
                } else {
                    if newLines.utf8.count > 2 {
                        copy = String(copy[..<index] + "\n\n" + copy[idx..<copy.endIndex])
                        newLineIndexEnd = nil
                        index = copy.index(after: copy.startIndex)
                    } else {
                        index = copy.index(after: idx)
                        newLineIndexEnd = nil
                    }
                }
            } else {
                let first = String(copy[index..<copy.index(after: index)])
                
                if first == "\n" {
                    newLineIndexEnd = copy.index(after: index)
                } else {
                    index = copy.index(after: index)
                }
            }
            
        }
        return copy
    }
    
    var stringEmojiReplacements:String {
        var text:NSString = self.nsstring
        
        for(key, obj) in emojiReplacements {
            var nextRange = NSRange(location: 0, length: text.length)
            var emojiRange = text.range(of: key, options: [], range: nextRange)
            while emojiRange.location != NSNotFound {
                var length: Int = emojiRange.length
                var c_prev: String = "!"
                var c_next: String = "!"
                let r_p = NSRange(location: max(0, Int(emojiRange.location) - 1), length: emojiRange.location == 0 ? 0 : 1)
                let r_n = NSRange(location: max(0, emojiRange.length + emojiRange.location), length: min(1, text.length - (emojiRange.location + emojiRange.length)))
                c_prev = (text as NSString).substring(with: r_p)
                c_next = (text as NSString).substring(with: r_n)
                if c_prev.trimmed.length == 0 && c_next.trimmed.length == 0 {
                    text = text.replacingCharacters(in: emojiRange, with: obj).nsstring
                    length = obj.length
                }
                nextRange = NSRange(location: emojiRange.location + length, length: text.length - emojiRange.location - length)
                emojiRange = text.range(of: key, options: [], range: nextRange)
            }
        }
        return text as String
    }
}


private let emojiRevervedReplacements:[String:String] = {
    var dictionary:[String:String] = [:]
    for (key, value) in emojiReplacements {
        dictionary[value] = key
    }
    return dictionary
}()

private let emojiReplacements:[String:String] = {
    var dictionary:[String:String] = [:]
    dictionary[":grinning:"] = "😀"
    dictionary[":grin:"] = "😁"
    dictionary[":joy:"] = "😂"
    dictionary[":rofl:"] = "🤣"
    dictionary[":smiley:"] = "😃"
    dictionary[":smile:"] = "😄"
    dictionary[":sweat_smile:"] = "😅"
    dictionary[":laughing:"] = "😆"
    dictionary[":wink:"] = "😉"
    dictionary[":blush:"] = "😊"
    dictionary[":yum:"] = "😋"
    dictionary[":sunglasses:"] = "😎"
    dictionary[":heart_eyes:"] = "😍"
    dictionary[":kissing_heart:"] = "😘"
    dictionary[":kissing:"] = "😗"
    dictionary[":kissing_smiling_eyes:"] = "😙"
    dictionary[":kissing_closed_eyes:"] = "😚"
    dictionary[":relaxed:"] = "☺️"
    dictionary[":slight_smile:"] = "🙂"
    dictionary[":hugging:"] = "🤗"
    dictionary[":thinking:"] = "🤔"
    dictionary[":neutral_face:"] = "😐"
    dictionary[":expressionless:"] = "😑"
    dictionary[":no_mouth:"] = "😶"
    dictionary[":rolling_eyes:"] = "🙄"
    dictionary[":smirk:"] = "😏"
    dictionary[":persevere:"] = "😣"
    dictionary[":disappointed_relieved:"] = "😥"
    dictionary[":open_mouth:"] = "😮"
    dictionary[":zipper_mouth:"] = "🤐"
    dictionary[":hushed:"] = "😯"
    dictionary[":sleepy:"] = "😪"
    dictionary[":tired_face:"] = "😫"
    dictionary[":sleeping:"] = "😴"
    dictionary[":relieved:"] = "😌"
    dictionary[":nerd:"] = "🤓"
    dictionary[":stuck_out_tongue:"] = "😛"
    dictionary[":stuck_out_tongue_winking_eye:"] = "😜"
    dictionary[":stuck_out_tongue_closed_eyes:"] = "😝"
    dictionary[":drooling_face:"] = "🤤"
    dictionary[":unamused:"] = "😒"
    dictionary[":sweat:"] = "😓"
    dictionary[":pensive:"] = "😔"
    dictionary[":confused:"] = "😕"
    dictionary[":upside_down:"] = "🙃"
    dictionary[":money_mouth:"] = "🤑"
    dictionary[":astonished:"] = "😲"
    dictionary[":frowning2:"] = "☹️"
    dictionary[":slight_frown:"] = "🙁"
    dictionary[":confounded:"] = "😖"
    dictionary[":disappointed:"] = "😞"
    dictionary[":worried:"] = "😟"
    dictionary[":triumph:"] = "😤"
    dictionary[":cry:"] = "😢"
    dictionary[":sob:"] = "😭"
    dictionary[":frowning:"] = "😦"
    dictionary[":anguished:"] = "😧"
    dictionary[":fearful:"] = "😨"
    dictionary[":weary:"] = "😩"
    dictionary[":grimacing:"] = "😬"
    dictionary[":cold_sweat:"] = "😰"
    dictionary[":scream:"] = "😱"
    dictionary[":flushed:"] = "😳"
    dictionary[":dizzy_face:"] = "😵"
    dictionary[":rage:"] = "😡"
    dictionary[":angry:"] = "😠"
    dictionary[":innocent:"] = "😇"
    dictionary[":cowboy:"] = "🤠"
    dictionary[":clown:"] = "🤡"
    dictionary[":lying_face:"] = "🤥"
    dictionary[":mask:"] = "😷"
    dictionary[":thermometer_face:"] = "🤒"
    dictionary[":head_bandage:"] = "🤕"
    dictionary[":nauseated_face:"] = "🤢"
    dictionary[":sneezing_face:"] = "🤧"
    dictionary[":smiling_imp:"] = "😈"
    dictionary[":imp:"] = "👿"
    dictionary[":japanese_ogre:"] = "👹"
    dictionary[":japanese_goblin:"] = "👺"
    dictionary[":skull:"] = "💀"
    dictionary[":ghost:"] = "👻"
    dictionary[":alien:"] = "👽"
    dictionary[":robot:"] = "🤖"
    dictionary[":poop:"] = "💩"
    dictionary[":smiley_cat:"] = "😺"
    dictionary[":smile_cat:"] = "😸"
    dictionary[":joy_cat:"] = "😹"
    dictionary[":heart_eyes_cat:"] = "😻"
    dictionary[":smirk_cat:"] = "😼"
    dictionary[":kissing_cat:"] = "😽"
    dictionary[":scream_cat:"] = "🙀"
    dictionary[":crying_cat_face:"] = "😿"
    dictionary[":pouting_cat:"] = "😾"
    dictionary[":boy:"] = "👦"
    dictionary[":girl:"] = "👧"
    dictionary[":man:"] = "👨"
    dictionary[":woman:"] = "👩"
    dictionary[":older_man:"] = "👴"
    dictionary[":older_woman:"] = "👵"
    dictionary[":baby:"] = "👶"
    dictionary[":angel:"] = "👼"
    dictionary[":cop:"] = "👮"
    dictionary[":spy:"] = "🕵️"
    dictionary[":guardsman:"] = "💂"
    dictionary[":construction_worker:"] = "👷"
    dictionary[":man_with_turban:"] = "👳"
    dictionary[":person_with_blond_hair:"] = "👱"
    dictionary[":santa:"] = "🎅"
    dictionary[":mrs_claus:"] = "🤶"
    dictionary[":princess:"] = "👸"
    dictionary[":prince:"] = "🤴"
    dictionary[":bride_with_veil:"] = "👰"
    dictionary[":man_in_tuxedo:"] = "🤵"
    dictionary[":pregnant_woman:"] = "🤰"
    dictionary[":man_with_gua_pi_mao:"] = "👲"
    dictionary[":person_frowning:"] = "🙍"
    dictionary[":person_with_pouting_face:"] = "🙎"
    dictionary[":no_good:"] = "🙅"
    dictionary[":ok_woman:"] = "🙆"
    dictionary[":information_desk_person:"] = "💁"
    dictionary[":raising_hand:"] = "🙋"
    dictionary[":bow:"] = "🙇"
    dictionary[":face_palm:"] = "🤦"
    dictionary[":shrug:"] = "🤷"
    dictionary[":massage:"] = "💆"
    dictionary[":haircut:"] = "💇"
    dictionary[":walking:"] = "🚶"
    dictionary[":runner:"] = "🏃"
    dictionary[":dancer:"] = "💃"
    dictionary[":man_dancing:"] = "🕺"
    dictionary[":dancers:"] = "👯"
    dictionary[":speaking_head:"] = "🗣️"
    dictionary[":bust_in_silhouette:"] = "👤"
    dictionary[":busts_in_silhouette:"] = "👥"
    dictionary[":couple:"] = "👫"
    dictionary[":two_men_holding_hands:"] = "👬"
    dictionary[":two_women_holding_hands:"] = "👭"
    dictionary[":couplekiss:"] = "💏"
    dictionary[":kiss_mm:"] = "👨‍❤️‍💋‍👨"
    dictionary[":kiss_ww:"] = "👩‍❤️‍💋‍👩"
    dictionary[":couple_with_heart:"] = "💑"
    dictionary[":couple_mm:"] = "👨‍❤️‍👨"
    dictionary[":couple_ww:"] = "👩‍❤️‍👩"
    dictionary[":family:"] = "👪"
    dictionary[":family_mwg:"] = "👨‍👩‍👧"
    dictionary[":family_mwgb:"] = "👨‍👩‍👧‍👦"
    dictionary[":family_mwbb:"] = "👨‍👩‍👦‍👦"
    dictionary[":family_mwgg:"] = "👨‍👩‍👧‍👧"
    dictionary[":family_mmb:"] = "👨‍👨‍👦"
    dictionary[":family_mmg:"] = "👨‍👨‍👧"
    dictionary[":family_mmgb:"] = "👨‍👨‍👧‍👦"
    dictionary[":family_mmbb:"] = "👨‍👨‍👦‍👦"
    dictionary[":family_mmgg:"] = "👨‍👨‍👧‍👧"
    dictionary[":family_wwb:"] = "👩‍👩‍👦"
    dictionary[":family_wwg:"] = "👩‍👩‍👧"
    dictionary[":family_wwgb:"] = "👩‍👩‍👧‍👦"
    dictionary[":family_wwbb:"] = "👩‍👩‍👦‍👦"
    dictionary[":family_wwgg:"] = "👩‍👩‍👧‍👧"
    dictionary[":muscle:"] = "💪"
    dictionary[":selfie:"] = "🤳"
    dictionary[":point_left:"] = "👈"
    dictionary[":point_right:"] = "👉"
    dictionary[":point_up:"] = "☝️"
    dictionary[":point_up_2:"] = "👆"
    dictionary[":middle_finger:"] = "🖕"
    dictionary[":point_down:"] = "👇"
    dictionary[":v:"] = "✌️"
    dictionary[":fingers_crossed:"] = "🤞"
    dictionary[":vulcan:"] = "🖖"
    dictionary[":metal:"] = "🤘"
    dictionary[":call_me:"] = "🤙"
    dictionary[":hand_splayed:"] = "🖐️"
    dictionary[":raised_hand:"] = "✋"
    dictionary[":ok_hand:"] = "👌"
    dictionary[":thumbsup:"] = "👍"
    dictionary[":thumbsdown:"] = "👎"
    dictionary[":fist:"] = "✊"
    dictionary[":punch:"] = "👊"
    dictionary[":left_facing_fist:"] = "🤛"
    dictionary[":right_facing_fist:"] = "🤜"
    dictionary[":raised_back_of_hand:"] = "🤚"
    dictionary[":wave:"] = "👋"
    dictionary[":clap:"] = "👏"
    dictionary[":writing_hand:"] = "✍️"
    dictionary[":open_hands:"] = "👐"
    dictionary[":raised_hands:"] = "🙌"
    dictionary[":pray:"] = "🙏"
    dictionary[":handshake:"] = "🤝"
    dictionary[":nail_care:"] = "💅"
    dictionary[":ear:"] = "👂"
    dictionary[":nose:"] = "👃"
    dictionary[":footprints:"] = "👣"
    dictionary[":eyes:"] = "👀"
    dictionary[":eye:"] = "👁️"
    dictionary[":tongue:"] = "👅"
    dictionary[":lips:"] = "👄"
    dictionary[":kiss:"] = "💋"
    dictionary[":zzz:"] = "💤"
    dictionary[":eyeglasses:"] = "👓"
    dictionary[":dark_sunglasses:"] = "🕶️"
    dictionary[":necktie:"] = "👔"
    dictionary[":shirt:"] = "👕"
    dictionary[":jeans:"] = "👖"
    dictionary[":dress:"] = "👗"
    dictionary[":kimono:"] = "👘"
    dictionary[":bikini:"] = "👙"
    dictionary[":womans_clothes:"] = "👚"
    dictionary[":purse:"] = "👛"
    dictionary[":handbag:"] = "👜"
    dictionary[":pouch:"] = "👝"
    dictionary[":school_satchel:"] = "🎒"
    dictionary[":mans_shoe:"] = "👞"
    dictionary[":athletic_shoe:"] = "👟"
    dictionary[":high_heel:"] = "👠"
    dictionary[":sandal:"] = "👡"
    dictionary[":boot:"] = "👢"
    dictionary[":crown:"] = "👑"
    dictionary[":womans_hat:"] = "👒"
    dictionary[":tophat:"] = "🎩"
    dictionary[":mortar_board:"] = "🎓"
    dictionary[":helmet_with_cross:"] = "⛑️"
    dictionary[":lipstick:"] = "💄"
    dictionary[":ring:"] = "💍"
    dictionary[":closed_umbrella:"] = "🌂"
    dictionary[":briefcase:"] = "💼"
    // Nature
    dictionary[":see_no_evil:"] = "🙈"
    dictionary[":hear_no_evil:"] = "🙉"
    dictionary[":speak_no_evil:"] = "🙊"
    dictionary[":sweat_drops:"] = "💦"
    dictionary[":dash:"] = "💨"
    dictionary[":monkey_face:"] = "🐵"
    dictionary[":monkey:"] = "🐒"
    dictionary[":gorilla:"] = "🦍"
    dictionary[":dog:"] = "🐶"
    dictionary[":dog2:"] = "🐕"
    dictionary[":poodle:"] = "🐩"
    dictionary[":wolf:"] = "🐺"
    dictionary[":fox:"] = "🦊"
    dictionary[":cat:"] = "🐱"
    dictionary[":cat2:"] = "🐈"
    dictionary[":lion_face:"] = "🦁"
    dictionary[":tiger:"] = "🐯"
    dictionary[":tiger2:"] = "🐅"
    dictionary[":leopard:"] = "🐆"
    dictionary[":horse:"] = "🐴"
    dictionary[":racehorse:"] = "🐎"
    dictionary[":deer:"] = "🦌"
    dictionary[":unicorn:"] = "🦄"
    dictionary[":cow:"] = "🐮"
    dictionary[":ox:"] = "🐂"
    dictionary[":water_buffalo:"] = "🐃"
    dictionary[":cow2:"] = "🐄"
    dictionary[":pig:"] = "🐷"
    dictionary[":pig2:"] = "🐖"
    dictionary[":boar:"] = "🐗"
    dictionary[":pig_nose:"] = "🐽"
    dictionary[":ram:"] = "🐏"
    dictionary[":sheep:"] = "🐑"
    dictionary[":goat:"] = "🐐"
    dictionary[":dromedary_camel:"] = "🐪"
    dictionary[":camel:"] = "🐫"
    dictionary[":elephant:"] = "🐘"
    dictionary[":rhino:"] = "🦏"
    dictionary[":mouse:"] = "🐭"
    dictionary[":mouse2:"] = "🐁"
    dictionary[":rat:"] = "🐀"
    dictionary[":hamster:"] = "🐹"
    dictionary[":rabbit:"] = "🐰"
    dictionary[":rabbit2:"] = "🐇"
    dictionary[":chipmunk:"] = "🐿️"
    dictionary[":bat:"] = "🦇"
    dictionary[":bear:"] = "🐻"
    dictionary[":koala:"] = "🐨"
    dictionary[":panda_face:"] = "🐼"
    dictionary[":feet:"] = "🐾"
    dictionary[":turkey:"] = "🦃"
    dictionary[":chicken:"] = "🐔"
    dictionary[":rooster:"] = "🐓"
    dictionary[":hatching_chick:"] = "🐣"
    dictionary[":baby_chick:"] = "🐤"
    dictionary[":hatched_chick:"] = "🐥"
    dictionary[":bird:"] = "🐦"
    dictionary[":penguin:"] = "🐧"
    dictionary[":dove:"] = "🕊️"
    dictionary[":eagle:"] = "🦅"
    dictionary[":duck:"] = "🦆"
    dictionary[":owl:"] = "🦉"
    dictionary[":frog:"] = "🐸"
    dictionary[":crocodile:"] = "🐊"
    dictionary[":turtle:"] = "🐢"
    dictionary[":lizard:"] = "🦎"
    dictionary[":snake:"] = "🐍"
    dictionary[":dragon_face:"] = "🐲"
    dictionary[":dragon:"] = "🐉"
    dictionary[":whale:"] = "🐳"
    dictionary[":whale2:"] = "🐋"
    dictionary[":dolphin:"] = "🐬"
    dictionary[":fish:"] = "🐟"
    dictionary[":tropical_fish:"] = "🐠"
    dictionary[":blowfish:"] = "🐡"
    dictionary[":shark:"] = "🦈"
    dictionary[":octopus:"] = "🐙"
    dictionary[":shell:"] = "🐚"
    dictionary[":crab:"] = "🦀"
    dictionary[":shrimp:"] = "🦐"
    dictionary[":squid:"] = "🦑"
    dictionary[":butterfly:"] = "🦋"
    dictionary[":snail:"] = "🐌"
    dictionary[":bug:"] = "🐛"
    dictionary[":ant:"] = "🐜"
    dictionary[":bee:"] = "🐝"
    dictionary[":beetle:"] = "🐞"
    dictionary[":spider:"] = "🕷️"
    dictionary[":spider_web:"] = "🕸️"
    dictionary[":scorpion:"] = "🦂"
    dictionary[":bouquet:"] = "💐"
    dictionary[":cherry_blossom:"] = "🌸"
    dictionary[":rosette:"] = "🏵️"
    dictionary[":rose:"] = "🌹"
    dictionary[":wilted_rose:"] = "🥀"
    dictionary[":hibiscus:"] = "🌺"
    dictionary[":sunflower:"] = "🌻"
    dictionary[":blossom:"] = "🌼"
    dictionary[":tulip:"] = "🌷"
    dictionary[":seedling:"] = "🌱"
    dictionary[":evergreen_tree:"] = "🌲"
    dictionary[":deciduous_tree:"] = "🌳"
    dictionary[":palm_tree:"] = "🌴"
    dictionary[":cactus:"] = "🌵"
    dictionary[":ear_of_rice:"] = "🌾"
    dictionary[":herb:"] = "🌿"
    dictionary[":shamrock:"] = "☘️"
    dictionary[":four_leaf_clover:"] = "🍀"
    dictionary[":maple_leaf:"] = "🍁"
    dictionary[":fallen_leaf:"] = "🍂"
    dictionary[":leaves:"] = "🍃"
    dictionary[":mushroom:"] = "🍄"
    dictionary[":chestnut:"] = "🌰"
    dictionary[":earth_africa:"] = "🌍"
    dictionary[":earth_americas:"] = "🌎"
    dictionary[":earth_asia:"] = "🌏"
    dictionary[":new_moon:"] = "🌑"
    dictionary[":waxing_crescent_moon:"] = "🌒"
    dictionary[":first_quarter_moon:"] = "🌓"
    dictionary[":waxing_gibbous_moon:"] = "🌔"
    dictionary[":full_moon:"] = "🌕"
    dictionary[":waning_gibbous_moon:"] = "🌖"
    dictionary[":last_quarter_moon:"] = "🌗"
    dictionary[":waning_crescent_moon:"] = "🌘"
    dictionary[":crescent_moon:"] = "🌙"
    dictionary[":new_moon_with_face:"] = "🌚"
    dictionary[":first_quarter_moon_with_face:"] = "🌛"
    dictionary[":last_quarter_moon_with_face:"] = "🌜"
    dictionary[":sunny:"] = "☀️"
    dictionary[":full_moon_with_face:"] = "🌝"
    dictionary[":sun_with_face:"] = "🌞"
    dictionary[":star:"] = "⭐️"
    dictionary[":star2:"] = "🌟"
    dictionary[":cloud:"] = "☁️"
    dictionary[":partly_sunny:"] = "⛅️"
    dictionary[":thunder_cloud_rain:"] = "⛈️"
    dictionary[":white_sun_small_cloud:"] = "🌤️"
    dictionary[":white_sun_cloud:"] = "🌥️"
    dictionary[":white_sun_rain_cloud:"] = "🌦️"
    dictionary[":cloud_rain:"] = "🌧️"
    dictionary[":cloud_snow:"] = "🌨️"
    dictionary[":cloud_lightning:"] = "🌩️"
    dictionary[":cloud_tornado:"] = "🌪️"
    dictionary[":fog:"] = "🌫️"
    dictionary[":wind_blowing_face:"] = "🌬️"
    dictionary[":umbrella2:"] = "☂️"
    dictionary[":umbrella:"] = "☔️"
    dictionary[":zap:"] = "⚡️"
    dictionary[":snowflake:"] = "❄️"
    dictionary[":snowman2:"] = "☃️"
    dictionary[":snowman:"] = "⛄️"
    dictionary[":comet:"] = "☄️"
    dictionary[":fire:"] = "🔥"
    dictionary[":droplet:"] = "💧"
    dictionary[":ocean:"] = "🌊"
    dictionary[":jack_o_lantern:"] = "🎃"
    dictionary[":christmas_tree:"] = "🎄"
    dictionary[":sparkles:"] = "✨"
    dictionary[":tanabata_tree:"] = "🎋"
    dictionary[":bamboo:"] = "🎍"
    // Food
    dictionary[":grapes:"] = "🍇"
    dictionary[":melon:"] = "🍈"
    dictionary[":watermelon:"] = "🍉"
    dictionary[":tangerine:"] = "🍊"
    dictionary[":lemon:"] = "🍋"
    dictionary[":banana:"] = "🍌"
    dictionary[":pineapple:"] = "🍍"
    dictionary[":apple:"] = "🍎"
    dictionary[":green_apple:"] = "🍏"
    dictionary[":pear:"] = "🍐"
    dictionary[":peach:"] = "🍑"
    dictionary[":cherries:"] = "🍒"
    dictionary[":strawberry:"] = "🍓"
    dictionary[":kiwi:"] = "🥝"
    dictionary[":tomato:"] = "🍅"
    dictionary[":avocado:"] = "🥑"
    dictionary[":eggplant:"] = "🍆"
    dictionary[":potato:"] = "🥔"
    dictionary[":carrot:"] = "🥕"
    dictionary[":corn:"] = "🌽"
    dictionary[":hot_pepper:"] = "🌶️"
    dictionary[":cucumber:"] = "🥒"
    dictionary[":peanuts:"] = "🥜"
    dictionary[":bread:"] = "🍞"
    dictionary[":croissant:"] = "🥐"
    dictionary[":french_bread:"] = "🥖"
    dictionary[":pancakes:"] = "🥞"
    dictionary[":cheese:"] = "🧀"
    dictionary[":meat_on_bone:"] = "🍖"
    dictionary[":poultry_leg:"] = "🍗"
    dictionary[":bacon:"] = "🥓"
    dictionary[":hamburger:"] = "🍔"
    dictionary[":fries:"] = "🍟"
    dictionary[":pizza:"] = "🍕"
    dictionary[":hotdog:"] = "🌭"
    dictionary[":taco:"] = "🌮"
    dictionary[":burrito:"] = "🌯"
    dictionary[":stuffed_flatbread:"] = "🥙"
    dictionary[":egg:"] = "🥚"
    dictionary[":cooking:"] = "🍳"
    dictionary[":shallow_pan_of_food:"] = "🥘"
    dictionary[":stew:"] = "🍲"
    dictionary[":salad:"] = "🥗"
    dictionary[":popcorn:"] = "🍿"
    dictionary[":bento:"] = "🍱"
    dictionary[":rice_cracker:"] = "🍘"
    dictionary[":rice_ball:"] = "🍙"
    dictionary[":rice:"] = "🍚"
    dictionary[":curry:"] = "🍛"
    dictionary[":ramen:"] = "🍜"
    dictionary[":spaghetti:"] = "🍝"
    dictionary[":sweet_potato:"] = "🍠"
    dictionary[":oden:"] = "🍢"
    dictionary[":sushi:"] = "🍣"
    dictionary[":fried_shrimp:"] = "🍤"
    dictionary[":fish_cake:"] = "🍥"
    dictionary[":dango:"] = "🍡"
    dictionary[":icecream:"] = "🍦"
    dictionary[":shaved_ice:"] = "🍧"
    dictionary[":ice_cream:"] = "🍨"
    dictionary[":doughnut:"] = "🍩"
    dictionary[":cookie:"] = "🍪"
    dictionary[":birthday:"] = "🎂"
    dictionary[":cake:"] = "🍰"
    dictionary[":chocolate_bar:"] = "🍫"
    dictionary[":candy:"] = "🍬"
    dictionary[":lollipop:"] = "🍭"
    dictionary[":custard:"] = "🍮"
    dictionary[":honey_pot:"] = "🍯"
    dictionary[":baby_bottle:"] = "🍼"
    dictionary[":milk:"] = "🥛"
    dictionary[":coffee:"] = "☕️"
    dictionary[":tea:"] = "🍵"
    dictionary[":sake:"] = "🍶"
    dictionary[":champagne:"] = "🍾"
    dictionary[":wine_glass:"] = "🍷"
    dictionary[":cocktail:"] = "🍸"
    dictionary[":tropical_drink:"] = "🍹"
    dictionary[":beer:"] = "🍺"
    dictionary[":beers:"] = "🍻"
    dictionary[":champagne_glass:"] = "🥂"
    dictionary[":tumbler_glass:"] = "🥃"
    dictionary[":fork_knife_plate:"] = "🍽️"
    dictionary[":fork_and_knife:"] = "🍴"
    dictionary[":spoon:"] = "🥄"
    // Activity
    dictionary[":space_invader:"] = "👾"
    dictionary[":levitate:"] = "🕴️"
    dictionary[":fencer:"] = "🤺"
    dictionary[":horse_racing:"] = "🏇"
    dictionary[":skier:"] = "⛷️"
    dictionary[":snowboarder:"] = "🏂"
    dictionary[":golfer:"] = "🏌️"
    dictionary[":surfer:"] = "🏄"
    dictionary[":rowboat:"] = "🚣"
    dictionary[":swimmer:"] = "🏊"
    dictionary[":basketball_player:"] = "⛹️"
    dictionary[":lifter:"] = "🏋️"
    dictionary[":bicyclist:"] = "🚴"
    dictionary[":mountain_bicyclist:"] = "🚵"
    dictionary[":cartwheel:"] = "🤸"
    dictionary[":wrestlers:"] = "🤼"
    dictionary[":water_polo:"] = "🤽"
    dictionary[":handball:"] = "🤾"
    dictionary[":juggling:"] = "🤹"
    dictionary[":circus_tent:"] = "🎪"
    dictionary[":performing_arts:"] = "🎭"
    dictionary[":art:"] = "🎨"
    dictionary[":slot_machine:"] = "🎰"
    dictionary[":bath:"] = "🛀"
    dictionary[":reminder_ribbon:"] = "🎗️"
    dictionary[":tickets:"] = "🎟️"
    dictionary[":ticket:"] = "🎫"
    dictionary[":military_medal:"] = "🎖️"
    dictionary[":trophy:"] = "🏆"
    dictionary[":medal:"] = "🏅"
    dictionary[":first_place:"] = "🥇"
    dictionary[":second_place:"] = "🥈"
    dictionary[":third_place:"] = "🥉"
    dictionary[":soccer:"] = "⚽️"
    dictionary[":baseball:"] = "⚾️"
    dictionary[":basketball:"] = "🏀"
    dictionary[":volleyball:"] = "🏐"
    dictionary[":football:"] = "🏈"
    dictionary[":rugby_football:"] = "🏉"
    dictionary[":tennis:"] = "🎾"
    dictionary[":8ball:"] = "🎱"
    dictionary[":bowling:"] = "🎳"
    dictionary[":cricket:"] = "🏏"
    dictionary[":field_hockey:"] = "🏑"
    dictionary[":hockey:"] = "🏒"
    dictionary[":ping_pong:"] = "🏓"
    dictionary[":badminton:"] = "🏸"
    dictionary[":boxing_glove:"] = "🥊"
    dictionary[":martial_arts_uniform:"] = "🥋"
    dictionary[":goal:"] = "🥅"
    dictionary[":dart:"] = "🎯"
    dictionary[":golf:"] = "⛳️"
    dictionary[":ice_skate:"] = "⛸️"
    dictionary[":fishing_pole_and_fish:"] = "🎣"
    dictionary[":running_shirt_with_sash:"] = "🎽"
    dictionary[":ski:"] = "🎿"
    dictionary[":video_game:"] = "🎮"
    dictionary[":game_die:"] = "🎲"
    dictionary[":musical_score:"] = "🎼"
    dictionary[":microphone:"] = "🎤"
    dictionary[":headphones:"] = "🎧"
    dictionary[":saxophone:"] = "🎷"
    dictionary[":guitar:"] = "🎸"
    dictionary[":musical_keyboard:"] = "🎹"
    dictionary[":trumpet:"] = "🎺"
    dictionary[":violin:"] = "🎻"
    dictionary[":drum:"] = "🥁"
    dictionary[":clapper:"] = "🎬"
    dictionary[":bow_and_arrow:"] = "🏹"
    // Travel
    dictionary[":race_car:"] = "🏎️"
    dictionary[":motorcycle:"] = "🏍️"
    dictionary[":japan:"] = "🗾"
    dictionary[":mountain_snow:"] = "🏔️"
    dictionary[":mountain:"] = "⛰️"
    dictionary[":volcano:"] = "🌋"
    dictionary[":mount_fuji:"] = "🗻"
    dictionary[":camping:"] = "🏕️"
    dictionary[":beach:"] = "🏖️"
    dictionary[":desert:"] = "🏜️"
    dictionary[":island:"] = "🏝️"
    dictionary[":park:"] = "🏞️"
    dictionary[":stadium:"] = "🏟️"
    dictionary[":classical_building:"] = "🏛️"
    dictionary[":construction_site:"] = "🏗️"
    dictionary[":homes:"] = "🏘️"
    dictionary[":cityscape:"] = "🏙️"
    dictionary[":house_abandoned:"] = "🏚️"
    dictionary[":house:"] = "🏠"
    dictionary[":house_with_garden:"] = "🏡"
    dictionary[":office:"] = "🏢"
    dictionary[":post_office:"] = "🏣"
    dictionary[":european_post_office:"] = "🏤"
    dictionary[":hospital:"] = "🏥"
    dictionary[":bank:"] = "🏦"
    dictionary[":hotel:"] = "🏨"
    dictionary[":love_hotel:"] = "🏩"
    dictionary[":convenience_store:"] = "🏪"
    dictionary[":school:"] = "🏫"
    dictionary[":department_store:"] = "🏬"
    dictionary[":factory:"] = "🏭"
    dictionary[":japanese_castle:"] = "🏯"
    dictionary[":european_castle:"] = "🏰"
    dictionary[":wedding:"] = "💒"
    dictionary[":tokyo_tower:"] = "🗼"
    dictionary[":statue_of_liberty:"] = "🗽"
    dictionary[":church:"] = "⛪️"
    dictionary[":mosque:"] = "🕌"
    dictionary[":synagogue:"] = "🕍"
    dictionary[":shinto_shrine:"] = "⛩️"
    dictionary[":kaaba:"] = "🕋"
    dictionary[":fountain:"] = "⛲️"
    dictionary[":tent:"] = "⛺️"
    dictionary[":foggy:"] = "🌁"
    dictionary[":night_with_stars:"] = "🌃"
    dictionary[":sunrise_over_mountains:"] = "🌄"
    dictionary[":sunrise:"] = "🌅"
    dictionary[":city_dusk:"] = "🌆"
    dictionary[":city_sunset:"] = "🌇"
    dictionary[":bridge_at_night:"] = "🌉"
    dictionary[":milky_way:"] = "🌌"
    dictionary[":carousel_horse:"] = "🎠"
    dictionary[":ferris_wheel:"] = "🎡"
    dictionary[":roller_coaster:"] = "🎢"
    dictionary[":steam_locomotive:"] = "🚂"
    dictionary[":railway_car:"] = "🚃"
    dictionary[":bullettrain_side:"] = "🚄"
    dictionary[":bullettrain_front:"] = "🚅"
    dictionary[":train2:"] = "🚆"
    dictionary[":metro:"] = "🚇"
    dictionary[":light_rail:"] = "🚈"
    dictionary[":station:"] = "🚉"
    dictionary[":tram:"] = "🚊"
    dictionary[":monorail:"] = "🚝"
    dictionary[":mountain_railway:"] = "🚞"
    dictionary[":train:"] = "🚋"
    dictionary[":bus:"] = "🚌"
    dictionary[":oncoming_bus:"] = "🚍"
    dictionary[":trolleybus:"] = "🚎"
    dictionary[":minibus:"] = "🚐"
    dictionary[":ambulance:"] = "🚑"
    dictionary[":fire_engine:"] = "🚒"
    dictionary[":police_car:"] = "🚓"
    dictionary[":oncoming_police_car:"] = "🚔"
    dictionary[":taxi:"] = "🚕"
    dictionary[":oncoming_taxi:"] = "🚖"
    dictionary[":red_car:"] = "🚗"
    dictionary[":oncoming_automobile:"] = "🚘"
    dictionary[":blue_car:"] = "🚙"
    dictionary[":truck:"] = "🚚"
    dictionary[":articulated_lorry:"] = "🚛"
    dictionary[":tractor:"] = "🚜"
    dictionary[":bike:"] = "🚲"
    dictionary[":scooter:"] = "🛴"
    dictionary[":motor_scooter:"] = "🛵"
    dictionary[":busstop:"] = "🚏"
    dictionary[":motorway:"] = "🛣️"
    dictionary[":railway_track:"] = "🛤️"
    dictionary[":fuelpump:"] = "⛽️"
    dictionary[":rotating_light:"] = "🚨"
    dictionary[":traffic_light:"] = "🚥"
    dictionary[":vertical_traffic_light:"] = "🚦"
    dictionary[":construction:"] = "🚧"
    dictionary[":anchor:"] = "⚓️"
    dictionary[":sailboat:"] = "⛵️"
    dictionary[":canoe:"] = "🛶"
    dictionary[":speedboat:"] = "🚤"
    dictionary[":cruise_ship:"] = "🛳️"
    dictionary[":ferry:"] = "⛴️"
    dictionary[":motorboat:"] = "🛥️"
    dictionary[":ship:"] = "🚢"
    dictionary[":airplane:"] = "✈️"
    dictionary[":airplane_small:"] = "🛩️"
    dictionary[":airplane_departure:"] = "🛫"
    dictionary[":airplane_arriving:"] = "🛬"
    dictionary[":seat:"] = "💺"
    dictionary[":helicopter:"] = "🚁"
    dictionary[":suspension_railway:"] = "🚟"
    dictionary[":mountain_cableway:"] = "🚠"
    dictionary[":aerial_tramway:"] = "🚡"
    dictionary[":rocket:"] = "🚀"
    dictionary[":satellite_orbital:"] = "🛰️"
    dictionary[":stars:"] = "🌠"
    dictionary[":rainbow:"] = "🌈"
    dictionary[":fireworks:"] = "🎆"
    dictionary[":sparkler:"] = "🎇"
    dictionary[":rice_scene:"] = "🎑"
    dictionary[":checkered_flag:"] = "🏁"
    // Objects
    dictionary[":skull_crossbones:"] = "☠️"
    dictionary[":love_letter:"] = "💌"
    dictionary[":bomb:"] = "💣"
    dictionary[":hole:"] = "🕳️"
    dictionary[":shopping_bags:"] = "🛍️"
    dictionary[":prayer_beads:"] = "📿"
    dictionary[":gem:"] = "💎"
    dictionary[":knife:"] = "🔪"
    dictionary[":amphora:"] = "🏺"
    dictionary[":map:"] = "🗺️"
    dictionary[":barber:"] = "💈"
    dictionary[":frame_photo:"] = "🖼️"
    dictionary[":bellhop:"] = "🛎️"
    dictionary[":door:"] = "🚪"
    dictionary[":sleeping_accommodation:"] = "🛌"
    dictionary[":bed:"] = "🛏️"
    dictionary[":couch:"] = "🛋️"
    dictionary[":toilet:"] = "🚽"
    dictionary[":shower:"] = "🚿"
    dictionary[":bathtub:"] = "🛁"
    dictionary[":hourglass:"] = "⌛️"
    dictionary[":hourglass_flowing_sand:"] = "⏳"
    dictionary[":watch:"] = "⌚️"
    dictionary[":alarm_clock:"] = "⏰"
    dictionary[":stopwatch:"] = "⏱️"
    dictionary[":timer:"] = "⏲️"
    dictionary[":clock:"] = "🕰️"
    dictionary[":thermometer:"] = "🌡️"
    dictionary[":beach_umbrella:"] = "⛱️"
    dictionary[":balloon:"] = "🎈"
    dictionary[":tada:"] = "🎉"
    dictionary[":confetti_ball:"] = "🎊"
    dictionary[":dolls:"] = "🎎"
    dictionary[":flags:"] = "🎏"
    dictionary[":wind_chime:"] = "🎐"
    dictionary[":ribbon:"] = "🎀"
    dictionary[":gift:"] = "🎁"
    dictionary[":joystick:"] = "🕹️"
    dictionary[":postal_horn:"] = "📯"
    dictionary[":microphone2:"] = "🎙️"
    dictionary[":level_slider:"] = "🎚️"
    dictionary[":control_knobs:"] = "🎛️"
    dictionary[":radio:"] = "📻"
    dictionary[":iphone:"] = "📱"
    dictionary[":calling:"] = "📲"
    dictionary[":telephone:"] = "☎️"
    dictionary[":telephone_receiver:"] = "📞"
    dictionary[":pager:"] = "📟"
    dictionary[":fax:"] = "📠"
    dictionary[":battery:"] = "🔋"
    dictionary[":electric_plug:"] = "🔌"
    dictionary[":computer:"] = "💻"
    dictionary[":desktop:"] = "🖥️"
    dictionary[":printer:"] = "🖨️"
    dictionary[":keyboard:"] = "⌨️"
    dictionary[":mouse_three_button:"] = "🖱️"
    dictionary[":trackball:"] = "🖲️"
    dictionary[":minidisc:"] = "💽"
    dictionary[":floppy_disk:"] = "💾"
    dictionary[":cd:"] = "💿"
    dictionary[":dvd:"] = "📀"
    dictionary[":movie_camera:"] = "🎥"
    dictionary[":film_frames:"] = "🎞️"
    dictionary[":projector:"] = "📽️"
    dictionary[":tv:"] = "📺"
    dictionary[":camera:"] = "📷"
    dictionary[":camera_with_flash:"] = "📸"
    dictionary[":video_camera:"] = "📹"
    dictionary[":vhs:"] = "📼"
    dictionary[":mag:"] = "🔍"
    dictionary[":mag_right:"] = "🔎"
    dictionary[":microscope:"] = "🔬"
    dictionary[":telescope:"] = "🔭"
    dictionary[":satellite:"] = "📡"
    dictionary[":candle:"] = "🕯️"
    dictionary[":bulb:"] = "💡"
    dictionary[":flashlight:"] = "🔦"
    dictionary[":izakaya_lantern:"] = "🏮"
    dictionary[":notebook_with_decorative_cover:"] = "📔"
    dictionary[":closed_book:"] = "📕"
    dictionary[":book:"] = "📖"
    dictionary[":green_book:"] = "📗"
    dictionary[":blue_book:"] = "📘"
    dictionary[":orange_book:"] = "📙"
    dictionary[":books:"] = "📚"
    dictionary[":notebook:"] = "📓"
    dictionary[":ledger:"] = "📒"
    dictionary[":page_with_curl:"] = "📃"
    dictionary[":scroll:"] = "📜"
    dictionary[":page_facing_up:"] = "📄"
    dictionary[":newspaper:"] = "📰"
    dictionary[":newspaper2:"] = "🗞️"
    dictionary[":bookmark_tabs:"] = "📑"
    dictionary[":bookmark:"] = "🔖"
    dictionary[":label:"] = "🏷️"
    dictionary[":moneybag:"] = "💰"
    dictionary[":yen:"] = "💴"
    dictionary[":dollar:"] = "💵"
    dictionary[":euro:"] = "💶"
    dictionary[":pound:"] = "💷"
    dictionary[":money_with_wings:"] = "💸"
    dictionary[":credit_card:"] = "💳"
    dictionary[":envelope:"] = "✉️"
    dictionary[":e-mail:"] = "📧"
    dictionary[":incoming_envelope:"] = "📨"
    dictionary[":envelope_with_arrow:"] = "📩"
    dictionary[":outbox_tray:"] = "📤"
    dictionary[":inbox_tray:"] = "📥"
    dictionary[":package:"] = "📦"
    dictionary[":mailbox:"] = "📫"
    dictionary[":mailbox_closed:"] = "📪"
    dictionary[":mailbox_with_mail:"] = "📬"
    dictionary[":mailbox_with_no_mail:"] = "📭"
    dictionary[":postbox:"] = "📮"
    dictionary[":ballot_box:"] = "🗳️"
    dictionary[":pencil2:"] = "✏️"
    dictionary[":black_nib:"] = "✒️"
    dictionary[":pen_fountain:"] = "🖋️"
    dictionary[":pen_ballpoint:"] = "🖊️"
    dictionary[":paintbrush:"] = "🖌️"
    dictionary[":crayon:"] = "🖍️"
    dictionary[":pencil:"] = "📝"
    dictionary[":file_folder:"] = "📁"
    dictionary[":open_file_folder:"] = "📂"
    dictionary[":dividers:"] = "🗂️"
    dictionary[":date:"] = "📅"
    dictionary[":calendar:"] = "📆"
    dictionary[":notepad_spiral:"] = "🗒️"
    dictionary[":calendar_spiral:"] = "🗓️"
    dictionary[":card_index:"] = "📇"
    dictionary[":chart_with_upwards_trend:"] = "📈"
    dictionary[":chart_with_downwards_trend:"] = "📉"
    dictionary[":bar_chart:"] = "📊"
    dictionary[":clipboard:"] = "📋"
    dictionary[":pushpin:"] = "📌"
    dictionary[":round_pushpin:"] = "📍"
    dictionary[":paperclip:"] = "📎"
    dictionary[":paperclips:"] = "🖇️"
    dictionary[":straight_ruler:"] = "📏"
    dictionary[":triangular_ruler:"] = "📐"
    dictionary[":scissors:"] = "✂️"
    dictionary[":card_box:"] = "🗃️"
    dictionary[":file_cabinet:"] = "🗄️"
    dictionary[":wastebasket:"] = "🗑️"
    dictionary[":lock:"] = "🔒"
    dictionary[":unlock:"] = "🔓"
    dictionary[":lock_with_ink_pen:"] = "🔏"
    dictionary[":closed_lock_with_key:"] = "🔐"
    dictionary[":key:"] = "🔑"
    dictionary[":key2:"] = "🗝️"
    dictionary[":hammer:"] = "🔨"
    dictionary[":pick:"] = "⛏️"
    dictionary[":hammer_pick:"] = "⚒️"
    dictionary[":tools:"] = "🛠️"
    dictionary[":dagger:"] = "🗡️"
    dictionary[":crossed_swords:"] = "⚔️"
    dictionary[":gun:"] = "🔫"
    dictionary[":shield:"] = "🛡️"
    dictionary[":wrench:"] = "🔧"
    dictionary[":nut_and_bolt:"] = "🔩"
    dictionary[":gear:"] = "⚙️"
    dictionary[":compression:"] = "🗜️"
    dictionary[":alembic:"] = "⚗️"
    dictionary[":scales:"] = "⚖️"
    dictionary[":link:"] = "🔗"
    dictionary[":chains:"] = "⛓️"
    dictionary[":syringe:"] = "💉"
    dictionary[":pill:"] = "💊"
    dictionary[":smoking:"] = "🚬"
    dictionary[":coffin:"] = "⚰️"
    dictionary[":urn:"] = "⚱️"
    dictionary[":moyai:"] = "🗿"
    dictionary[":oil:"] = "🛢️"
    dictionary[":crystal_ball:"] = "🔮"
    dictionary[":shopping_cart:"] = "🛒"
    dictionary[":triangular_flag_on_post:"] = "🚩"
    dictionary[":crossed_flags:"] = "🎌"
    dictionary[":flag_black:"] = "🏴"
    dictionary[":flag_white:"] = "🏳️"
    dictionary[":rainbow_flag:"] = "🏳🌈"
    // Symbols
    dictionary[":eye_in_speech_bubble:"] = "👁‍🗨"
    dictionary[":cupid:"] = "💘"
    dictionary[":heart:"] = "❤️"
    dictionary[":heartbeat:"] = "💓"
    dictionary[":broken_heart:"] = "💔"
    dictionary[":two_hearts:"] = "💕"
    dictionary[":sparkling_heart:"] = "💖"
    dictionary[":heartpulse:"] = "💗"
    dictionary[":blue_heart:"] = "💙"
    dictionary[":green_heart:"] = "💚"
    dictionary[":yellow_heart:"] = "💛"
    dictionary[":purple_heart:"] = "💜"
    dictionary[":black_heart:"] = "🖤"
    dictionary[":gift_heart:"] = "💝"
    dictionary[":revolving_hearts:"] = "💞"
    dictionary[":heart_decoration:"] = "💟"
    dictionary[":heart_exclamation:"] = "❣️"
    dictionary[":anger:"] = "💢"
    dictionary[":boom:"] = "💥"
    dictionary[":dizzy:"] = "💫"
    dictionary[":speech_balloon:"] = "💬"
    dictionary[":speech_left:"] = "🗨️"
    dictionary[":anger_right:"] = "🗯️"
    dictionary[":thought_balloon:"] = "💭"
    dictionary[":white_flower:"] = "💮"
    dictionary[":globe_with_meridians:"] = "🌐"
    dictionary[":hotsprings:"] = "♨️"
    dictionary[":octagonal_sign:"] = "🛑"
    dictionary[":clock12:"] = "🕛"
    dictionary[":clock1230:"] = "🕧"
    dictionary[":clock1:"] = "🕐"
    dictionary[":clock130:"] = "🕜"
    dictionary[":clock2:"] = "🕑"
    dictionary[":clock230:"] = "🕝"
    dictionary[":clock3:"] = "🕒"
    dictionary[":clock330:"] = "🕞"
    dictionary[":clock4:"] = "🕓"
    dictionary[":clock430:"] = "🕟"
    dictionary[":clock5:"] = "🕔"
    dictionary[":clock530:"] = "🕠"
    dictionary[":clock6:"] = "🕕"
    dictionary[":clock630:"] = "🕡"
    dictionary[":clock7:"] = "🕖"
    dictionary[":clock730:"] = "🕢"
    dictionary[":clock8:"] = "🕗"
    dictionary[":clock830:"] = "🕣"
    dictionary[":clock9:"] = "🕘"
    dictionary[":clock930:"] = "🕤"
    dictionary[":clock10:"] = "🕙"
    dictionary[":clock1030:"] = "🕥"
    dictionary[":clock11:"] = "🕚"
    dictionary[":clock1130:"] = "🕦"
    dictionary[":cyclone:"] = "🌀"
    dictionary[":spades:"] = "♠️"
    dictionary[":hearts:"] = "♥️"
    dictionary[":diamonds:"] = "♦️"
    dictionary[":clubs:"] = "♣️"
    dictionary[":black_joker:"] = "🃏"
    dictionary[":mahjong:"] = "🀄️"
    dictionary[":flower_playing_cards:"] = "🎴"
    dictionary[":mute:"] = "🔇"
    dictionary[":speaker:"] = "🔈"
    dictionary[":sound:"] = "🔉"
    dictionary[":loud_sound:"] = "🔊"
    dictionary[":loudspeaker:"] = "📢"
    dictionary[":mega:"] = "📣"
    dictionary[":bell:"] = "🔔"
    dictionary[":no_bell:"] = "🔕"
    dictionary[":musical_note:"] = "🎵"
    dictionary[":notes:"] = "🎶"
    dictionary[":chart:"] = "💹"
    dictionary[":currency_exchange:"] = "💱"
    dictionary[":heavy_dollar_sign:"] = "💲"
    dictionary[":atm:"] = "🏧"
    dictionary[":put_litter_in_its_place:"] = "🚮"
    dictionary[":potable_water:"] = "🚰"
    dictionary[":wheelchair:"] = "♿️"
    dictionary[":mens:"] = "🚹"
    dictionary[":womens:"] = "🚺"
    dictionary[":restroom:"] = "🚻"
    dictionary[":baby_symbol:"] = "🚼"
    dictionary[":wc:"] = "🚾"
    dictionary[":passport_control:"] = "🛂"
    dictionary[":customs:"] = "🛃"
    dictionary[":baggage_claim:"] = "🛄"
    dictionary[":left_luggage:"] = "🛅"
    dictionary[":warning:"] = "⚠️"
    dictionary[":children_crossing:"] = "🚸"
    dictionary[":no_entry:"] = "⛔️"
    dictionary[":no_entry_sign:"] = "🚫"
    dictionary[":no_bicycles:"] = "🚳"
    dictionary[":no_smoking:"] = "🚭"
    dictionary[":do_not_litter:"] = "🚯"
    dictionary[":non-potable_water:"] = "🚱"
    dictionary[":no_pedestrians:"] = "🚷"
    dictionary[":no_mobile_phones:"] = "📵"
    dictionary[":underage:"] = "🔞"
    dictionary[":radioactive:"] = "☢️"
    dictionary[":biohazard:"] = "☣️"
    dictionary[":arrow_up:"] = "⬆️"
    dictionary[":arrow_upper_right:"] = "↗️"
    dictionary[":arrow_right:"] = "➡️"
    dictionary[":arrow_lower_right:"] = "↘️"
    dictionary[":arrow_down:"] = "⬇️"
    dictionary[":arrow_lower_left:"] = "↙️"
    dictionary[":arrow_left:"] = "⬅️"
    dictionary[":arrow_upper_left:"] = "↖️"
    dictionary[":arrow_up_down:"] = "↕️"
    dictionary[":left_right_arrow:"] = "↔️"
    dictionary[":leftwards_arrow_with_hook:"] = "↩️"
    dictionary[":arrow_right_hook:"] = "↪️"
    dictionary[":arrow_heading_up:"] = "⤴️"
    dictionary[":arrow_heading_down:"] = "⤵️"
    dictionary[":arrows_clockwise:"] = "🔃"
    dictionary[":arrows_counterclockwise:"] = "🔄"
    dictionary[":back:"] = "🔙"
    dictionary[":end:"] = "🔚"
    dictionary[":on:"] = "🔛"
    dictionary[":soon:"] = "🔜"
    dictionary[":top:"] = "🔝"
    dictionary[":place_of_worship:"] = "🛐"
    dictionary[":atom:"] = "⚛️"
    dictionary[":om_symbol:"] = "🕉️"
    dictionary[":star_of_david:"] = "✡️"
    dictionary[":wheel_of_dharma:"] = "☸️"
    dictionary[":yin_yang:"] = "☯️"
    dictionary[":cross:"] = "✝️"
    dictionary[":orthodox_cross:"] = "☦️"
    dictionary[":star_and_crescent:"] = "☪️"
    dictionary[":peace:"] = "☮️"
    dictionary[":menorah:"] = "🕎"
    dictionary[":six_pointed_star:"] = "🔯"
    dictionary[":aries:"] = "♈️"
    dictionary[":taurus:"] = "♉️"
    dictionary[":gemini:"] = "♊️"
    dictionary[":cancer:"] = "♋️"
    dictionary[":leo:"] = "♌️"
    dictionary[":virgo:"] = "♍️"
    dictionary[":libra:"] = "♎️"
    dictionary[":scorpius:"] = "♏️"
    dictionary[":sagittarius:"] = "♐️"
    dictionary[":capricorn:"] = "♑️"
    dictionary[":aquarius:"] = "♒️"
    dictionary[":pisces:"] = "♓️"
    dictionary[":ophiuchus:"] = "⛎"
    dictionary[":twisted_rightwards_arrows:"] = "🔀"
    dictionary[":repeat:"] = "🔁"
    dictionary[":repeat_one:"] = "🔂"
    dictionary[":arrow_forward:"] = "▶️"
    dictionary[":fast_forward:"] = "⏩"
    dictionary[":track_next:"] = "⏭️"
    dictionary[":play_pause:"] = "⏯️"
    dictionary[":arrow_backward:"] = "◀️"
    dictionary[":rewind:"] = "⏪"
    dictionary[":track_previous:"] = "⏮️"
    dictionary[":arrow_up_small:"] = "🔼"
    dictionary[":arrow_double_up:"] = "⏫"
    dictionary[":arrow_down_small:"] = "🔽"
    dictionary[":arrow_double_down:"] = "⏬"
    dictionary[":pause_button:"] = "⏸️"
    dictionary[":stop_button:"] = "⏹️"
    dictionary[":record_button:"] = "⏺️"
    dictionary[":eject:"] = "⏏️"
    dictionary[":cinema:"] = "🎦"
    dictionary[":low_brightness:"] = "🔅"
    dictionary[":high_brightness:"] = "🔆"
    dictionary[":signal_strength:"] = "📶"
    dictionary[":vibration_mode:"] = "📳"
    dictionary[":mobile_phone_off:"] = "📴"
    dictionary[":recycle:"] = "♻️"
    dictionary[":name_badge:"] = "📛"
    dictionary[":fleur-de-lis:"] = "⚜️"
    dictionary[":beginner:"] = "🔰"
    dictionary[":trident:"] = "🔱"
    dictionary[":o:"] = "⭕️"
    dictionary[":white_check_mark:"] = "✅"
    dictionary[":ballot_box_with_check:"] = "☑️"
    dictionary[":heavy_check_mark:"] = "✔️"
    dictionary[":heavy_multiplication_x:"] = "✖️"
    dictionary[":x:"] = "❌"
    dictionary[":negative_squared_cross_mark:"] = "❎"
    dictionary[":heavy_plus_sign:"] = "➕"
    dictionary[":heavy_minus_sign:"] = "➖"
    dictionary[":heavy_division_sign:"] = "➗"
    dictionary[":curly_loop:"] = "➰"
    dictionary[":loop:"] = "➿"
    dictionary[":part_alternation_mark:"] = "〽️"
    dictionary[":eight_spoked_asterisk:"] = "✳️"
    dictionary[":eight_pointed_black_star:"] = "✴️"
    dictionary[":sparkle:"] = "❇️"
    dictionary[":bangbang:"] = "‼️"
    dictionary[":interrobang:"] = "⁉️"
    dictionary[":question:"] = "❓"
    dictionary[":grey_question:"] = "❔"
    dictionary[":grey_exclamation:"] = "❕"
    dictionary[":exclamation:"] = "❗️"
    dictionary[":wavy_dash:"] = "〰️"
    dictionary[":copyright:"] = "©️"
    dictionary[":registered:"] = "®️"
    dictionary[":tm:"] = "™️"
    dictionary[":hash:"] = "#️⃣"
    dictionary[":asterisk:"] = "*️⃣"
    dictionary[":zero:"] = "0️⃣"
    dictionary[":one:"] = "1️⃣"
    dictionary[":two:"] = "2️⃣"
    dictionary[":three:"] = "3️⃣"
    dictionary[":four:"] = "4️⃣"
    dictionary[":five:"] = "5️⃣"
    dictionary[":six:"] = "6️⃣"
    dictionary[":seven:"] = "7️⃣"
    dictionary[":eight:"] = "8️⃣"
    dictionary[":nine:"] = "9️⃣"
    dictionary[":keycap_ten:"] = "🔟"
    dictionary[":100:"] = "💯"
    dictionary[":capital_abcd:"] = "🔠"
    dictionary[":abcd:"] = "🔡"
    dictionary[":1234:"] = "🔢"
    dictionary[":symbols:"] = "🔣"
    dictionary[":abc:"] = "🔤"
    dictionary[":a:"] = "🅰"
    dictionary[":ab:"] = "🆎"
    dictionary[":b:"] = "🅱"
    dictionary[":cl:"] = "🆑"
    dictionary[":cool:"] = "🆒"
    dictionary[":free:"] = "🆓"
    dictionary[":information_source:"] = "ℹ️"
    dictionary[":id:"] = "🆔"
    dictionary[":m:"] = "Ⓜ️"
    dictionary[":new:"] = "🆕"
    dictionary[":ng:"] = "🆖"
    dictionary[":o2:"] = "🅾"
    dictionary[":ok:"] = "🆗"
    dictionary[":parking:"] = "🅿️"
    dictionary[":sos:"] = "🆘"
    dictionary[":up:"] = "🆙"
    dictionary[":vs:"] = "🆚"
    dictionary[":koko:"] = "🈁"
    dictionary[":sa:"] = "🈂️"
    dictionary[":u6708:"] = "🈷️"
    dictionary[":u6709:"] = "🈶"
    dictionary[":u6307:"] = "🈯️"
    dictionary[":ideograph_advantage:"] = "🉐"
    dictionary[":u5272:"] = "🈹"
    dictionary[":u7121:"] = "🈚️"
    dictionary[":u7981:"] = "🈲"
    dictionary[":accept:"] = "🉑"
    dictionary[":u7533:"] = "🈸"
    dictionary[":u5408:"] = "🈴"
    dictionary[":u7a7a:"] = "🈳"
    dictionary[":congratulations:"] = "㊗️"
    dictionary[":secret:"] = "㊙️"
    dictionary[":u55b6:"] = "🈺"
    dictionary[":u6e80:"] = "🈵"
    dictionary[":black_small_square:"] = "▪️"
    dictionary[":white_small_square:"] = "▫️"
    dictionary[":white_medium_square:"] = "◻️"
    dictionary[":black_medium_square:"] = "◼️"
    dictionary[":white_medium_small_square:"] = "◽️"
    dictionary[":black_medium_small_square:"] = "◾️"
    dictionary[":black_large_square:"] = "⬛️"
    dictionary[":white_large_square:"] = "⬜️"
    dictionary[":large_orange_diamond:"] = "🔶"
    dictionary[":large_blue_diamond:"] = "🔷"
    dictionary[":small_orange_diamond:"] = "🔸"
    dictionary[":small_blue_diamond:"] = "🔹"
    dictionary[":small_red_triangle:"] = "🔺"
    dictionary[":small_red_triangle_down:"] = "🔻"
    dictionary[":diamond_shape_with_a_dot_inside:"] = "💠"
    dictionary[":radio_button:"] = "🔘"
    dictionary[":black_square_button:"] = "🔲"
    dictionary[":white_square_button:"] = "🔳"
    dictionary[":white_circle:"] = "⚪️"
    dictionary[":black_circle:"] = "⚫️"
    dictionary[":red_circle:"] = "🔴"
    dictionary[":blue_circle:"] = "🔵"
    // Flags
    dictionary[":flag_ac:"] = "🇦🇨"
    dictionary[":flag_ad:"] = "🇦🇩"
    dictionary[":flag_ae:"] = "🇦🇪"
    dictionary[":flag_af:"] = "🇦🇫"
    dictionary[":flag_ag:"] = "🇦🇬"
    dictionary[":flag_ai:"] = "🇦🇮"
    dictionary[":flag_al:"] = "🇦🇱"
    dictionary[":flag_am:"] = "🇦🇲"
    dictionary[":flag_ao:"] = "🇦🇴"
    dictionary[":flag_aq:"] = "🇦🇶"
    dictionary[":flag_ar:"] = "🇦🇷"
    dictionary[":flag_as:"] = "🇦🇸"
    dictionary[":flag_at:"] = "🇦🇹"
    dictionary[":flag_au:"] = "🇦🇺"
    dictionary[":flag_aw:"] = "🇦🇼"
    dictionary[":flag_ax:"] = "🇦🇽"
    dictionary[":flag_az:"] = "🇦🇿"
    dictionary[":flag_ba:"] = "🇧🇦"
    dictionary[":flag_bb:"] = "🇧🇧"
    dictionary[":flag_bd:"] = "🇧🇩"
    dictionary[":flag_be:"] = "🇧🇪"
    dictionary[":flag_bf:"] = "🇧🇫"
    dictionary[":flag_bg:"] = "🇧🇬"
    dictionary[":flag_bh:"] = "🇧🇭"
    dictionary[":flag_bi:"] = "🇧🇮"
    dictionary[":flag_bj:"] = "🇧🇯"
    dictionary[":flag_bl:"] = "🇧🇱"
    dictionary[":flag_bm:"] = "🇧🇲"
    dictionary[":flag_bn:"] = "🇧🇳"
    dictionary[":flag_bo:"] = "🇧🇴"
    dictionary[":flag_bq:"] = "🇧🇶"
    dictionary[":flag_br:"] = "🇧🇷"
    dictionary[":flag_bs:"] = "🇧🇸"
    dictionary[":flag_bt:"] = "🇧🇹"
    dictionary[":flag_bv:"] = "🇧🇻"
    dictionary[":flag_bw:"] = "🇧🇼"
    dictionary[":flag_by:"] = "🇧🇾"
    dictionary[":flag_bz:"] = "🇧🇿"
    dictionary[":flag_ca:"] = "🇨🇦"
    dictionary[":flag_cc:"] = "🇨🇨"
    dictionary[":flag_cd:"] = "🇨🇩"
    dictionary[":flag_cf:"] = "🇨🇫"
    dictionary[":flag_cg:"] = "🇨🇬"
    dictionary[":flag_ch:"] = "🇨🇭"
    dictionary[":flag_ci:"] = "🇨🇮"
    dictionary[":flag_ck:"] = "🇨🇰"
    dictionary[":flag_cl:"] = "🇨🇱"
    dictionary[":flag_cm:"] = "🇨🇲"
    dictionary[":flag_cn:"] = "🇨🇳"
    dictionary[":flag_co:"] = "🇨🇴"
    dictionary[":flag_cp:"] = "🇨🇵"
    dictionary[":flag_cr:"] = "🇨🇷"
    dictionary[":flag_cu:"] = "🇨🇺"
    dictionary[":flag_cv:"] = "🇨🇻"
    dictionary[":flag_cw:"] = "🇨🇼"
    dictionary[":flag_cx:"] = "🇨🇽"
    dictionary[":flag_cy:"] = "🇨🇾"
    dictionary[":flag_cz:"] = "🇨🇿"
    dictionary[":flag_de:"] = "🇩🇪"
    dictionary[":flag_dg:"] = "🇩🇬"
    dictionary[":flag_dj:"] = "🇩🇯"
    dictionary[":flag_dk:"] = "🇩🇰"
    dictionary[":flag_dm:"] = "🇩🇲"
    dictionary[":flag_do:"] = "🇩🇴"
    dictionary[":flag_dz:"] = "🇩🇿"
    dictionary[":flag_ea:"] = "🇪🇦"
    dictionary[":flag_ec:"] = "🇪🇨"
    dictionary[":flag_ee:"] = "🇪🇪"
    dictionary[":flag_eg:"] = "🇪🇬"
    dictionary[":flag_eh:"] = "🇪🇭"
    dictionary[":flag_er:"] = "🇪🇷"
    dictionary[":flag_es:"] = "🇪🇸"
    dictionary[":flag_et:"] = "🇪🇹"
    dictionary[":flag_eu:"] = "🇪🇺"
    dictionary[":flag_fi:"] = "🇫🇮"
    dictionary[":flag_fj:"] = "🇫🇯"
    dictionary[":flag_fk:"] = "🇫🇰"
    dictionary[":flag_fm:"] = "🇫🇲"
    dictionary[":flag_fo:"] = "🇫🇴"
    dictionary[":flag_fr:"] = "🇫🇷"
    dictionary[":flag_ga:"] = "🇬🇦"
    dictionary[":flag_gb:"] = "🇬🇧"
    dictionary[":flag_gd:"] = "🇬🇩"
    dictionary[":flag_ge:"] = "🇬🇪"
    dictionary[":flag_gf:"] = "🇬🇫"
    dictionary[":flag_gg:"] = "🇬🇬"
    dictionary[":flag_gh:"] = "🇬🇭"
    dictionary[":flag_gi:"] = "🇬🇮"
    dictionary[":flag_gl:"] = "🇬🇱"
    dictionary[":flag_gm:"] = "🇬🇲"
    dictionary[":flag_gn:"] = "🇬🇳"
    dictionary[":flag_gp:"] = "🇬🇵"
    dictionary[":flag_gq:"] = "🇬🇶"
    dictionary[":flag_gr:"] = "🇬🇷"
    dictionary[":flag_gs:"] = "🇬🇸"
    dictionary[":flag_gt:"] = "🇬🇹"
    dictionary[":flag_gu:"] = "🇬🇺"
    dictionary[":flag_gw:"] = "🇬🇼"
    dictionary[":flag_gy:"] = "🇬🇾"
    dictionary[":flag_hk:"] = "🇭🇰"
    dictionary[":flag_hm:"] = "🇭🇲"
    dictionary[":flag_hn:"] = "🇭🇳"
    dictionary[":flag_hr:"] = "🇭🇷"
    dictionary[":flag_ht:"] = "🇭🇹"
    dictionary[":flag_hu:"] = "🇭🇺"
    dictionary[":flag_ic:"] = "🇮🇨"
    dictionary[":flag_id:"] = "🇮🇩"
    dictionary[":flag_ie:"] = "🇮🇪"
    dictionary[":flag_il:"] = "🇮🇱"
    dictionary[":flag_im:"] = "🇮🇲"
    dictionary[":flag_in:"] = "🇮🇳"
    dictionary[":flag_io:"] = "🇮🇴"
    dictionary[":flag_iq:"] = "🇮🇶"
    dictionary[":flag_ir:"] = "🇮🇷"
    dictionary[":flag_is:"] = "🇮🇸"
    dictionary[":flag_it:"] = "🇮🇹"
    dictionary[":flag_je:"] = "🇯🇪"
    dictionary[":flag_jm:"] = "🇯🇲"
    dictionary[":flag_jo:"] = "🇯🇴"
    dictionary[":flag_jp:"] = "🇯🇵"
    dictionary[":flag_ke:"] = "🇰🇪"
    dictionary[":flag_kg:"] = "🇰🇬"
    dictionary[":flag_kh:"] = "🇰🇭"
    dictionary[":flag_ki:"] = "🇰🇮"
    dictionary[":flag_km:"] = "🇰🇲"
    dictionary[":flag_kn:"] = "🇰🇳"
    dictionary[":flag_kp:"] = "🇰🇵"
    dictionary[":flag_kr:"] = "🇰🇷"
    dictionary[":flag_kw:"] = "🇰🇼"
    dictionary[":flag_ky:"] = "🇰🇾"
    dictionary[":flag_kz:"] = "🇰🇿"
    dictionary[":flag_la:"] = "🇱🇦"
    dictionary[":flag_lb:"] = "🇱🇧"
    dictionary[":flag_lc:"] = "🇱🇨"
    dictionary[":flag_li:"] = "🇱🇮"
    dictionary[":flag_lk:"] = "🇱🇰"
    dictionary[":flag_lr:"] = "🇱🇷"
    dictionary[":flag_ls:"] = "🇱🇸"
    dictionary[":flag_lt:"] = "🇱🇹"
    dictionary[":flag_lu:"] = "🇱🇺"
    dictionary[":flag_lv:"] = "🇱🇻"
    dictionary[":flag_ly:"] = "🇱🇾"
    dictionary[":flag_ma:"] = "🇲🇦"
    dictionary[":flag_mc:"] = "🇲🇨"
    dictionary[":flag_md:"] = "🇲🇩"
    dictionary[":flag_me:"] = "🇲🇪"
    dictionary[":flag_mf:"] = "🇲🇫"
    dictionary[":flag_mg:"] = "🇲🇬"
    dictionary[":flag_mh:"] = "🇲🇭"
    dictionary[":flag_mk:"] = "🇲🇰"
    dictionary[":flag_ml:"] = "🇲🇱"
    dictionary[":flag_mm:"] = "🇲🇲"
    dictionary[":flag_mn:"] = "🇲🇳"
    dictionary[":flag_mo:"] = "🇲🇴"
    dictionary[":flag_mp:"] = "🇲🇵"
    dictionary[":flag_mq:"] = "🇲🇶"
    dictionary[":flag_mr:"] = "🇲🇷"
    dictionary[":flag_ms:"] = "🇲🇸"
    dictionary[":flag_mt:"] = "🇲🇹"
    dictionary[":flag_mu:"] = "🇲🇺"
    dictionary[":flag_mv:"] = "🇲🇻"
    dictionary[":flag_mw:"] = "🇲🇼"
    dictionary[":flag_mx:"] = "🇲🇽"
    dictionary[":flag_my:"] = "🇲🇾"
    dictionary[":flag_mz:"] = "🇲🇿"
    dictionary[":flag_na:"] = "🇳🇦"
    dictionary[":flag_nc:"] = "🇳🇨"
    dictionary[":flag_ne:"] = "🇳🇪"
    dictionary[":flag_nf:"] = "🇳🇫"
    dictionary[":flag_ng:"] = "🇳🇬"
    dictionary[":flag_ni:"] = "🇳🇮"
    dictionary[":flag_nl:"] = "🇳🇱"
    dictionary[":flag_no:"] = "🇳🇴"
    dictionary[":flag_np:"] = "🇳🇵"
    dictionary[":flag_nr:"] = "🇳🇷"
    dictionary[":flag_nu:"] = "🇳🇺"
    dictionary[":flag_nz:"] = "🇳🇿"
    dictionary[":flag_om:"] = "🇴🇲"
    dictionary[":flag_pa:"] = "🇵🇦"
    dictionary[":flag_pe:"] = "🇵🇪"
    dictionary[":flag_pf:"] = "🇵🇫"
    dictionary[":flag_pg:"] = "🇵🇬"
    dictionary[":flag_ph:"] = "🇵🇭"
    dictionary[":flag_pk:"] = "🇵🇰"
    dictionary[":flag_pl:"] = "🇵🇱"
    dictionary[":flag_pm:"] = "🇵🇲"
    dictionary[":flag_pn:"] = "🇵🇳"
    dictionary[":flag_pr:"] = "🇵🇷"
    dictionary[":flag_ps:"] = "🇵🇸"
    dictionary[":flag_pt:"] = "🇵🇹"
    dictionary[":flag_pw:"] = "🇵🇼"
    dictionary[":flag_py:"] = "🇵🇾"
    dictionary[":flag_qa:"] = "🇶🇦"
    dictionary[":flag_re:"] = "🇷🇪"
    dictionary[":flag_ro:"] = "🇷🇴"
    dictionary[":flag_rs:"] = "🇷🇸"
    dictionary[":flag_ru:"] = "🇷🇺"
    dictionary[":flag_rw:"] = "🇷🇼"
    dictionary[":flag_sa:"] = "🇸🇦"
    dictionary[":flag_sb:"] = "🇸🇧"
    dictionary[":flag_sc:"] = "🇸🇨"
    dictionary[":flag_sd:"] = "🇸🇩"
    dictionary[":flag_se:"] = "🇸🇪"
    dictionary[":flag_sg:"] = "🇸🇬"
    dictionary[":flag_sh:"] = "🇸🇭"
    dictionary[":flag_si:"] = "🇸🇮"
    dictionary[":flag_sj:"] = "🇸🇯"
    dictionary[":flag_sk:"] = "🇸🇰"
    dictionary[":flag_sl:"] = "🇸🇱"
    dictionary[":flag_sm:"] = "🇸🇲"
    dictionary[":flag_sn:"] = "🇸🇳"
    dictionary[":flag_so:"] = "🇸🇴"
    dictionary[":flag_sr:"] = "🇸🇷"
    dictionary[":flag_ss:"] = "🇸🇸"
    dictionary[":flag_st:"] = "🇸🇹"
    dictionary[":flag_sv:"] = "🇸🇻"
    dictionary[":flag_sx:"] = "🇸🇽"
    dictionary[":flag_sy:"] = "🇸🇾"
    dictionary[":flag_sz:"] = "🇸🇿"
    dictionary[":flag_ta:"] = "🇹🇦"
    dictionary[":flag_tc:"] = "🇹🇨"
    dictionary[":flag_td:"] = "🇹🇩"
    dictionary[":flag_tf:"] = "🇹🇫"
    dictionary[":flag_tg:"] = "🇹🇬"
    dictionary[":flag_th:"] = "🇹🇭"
    dictionary[":flag_tj:"] = "🇹🇯"
    dictionary[":flag_tk:"] = "🇹🇰"
    dictionary[":flag_tl:"] = "🇹🇱"
    dictionary[":flag_tm:"] = "🇹🇲"
    dictionary[":flag_tn:"] = "🇹🇳"
    dictionary[":flag_to:"] = "🇹🇴"
    dictionary[":flag_tr:"] = "🇹🇷"
    dictionary[":flag_tt:"] = "🇹🇹"
    dictionary[":flag_tv:"] = "🇹🇻"
    dictionary[":flag_tw:"] = "🇹🇼"
    dictionary[":flag_tz:"] = "🇹🇿"
    dictionary[":flag_ua:"] = "🇺🇦"
    dictionary[":flag_ug:"] = "🇺🇬"
    dictionary[":flag_um:"] = "🇺🇲"
    dictionary[":flag_us:"] = "🇺🇸"
    dictionary[":flag_uy:"] = "🇺🇾"
    dictionary[":flag_uz:"] = "🇺🇿"
    dictionary[":flag_va:"] = "🇻🇦"
    dictionary[":flag_vc:"] = "🇻🇨"
    dictionary[":flag_ve:"] = "🇻🇪"
    dictionary[":flag_vg:"] = "🇻🇬"
    dictionary[":flag_vi:"] = "🇻🇮"
    dictionary[":flag_vn:"] = "🇻🇳"
    dictionary[":flag_vu:"] = "🇻🇺"
    dictionary[":flag_wf:"] = "🇼🇫"
    dictionary[":flag_ws:"] = "🇼🇸"
    dictionary[":flag_xk:"] = "🇽🇰"
    dictionary[":flag_ye:"] = "🇾🇪"
    dictionary[":flag_yt:"] = "🇾🇹"
    dictionary[":flag_za:"] = "🇿🇦"
    dictionary[":flag_zm:"] = "🇿🇲"
    dictionary[":flag_zw:"] = "🇿🇼"
    
    // Custom aliases - These aliases exist in the legacy versions and
    // the non-conflicting ones are kept here for backward compatibility
    dictionary[":hm:"] = "🤔"
    dictionary[":satisfied:"] = "😌"
    dictionary[":collision:"] = "💥"
    dictionary[":shit:"] = "💩"
    dictionary[":+1:"] = "👍"
    dictionary[":-1:"] = "👎"
    dictionary[":ok:"] = "👌"
    dictionary[":facepunch:"] = "👊"
    dictionary[":hand:"] = "✋"
    dictionary[":running:"] = "🏃"
    dictionary[":honeybee:"] = "🐝"
    dictionary[":paw_prints:"] = "🐾"
    dictionary[":moon:"] = "🌙"
    dictionary[":hocho:"] = "🔪"
    dictionary[":shoe:"] = "👞"
    dictionary[":tshirt:"] = "👕"
    dictionary[":city_sunrise:"] = "🌇"
    dictionary[":city_sunset:"] = "🌆"
    dictionary[":flag_uk:"] = "🇬🇧"
    
    // Custom emoticon-to-emoji conversion
    // Note: Do not define two char shortcuts with the second char
    // being a lower case letter of the alphabet, such as :p or :x
    // or else user will not be able to use emojis starting with p or x!
    dictionary[":)"] = "🙂"
    dictionary[":-)"] = "🙂"
    dictionary["(:"] = "🙂"
    dictionary[":D"] = "😄"
    dictionary[":-D"] = "😄"
    dictionary["=D"] = "😃"
    dictionary["=-D"] = "😃"
    dictionary[":')"] = "😂"
    dictionary[":'-)"] = "😂"
    dictionary[":*)"] = "😊"
    dictionary[";)"] = "😉"
    dictionary[";-)"] = "😉"
    dictionary[":>"] = "😆"
    dictionary[":->"] = "😆"
    dictionary["XD"] = "😆"
    dictionary["O:)"] = "😇"
    dictionary["3-)"] = "😌"
    dictionary[":P"] = "😛"
    dictionary[":-P"] = "😛"
    dictionary[";P"] = "😜"
    dictionary[";-P"] = "😜"
    dictionary["8)"] = "😍"
    dictionary[":*"] = "😚"
    dictionary[":-*"] = "😚"
    dictionary["B)"] = "😎"
    dictionary["B-)"] = "😎"
    dictionary[":J"] = "😏"
    dictionary[":-J"] = "😏"
    dictionary["3("] = "😔"
    dictionary[":|"] = "😐"
    dictionary[":("] = "🙁"
    dictionary[":-("] = "🙁"
    dictionary[":'("] = "😢"
    dictionary[":/"] = "😕"
    dictionary[":-/"] = "😕"
    dictionary[":\\"] = "😕"
    dictionary[":-\\"] = "😕"
    dictionary["D:"] = "😧"
    dictionary[":O"] = "😮"
    dictionary[":-O"] = "😮"
    dictionary[">:("] = "😠"
    dictionary[">:-("] = "😠"
    dictionary[";o"] = "😰"
    dictionary[";-o"] = "😰"
    dictionary[":$"] = "😳"
    dictionary[":-$"] = "😳"
    dictionary["8o"] = "😲"
    dictionary["8-o"] = "😲"
    dictionary[":X"] = "😷"
    dictionary[":-X"] = "😷"
    dictionary["%)"] = "😵"
    dictionary["%-)"] = "😵"
    dictionary["}:)"] = "😈"
    dictionary["}:-)"] = "😈"
    dictionary["<3"] = "❤️"
    dictionary["</3"] = "💔"
    dictionary["<_<"] = "🌝"
    dictionary[">_>"] = "🌚"
    dictionary["9_9"] = "🙄"
    
    
    return dictionary
}()

struct EmojiClue : Equatable {
    let emoji: String
    let label: String
    let replacement: String
    var hashValue: Int64 {
        return Int64((emoji + label + replacement).hashValue)
    }
}
func ==(lhs: EmojiClue, rhs: EmojiClue) -> Bool {
    return lhs.emoji == rhs.emoji && lhs.label == rhs.label && lhs.replacement == rhs.replacement
}

func searchEmojiClue(query: String, postbox: Postbox) -> Signal<[EmojiClue], Void> {
    return recentUsedEmoji(postbox: postbox) |> deliverOn(resourcesQueue) |> map { recent in
        
        
        var clues:[EmojiClue] = []
        if query.isEmpty {
            for emoji in recent.emojies {
                if let query = emojiRevervedReplacements[emoji] {
                    let clue = EmojiClue(emoji: emoji, label: query, replacement: query)
                    if clues.index(of: clue) == nil {
                        clues.append(clue)
                    }
                }
            }
        } else {
            return Array(EmojiSuggestionBridge.getSuggestions(query).map{EmojiClue(emoji: $0.emoji, label: $0.label, replacement: $0.replacement)}.prefix(5))
        }
        
        return Array(clues.prefix(5))
    }
}


func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>)
    -> Dictionary<K,V>
{
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

extension Array {
    func subarray(with range: NSRange) -> Array {
        return Array(self[range.min ..< range.max])
    }
    mutating func move(at oldIndex: Int, to newIndex: Int) {
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

func copyToClipboard(_ string:String) {
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(string, forType: .string)
}

extension LAPolicy {
    static var applicationPolicy: LAPolicy {
        if #available(OSX 10.12.2, *) {
            #if DEBUG
                return .deviceOwnerAuthentication
            #endif
            return .deviceOwnerAuthenticationWithBiometrics
        } else {
            return .deviceOwnerAuthentication
        }
    }
}

extension LAContext {
    var canUseBiometric: Bool {
        if #available(OSX 10.12.2, *) {
            #if DEBUG
                return true
            #endif
            if canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return true
            } else {
                return false
            }
        } else {
            #if DEBUG
                return true
            #endif
            return false
        }
    }
}


extension CVImageBuffer {
    var cgImage: CGImage?
    {
        let imageBuffer: CVImageBuffer = self
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer);
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        let quartzImage = context?.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly);
        
        return quartzImage
    }
}


extension CGImage {
    func saveToFile(_ path:String) -> Bool {
//        var randomId: Int64 = 0
//        arc4random_buf(&randomId, 8)
//        let path = NSTemporaryDirectory() + "\(randomId)"
        let url = URL(fileURLWithPath: path)
        
        
        
        if let colorDestination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil) {
            
                        
            let colorQuality: Float = 1
            
            let options = NSMutableDictionary()
            options.setObject(colorQuality as NSNumber, forKey: kCGImageDestinationLossyCompressionQuality as NSString)
            
            
            
            CGImageDestinationAddImage(colorDestination, self, nil)
            if CGImageDestinationFinalize(colorDestination) {
                return true
            }
        }
        return false
    }
    
    var blurred: CGImage {
        
        let thumbnailImage: CGImage = self
        
        let thumbnailContextSize = thumbnailImage.size
        let thumbnailContext = DrawingContext(size: thumbnailContextSize, scale: 1.0)
        thumbnailContext.withContext { ctx in
            ctx.interpolationQuality = .none
            
            ctx.draw(thumbnailImage, in: CGRect(origin: CGPoint(), size: thumbnailContextSize))
        }
        telegramFastBlur(Int32(thumbnailContextSize.width), Int32(thumbnailContextSize.height), Int32(thumbnailContext.bytesPerRow), thumbnailContext.bytes)
        
        return thumbnailContext.generateImage()!
    }

    
    static func loadFromFile(_ path:String) -> CGImage? {
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            if let dataProvider = CGDataProvider(data: data as CFData) {
                return CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            }
        }

        return nil
    }
}

func synced(_ lock: Any, closure: ()->Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}


extension NSTextView {
    
    var selectedRangeRect: NSRect {

        var rect: NSRect = firstRect(forCharacterRange: selectedRange(), actualRange: nil)
        
        

        
        if let window = window {
            //rect = window.convertFromScreen(rect)
            
            var textViewBounds: NSRect = convert(bounds, to: nil)
            textViewBounds = window.convertToScreen(textViewBounds)
            
            rect.origin.x -= textViewBounds.origin.x;
            rect.origin.y -= (textViewBounds.origin.y );
        }
        
//        if let superview = superview {
//            rect = superview.convert(rect, from: nil)
//        }
      //  rect.origin.y += 10
        return rect
    }
    
}

extension CGContext {
    func round(_ size:NSSize,_ cornerRadius:CGFloat = .cornerRadius, positionFlags: GroupLayoutPositionFlags? = nil) {
        let minx:CGFloat = 0, midx = size.width/2.0, maxx = size.width
        let miny:CGFloat = 0, midy = size.height/2.0, maxy = size.height
        
        self.move(to: NSMakePoint(minx, midy))
        
        var topLeftRadius: CGFloat = cornerRadius
        var bottomLeftRadius: CGFloat = cornerRadius
        var topRightRadius: CGFloat = cornerRadius
        var bottomRightRadius: CGFloat = cornerRadius
        
        
        if let positionFlags = positionFlags {
            if positionFlags.contains(.top) && positionFlags.contains(.left) {
                topLeftRadius = topLeftRadius * 3 + 2
            }
            if positionFlags.contains(.top) && positionFlags.contains(.right) {
                topRightRadius = topRightRadius * 3 + 2
            }
            if positionFlags.contains(.bottom) && positionFlags.contains(.left) {
                bottomLeftRadius = bottomLeftRadius * 3 + 2
            }
            if positionFlags.contains(.bottom) && positionFlags.contains(.right) {
                bottomRightRadius = bottomRightRadius * 3 + 2
            }
        }
        
        self.addArc(tangent1End: NSMakePoint(minx, miny), tangent2End: NSMakePoint(midx, miny), radius: topLeftRadius)
        self.addArc(tangent1End: NSMakePoint(maxx, miny), tangent2End: NSMakePoint(maxx, midy), radius: topRightRadius)
        self.addArc(tangent1End: NSMakePoint(maxx, maxy), tangent2End: NSMakePoint(midx, maxy), radius: bottomLeftRadius)
        self.addArc(tangent1End: NSMakePoint(minx, maxy), tangent2End: NSMakePoint(minx, midy), radius: bottomRightRadius)
        
        self.closePath()
        self.clip()
        
    }
}


func ninePartPiecesFromImageWithInsets(_ image: CGImage, capInsets: RHEdgeInsets) -> [CGImage] {
    
    let imageWidth: CGFloat  = image.backingSize.width
    let imageHeight: CGFloat = image.backingSize.height
    
    let leftCapWidth: CGFloat = capInsets.left
    let topCapHeight: CGFloat = capInsets.top
    let rightCapWidth: CGFloat = capInsets.right
    let bottomCapHeight: CGFloat = capInsets.bottom
    
    let centerSize: NSSize  = NSMakeSize(imageWidth - leftCapWidth - rightCapWidth, imageHeight - topCapHeight - bottomCapHeight);
    
    let topLeftCorner: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(0.0, imageHeight - topCapHeight, leftCapWidth, topCapHeight))
    let topEdgeFill: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(leftCapWidth, imageHeight - topCapHeight, centerSize.width, topCapHeight))
    let topRightCorner: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(imageWidth - rightCapWidth, imageHeight - topCapHeight, rightCapWidth, topCapHeight))
    
    let leftEdgeFill: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(0.0, bottomCapHeight, leftCapWidth, centerSize.height))
    let centerFill: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(leftCapWidth, bottomCapHeight, centerSize.width, centerSize.height))
    let rightEdgeFill: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(imageWidth - rightCapWidth, bottomCapHeight, rightCapWidth, centerSize.height))
    
    let bottomLeftCorner: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(0.0, 0.0, leftCapWidth, bottomCapHeight))
    let bottomEdgeFill: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(leftCapWidth, 0.0, centerSize.width, bottomCapHeight))
    let bottomRightCorner: CGImage = imageByReferencingRectOfExistingImage(image, NSMakeRect(imageWidth - rightCapWidth, 0.0, rightCapWidth, bottomCapHeight))
    
    return [topLeftCorner, topEdgeFill, topRightCorner, leftEdgeFill, centerFill, rightEdgeFill, bottomLeftCorner, bottomEdgeFill, bottomRightCorner]
}

func drawNinePartImage(_ context: CGContext, frame: NSRect, topLeftCorner: CGImage, topEdgeFill: CGImage, topRightCorner: CGImage, leftEdgeFill: CGImage, centerFill: CGImage, rightEdgeFill: CGImage, bottomLeftCorner: CGImage, bottomEdgeFill: CGImage, bottomRightCorner: CGImage){
    
    let imageWidth: CGFloat = frame.size.width;
    let imageHeight: CGFloat = frame.size.height;
    
    let leftCapWidth: CGFloat = topLeftCorner.backingSize.width;
    let topCapHeight: CGFloat = topLeftCorner.backingSize.height;
    let rightCapWidth: CGFloat = bottomRightCorner.backingSize.width;
    let bottomCapHeight: CGFloat = bottomRightCorner.backingSize.height;
    
    let centerSize = NSMakeSize(imageWidth - leftCapWidth - rightCapWidth, imageHeight - topCapHeight - bottomCapHeight);
    
    let topLeftCornerRect: NSRect = NSMakeRect(0.0, imageHeight - topCapHeight, leftCapWidth, topCapHeight);
    let topEdgeFillRect: NSRect = NSMakeRect(leftCapWidth, imageHeight - topCapHeight, centerSize.width, topCapHeight);
    let topRightCornerRect: NSRect = NSMakeRect(imageWidth - rightCapWidth, imageHeight - topCapHeight, rightCapWidth, topCapHeight);
    
    let leftEdgeFillRect: NSRect = NSMakeRect(0.0, bottomCapHeight, leftCapWidth, centerSize.height);
    let centerFillRect: NSRect = NSMakeRect(leftCapWidth, bottomCapHeight, centerSize.width, centerSize.height);
    let rightEdgeFillRect: NSRect = NSMakeRect(imageWidth - rightCapWidth, bottomCapHeight, rightCapWidth, centerSize.height);
    
    let bottomLeftCornerRect: NSRect = NSMakeRect(0.0, 0.0, leftCapWidth, bottomCapHeight);
    let bottomEdgeFillRect: NSRect = NSMakeRect(leftCapWidth, 0.0, centerSize.width, bottomCapHeight);
    let bottomRightCornerRect: NSRect = NSMakeRect(imageWidth - rightCapWidth, 0.0, rightCapWidth, bottomCapHeight);
    
    
    drawStretchedImageInRect(topLeftCorner, context: context, rect: topLeftCornerRect);
    drawStretchedImageInRect(topEdgeFill, context: context, rect: topEdgeFillRect);
    drawStretchedImageInRect(topRightCorner, context: context, rect: topRightCornerRect);
    
    drawStretchedImageInRect(leftEdgeFill, context: context, rect: leftEdgeFillRect);
    drawStretchedImageInRect(centerFill, context: context, rect: centerFillRect);
    drawStretchedImageInRect(rightEdgeFill, context: context, rect: rightEdgeFillRect);
    
    drawStretchedImageInRect(bottomLeftCorner, context: context, rect: bottomLeftCornerRect);
    drawStretchedImageInRect(bottomEdgeFill, context: context, rect: bottomEdgeFillRect);
    drawStretchedImageInRect(bottomRightCorner, context: context, rect: bottomRightCornerRect);
    
}


func imageByReferencingRectOfExistingImage(_ image: CGImage, _ rect: NSRect) -> CGImage {
    if (!NSIsEmptyRect(rect)){
        
        let pixelsHigh = CGFloat(image.height) 
        
        let scaleFactor:CGFloat = pixelsHigh / image.backingSize.height
        var captureRect = NSMakeRect(scaleFactor * rect.origin.x, scaleFactor * rect.origin.y, scaleFactor * rect.size.width, scaleFactor * rect.size.height)
        
        captureRect.origin.y = pixelsHigh - captureRect.origin.y - captureRect.size.height;
        
        return image.cropping(to: captureRect)!
    }
    return image.cropping(to: NSMakeRect(0, 0, image.size.width, image.size.height))!
}

func drawStretchedImageInRect(_ image: CGImage, context: CGContext, rect: NSRect) -> Void {
    context.saveGState()
    context.setBlendMode(.normal) //NSCompositeSourceOver
    context.clip(to: rect)
    
    context.draw(image, in: rect)
    context.restoreGState()
}

