# vault-tools

Tools for completely automated Cloud deployments that need to store and retrieve certificates and credentials.

# Example usage during automatic setup.

This is a snippet from an automated deployment script for 389 Directory Server on AWS using Terraform.

```
# Gather passwords and certificates from Vault.
$VAULT_TOOLS_DIR/login-to-vault.sh
check_rc $? "Unable to login to Vault."

# Obtain the certifcate from Vault.
$VAULT_TOOLS_DIR/get-vault-cert.sh
check_rc $? "Unable to obtain cetificate from Vault."

# Create separate certificate files (will be securely removed after importing into the 389DS keystore).
$VAULT_TOOLS_DIR/get-vault-cert.sh ca > $MY_TMPD/ca.pem
$VAULT_TOOLS_DIR/get-vault-cert.sh key > $MY_TMPD/key.pem
$VAULT_TOOLS_DIR/get-vault-cert.sh cert > $MY_TMPD/cert.pem

# Generate our passwords.
# The args are: hostname app_name key_name [force]
# `force` means the password will be recreated if already present.
DS_DIRMAN_PW=$(${VAULT_TOOLS_DIR}/get-vault-pass.sh $TERRA_HOSTNAME 389DS dirman force)
DS_REPMAN_PW=$(${VAULT_TOOLS_DIR}/get-vault-pass.sh $TERRA_HOSTNAME 389DS repman force)

# Now configure the server to use the cert and credentials...
```

# Example usage after setup.

```
ldapsearch -x -D 'cn=Directory Manager' -w "$(get-vault-pass.sh $HOSTNAME 389DS dirman)" -b "cn=config" '(objectClass=*)'
```
