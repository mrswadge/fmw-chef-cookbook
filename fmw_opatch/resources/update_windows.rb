# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_opatch
# Resource:: opatch
#
provides :fmw_opatch_update, os: 'windows'

# apply or rollback the patch
actions :apply, :rollback

# Make create the default action
default_action :apply

# Opatch version
attribute :version, kind_of: String, required: true
# Opatch patch id
attribute :patch_id, kind_of: String, required: true, name_attribute: true
# Oracle home folder
attribute :oracle_home_dir, kind_of: String, required: true
# Java home folder
attribute :java_home_dir, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :patch_id, :oracle_home_dir, :java_home_dir, :tmp_dir

attr_accessor :exists
