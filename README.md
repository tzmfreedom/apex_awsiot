# apex_awsiot
sample for aws iot publishing with apex.

# usage

```apex
AWSIoTClient client = new AWSIoTClient(
  'input your aws access key id',
  'input your aws secret access key',
  'input your region',
  'input your iot endpoint prefix'
);

String response = client.publish(
  'input your topic name',
  new Map<String, Object>{
    'payload_key1' => 'payload_value1',
    'payload_key2' => 'payload_value2'
  }
);
```
