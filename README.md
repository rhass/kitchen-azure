# <a name="title"></a> Kitchen::Msazure

A Test Kitchen Driver for Microsoft Azure.

## <a name="requirements"></a> Requirements

* A Microsoft Azure account
* An Azure subscription
* A `.publishsettings` file with the subscription definition and 
management certificate

## <a name="installation"></a> Installation and Setup

The most basic configuration required is show below. Specify this in the 
.kitchen.yml file

```yaml
driver:
  name: msazure
  subscription: "SubscriptionName"
  publish_settings_file: "/path/to/publishsettings"
  storage_account: "StorageAccountName"
```

Platforms currently supported:

```yaml
platforms:
  - name: centos-6.3
  - name: centos-6.4
  - name: centos-6.5
  - name: ubuntu-12.04
  - name: ubuntu-13.10
  - name: ubuntu-14.04
``` 

Please read the [Driver usage][driver_usage] page for more details.

## <a name="config"></a> Configuration

Below is a list of the configuration options, their obligatoriness and defaults

* ### <a name="config-pub-settings"></a> publish_settings_file
**Required** Path to publish settings file
  Either specify as an environment variable `PUBLISH_SETTINGS_FILE=/path/to/file`
or in the .kitchen.yml file

* ### <a name="config-subscription"></a> subscription
**Required** Name of Azure subscription
  Either specify as an environment variable `SUBSCRIPTION=SubscriptionName`
or in the .kitchen.yml file

* ### <a name="config-subscription"></a> storage_account
**Required** Name of the storage account to use
  Either specify as an environment variable `STORAGE_ACCOUNT=StorageAccountName`
or in the .kitchen.yml file

* ### <a name="config-ssh"></a> port
The SSH port to use
  **Default:** 2222

* ### <a name="config-username"></a> username
The VM username to use
  **Default:** azureuser

* ### <a name="config-location"></a> location
The Azure datacenter location to use
  **Default:** East US

* ### <a name="config-size"></a> size
The size of the VM to create
  **Default:** small

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Grant Ellis][author] (<grant.ellis@marks-and-spencer.com>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/DigitalInnovation
[issues]:           https://github.com/DigitalInnovation/kitchen-msazure/issues
[license]:          https://github.com/DigitalInnovation/kitchen-msazure/blob/master/LICENSE
[repo]:             https://github.com/DigitalInnovation/kitchen-msazure
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.getchef.com/chef/install/
