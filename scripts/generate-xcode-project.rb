#!/usr/bin/env ruby
require 'xcodeproj'
require 'json'
require 'fileutils'

root = File.expand_path('..', __dir__)
Dir.chdir(root)
project = Xcodeproj::Project.new('Brighter.xcodeproj')
project.root_object.attributes['LastUpgradeCheck'] = '2700'
project.root_object.development_region = 'en'
project.root_object.known_regions = %w[en tr Base]
project.build_configurations.each do |config|
  config.build_settings.merge!({ 'SWIFT_VERSION' => '6.0', 'MACOSX_DEPLOYMENT_TARGET' => '14.0', 'ARCHS' => 'arm64', 'ONLY_ACTIVE_ARCH' => 'NO' })
end

core = project.new_target(:static_library, 'BrighterCore', :osx, '14.0')
core_group = project.main_group.new_group('BrighterCore', 'Sources/BrighterCore')
core.add_file_references(Dir['Sources/BrighterCore/*.swift'].map { |file| core_group.new_file(File.basename(file)) })
core.build_configurations.each do |config|
  config.build_settings.merge!({ 'PRODUCT_MODULE_NAME' => 'BrighterCore', 'DEFINES_MODULE' => 'YES', 'SKIP_INSTALL' => 'YES', 'CODE_SIGNING_ALLOWED' => 'NO' })
end

app = project.new_target(:application, 'Brighter', :osx, '14.0')
source_group = project.main_group.new_group('Brighter', 'Sources/Brighter')
app.add_file_references(Dir['Sources/Brighter/*.swift'].map { |file| source_group.new_file(File.basename(file)) })
app.add_dependency(core)
app.frameworks_build_phase.add_file_reference(core.product_reference)
resources = project.main_group.new_group('Resources', 'Resources')
%w[Brighter.icns PrivacyInfo.xcprivacy].each do |file|
  app.resources_build_phase.add_file_reference(resources.new_file(file))
end
strings = resources.new_variant_group('Localizable.strings')
%w[en tr].each { |lang| strings.new_file("#{lang}.lproj/Localizable.strings").name = lang }
app.resources_build_phase.add_file_reference(strings)
app.build_configurations.each do |config|
  config.build_settings.merge!({
    'PRODUCT_BUNDLE_IDENTIFIER' => 'com.developcu.brighter',
    'PRODUCT_NAME' => 'Brighter', 'MARKETING_VERSION' => '1.0.0', 'CURRENT_PROJECT_VERSION' => '2',
    'INFOPLIST_FILE' => 'Resources/Info-AppStore.plist', 'GENERATE_INFOPLIST_FILE' => 'NO',
    'CODE_SIGN_STYLE' => 'Automatic', 'DEVELOPMENT_TEAM' => 'QN7J224TVJ',
    'CODE_SIGN_ENTITLEMENTS' => 'Resources/Brighter.entitlements',
    'ENABLE_APP_SANDBOX' => 'YES', 'ENABLE_HARDENED_RUNTIME' => 'YES',
    'SWIFT_EMIT_LOC_STRINGS' => 'YES', 'SKIP_INSTALL' => 'NO',
    'COMBINE_HIDPI_IMAGES' => 'YES'
  })
end
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.set_launch_target(app)
scheme.save_as('Brighter.xcodeproj', 'Brighter', true)
puts 'Generated Brighter.xcodeproj'
