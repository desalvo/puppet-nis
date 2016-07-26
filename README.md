puppet-nis
======

Puppet module for managing NIS clients and servers.

#### Table of Contents
1. [Overview - What is the NIS module?](#overview)
2. [Usage](#usage)

Overview
--------

This module is a simple collection of configurations to set up a nis master/slave or client.

Usage
-----

Parameters:
* **ypdomain**: the NIS domain name
* **ypserv**: the NIS server, can be a single value or an array
* **ypmaster**: the NIS master, for server configurations
* **client**: enable the client configuration, default is true
* **server**: enable the server configuration, default is false
* **master**: enable the a master server if true or a slave one if false
* **groups**: enable group login via NIS. Default is none.
* **securenets**: securenets file to be used
* **hostallow**: list of hosts to allow for portmap/rpcbind

**Defining a nis client**

```nis-client
class {'nis':
    ypdomain => 'mydomain',
    ypserv   => ['nis1.example.com','nis2.example.com'],
    groups   => ['users'],
}
```

**Defining a nis slave**

```nis-slave
class {'nis':
    ypdomain   => 'mydomain',
    ypserv     => 'nis.example.com',
    ypmaster   => 'nismaster.example.com',
    master     => true,
    securenets => 'puppet:///modules/mymodule/securenets',
    hostallow  => ['10.0.0.1','192.168.0.*'],
    groups     => ['users'],
}
```

Contributors
------------

* https://github.com/desalvo/puppet-nis/graphs/contributors

Release Notes
-------------

**0.3.1**

* Make ypmaster optional

**0.3.0**

* Add puppet 4 support
* Fix ypserv directive in templates

**0.2.0**

* Add multiple nis servers support

**0.1.2**

* Fix the nis auth enable procedure

**0.1.1**

* Using custom augeas lenses to edit /var/yp/nicknames

**0.1.0**

* Initial version
