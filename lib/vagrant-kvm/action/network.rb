require "log4r"

module VagrantPlugins
  module ProviderKvm
    module Action
      # This middleware class configures networking
      class Network

        def initialize(app, env)
          @logger = Log4r::Logger.new("vagrant::plugins::kvm::network")
          @app    = app
        end

        def call(env)
          # TODO: Validate network configuration prior to anything below
          @env = env

          options = nil
          env[:machine].config.vm.networks.each do |type, network_options|
            options = network_options if type == :private_network
          end

          if options.has_key?(:ip)
            addr = options[:ip].split(".")
            addr[3] = "1"
            base_ip = addr.join(".")
            addr[3] = "100"
            start_ip = addr.join(".")
            addr[3] = "200"
            end_ip = addr.join(".")
            range = {
              :start => start_ip,
              :end   => end_ip }
            options = {
              :base_ip => base_ip,
              :netmask => "255.255.255.0",
              :range   => range
            }.merge(options)
          end

          hosts = []
          name = env[:machine].provider_config.name ?
                      env[:machine].provider_config.name : "default"

          mac = env[:machine].provider.driver.read_mac_address
          @logger.info("Setting the MAC address of the VM: #{mac}")

          hosts << {
            :mac => format_mac(mac),
            :name => name,
            :ip => options[:ip]
          }
          options[:hosts] = hosts

          env[:ui].info I18n.t("vagrant.actions.vm.network.preparing")
          env[:machine].provider.driver.create_network(options)

          @app.call(env)
        end

        def format_mac(mac)
          if mac.length == 12
            mac = mac[0..1] + ":" + mac[2..3] + ":" +
              mac[4..5] + ":" + mac[6..7] + ":" +
              mac[8..9] + ":" + mac[10..11]
          end
          mac
        end

      end
    end
  end
end
