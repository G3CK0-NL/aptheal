# Introduction

Aptheal tries to heal your apt.

**WARNING**: This script is provided as-is, I am not responsible for any damage this script causes!


# What does it do?

* Kills hanging apt instances
* Removes remaining apt locks while apt is already terminated
* Fix packages
  * Broken during installation
  * Corrupted files managed by apt
  * Deleted files managed by apt
* Cleans up apt environment (removes unused stuff lying around)


# How does it work?

Deleting apt locks:
```
sudo rm -vf /var/lib/apt/lists/lock
sudo rm -vf /var/cache/apt/archives/lock
```

Fixing apt:
```
sudo apt-get clean
sudo apt-get install -y -f
sudo dpkg --configure -a
sudo apt-get update -y --fix-missing
```

Fixing any corrupted/deleted files managed by apt:
```
sudo apt-get install -f --reinstall $(sudo dpkg -S $(sudo debsums -c 2>&1 | cut -d' ' -f4) | cut -d':' -f1 | sort -u)
```

