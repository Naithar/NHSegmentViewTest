Pod::Spec.new do |s|
s.name             = "NHSegmentView"
s.version          = "0.0.1"
s.summary          = "Custom segment view"
s.license          = 'MIT'
s.author           = { "Naithar" => "devias.naith@gmail.com" }
s.source           = { :git => "https://github.com/naithar/NHSegmentViewTest.git", :tag => s.version.to_s }
s.platform     = :ios, '7.0'
s.requires_arc = true

s.source_files = 'NHSegmentViewTest/NHSegmentView.{h,m}', 'NHSegmentViewTest/NHTextLayer.{h,m}'

s.public_header_files = 'NHSegmentViewTest/NHSegmentView.h', 'NHSegmentViewTest/NHTextLayer.h'

end