
Pod::Spec.new do |spec|

  spec.name         = "HJBaseTableView"
  spec.version      = "0.0.1"
  spec.summary      = "Modules and components framework for iOS."
  spec.authors      = { 'HJ' => '2033253382@qq.com' }  
  spec.description  = <<-DESC
	一个简单的TableView 内部采用了 FDTemplateLayoutCell 计算和缓存高度。
                   DESC

  spec.homepage     = "https://github.com/whhaijun/HJBaseTableView"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/whhaijun/HJBaseTableView.git", :tag => spec.version }


  spec.source_files  = "HJBaseTableView/HJBaseTableView/**/*"

  #spec.public_header_files = "HJBaseTableView/HJBaseTableView/**/*.h"


  spec.swift_version = '4.0'
  spec.static_framework  =  true
  spec.requires_arc = true

  spec.dependency 'UITableView+FDTemplateLayoutCell', '1.6'

end
