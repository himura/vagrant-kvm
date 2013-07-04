module VagrantPlugins
  module ProviderKvm
    module Action
      class MatchMACAddress
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if env[:machine].provider_config.ignore_base_mac
            env[:machine].provider.driver.clear_mac_address

          else
            raise Vagrant::Errors::VMBaseMacNotSpecified if !env[:machine].config.vm.base_mac

            # Create the proc which we want to use to modify the virtual machine
            env[:ui].info I18n.t("vagrant.actions.vm.match_mac.matching")
            env[:machine].provider.driver.set_mac_address(env[:machine].config.vm.base_mac)
          end

          @app.call(env)
        end
      end
    end
  end
end
