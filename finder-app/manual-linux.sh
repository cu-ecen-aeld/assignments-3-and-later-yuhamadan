#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

# # Replace all references to “outdir” in the remainder of the assignment with the absolute path to this directory. 
OUTDIR=$(realpath ${OUTDIR})
# echo ${OUTDIR}

# # Create a directory outdir if it doesn’t exist.
mkdir -p ${OUTDIR}

if [ ! -d ${OUTDIR} ] ; then
    # # Fail if the directory could not be created. 
    echo "Could not create directory: ${OUTDIR} ...exiting!"
    exit 1
fi

## for fixing issues
# sudo apt install -y libssl-dev

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "TODO: Add your kernel build steps here"

    ## “deep clean” the kernel build tree - removing the .config file with any existing configurations
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
    
    ## Configure for our “virt” arm dev board we will simulate in QEMU
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig

    ## Build a kernel image for booting with QEMU
    make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all

    ## Build any kernel modules
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules

    ## Build the devicetree
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "TODO: Create necessary base directories"
ROOT_FS_DIR=${OUTDIR}/rootfs
mkdir -p $ROOT_FS_DIR
cd "$ROOT_FS_DIR"
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "TODO:  Configure busybox ??"
else
    cd busybox
fi


# TODO: Make and install busybox
echo "TODO: Make and install busybox"
make distclean
make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=$ROOT_FS_DIR ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"


cd "$ROOT_FS_DIR"

# TODO: Add library dependencies to rootfs
echo "TODO: Add library dependencies to rootfs"
cp /lib/ld-linux-aarch64.so.1 lib/
cp /lib64/libm.so.6 /lib64/libresolv.so.2 /lib64/libc.so.6 lib64/

# TODO: Make device nodes
echo "TODO: Make device nodes"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
echo "TODO: Clean and build the writer utility"
make clean
make CROSS_COMPILE=aarch64-none-linux-gnu-

# TODO: Copy the finder related scripts and executables to the /home directory
echo "TODO: Copy the finder related scripts and executables to the /home directory"
# on the target rootfs
cp -r ../finder-app/* ${ROOT_FS_DIR}/home/

# TODO: Chown the root directory
echo "TODO: Chown the root directory"
cd "$ROOT_FS_DIR"
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
echo "TODO: Create initramfs.cpio.gz"
cd "$ROOT_FS_DIR"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f initramfs.cpio