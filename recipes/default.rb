#
# Author:: Joshua Timberman (<jtimberman@opscode.com>)
# Author:: Graeme Mathieson (<mathie@woss.name>)
# Cookbook Name:: homebrewalt
# Recipes:: default
#
# Copyright 2011-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory "/usr/local" do
  owner node['current_user']
  recursive true
end

homebrew_go = "#{Chef::Config[:file_cache_path]}/homebrew_go"

remote_file homebrew_go do
  source 'https://raw.github.com/Homebrew/homebrew/go/install'
  mode 00755
end

execute homebrew_go do
  command "sudo -u #{node['current_user']} #{homebrew_go}"
  user node['current_user']
  not_if { ::File.exist? '/usr/local/bin/brew' }
end

package 'git' do
  not_if 'which git'
end

homebrewalt_tap 'phinze/cask'
homebrewalt_tap 'caskroom/versions'

directory "/opt/homebrew-cask/Caskroom" do
    user node['current_user']
    mode 00755
    recursive true
end

package "brew-cask" do
  options "--HEAD"
end

execute 'update homebrew from github' do
  user node['current_user']
  command "sudo -u #{node['current_user']} /usr/local/bin/brew update || true"
end

node['homebrewalt']['tap'].each do |taps|
  homebrewalt_tap taps
end

node['homebrewalt']['cask_apps'].each do |app|
  homebrewalt_cask app
end

node['homebrewalt']['apps'].each do |app|
  package app
end
