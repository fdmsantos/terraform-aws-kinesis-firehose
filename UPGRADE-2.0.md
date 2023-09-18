# Upgrade from v1.x to v2.x

If you have any questions regarding this upgrade process, please consult the `examples` directory

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

### Variable and output changes

1. Renamed variables:

   - `buffer_size` -> `buffering_size`
   - `buffer_interval` -> `buffering_interval`
   - `s3_backup_buffer_size` -> `s3_backup_buffering_size`
   - `s3_backup_buffer_interval` -> `s3_backup_buffering_interval`

2. Added variables:

   - `s3_configuration_buffering_size` has been added to S3 Configuration block. On version 1 buffer size for s3 configuration was the same as destination. Now you can configure different buffer size
   - `s3_configuration_buffering_interval` has been added to S3 Configuration block. On version 1 buffer interval for s3 configuration was the same as destination. Now you can configure different buffer interval
   
