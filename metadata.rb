name "db-study"
maintainer "高津英輔"
maintainer_email "eisuke@kozu.in"
license "Apache 2.0"
description "DBサーバー構築勉強用"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version "0.0.1"

%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end

depends "apt", ">= 1.9.0"
depends "build-essential"
depends "openssl"
