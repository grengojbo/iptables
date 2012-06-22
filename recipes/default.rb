#
# Cookbook Name:: iptables
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
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

package "iptables"

execute "rebuild-iptables" do
  command "/usr/sbin/rebuild-iptables"
  action :nothing
end

directory "/etc/iptables.d" do
  action :create
end

cookbook_file "/usr/sbin/rebuild-iptables" do
  source "rebuild-iptables"
  mode 0755
end

case node[:platform]
when "ubuntu", "debian"
  iptables_save_file = "/etc/iptables/general"

  template "/etc/network/if-pre-up.d/iptables_load" do
    source "iptables_load.erb"
    mode 0755
    variables :iptables_save_file => iptables_save_file
  end
end

if node["iptables"]["install_rules"]
  iptables_rule "all"
  iptables_rule "all_established"
  iptables_rule "limit_icmp"
  iptables_rule "logged"
end

if node["iptables"]["ssh"] == "all"
  iptables_rule "ssh"
end

if node.run_list.include?("role[freeswitch]")
  iptables_rule "freeswitch"
end

if node.run_list.include?("role[opensips]")
  iptables_rule "opensips"
end

if node["iptables"]["logged"]
  iptables_rule "logged"
end