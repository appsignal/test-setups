
Vagrant.configure("2") do |config|
  config.vm.define "freebsd" do |freebsd|
    freebsd.vm.box = "bento/freebsd-14"
    freebsd.vm.guest = :freebsd
    freebsd.vm.network "private_network", type: "dhcp"
    freebsd.vm.synced_folder "./elixir/phoenix/app", "/app", type: "rsync",
      rsync__exclude: [".git/", "node_modules/", "_build/", "deps/"]
    freebsd.vm.synced_folder "./elixir/integration", "/integration", type: "rsync",
      rsync__exclude: [".git/", "_build/", "deps/"]

    freebsd.vm.provider "virtualbox" do |vb|
      vb.check_guest_additions = false
    end

    freebsd.vm.provider "utm" do |u|
      u.name = "freebsd"
      u.cpus = 2
      u.memory = 2048
      u.icon = "freebsd"
      #u.directory_share_mode = "webDAV"
      u.check_guest_additions = false
    end
    freebsd.ssh.shell = "sh"

    freebsd.vm.hostname = "freebsd"
    freebsd.vm.network "private_network", ip: "192.168.56.12"
    freebsd.vm.network "forwarded_port", guest: 4001, host: 4001
    freebsd.vm.provision "shell", inline: <<-SHELL
      echo test >> ~/testado
      sed  -e 's/\#DEFAULT_ALWAYS_YES = false/DEFAULT_ALWAYS_YES = true/g' -e 's/\#ASSUME_ALWAYS_YES = false/ASSUME_ALWAYS_YES = true/g' /usr/local/etc/pkg.conf > /tmp/pkg.conf
      mv -f /tmp/pkg.conf /usr/local/etc/pkg.conf
      pkg install gcc gmake openssl automake libtool wget python3 gmake lftp vim ruby-build elixir postgresql16-server postgresql16-client git
      echo 'eval "$(rbenv init -)"' > ~/.bashrc

      # Set up PostgreSQL
      sysrc postgresql_enable="YES"
      service postgresql initdb
      service postgresql start

      # Create database user and database
      su -m postgres -c "createuser -s vagrant" || true
      su -m vagrant -c "createdb phoenix_dev" || true
    SHELL
  end
end
