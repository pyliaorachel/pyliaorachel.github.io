---
layout: post
title:  "Serverside Swift"
categories: Blog Notes Swift
tags: ["swift"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Basics
  1. Terminologies
  2. Commands
2. Docker Images
  1. Image Types
  2. Create Images
3. Docker Compose
  1. `docker-compose.yml`
  2. Run Application

<!--more-->
---
## Create Swift Package

`swift package init`  
`swift build`  
`swift package generate-xcodeproj`

#### Package.swift

```
name: name of package
targets: binary files
dependencies: [
  .Package(url: "url", majorVersion: version, minor: version)
]
```

## Swift Basics

##### Strongly-Typed

`var myVar = "string"` or `var myVar: String`  
`var myInt = Int(myVar)` or `var myInt = (myVar as NSString).integerValue`  

##### Constants & Variables

`let const = value` vs `var const = value`

##### Class

```swift
class MyClass {
  var myName = "name"
  func myFunc(_ name:String) -> String { // unnamed parameter
    return "Hello \(myName)"
  }
  static func myStaticFunc(name: String = "default") -> String { // named parameter
    return "Hello \(myName)"
  }
}

let this = MyClass()
print(this.myFunc("name"))

print(MyClass.myStaticFunc(name:"name"))
```

## Building Swift Applicstions

#### Targets

1. Library
2. Executable (terminal-like icon)

#### Settings

Target > Edit Scheme > Run > Options > Use custom working directory: [project-directory]












