#!/usr/bin/env ruby
# Adds the Apple Watch app (WaqtWatch, watchOS 10+) and its complications
# extension (WaqtWatchWidgets) to ios/Runner.xcodeproj, embeds the watch app
# in Runner ("Embed Watch Content"), and adds the shared Swift sources:
#   ios/Shared/WaqtTimes.swift   → WaqtWidget, WaqtWatch, WaqtWatchWidgets
#   ios/WatchShared/*.swift      → WaqtWatch, WaqtWatchWidgets
#   ios/Runner/WatchBridge.swift, QuickActions.swift → Runner
# Idempotent: every step checks whether it already happened.
#
#   GEM_HOME=$(brew --prefix)/Cellar/cocoapods/<ver>/libexec \
#     ruby tool/ios/add_watch_targets.rb ios/Runner.xcodeproj
require 'xcodeproj'

proj_path = ARGV[0] or abort 'usage: add_watch_targets.rb path/to/Runner.xcodeproj'
project = Xcodeproj::Project.open(proj_path)

runner = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'
widget = project.targets.find { |t| t.name == 'WaqtWidget' } or abort 'run add_widget_target.rb first'
team = runner.build_configurations.first.build_settings['DEVELOPMENT_TEAM']
generated = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' }

def group_for(project, name)
  project.main_group.children.find { |g| g.display_name == name && g.is_a?(Xcodeproj::Project::Object::PBXGroup) } ||
    project.main_group.new_group(name, name)
end

def file_in(group, path)
  group.files.find { |f| f.path == path } || group.new_reference(path)
end

def add_source(target, ref)
  return if target.source_build_phase.files_references.include?(ref)
  target.source_build_phase.add_file_reference(ref)
end

def add_resource(target, ref)
  return if target.resources_build_phase.files_references.include?(ref)
  target.resources_build_phase.add_file_reference(ref)
end

# new_target links Foundation by a versioned SDK path; Swift auto-links it.
def drop_foundation(project, target)
  target.frameworks_build_phase.files.dup.each do |bf|
    ref = bf.file_ref
    next unless ref && ref.path.to_s.end_with?('Foundation.framework')
    target.frameworks_build_phase.remove_build_file(bf)
    parent = ref.parent
    ref.remove_from_project
    parent.remove_from_project if parent.is_a?(Xcodeproj::Project::Object::PBXGroup) &&
                                  parent.children.empty? && parent != project.frameworks_group
  end
end

def ensure_configs(project, target)
  project.build_configurations.each do |pc|
    next if target.build_configurations.any? { |c| c.name == pc.name }
    base = target.build_configurations.find { |c| c.name == 'Release' }
    c = target.add_build_configuration(pc.name, :release)
    c.build_settings = base.build_settings.dup
  end
end

def configure(target, generated, team, settings)
  target.build_configurations.each do |c|
    c.base_configuration_reference = generated if generated
    s = c.build_settings
    s['PRODUCT_NAME'] = '$(TARGET_NAME)'
    s['CODE_SIGN_STYLE'] = 'Automatic'
    s['DEVELOPMENT_TEAM'] = team if team
    s['SDKROOT'] = 'watchos'
    # Flutter's project-level Release/Profile pin this to iphoneos.
    s['SUPPORTED_PLATFORMS'] = 'watchos watchsimulator'
    s['WATCHOS_DEPLOYMENT_TARGET'] = '10.0'
    s['TARGETED_DEVICE_FAMILY'] = '4'
    s['SWIFT_VERSION'] = '5.0'
    s['SKIP_INSTALL'] = 'YES'
    s['GENERATE_INFOPLIST_FILE'] = 'NO'
    s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
    s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
    s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
    s.delete('IPHONEOS_DEPLOYMENT_TARGET')
    if c.name == 'Debug'
      s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
      s['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    else
      s['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      s['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
    end
    settings.each { |k, v| s[k] = v }
  end
end

def embed_phase(project, target, name, spec, dst_path)
  phase = target.copy_files_build_phases.find { |p| p.name == name }
  return phase if phase
  phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  phase.name = name
  phase.symbol_dst_subfolder_spec = spec
  phase.dst_path = dst_path
  phases = target.build_phases
  idx = phases.index { |p| p.respond_to?(:name) && p.name == 'Embed Frameworks' } ||
        phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } ||
        phases.length
  phases.insert(idx, phase)
  phase
end

def embed(phase, product)
  return if phase.files_references.include?(product)
  bf = phase.add_file_reference(product, true)
  bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

attrs = project.root_object.attributes['TargetAttributes'] ||= {}

# --- Shared sources ----------------------------------------------------------
shared = group_for(project, 'Shared')
times = file_in(shared, 'WaqtTimes.swift')
add_source(widget, times)

runner_group = project.main_group.children.find { |g| g.display_name == 'Runner' }
add_source(runner, file_in(runner_group, 'WatchBridge.swift'))
add_source(runner, file_in(runner_group, 'QuickActions.swift'))

watch_shared = group_for(project, 'WatchShared')
watch_data = file_in(watch_shared, 'WatchData.swift')

# --- Complications extension -------------------------------------------------
widgets = project.targets.find { |t| t.name == 'WaqtWatchWidgets' }
unless widgets
  widgets = project.new_target(:app_extension, 'WaqtWatchWidgets', :watchos, '10.0', nil, :swift)
  drop_foundation(project, widgets)
  attrs[widgets.uuid] = { 'CreatedOnToolsVersion' => '16.0' }
end
ensure_configs(project, widgets)
configure(widgets, generated, team,
          'PRODUCT_BUNDLE_IDENTIFIER' => 'tm.ofis.waqt.watchkitapp.widgets',
          'INFOPLIST_FILE' => 'WaqtWatchWidgets/Info.plist',
          'CODE_SIGN_ENTITLEMENTS' => 'WaqtWatchWidgets/WaqtWatchWidgets.entitlements',
          'APPLICATION_EXTENSION_API_ONLY' => 'YES',
          'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks',
                                        '@executable_path/../../Frameworks'])
wgroup = group_for(project, 'WaqtWatchWidgets')
add_source(widgets, file_in(wgroup, 'WaqtWatchWidgets.swift'))
file_in(wgroup, 'Info.plist')
file_in(wgroup, 'WaqtWatchWidgets.entitlements')
add_source(widgets, times)
add_source(widgets, watch_data)

# --- Watch app ---------------------------------------------------------------
watch = project.targets.find { |t| t.name == 'WaqtWatch' }
unless watch
  watch = project.new_target(:application, 'WaqtWatch', :watchos, '10.0', nil, :swift)
  drop_foundation(project, watch)
  attrs[watch.uuid] = { 'CreatedOnToolsVersion' => '16.0' }
end
ensure_configs(project, watch)
configure(watch, generated, team,
          'PRODUCT_BUNDLE_IDENTIFIER' => 'tm.ofis.waqt.watchkitapp',
          'INFOPLIST_FILE' => 'WaqtWatch/Info.plist',
          'CODE_SIGN_ENTITLEMENTS' => 'WaqtWatch/WaqtWatch.entitlements',
          'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
          'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
          'ENABLE_PREVIEWS' => 'YES',
          'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks'])
group = group_for(project, 'WaqtWatch')
%w[WaqtWatchApp.swift WatchStore.swift HomeView.swift TasbihView.swift QiblaView.swift AdhkarView.swift]
  .each { |f| add_source(watch, file_in(group, f)) }
file_in(group, 'Info.plist')
file_in(group, 'WaqtWatch.entitlements')
add_resource(watch, file_in(group, 'Assets.xcassets'))
add_source(watch, times)
add_source(watch, watch_data)
# Bundled straight from the Flutter assets, so there is one source of truth.
add_resource(watch, file_in(group, '../../assets/adhkar/adhkar.json'))
add_resource(watch, file_in(group, '../../assets/fonts/Amiri-Regular.ttf'))

watch.add_dependency(widgets) unless watch.dependencies.any? { |d| d.target == widgets }
embed(embed_phase(project, watch, 'Embed Foundation Extensions', :plug_ins, ''), widgets.product_reference)

# --- Embed in Runner -----------------------------------------------------------
runner.add_dependency(watch) unless runner.dependencies.any? { |d| d.target == watch }
embed(embed_phase(project, runner, 'Embed Watch Content', :products_directory, '$(CONTENTS_FOLDER_PATH)/Watch'),
      watch.product_reference)

project.save
puts 'Targets: ' + project.targets.map(&:name).join(', ')
puts 'Runner phases: ' + runner.build_phases.map(&:display_name).join(' -> ')
puts 'WaqtWatch phases: ' + watch.build_phases.map(&:display_name).join(' -> ')
