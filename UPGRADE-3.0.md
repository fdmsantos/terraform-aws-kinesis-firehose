# Upgrade from v2.x to v3.x

If you have any questions regarding this upgrade process, please consult the `examples` directory

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

### New features

1. New Destination: Opensearch
2. New Destination: Opensearch Serverless

### Variable and output changes

1. Renamed variables:

    - `elasticsearch_enable_vpc` -> `enable_vpc`
    - `elasticsearch_vpc_use_existing_role` -> `vpc_use_existing_role`
    - `elasticsearch_vpc_role_arn` -> `vpc_role_arn`
    - `elasticsearch_vpc_subnet_ids` -> `vpc_subnet_ids`
    - `elasticsearch_cross_account` -> `destination_cross_account`
    - `elasticsearch_vpc_create_service_linked_role` -> `opensearch_vpc_create_service_linked_role`
    - `elasticsearch_vpc_security_group_same_as_destination` -> `vpc_security_group_same_as_destination`

2. Renamed Outputs:

   - `opensearch_cross_account_service_policy` -> `elasticsearch_cross_account_service_policy`

3. Default Values Changed:

    - `elasticsearch_retry_duration` -> Default value changed from 3600 to 300. If used the default value, please configure this variable equals to 3600

4. Added variables:

   - All variables prefixed with opensearch and opensearchserverless

5. Deprecations

   - Variable `enable_kinesis_source` removed. Use instead `input_source = "kinesis"`.
