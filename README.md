# SCEPman Artifacts Repository

SCEPman is a cloud-based certification authority. It is installed within minutes and requires virtually no operations efforts.

It easily enables your Intune and JAMF managed clients for certificate based WiFi authentication based on the SCEP protocol, but it can also issue certificates for Domain Controllers or TLS Servers.

Please see https://docs.scepman.com/ for a full documentation.

## Purpose of this Repository

This repository serves the binary artifacts for SCEPman. Under this address, you previously also found Bicep code and ARM templates with which you could deploy SCEPman in your tenant. These files are now hosted at [https://github.com/scepman/deploy].

##  Changing History

This repository is regularly cleaned up and old versions are deleted from history. The retention period for Internal Channel, Beta Channel, and Production Channel are 30 days, 60 days, and 3 years minimum (usually longer). Changing the history can change commit hashes of unmodified commits, though, and therefore you must not pin your SCEPman version to a specific commit, even if it is within the retention period of your channel.