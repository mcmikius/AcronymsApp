//
//  ImageUploadData.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 06.03.2020.
//

import Foundation
import Vapor

struct ImageUploadData: Content {
    var picture: Data
}
