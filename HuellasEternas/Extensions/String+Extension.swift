//
//  String+Extension.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 11/2/26.
//

extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
