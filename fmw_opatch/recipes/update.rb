#
# Cookbook Name:: fmw_opatch
# Recipe:: update_opatch
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_opatch attributes cannot be empty' unless node.attribute?('fmw_opatch')
fail 'source_file parameter cannot be empty' unless node['fmw_opatch'].attribute?('opatch_source_file')
fail 'patch_id parameter cannot be empty' unless node['fmw_opatch'].attribute?('opatch_patch_id')
fail 'version parameter cannot be empty' unless node['fmw_opatch'].attribute?('opatch_version')

if ['10.3.6', '12.1.1'].include?(node['fmw']['version'])
  return
else
  fmw_oracle_home = node['fmw']['middleware_home_dir']
end

fmw_opatch_fmw_extract node['fmw_opatch']['opatch_patch_id'] do
  action              :extract
  source_file         node['fmw_opatch']['opatch_source_file']
  os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
  os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
  tmp_dir             node['fmw']['tmp_dir']
  middleware_home_dir node['fmw']['middleware_home_dir'] if node['os'].include?('windows')
  java_home_dir       node['fmw']['java_home_dir']       if node['os'].include?('windows')
  version             node['fmw']['version']             if node['os'].include?('windows')
end

fmw_opatch_update node['fmw_opatch']['opatch_patch_id'] do
  action              :apply
  version             node['fmw_opatch']['opatch_version']
  patch_id            node['fmw_opatch']['opatch_patch_id']
  oracle_home_dir     fmw_oracle_home
  java_home_dir       node['fmw']['java_home_dir']
  orainst_dir         node['fmw']['orainst_dir']         if ['solaris2', 'linux'].include?(node['os'])
  os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
  os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
  tmp_dir             node['fmw']['tmp_dir']
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
