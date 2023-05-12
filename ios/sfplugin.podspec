#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'salesforceplugin'
  s.version          = '11.0.0'
  s.summary          = 'Flutter plugin for the Salesforce Mobile SDK.'
  s.description      = 'Flutter plugin for the Salesforce Mobile SDK.'
  s.homepage         = "https://github.com/forcedotcom/SalesforceMobileSDK-iOS.git"
  s.license          = { :type => "Salesforce.com Mobile SDK License", :file => "../LICENSE.md" }
  s.author           = { "Wolfgang Mathurin" => "wmathurin@salesforce.com" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'SmartSync'
  s.dependency 'SmartStore'
  s.dependency 'SalesforceSDKCore'
  s.dependency 'SalesforceAnalytics'

  s.ios.deployment_target = '11.0'
end

