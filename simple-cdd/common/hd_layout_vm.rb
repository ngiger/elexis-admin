Layout_HD_VM_Server=<<EOF
d-i partman-auto/expert_recipe string \
condpart :: \
512 512 512 ext3 \
$primary{ } $bootable{ } \
method{ format } format{ } \
label { boot } \
use_filesystem{ } filesystem{ ext2 } \
mountpoint{ /boot } \
. \
2048 10240 10240 ext3 \
method{ format } format{ } \
label { ROOT } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ / } \
. \
1024 10240 300% linux-swap \
method{ swap } format{ } \
. \
512 5120 5120 ext3 \
method{ format } format{ } \
label { home } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /home } \
. \
512 4096 10000000 ext3 \
method{ format } format{ } \
label {opt } \
use_filesystem{ } filesystem{ ext3 } \
mountpoint{ /opt } \
.
EOF
