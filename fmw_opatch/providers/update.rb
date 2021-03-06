#
# Cookbook Name:: fmw_opatch
# Provider:: opatch
#
# Copyright 2015 Oracle. All Rights Reserved
#
# opatch provider for unix
provides :fmw_opatch_update, os: [ 'linux', 'solaris2'] if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_opatch_update').new(new_resource.name)
  @current_resource.version(@new_resource.version)
  @current_resource.patch_id(@new_resource.patch_id)
  @current_resource.oracle_home_dir(@new_resource.oracle_home_dir)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.orainst_dir(@new_resource.orainst_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = false
  shell_out!("su - #{@new_resource.os_user} -c '#{@new_resource.oracle_home_dir}/OPatch/opatch version").stdout.each_line do |line|
    unless line.nil?
      opatch = line[line.index(':')..-1].strip if line['OPatch Version']
      unless opatch.nil?
        if opatch.include? @new_resource.version
          @current_resource.exists = true
        end
      end
    end
  end

  @current_resource
end

# opatch apply on a unix host
action :apply do
  Chef::Log.info("#{@new_resource} fired the apply action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already patched")
  else
    converge_by("Create resource #{ @new_resource }") do
      result = false
      shell_out!("su - #{@new_resource.os_user} -c #{@new_resource.java_home_dir}/bin/java -jar #{@new_resource.tmp_dir}\\#{@new_resource.patch_id}\\opatch_generic.jar -silent oracle_home=#{@new_resource.oracle_home_dir}", :timeout => 1200).stdout.each_line do |line|
        unless line.nil?
          Chef::Log.info(line)
          if line.include? 'The install operation completed successfully.'
            result = true
          end
        end
      end
      fail if result == false

      new_resource.updated_by_last_action(true)
    end
  end
end