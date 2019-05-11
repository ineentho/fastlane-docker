# fastlane-docker

`ineentho/fastlane-docker` is a Docker image that comes with both fastlane and the apple iTMSTransporter preinstalled. That makes most fastlane features available, including uploading compiled iOS apps (.ipa's) from a linux container.

This is accomplished by using an older version of iTMSTransporter found in the windows installer. Read more about the challenges of uploading iOS apps on linux here at [fastlane#14256](https://github.com/fastlane/fastlane/issues/14256).

The buildt image is available as [ineentho/fastlane-docker](https://hub.docker.com/r/ineentho/fastlane-docker).
