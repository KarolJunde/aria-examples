REPOSITORY MIGRATION NOTICE:
============================

ARIA-TOSCA proejct was accepted as an Apache Software Foundation(ASF) Incubation project, development is now moved to https://github.com/apache/incubator-ariatosca 


# Aria Example Blueprint

This repository contains a TOSCA blueprint for installing the [Paypal Pizza Store](https://github.com/paypal/rest-api-sample-app-nodejs/) example application.

The contents of this repository:

- The Aria Blueprint that you will execute
- The supporting scripts.

This example blueprint creates:

- Bind9 DNS server application
- NodeJS application that contains:
    - A Mongo Database
    - A NodeJS Server
    - A JavaScript Application

## How to Execute this Blueprint


### Step 1: Initialize

`aria init -b clearwater-5.1-multicloud-blueprint -p clearwater-5.1-multicloud-blueprint.yaml -i inputs/clearwater-5.1-multicloud-inputs.yaml.template --install-plugins`

### Step 2: Install

Lets run the `install` workflow:

`aria execute -w install -b clearwater-5.1-multicloud-blueprint --task-retries 10 --task-retry-interval 10`

### Step 3: Uninstall

To uninstall the application we run the `uninstall` workflow:

`aria execute -w uninstall --task-retries 10 --task-retry-interval 10`
