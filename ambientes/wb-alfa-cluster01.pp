group { 'dba' :
  ensure => present,
}

user { 'oracle' :
  ensure     => present,
  groups     => 'dba',
  shell      => '/bin/bash',
  password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
  home       => "/home/oracle",
  comment    => 'Oracle user created by Puppet',
  managehome => true,
  require    => Group['dba'],
}

jdk7::install7{ 'jdk-8u72-linux-x64':
    version                     => "8u72" ,
    full_version                => "jdk1.8.0_72",
    alternatives_priority       => 18001,
    x64                         => true,
    download_dir                => "/var/tmp/install",
    urandom_java_fix            => true,
    rsa_key_size_fix            => true,
    cryptography_extension_file => "jce_policy-8.zip",
    source_path                 => "/software",
}

class{'orawls::weblogic':
  version              => 12211,
  filename             => 'fmw_12.2.1.0.0_wls.jar',
  jdk_home_dir         => '/usr/java/jdk1.8.0_72',
  oracle_base_home_dir => "/opt/oracle",
  middleware_home_dir  => "/opt/oracle/middleware12c",
  weblogic_home_dir    => "/opt/oracle/middleware12c/wlserver",
  os_user              => "oracle",
  os_group             => "dba",
  download_dir         => "/data/install",
  source               => "puppet:///modules/orawls/",
  log_output           => true,
}

orawls::opatch {'16175470':
  ensure                  => "present",
  oracle_product_home_dir => "/opt/oracle/middleware12c",
  jdk_home_dir            => "/usr/java/jdk1.8.0_72",
  patch_id                => "16175470",
  patch_file              => "p16175470_121200_Generic.zip",
  os_user                 => "oracle",
  os_group                => "dba",
  download_dir            => "/data/install",
  source                  => "puppet:///modules/orawls/",
  log_output              => false,
}

orawls::domain { 'wlsDomain12c':
  version                     => 12211, 
  weblogic_home_dir           => "/opt/oracle/middleware12c/wlserver",
  middleware_home_dir         => "/opt/oracle/middleware12c",
  jdk_home_dir                => "/usr/java/jdk1.8.0_72",
  domain_template             => "standard",
  domain_name                 => "Wls12c",
  development_mode            => false,
  adminserver_name            => "AdminServer",
  adminserver_address         => "localhost",
  adminserver_port            => 7001,
  nodemanager_secure_listener => true,
  nodemanager_port            => 5556,
  weblogic_user               => "weblogic",
  weblogic_password           => "weblogic1",
  os_user                     => "oracle",
  os_group                    => "dba",
  log_dir                     => "/data/logs",
  download_dir                => "/data/install",
  log_output                  => true,
}

orawls::nodemanager{'nodemanager12c':
  version                     => 12211,
  weblogic_home_dir           => "/opt/oracle/middleware12c/wlserver",
  jdk_home_dir                => "/usr/java/jdk1.8.0_72",
  nodemanager_port            => 5556,
  nodemanager_secure_listener => true,
  domain_name                 => "Wls12c",
  os_user                     => "oracle",
  os_group                    => "dba",
  log_dir                     => "/data/logs",
  download_dir                => "/data/install",
  log_output                  => true,
  sleep                       => 20,
  properties                  => {},
}

wls_server { 'wlsServer1':
  ensure                            => 'present',
  arguments                         => '-XX:PermSize=256m -XX:MaxPermSize=256m -Xms752m -Xmx752m -Dweblogic.Stdout=/var/log/weblogic/wlsServer1.out -Dweblogic.Stderr=/var/log/weblogic/wlsServer1_err.out',
  jsseenabled                       => '0',
  listenaddress                     => '10.10.10.100',
  listenport                        => '8001',
  listenportenabled                 => '1',
  machine                           => 'Node1',
  sslenabled                        => '0',
  tunnelingenabled                  => '0',
  max_message_size                  => '10000000',
  server_parameter                  => 'WebCluster, hrDs',
}

wls_server { 'wlsServer2':
  ensure                            => 'present',
  arguments                         => '-XX:PermSize=256m -XX:MaxPermSize=256m -Xms752m -Xmx752m -Dweblogic.Stdout=/var/log/weblogic/wlsServer1.out -Dweblogic.Stderr=/var/log/weblogic/wlsServer1_err.out',
  jsseenabled                       => '0',
  listenaddress                     => '10.10.10.101',
  listenport                        => '8001',
  listenportenabled                 => '1',
  machine                           => 'Node1',
  sslenabled                        => '0',
  tunnelingenabled                  => '0',
  max_message_size                  => '10000000',
  server_parameter                  => 'WebCluster, hrDs',
}

wls_server { 'wlsServer3':
  ensure                            => 'present',
  arguments                         => '-XX:PermSize=256m -XX:MaxPermSize=256m -Xms752m -Xmx752m -Dweblogic.Stdout=/var/log/weblogic/wlsServer1.out -Dweblogic.Stderr=/var/log/weblogic/wlsServer1_err.out',
  jsseenabled                       => '0',
  listenaddress                     => '10.10.10.102',
  listenport                        => '8001',
  listenportenabled                 => '1',
  machine                           => 'Node1',
  sslenabled                        => '0',
  tunnelingenabled                  => '0',
  max_message_size                  => '10000000',
  server_parameter                  => 'WebCluster, hrDs',
}

wls_cluster { 'WebCluster':
  ensure           => 'present',
  messagingmode    => 'unicast',
  migrationbasis   => 'consensus',
  servers          => ['inherited'],
  multicastaddress => '239.192.0.0',
  multicastport    => '7001',
}

wls_datasource { 'hrDS':
  ensure                           => 'present',
  connectioncreationretryfrequency => '0',
  drivername                       => 'oracle.jdbc.xa.client.OracleXADataSource',
  extraproperties                  => ['SendStreamAsBlob=true', 'oracle.net.CONNECT_TIMEOUT=10001'],
  fanenabled                       => '0',
  globaltransactionsprotocol       => 'TwoPhaseCommit',
  initialcapacity                  => '2',
  initsql                          => 'None',
  jndinames                        => ['jdbc/hrDS', 'jdbc/hrDS2'],
  maxcapacity                      => '15',
  mincapacity                      => '1',
  rowprefetchenabled               => '0',
  rowprefetchsize                  => '48',
  secondstotrustidlepoolconnection => '10',
  statementcachesize               => '10',
  target                           => ['inherited'],
  targettype                       => ['inherited'],
  testconnectionsonreserve         => '0',
  testfrequency                    => '120',
  testtablename                    => 'SQL SELECT 1 FROM DUAL',
  url                              => 'jdbc:oracle:thin:@dbagent2.alfa.local:1521/test.oracle.com',
  user                             => 'hr',
  usexa                            => '0',
}
wls_cluster { 'WebCluster':
  ensure           => 'present',
  messagingmode    => 'unicast',
  migrationbasis   => 'consensus',
  servers          => ['inherited'],
  multicastaddress => '239.192.0.0',
  multicastport    => '7001',
}

wls_datasource { 'hrDS':
  ensure                           => 'present',
  connectioncreationretryfrequency => '0',
  drivername                       => 'oracle.jdbc.xa.client.OracleXADataSource',
  extraproperties                  => ['SendStreamAsBlob=true', 'oracle.net.CONNECT_TIMEOUT=10001'],
  fanenabled                       => '0',
  globaltransactionsprotocol       => 'TwoPhaseCommit',
  initialcapacity                  => '2',
  initsql                          => 'None',
  jndinames                        => ['jdbc/hrDS', 'jdbc/hrDS2'],
  maxcapacity                      => '15',
  mincapacity                      => '1',
  rowprefetchenabled               => '0',
  rowprefetchsize                  => '48',
  secondstotrustidlepoolconnection => '10',
  statementcachesize               => '10',
  target                           => ['inherited'],
  targettype                       => ['inherited'],
  testconnectionsonreserve         => '0',
  testfrequency                    => '120',
  testtablename                    => 'SQL SELECT 1 FROM DUAL',
  url                              => 'jdbc:oracle:thin:@dbagent2.alfa.local:1521/test.oracle.com',
  user                             => 'hr',
  usexa                            => '0',
}

wls_cluster { 'WebCluster':
  ensure           => 'present',
  messagingmode    => 'unicast',
  migrationbasis   => 'consensus',
  servers          => ['inherited'],
  multicastaddress => '239.192.0.0',
  multicastport    => '7001',
}

wls_datasource { 'hrDS':
  ensure                           => 'present',
  connectioncreationretryfrequency => '0',
  drivername                       => 'oracle.jdbc.xa.client.OracleXADataSource',
  extraproperties                  => ['SendStreamAsBlob=true', 'oracle.net.CONNECT_TIMEOUT=10001'],
  fanenabled                       => '0',
  globaltransactionsprotocol       => 'TwoPhaseCommit',
  initialcapacity                  => '2',
  initsql                          => 'None',
  jndinames                        => ['jdbc/hrDS', 'jdbc/hrDS2'],
  maxcapacity                      => '15',
  mincapacity                      => '1',
  rowprefetchenabled               => '0',
  rowprefetchsize                  => '48',
  secondstotrustidlepoolconnection => '10',
  statementcachesize               => '10',
  target                           => ['inherited'],
  targettype                       => ['inherited'],
  testconnectionsonreserve         => '0',
  testfrequency                    => '120',
  testtablename                    => 'SQL SELECT 1 FROM DUAL',
  url                              => 'jdbc:oracle:thin:@dbagent2.adtsys.local:1521/test.oracle.com',
  user                             => 'hr',
  usexa                            => '0',
}

