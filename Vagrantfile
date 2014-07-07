# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version "~> 1.6.3"

REQUIRE_PLUGINS=[
  "vagrant-omnibus",
  "vagrant-vbguest",
  "vagrant-hostsupdater",
  #プラグインのバージョン'>= 2.0.1'をみていない
  "vagrant-berkshelf"
]
#自分でプラグインチェック。require_pluginがVagrantで廃止の方向らしいので。
REQUIRE_PLUGINS.each do |plugin_name|
  if Vagrant.has_plugin?(plugin_name)
    puts "[#{plugin_name}] installed."
  else
    raise Vagrant::Errors::VagrantError.new,
    "Install [#{plugin_name}]!\n"
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #11.10.4で固定しているのは、現状AWS OpsworksのChefが11.4か11.10のサポートで、11.10はRuby 2.0対応らしいので。
  config.omnibus.chef_version = "11.10.4"
  config.hostsupdater.remove_on_suspend = true
  config.berkshelf.enabled = true

  CHEF_NODES_PATH=File.dirname(__FILE__) + "/nodes/"
  CHEF_COOKBOOKS_PATH=File.dirname(__FILE__) + "/cookbooks/"
  CHEF_SITE_COOKBOOKS_PATH=File.dirname(__FILE__) + "/site-cookbooks/"
  CHEF_DATA_BAGS_PATH=File.dirname(__FILE__) + "/data_bags/"
  CHEF_ROLES_PATH=File.dirname(__FILE__) + "/roles/"
  CHEF_ENVIRONMENTS_PATH=File.dirname(__FILE__) + "/environments/"
  #nodes/*.jsonのファイルを起動できるようにRubyで定義したサーバーファイルを起動する
  Dir::glob("#{CHEF_NODES_PATH}*.json").each do |file|
    vagrant_json = JSON.parse(File.read(file))
    config.vm.define vagrant_json["name"] do |node|
      #vagrant cloudに公開されているubuntu14.04のbox
      node.vm.box = "ubuntu/trusty64"
      #Vagrant1.5以上で提供されているrsyncオプションはvirtulboxの共有フォルダオプションより安定してて便利
      node.vm.synced_folder "./", "/vagrant", type:"rsync", rsync__exclude:["*"]
      #nodes/*.jsonで指定した名前を/etc/hostsに指定させることでローカルでも名前アクセス可能に
      node.vm.hostname = vagrant_json["fqdn"]
      #一人開発環境であればプライベートネットワーク内で構築したほうがわかりやすいです。
      node.vm.network :private_network, ip: vagrant_json["ipaddress"]
      #ここからは少しRubyを使ってnodes/*.jsonをchefっぽく動くように読み込み
      node.vm.provision :chef_solo do |chef|
        chef.synced_folder_type="rsync"
        chef.cookbooks_path = Array.new()
        if File.directory?(CHEF_COOKBOOKS_PATH) then
          chef.cookbooks_path.push(CHEF_COOKBOOKS_PATH)
        end
        if File.directory?(CHEF_SITE_COOKBOOKS_PATH) then
          chef.cookbooks_path.push(CHEF_SITE_COOKBOOKS_PATH)
        end
        if File.directory?(CHEF_ENVIRONMENTS_PATH) then
          chef.environments_path = CHEF_ENVIRONMENTS_PATH
        end
        if File.directory?(CHEF_DATA_BAGS_PATH) then
          chef.data_bags_path = CHEF_DATA_BAGS_PATH
        end
        if File.directory?(CHEF_ROLES_PATH) then
          chef.roles_path = CHEF_ROLES_PATH
        end

        chef_run_list = vagrant_json.delete('run_list')
        if chef_run_list.instance_of?(Array) then
          chef.run_list = chef_run_list
        end
        chef_environment=vagrant_json.delete('environment')
        if chef_run_list.instance_of?(String) then
          chef.environment=chef_environment
        end
        chef.json = vagrant_json
      end
    end
  end
end
