//
//  NetworkErrors.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.09.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case BadRequest, Unauthorised, NotFound
}
