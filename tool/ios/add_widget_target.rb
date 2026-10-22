#!/usr/bin/env ruby
# Adds the WaqtWidget WidgetKit extension target to ios/Runner.xcodeproj
# and embeds it in Runner. Idempotent: exits early if the target exists.
require 'xcodeproj'

proj_path = ARGV[0] or abort 'usage: add_widget_target.rb path/to/Runner.xcodeproj'
project = Xcodeproj::Project.open(proj_path)

name = 'WaqtWidget'
if project.targets.any? { |t| t.name == name }
  puts "#{name} target already exists; nothing to do."
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'
team = runner.build_configurations.first.build_settings['DEVELOPMENT_TEAM']

# --- Target -----------------------------------------------------------------
widget = project.new_target(:app_extension, name, :ios, '15.0', nil, :swift)

# new_target links Foundation via a versioned SDK path (iPhoneOSxx.x.sdk) that
# breaks on other Xcode versions; Swift auto-links it, so drop the reference.
widget.frameworks_build_phase.files.dup.each do |bf|
  ref = bf.file_ref
  next unless ref && ref.path.to_s.end_with?('Foundation.framework')
  widget.frameworks_build_phase.remove_build_file(bf)
  parent = ref.parent
  ref.remove_from_project
  parent.remove_from_project if parent.is_a?(Xcodeproj::Project::Object::PBXGroup) &&
                                parent.children.empty? && parent != project.frameworks_group
end

# Make sure there is a config for every project config (Debug/Release/Profile).
project.build_configurations.each do |pc|
  next if widget.build_configurations.any? { |c| c.name == pc.name }
  base = widget.build_configurations.find { |c| c.name == 'Release' }
  c = widget.add_build_configuration(pc.name, :release)
  c.build_settings = base.build_settings.dup
end

# --- Files ------------------------------------------------------------------
group = project.main_group.new_group(name, name)
swift = group.new_reference('WaqtWidget.swift')
group.new_reference('Info.plist')
group.new_reference('WaqtWidget.entitlements')
widget.source_build_phase.add_file_reference(swift)

# Live Activity attributes are compiled into both the app and extension.
shared = project.main_group.new_group('Shared', 'Shared')
activity_attributes = shared.new_reference('PrayerActivityAttributes.swift')
widget.source_build_phase.add_file_reference(activity_attributes)
runner.source_build_phase.add_file_reference(activity_attributes)

%w[WidgetKit SwiftUI ActivityKit].each do |fw|
  ref = project.frameworks_group.new_file("System/Library/Frameworks/#{fw}.framework", :sdk_root)
  widget.frameworks_build_phase.add_file_reference(ref, true)
end

# Generated.xcconfig provides FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER so the
# extension version always matches the app (no Pods settings leak in).
generated = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' }

widget.build_configurations.each do |c|
  c.base_configuration_reference = generated if generated
  s = c.build_settings
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'tm.ofis.waqt.WaqtWidget'
  s['INFOPLIST_FILE'] = 'WaqtWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS'] = 'WaqtWidget/WaqtWidget.entitlements'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['DEVELOPMENT_TEAM'] = team if team
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SWIFT_VERSION'] = '5.0'
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks',
                                  '@executable_path/../../Frameworks']
  if c.name == 'Debug'
    s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
    s['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  else
    s['SWIFT_COMPILATION_MODE'] = 'wholemodule'
    s['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
  end
end

attrs = project.root_object.attributes['TargetAttributes'] ||= {}
attrs[widget.uuid] = { 'CreatedOnToolsVersion' => '16.0' }

# --- Embed in Runner --------------------------------------------------------
runner.add_dependency(widget)
embed = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
embed.name = 'Embed Foundation Extensions'
embed.symbol_dst_subfolder_spec = :plug_ins
embed.dst_path = ''
bf = embed.add_file_reference(widget.product_reference, true)
bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Must run before Flutter's "Thin Binary" script, otherwise Xcode reports
# "Cycle inside Runner; building could produce unreliable results".
phases = runner.build_phases
idx = phases.index { |p| p.respond_to?(:name) && p.name == 'Embed Frameworks' } ||
      phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } ||
      phases.length
phases.insert(idx, embed)

project.save
puts "Added #{name} target (configs: #{widget.build_configurations.map(&:name).join(', ')})"
puts 'Runner phases: ' + runner.build_phases.map(&:display_name).join(' -> ')
