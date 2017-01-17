#
# Be sure to run `pod lib lint PDFDrumKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PDFDrumKit'
  s.version          = '0.1.4'
  s.summary          = 'A short description of PDFDrumKit.'

  s.homepage         = 'https://github.com/pencildrummer/PDFDrumKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fabio Borella' => 'info@pencildrummer.com' }
  s.source           = { :git => 'https://github.com/pencildrummer/PDFDrumKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PDFDrumKit/Classes/**/*'

end
