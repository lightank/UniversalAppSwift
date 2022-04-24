//
//  main.swift
//  i18nScript
//
//  Created by huanyu.li on 2021/4/28.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

import Foundation

print("Hello, World!")

var localKeyContent = """
import Foundation

public class LocalKey: NSObject {\n
"""

/// 这个路径在 Edit Scheme 中找到对应 Target ，选项 Run 中 Argument 中新增的
let root = ProcessInfo.processInfo.environment["ResourceBasePath"]!
let localKeyPath = root + "/I18nKit/Src/LocalKey.swift"

// add Content
let space = "    "

// 添加注释
localKeyContent.append(space + "/// " + "添加注释" + "\n")
// 添加内容
localKeyContent.append(space + "@objc public static let test_Id = \"test\"" + "\n")
// 添加结尾
localKeyContent.append("\n}")
// save to file
let manager = FileManager.default
if let data = localKeyContent.data(using: .utf8) {
    let createSuccess = manager.createFile(atPath: localKeyPath, contents:data, attributes:nil)
    print("createSuccess:\(createSuccess)  \(localKeyPath)")
}
