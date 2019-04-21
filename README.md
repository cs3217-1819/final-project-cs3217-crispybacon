# Bacon
[![Build Status](https://travis-ci.com/cs3217-crispybacon/bacon.svg?branch=master)](https://travis-ci.com/cs3217-crispybacon/bacon)

## Developer Guide
### Getting started
1. `git clone` the repository
2. Ensure that your `cocoapods` is at least version 1.6.1 (check with `pod --version`)
3. Update your local specs repo: `pod repo update`
4. Install project pods: `pod install`

Note: The `Pods/` directory will be gitignore-d.

5. Finally, edit `bacon/commons/Constants.swift` line 169 (`static let LocationPromptGooglePlacesApiKey = "PLACEHOLDER"`) and replace with the API key. This is required to load the heatmap.

### Logging
This project uses the SwiftyBeaver framework.
Logger setup can be found in `AppDelegate.swift`. 

#### Levels
SwiftyBeaver provides 5 levels of logging in ascending order of priority:
* verbose
* debug
* info
* warning
* error

See https://github.com/SwiftyBeaver/SwiftyBeaver

#### Consistency
To ensure consistency in logging, this may serve as a guide:
* Use `log.info()` as the default log operation (e.g. when entering a method)
* To indicate the start of a method call, use `<Class/Struct>.<methodName>() ...`,
e.g. `Transaction.init() with the following arguments ...`

## Design

![Class-Diagram](/class-diagram.png)
