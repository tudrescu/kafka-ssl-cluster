
# Create SSL Certificates

- this guide assumes a complete self-signed chain and will also generate root and intermediate certificates.

## Configuration

- configure `env.sh` as required by specifying

  - desired passwords for ca, intermediate, and broker/client certificates

  - additional hostnames to the `MACHINES` array if more certificates are required (if doing mTLS).

## Steps

1. `create_ca.sh`: create the CA root cert, if you run this you will need to re-run all other scripts.

2. `create_intermediate.sh`: this creates an intermediate certificate to simulate a real world example with chains of certificates.

3. `create_certs.sh`: for each machine call the `create_cert.sh` script to create the certificate for each machine.

4. `create_keystore.sh`: bundles the certificates into Java keystore files.  Keystore password and key passwords **must** match, which is a limitation of the JKS format of certificates stored in keystore.

The process can be restarted at any level.
