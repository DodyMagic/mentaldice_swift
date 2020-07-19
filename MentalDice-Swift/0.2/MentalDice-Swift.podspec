#
# Be sure to run `pod lib lint MentalDice-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'MentalDice-Swift'
  s.version               = '0.2'
  s.summary               = 'Swift frameworks to communicate with Marc Antoine\'s Mental Dice'
  s.homepage              = 'https://dodymagic.com'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Guillaume Bellut' => 'guillaume@bellut.com' }
  s.source                = { :git => 'https://github.com/DodyMagic/mentaldice_swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files          = 'MentalDiceFramework/**/*'
  s.swift_versions        = ['5.0']
  s.exclude_files         = 'MentalDiceFramework/Info.plist'
end
