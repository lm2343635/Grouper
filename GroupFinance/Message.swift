//
//	Message.swift
//
//	Create by Meng Li on 15/1/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

@objc class Message: NSObject {

	var content : String!
	var messageId : String!
	var object : String!
	var receiver : String!
	var sendtime : Int!
	var sequence : Int!
	var type : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: Dictionary<String, Any>) {
		content = dictionary["content"] as? String
		messageId = dictionary["message_id"] as? String
		object = dictionary["object"] as? String
		receiver = dictionary["receiver"] as? String
		sendtime = dictionary["sendtime"] as? Int
		sequence = dictionary["sequence"] as? Int
		type = dictionary["type"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
		if content != nil {
			dictionary["content"] = content
		}
		if messageId != nil {
			dictionary["message_id"] = messageId
		}
		if object != nil {
			dictionary["object"] = object
		}
		if receiver != nil {
			dictionary["receiver"] = receiver
		}
		if sendtime != nil {
			dictionary["sendtime"] = sendtime
		}
		if sequence != nil {
			dictionary["sequence"] = sequence
		}
		if type != nil {
			dictionary["type"] = type
		}
		return dictionary
	}

}
