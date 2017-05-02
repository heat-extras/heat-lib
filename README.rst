========
heat-lib
========

Overview
========

This repository serves as a library for various infrastructure components
and software configurations (SC) written in the form of Openstack Heat templates.
The consumer of this library can either leverage the basic building blocks
found in this library, both infrastructure and software configurations, or they
can follow the framework this library offers in order to develop new
components.

As initially mentioned there are both infrastructure and software configuration
building blocks. Naturally, the infrastructure components orchestrate Openstack
resources such as instances, networks, load balancers, etc. The moderately
experienced Heat user with knowledge of the nested Heat template format should
easily be able to consume the infrastructure components right away. However,
the software configuration components require a more thorough overview.

There are many different ways to orchestrate software on top of deployed
infrastructure, for example:

**via cloud-init**

* Advantages: Very simple to use and typically available in all cloud ready
  images
* Disadvantages: Only able to apply a SC once when the instance is deployed
  (no LCM), hard to debug, hard to pass back meaningful information to the user
  (ie. generated credentials, std_err, std_out, etc)

**via a cloud-agnostic orchestrator** (such as Puppet, Chef, Salt, etc)

* Advantages: Robust full feature set solution satisfying LCM requirements,
  supports hybrid-cloud workloads
* Disadvantages: Typically requires agents or extra configuration/coordination
  with deployed infrastructure resources, a different system than the
  infrastructure orchestrator

**via a cloud-native orchestrator**

* Advantages: Single point of control for software configuration and
  infrastructure orchestration; coordination between infrastructure and
  software deployment
* Disadvantages: May lack a full LCM feature set, does not typically support
  hybrid cloud workloads

This library leverages a cloud-native orchestrator, namely using Software
Deployments in Heat. This orchestration engine allows users to manage
instances from a software orchestration point of view all throughout the
instance life cycle. The reader is strongly encouraged to read the `Heat Software Deployments
<http://docs.openstack.org/developer/heat/template_guide/software_deployment.html#software-deployment-resources>`_
documentation. Software Deployments is a very powerful tool in the sense
that it allows for deploying scripts of many different types of formats via
the concept of hooks. These hooks define what type of interpreter should be used
to apply the supplied script, where puppet, chef, or salt are examples of such
hooks. This means that users can deploy any software configurations via
existing scripts in whatever format with Software Deployments. The reader is
encouraged to check out the full list of supported `Software Configuration Hooks
<https://github.com/openstack/heat-templates/tree/master/hot/software-config/elements>`_
and also be aware of the fact that it is quite simple to develop your own hooks.

Structure
=========

This repository contains the following folders:

* lib - this folder contains all of the components, both infrastructure and
  software configurations, in the form of Heat templates and scripts
* env - this folder contains OS specific Heat `environment files
  <https://docs.openstack.org/developer/heat/template_guide/environment.html>`_
  that point to local repo files
* env-ext - this folder contains OS specific Heat `environment files
  <https://docs.openstack.org/developer/heat/template_guide/environment.html>`_
  that point to remote files (in this github repo) 
* tests - this folder contains various Heat templates that use the components
  in the Lib directory to test their functionality

lib
---

The lib directory is the core of this repository and contains three different
folders:

**openstack**

This folder contains all of the infrastructure components for various types of
resources categorized in folders such as instance, network, cluster, etc. Each
template has a list of parameters that can be used to customize the resource
as well as a list of outputs that can be used as attributes to retrieve
information regarding that particular resource.

**boot-config**

In order to employ Heat Software Deployments, the image that's used to run the
instance must have a number of agents namely:  os-collect-config,
os-apply-config, and os-refresh-config. Their job is to coordinate the reading,
running, and updating of the software configuration that will be sent via Heat.
These agents may either be made available by creating a cloud image that
contains these agents or they can be made available by installing them at
instance boot time via cloud-init. This folder contains OS specific cloud-init
installation scripts for these agents. The reader will notice that for every
instance definition found in the openstack/instance folder there is a
Heat::InstallConfigAgent resource definition that is applied to the instance
via the user_data property of the instance. Following the installation of these
agents, the agents are started at which point they will begin communicating with
Heat in order to retrieve and apply any software configurations that were
applied to the instance via Software Deployments.

**software-configs**

This folder contains OS specific scripts for various software configurations
such as installing various packages, adding new users, making configuration
file changes, etc. Each OS has its own folder and within each folder there
exists a Heat template for every software configuration. The base.yaml template
is used to derive every other template. It's basically a "template" for
developing new software configuration templates. Within base.yaml, the reader
will notice three different SoftwareConfig resources along side
three different SoftwareDeployment resources that apply these SoftwareConfig
resources to the instance passed in as a parameter. These three different
SoftwareConfig resources are for different phases of applying the software
configurations, namely the install, configure and start phases. Some software
configurations may only have one of these phases (ie. only configure for the
reboot software configuration) or all three (ie. httpd installation).

Each SoftwareConfig resource has a reference to the scripts that it
contains via the get_file `intrinsic function
<https://docs.openstack.org/developer/heat/template_guide/hot_spec.html#hot-spec-intrinsic-functions>`_.
Each OS folder, has its own scripts folder alongside all of the templates.
Within the scripts folder, there exists a folder matching the name of the
software configuration template that contains at most three scripts:
install.sh, configure.sh, start.sh which match each phase of the software
configuration template. At the time of this writing, only bash scripts are used
to apply software configurations, however any script types in the hooks list
may be used. The only required change to allow for a different type of script
is the script name specified in the get_file function and the group attribute
of the SoftwareConfig resource as detailed in the `SoftwareConfig resource specification
<https://docs.openstack.org/developer/heat/template_guide/hot_spec.html#hot-spec-intrinsic-functions>`_.

The reader can also utilize the inputs attribute of the SoftwareConfig resource
and the input_values of the SoftwareDeployment resource along side template
parameters to pass inputs to the script that's being applied. And lastly, the
reader can also use the outputs attribute of the SoftwareDeployment along side
template outputs to pass back meaningful information. By default, all
software configuration resources will expose the std_out and std_err for each
script being applied.

env
---

This folder contains a number of environment files each for operating system.
The template_library.yaml is the generic template. Upon opening this template,
the reader will notice two sections. One for Openstack components and another
for software configurations. The XXX in the paths for software configurations
represents the operating system so for rhel_library.yaml the XXX is just rhel.
Also, the reader will also notice the Heat::InstallConfigAgent definition at
the end of the file which is also OS specific.

All Openstack component definitions are the exact same across all different
environment files. Unfortunately, Heat does not have a support the concept of
including a file within the environment file and so the Openstack components
section will be replicated across all environment files. This means that if you
develop a new component you will have to update every environment file. Heat
does support passing in multiple environment files when creating a stack, so
technically the openstack components could be their own environment file,
however this decision was made in order to allow for the simple reference of
only one environment file when using this library, especially since in most
cases the user will use another environment file for parameters, etc.

Lastly, these enviroment files point to local file paths, meaning that if the
reader would like to use these enviroment files, they'd have to download the 
whole repo. 

env-ext
-------

The structure of this folder is the exact same as *env/*, the only difference 
being that instead of pointing to local files paths, these enviroment files 
are using URLs that point to files hosted on gitHub. This means that in order
for the reader to use this library, the only thing they'd have to do is 
download these files and have network access to github.

tests
-----

This folder contains templates that use the various components in the lib
folder. These tests can be manually deployed and manually verified by the user
or library developer in order to ensure component functionality and perform
syntax checking. These templates also serve as good examples of how to use this
library.

Developing New Software Configurations
======================================

For the sake of step by step instructions, consider we are installing and
configuring httpd for rhel based images:

1. cd lib/software-configs/rhel
2. cp base.yaml httpd.yaml
3. change PACKAGE_NAME to httpd in the get_file function
4. Add any parameters you may need for this package and pass them in via inputs
   property in the SoftwareConfig resource and input_values in the
   SoftwareDeployment resource
5. Add any outputs you may need for this package to the outputs section of the
   template
6. cd scripts
7. mkdir httpd
8. Create the install.sh, configure.sh and start.sh scripts
9. Add the respective entry in the rhel_library.yaml in the env folder
