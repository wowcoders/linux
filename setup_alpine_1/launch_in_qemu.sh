sudo qemu-system-x86_64 -enable-kvm -m 1G -drive file='./boot,if=virtio,format=raw' -device virtio-net-pci,netdev=user0,mac=58:47:ca:78:36:2e -netdev bridge,id=user0,br=virbr0
