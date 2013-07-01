module VagrantPlugins
  module ProviderKvm
    module Action
      class MatchMACAddress
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if env[:machine].provider_config.use_base_mac
            raise Vagrant::Errors::VMBaseMacNotSpecified if !env[:machine].config.vm.base_mac

            # Create the proc which we want to use to modify the virtual machine
            env[:ui].info I18n.t("vagrant.actions.vm.match_mac.matching")
            env[:machine].provider.driver.set_mac_address(env[:machine].config.vm.base_mac)
          else
            mac = generate_mac
            # @logger.info("Setting the MAC address of the VM: #{mac}")
            env[:machine].provider.driver.set_mac_address(mac)
          end

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

        def generate_mac
          format_mac("5253" + SecureRandom.random_bytes(4).unpack('h*').first)
        end
      end
    end
  end
end
