# small-sandbox
A basic, `unshare`-based linux sandbox. The script creates an isolated file system using most available namespaces, where the script executing user becomes root. The file system is created using default folders and basic config files, but for testing chosen files, the user can transfer those using the --file flag.

**TO-DO: add networking support**

## Dependencies
```
sudo apt install -y fuse3 fuse-overlayfs # for Debian-based
yum install -y fuse3 fuse-overlayfs # for Red Hat
```
## Usage
```
# all is to be run in project folder
chmod +x busybox
chmod +x script.sh init.sh
./script.sh -f | --files file1 file2 dir1 dir2 # it is prefferable to use absolute paths. these files and directories will be available in /home/tester in the new fs
```
