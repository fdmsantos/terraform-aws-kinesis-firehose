# Changelog

All notable changes to this project will be documented in this file.

## [3.3.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v3.2.0...v3.3.0) (2024-03-05)


### Features

* Merge pull request [#13](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/13) from Tonkonozhenko/patch-1 ([7e47d48](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/7e47d48058fc0c654f6e46ed436332246e3ec6ba))

## [3.2.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v3.1.0...v3.2.0) (2024-02-28)


### Features

* Merge pull request [#12](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/12) from tropnikovvl/main ([7686e0e](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/7686e0e4b0d6f3d2e5bad3d59a892ba67004decc))

## [3.1.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v3.0.0...v3.1.0) (2024-02-22)


### Features

* Add support for MSK Source Configuration ([#10](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/10)) ([9262a54](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/9262a545186b4e8faf7441095aa6cc07055f68f8))

## [3.0.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.2.3...v3.0.0) (2024-02-19)


### ⚠ BREAKING CHANGES

* Add support for Opensearch and Opensearch Serverless destinations ([9c37b8f](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/9c37b8f6b2c512ee1a493a044f9b2c852f6eeec8))

### [2.2.3](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.2.2...v2.2.3) (2024-02-16)


### Bug Fixes

* Remove aws provider strict to major version constraint ([#9](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/9)) ([643f99b](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/643f99b4a8a372f454bd032208efc02ebc30677d))

### [2.2.2](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.2.1...v2.2.2) (2024-01-15)


### Bug Fixes

* buffering_interval variable validation doesn't allow to specify values less than 60 seconds ([#7](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/7)) ([fc78ff3](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/fc78ff3816915f6414e750c2f438091c5304b17c))

### [2.2.1](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.2.0...v2.2.1) (2023-12-04)


### Bug Fixes

* change kinesisDecrypt to kmsDecrypt ([c3c28a0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/c3c28a013e1a6705c94bab448de123012bcd70e9))

## [2.2.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.1.2...v2.2.0) (2023-11-09)


### Features

* Merge pull request [#5](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/5) from angryhamsterx/glue_tables_another_account ([a09447e](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/a09447edc0b4e39e76d6ad6922ecbe5fef247bf9))

### [2.1.2](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.1.1...v2.1.2) (2023-11-09)


### Bug Fixes

* Merge pull request [#4](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/4) from mzupan/main ([bb0ee4a](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/bb0ee4acfe1fd08775d482073393805e1edf463f))

### [2.1.1](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.1.0...v2.1.1) (2023-09-20)


### Bug Fixes

* Merge pull request [#3](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/3) from schshmuel/fix-configuring-existing-role ([74a626b](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/74a626b6f530684a37cf4149e06cb3ff1172755a)), closes [#2](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/issues/2)

## [2.1.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v2.0.0...v2.1.0) (2023-09-19)


### Features

* Add Waf Source ([11abc46](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/11abc46eb71a758796f1f41a4e3a12f32e0cd2a8))

## [2.0.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.9.1...v2.0.0) (2023-09-18)


### ⚠ BREAKING CHANGES

* Bump Terraform AWS Provider version to 5.0

### Features

* Bump Terraform AWS Provider version to 5.0 ([29601cf](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/29601cf8ad93a9a56ac3fba37f9e8b0c968c5c3f))

### [1.9.1](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.9.0...v1.9.1) (2023-09-16)


### Bug Fixes

* Add AWS Provider Version Constraint to major version 4 ([017f340](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/017f3408db24f3318e27d3a1308522925d2e5af7))

## [1.9.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.8.0...v1.9.0) (2022-10-19)


### Features

* Add support to cross account opensearch domain in opensearch destination ([ac36ec1](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/ac36ec1e9a3474d86195e9b38336288a77327705))
* Add support to cross account s3 buckets in s3 destination ([aa42c43](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/aa42c439bcf27cf95b851c5bc0fafe7454bdd960))
* Add support to iam role when don't own the bucket ([b07541e](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/b07541ee80f99f3d9a805072a50bbf28164428cf))

## [1.8.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.7.0...v1.8.0) (2022-10-18)


### Features

* Add Logic Monitor destination ([60e1bb6](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/60e1bb60d6c34fc7748368e365accc295065203c))
* Add MongoDB Cloud destination ([39ab429](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/39ab429d43440033059732426e275294ed6ec62b))
* Add SumoLogic destination ([ea6cf3d](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/ea6cf3d1c91d34d068c91a4d0854b3ba20391ed7))

## [1.7.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.6.0...v1.7.0) (2022-10-17)


### Features

* Add coralogix destination ([d8ea509](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/d8ea5096d34af8cec367c5f5b79413e20416e576))
* Add Dynatrace destination ([378ba91](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/378ba91f4329542325b435c2891ef353f16251f2))
* Add Honeycomb destination ([5dc04fe](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/5dc04fe00e3e6c3acc857ca8b00665d10e3eabca))
* Add New Relic destination ([227d95e](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/227d95ea321b676308a7b3ad6fc1ac94c2e4e3e4))

## [1.6.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.5.0...v1.6.0) (2022-10-14)


### Features

* Add application Role ([42d947e](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/42d947e9c9f078e72abcf634e2df6042cef5f06e))
* Add datadog destination ([73e6604](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/73e6604885d07689e6c870ce61549f2b6a7c3a83))
* Add external id in firehose role trusted policy to prevent confused deputy problem ([ade4133](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/ade4133e921460639ef2558096fd97453f50547c))
* Add Lambda ARN Feature to transform Lambda ([c74f31f](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/c74f31f14468717318b48d4a2a3970c6c5b5fe0b))
* Add Opensearch destination alias ([9511cc3](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/9511cc393e1feb607c9711c34419456d6acc5115))
* Add S3 destination alias ([ef88def](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/ef88defabea30ef7298ca25273374e9cfbaa64f2))

## [1.5.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.4.0...v1.5.0) (2022-10-13)


### Features

* add vpc support to elasticsearch, redshift and splunk destinations ([dfc051b](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/dfc051b0562129f5b6579eb6e7ac083c7e2980c7))

## [1.4.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.3.0...v1.4.0) (2022-09-29)


### Features

* Add support to http endpoint destination ([a4823e8](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/a4823e8c3c94367b6673223e6ea68e0aa7a443cd))

## [1.3.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.2.0...v1.3.0) (2022-09-28)


### Features

* Add support to Splunk destination ([0b329fc](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/0b329fc4df7a38c2cfc00ea66f0d2ae6a4a048e4))

## [1.2.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.1.0...v1.2.0) (2022-09-23)


### Features

* add support to elasticsearch destination ([915a1d6](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/915a1d69a15a7f559120bca2a7636e96135ddb13))

## [1.1.0](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/compare/v1.0.0...v1.1.0) (2022-09-13)


### Features

* Add support to redshift destination ([f50342c](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/f50342cf660fc49f5c00fe87b876913fc1b55e2f))

## 1.0.0 (2022-09-12)


### Features

* Initial Release ([6437179](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/commit/6437179ae196adc2b7684130cbca3b6bc019dae2))
