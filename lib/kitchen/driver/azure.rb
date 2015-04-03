# -*- encoding: utf-8 -*-
#
# Author:: Grant Ellis (<grant.ellis@marks-and-spencer.com>)
#
# Copyright (C) 2014, Grant Ellis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'azure'
require 'securerandom'
require 'openssl'
require 'nokogiri'
require 'kitchen'
require 'kitchen/transport/ssh'

module Kitchen

  module Transport
    class Connection < Kitchen::Transport::Base::Connection
      # Redefine login_command for use with putty
      def login_command
         super

         args = %W[ #{username}@#{hostname} ]

         LoginCommand.new("putty", args)
      end
    end
  end

  module Driver

    # Azure driver for Kitchen.
    #
    # @author Grant Ellis <grant.ellis@marks-and-spencer.com>
    class Azure < Kitchen::Driver::SSHBase

      AZURE_MANAGEMENT_ENDPOINT='https://management.core.windows.net'
      default_config :port, 2222
      default_config :username, 'azureuser'
      default_config :location, 'East US'
      default_config :size, 'Small'
      default_config :publish_settings_file do |driver|
        ENV['PUBLISH_SETTINGS_FILE']
      end
      default_config :subscription do |driver|
        ENV['SUBSCRIPTION']
      end
      default_config :storage_account do |driver|
        ENV['STORAGE_ACCOUNT']
      end

      required_config :publish_settings_file
      required_config :subscription
      required_config :storage_account

      def create(state)
        if state[:cloud_service] 
          info("Already created: #{instance.name}")
          return
        end
        azure_configure
        debug("Config: #{config.inspect}")
        debug("Platform: #{instance.platform.name}")
        info("Searching for images for distro #{instance.platform.name}")
        distro = instance.platform.name.match(/(\w+)[\-_](\d+)[\-_\.](\d+)/)
        @cloud_service = "test-kitchen-" + SecureRandom.hex(6)
        if (distro.nil? || (distro.length != 4))
          raise 'Unable to parse linux distro'
        end

        flavour = distro[1]
        maj = distro[2]
        min = distro[3]
        vmis = ::Azure::VirtualMachineImageManagementService.new
        image = vmis.list_virtual_machine_images.select{ |i| i.name =~ /#{flavour}.*#{maj}[\-_\.]#{min}/i }.last
        raise "Unable to find matching image for #{instance.platform.name}" if image.nil?

        generate_ssh_certs

        vm_params = { 
          :vm_name => instance.name,
          :vm_user => config[:username],
          :image => image.name,
          :location => config[:location]
        }
        vm_options = {
          :storage_account_name => config[:storage_account],
          :ssh_port => config[:port],
          :cloud_service_name => @cloud_service,
          :vm_size => config[:size],
          :private_key_file => File.join(cert_dir , 'azure.key'),
          :certificate_file => File.join(cert_dir , 'azure.pem')
        }

        @instance_opts = vm_params.merge(vm_options)

        state[:hostname] = "#{@cloud_service}.cloudapp.net"
        state[:ssh_key] = vm_options[:private_key_file]
        state[:vm_name] = vm_params[:vm_name]
        state[:cloud_service] = vm_options[:cloud_service_name]

        debug('Instance Options: ' + @instance_opts.inspect)

        vms = ::Azure::VirtualMachineManagementService.new
        vms.create_virtual_machine(vm_params, vm_options)

        # Logic to wait until VM is ReadyRole
        while ((vm_status = vms.list_virtual_machines.find{ |vm| vm.vm_name == instance.name }.status) != 'ReadyRole')
          info("Waiting for VM to be ready. Current state: #{vm_status}")
          sleep 10
        end

        wait_for_sshd(state[:hostname], config[:username], { :port => config[:port] })
      end

      def destroy(state)
        return unless state[:hostname]
        azure_configure
        vms = ::Azure::VirtualMachineManagementService.new
        vms.delete_virtual_machine(state[:vm_name], state[:cloud_service])
        FileUtils.rm_r(azure_temp_dir)
      end

      private

      def azure_configure

        begin
          settings = Nokogiri::XML(File.open(config[:publish_settings_file]))
          sub_data = settings.xpath("//Subscription").find{ |s| s.attributes['Name'].value == config[:subscription]}
          raise "Couldn't find subscription" unless sub_data
          cert = sub_data['ManagementCertificate']
          raise "Couldn't parse certificate" unless cert
          sub_id = sub_data['Id']
          raise "Couldn't get Subscription Id" unless sub_id
        rescue Exception => e
          raise "Error parsing publishsettings file: #{e.message}"
        end

        cert_file = File.join(config[:kitchen_root], %w{.kitchen kitchen-azure}, 'management_cert.pfx')

        FileUtils.mkdir_p(File.join(config[:kitchen_root], %w{.kitchen kitchen-azure}))
        File.open(cert_file,"w") do |f|
          f.write(cert)
        end

        ::Azure.configure do |c|
          c.management_certificate = cert_file
          c.subscription_id = sub_id
          c.management_endpoint = AZURE_MANAGEMENT_ENDPOINT
        end
      end

      def azure_temp_dir
        @az_tmp_dir ||= File.join(
          config[:kitchen_root], %w{.kitchen kitchen-azure}, instance.name
        )
      end

      def cert_dir
        @cert_dir ||= File.join(azure_temp_dir, ".ssh")
      end

      def generate_ssh_certs
        if File.exists?(File.join(cert_dir, "azure.key")) && File.exists?(File.join(cert_dir , "azure.pem"))
          debug("certificate files already exist")
          return
        end

        FileUtils.mkdir_p(cert_dir)
        FileUtils.chmod(0700, cert_dir)
        key = OpenSSL::PKey::RSA.new 2048
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 0
        cert.not_before = Time.now
        cert.not_after = Time.now + 3600
        cert.public_key = key.public_key

        open(cert_dir + "/azure.key","w",0600) { |io| io.write(key.to_pem) }
        open(cert_dir + "/azure.pem","w",0600) { |io| io.write(cert.to_pem) }
      end

    end

  end
end
