require 'spec_helper'

describe 'zabbix::agent' do
  # Set some facts / params.
  let(:facts) {{:operatingsystem => 'RedHat', :operatingsystemrelease => '6.5'}}
  let(:params) { {:server => '192.168.1.1', :serveractive => '192.168.1.1', :manage_repo => true, :zabbix_version => '2.2'} }

  context "when declaring manage_repo is true" do
    let :params do
      { :manage_repo => true }
    end

    describe 'with repo' do
      let(:facts) {{:operatingsystem => 'RedHat', :operatingsystemrelease => '6.5'}}

      # Make sure we have the zabbix::repo 
      it do 
        should contain_class('zabbix::repo').with({
          'zabbix_version' => '2.2',
        })
      end

      # Make sure we have 'required' the zabbix::repo module for the package.
      it do 
        should contain_package('zabbix-agent').with_require('Class[Zabbix::Repo]')
      end

    end
  end

  context "when declaring manage_repo is false" do
    let(:facts) {{:operatingsystem => 'RedHat', :operatingsystemrelease => '6.5'}}
    let :params do
      { :manage_repo => false }
    end
    describe 'without repo' do
        it { should_not contain_class('Zabbix::Repo') }
    end
  end

  # Make sure package will be installed.
  it do
    should contain_package('zabbix-agent').with({
    :ensure => :present,
    :name   => 'zabbix-agent',
  })
  end

  # We need an zabbix-agent service.
  it { should contain_service('zabbix-agent').with(
    'name'       => 'zabbix-agent',
    'ensure'     => 'running',
    'enable'     => 'true',
    'hasstatus'  => 'true',
    'hasrestart' => 'true',
    'require'    => 'Package[zabbix-agent]'
    )
  }

  # Include directory should be available.
  it { should contain_file('/etc/zabbix/zabbix_agentd.d/').with(
    'ensure'  => 'directory',
    'owner'   => 'zabbix',
    'group'   => 'zabbix',
    'recurse' => 'true',
    'purge'   => 'true',
    )
  }

  # Make sure the confifuration file is present.
  it { should contain_file('/etc/zabbix/zabbix_agentd.conf').with(
    'ensure'  => 'present',
    'owner'   => 'zabbix',
    'group'   => 'zabbix',
    'mode'    => '0644',
    'notify'  => 'Service[zabbix-agent]',
    'require' => 'Package[zabbix-agent]',
    )
  }

  # Make sure we have set some vars in zabbix_agentd.conf file. 
  #TODO: A lot more vars has to be added. (Also for specific zabbix version?)
  context 'with pidfile => /var/run/zabbix/zabbix_agentd.pid' do
    let(:params) { {:pidfile => '/var/run/zabbix/zabbix_agentd.pid'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^PidFile=/var/run/zabbix/zabbix_agentd.pid$}
    end
  end

  context 'with logfile => /var/run/zabbix/zabbix_agentd.pid' do
    let(:params) { {:logfile => '/var/log/zabbix/zabbix_agentd.log'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^LogFile=/var/log/zabbix/zabbix_agentd.log$}
    end
  end

  context 'with DebugLevel => 4' do
    let(:params) { {:debuglevel => '4'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^DebugLevel=4$}
    end
  end

  context 'with logfilesize => 4' do
    let(:params) { {:logfilesize => '4'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^LogFileSize=4$}
    end
  end

  context 'with EnableRemoteCommands => 1' do
    let(:params) { {:enableremotecommands => '1'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^EnableRemoteCommands=1$}
    end
  end

  context 'with LogRemoteCommands => 0' do
    let(:params) { {:logremotecommands => '0'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^LogRemoteCommands=0$}
    end
  end

  context 'with server => 192.168.1.1' do
    let(:params) { {:server => '192.168.1.1'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^Server=192.168.1.1$}
    end
  end

  context 'with ListenPort => 192.168.1.1' do
    let(:params) { {:listenport => '10050'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^ListenPort=10050$}
    end
  end

  context 'with StartAgents => 3' do
    let(:params) { {:startagents => '3'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^StartAgents=3$}
    end
  end

  context 'with ServerActive => 192.168.1.1' do
    let(:params) { {:serveractive => '192.168.1.1'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^ServerActive=192.168.1.1$}
    end
  end

  context 'with Hostname => 192.168.1.1' do
    let(:params) { {:hostname => '10050'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^Hostname=10050$}
    end
  end

  context 'with HostnameItem => system.hostname' do
    let(:params) { {:hostnameitem => 'system.hostname'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^HostnameItem=system.hostname$}
    end
  end

  context 'with RefreshActiveChecks => 120' do
    let(:params) { {:refreshactivechecks => '120'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^RefreshActiveChecks=120$}
    end
  end
  
  context 'with BufferSend => 5' do
    let(:params) { {:buffersend => '5'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^BufferSend=5$}
    end
  end

  context 'with BufferSize => 100' do
    let(:params) { {:buffersize => '100'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^BufferSize=100$}
    end
  end

  context 'with Timeout => 30' do
    let(:params) { {:timeout => '30'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^Timeout=30$}
    end
  end

  context 'with AllowRoot => 0' do
    let(:params) { {:allowroot => '0'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^AllowRoot=0$}
    end
  end

  context 'with Include => /etc/zabbix/zabbix_agentd.d/' do
    let(:params) { {:include_dir => '/etc/zabbix/zabbix_agentd.d/'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^Include=/etc/zabbix/zabbix_agentd.d/$}
    end
  end

  context 'with UnsafeUserParameters => 0' do
    let(:params) { {:unsafeuserparameters => '0'} }
    it do
      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^UnsafeUserParameters=0$}
    end
  end

#  context 'with LoadModulePath => ${libdir}/modules' do
#    let(:params) { {:loadmodulepath => '${libdir}/modules'} }
#    it do
#      should contain_file('/etc/zabbix/zabbix_agentd.conf').with_content %r{^LoadModulePath=${libdir}/modules$}
#    end
#  end


  # So if manage_firewall is set to true, it should install
  # the firewall rule.
  context "when declaring manage_firewall is true" do
    let :params do
      { :manage_firewall => true }
    end
    describe 'with firewall' do
      it { should contain_firewall('150 zabbix-agent') }
    end
  end

  # If not, we don't want an firewall rule.
  context "when declaring manage_firewall is false" do
    let :params do
      { :manage_firewall => false }
    end
    describe 'without firewall' do
      it { should_not contain_firewall('150 zabbix-agent') }
    end
  end

end
