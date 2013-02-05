ZFS plugin for Vagrant
======================

This is a plugin for Vagrant that allows you to instantly create and destroy
vagrantboxes using the snapshot and clone functionality of the ZFS filesystem.

Why?
====

To save time when creating and destroying boxes. If you create and destroy many boxes, you probably don't like waiting for the basebox of several hundred megabytes to be copied to the VirtualBox VMs directory. Using this you don't have to wait.

As an example, on a laptop with an OCZ Vertex 3 240GB SSD and an Intel Core i7 @ 2.6GHz, running "vagrant up" from "not created":

    +--------------------+--------------------------+
    | Without ZFS plugin |    1 minute 26 seconds   |
    +--------------------+--------------------------+
    | With ZFS plugin    |    20 seconds            |
    +--------------------+--------------------------+

Usage
=====
To use the instant-create functionality, you must first add a box via the plugin. This is done the usual way:

    vagrant box add base http://files.vagrantup.com/lucid32.box

This operation will create a new ZFS filesystem and mount it at

    ~/.vagrant.d/boxes/base

and then the box will be unpacked into that directory. To create a new box from this basebox, do it the usual way:

    vagrant up

This will take a ZFS snapshot of the basebox filesystem, then clone and mount it at:

    ~/.vagrant.d/instances/mybox_1360066480

then create the VM using, register it, attach the disk from the clone and boot it.

Destroy
=======

To destroy the instance, do as usual:

    vagrant destroy

This will destroy the box in the usual way, and in addition destroy the ZFS clone and snapshot that were created for it.

To destroy the basebox, do as usual:

    vagrant box remove base

This will destroy the ZFS filesystem that was created for it.
