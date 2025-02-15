# HIPAAChecker-xPlugin


A tool to enforce HIPAA compliance when developing and iOS application, loosely based on the now archived [HIPAA Compliance Guide](https://hipaachecker.health/developers_guides). HIPAA Checker enforces the rules that are generally accepted by the HIPAA Compliance authority. These rules are well described in [HIPAA Compliance Guide](https://www.hhs.gov/hipaa/index.html).

HIPAAChecker hooks into [Clang](http://clang.llvm.org) and
[SourceKit](http://www.jpsim.com/uncovering-sourcekit) to use the
[AST](http://clang.llvm.org/docs/IntroductionToTheClangAST.html) representation
of your source files for more accurate results.


## Installation

Step 1: Create Project
From the iOS IDE - Xcode, create a project
Step 2: Add Package
Click on the File option Xcode and click “Add Package..”
Step 3: Download Package from Github
Search HIPAAChecker-iOS or paste the github repository link.
Select the main branch
Click add Package
HIPAAChecker main will be shown to the project Package Dependencies 
Step 4: Project Build Phase configuration
Select the project file in Xcode
Go the Build Phases
Expand Link Binary With Libraries
Click “+” icon
Search for HIPAAChecker
Add HIPAAChecker
Step 5: Project configuration
Go to the initial file that would be run after starting the project. It can be AppDelegate or SceneDelegate or any other root viewcontroller.
Import HIPAAChecker
Step 6: Package Initialization
If the plugin is installed successfully, the package API will be accessible.
Just add:
        let _ = HIPAAChecker(in: self.view, projectPath: "", email: "", password: "")
Self.view will be the view that need to pass, it can be window view and any view in controller.
Project path needs to be given. It can be copy from Xcode right panel or from Finder in Mac. That the root directory of the project.
The email and password is the credentials of hipaa checker platform

Step 7: Run Package
After adding these code in the project, just run the project. It will traverse the project with  valid token and find the HIPAA rules implementation on the project.
The report can be shown on the HIPAA checker web platform.
The above code should be comment out if the developer don’t want to check the HIPAA rules everytime when the project started.
Step 8: Uninstall process!
Go to the Package Dependencies from Project navigation.
Remove the package by clicking “-” after selecting the package


## Usage

### Presentation

To get a high-level overview of recommended ways to integrate HIPAAChecker into your project,
we encourage you to watch this presentation or read the transcript:

[![Presentation](Link)](youtube link)

### Xcode

Integrate HIPAAChecker-xPlugin into your Xcode project to get HIPAA rules maintained or not.

> warning: HIPAAChecker not installed, download from link

Add HIPAAChecker as a package dependency to your project without linking any of the
products.

Select the target you want to add checking to and open the `Build Phases` inspector.
Open `Run Build Tool Plug-ins` and select the `+` button.
Select `HIPAACheckerPlugin` from the list and add it to the project.


#### Swift Package

You can integrate HIPAAChecker as a Swift Package Manager Plug-in if you're working with
a Swift Package with a `Package.swift` manifest.

Add HIPAAChecker as a package dependency to your `Package.swift` file.  
Add HIPAAChecker to a target using the `plugins` parameter.

```swift
.dependencies: [
        .package(url: "https://github.com/HIPAACKR/HIPAAChecker-xPlugin", from: "1.0.0"),
.target(
    ...
    plugins: [.plugin(name: "HIPAAChecker-xPlugin", package: "HIPAAChecker-xPlugin")]
),
```


## Rules

Over 11 rules are included in HIPAAChecker 
[Pull requests](link) are encouraged.

You can find an updated list of rules and more information about them
[here](https://hipaachecker.health/user_guides).



## License

[Licensed.](https://hipaachecker.health/)

## About

<img src="link" width="184" />

HIPAAChecker-xPlugin is maintained and funded by Ubitrics Inc. The names and logos for
HIPAAChecker-xPlugin are trademarks of Ubitrics Inc.

<img src="link" width="184" />

Our thanks to team for providing a Mac Mini to run our performance
